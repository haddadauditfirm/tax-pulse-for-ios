import Foundation

enum PayrollEngine {
    static func monthlyBrackets() -> [TaxBracket] {
        [
            TaxBracket(minAmount: 0, maxAmount: 30_000_000, rate: 0.02),
            TaxBracket(minAmount: 30_000_000, maxAmount: 75_000_000, rate: 0.04),
            TaxBracket(minAmount: 75_000_000, maxAmount: 150_000_000, rate: 0.07),
            TaxBracket(minAmount: 150_000_000, maxAmount: 300_000_000, rate: 0.11),
            TaxBracket(minAmount: 300_000_000, maxAmount: 600_000_000, rate: 0.15),
            TaxBracket(minAmount: 600_000_000, maxAmount: 1_125_000_000, rate: 0.20),
            TaxBracket(minAmount: 1_125_000_000, maxAmount: .greatestFiniteMagnitude, rate: 0.25)
        ]
    }

    static func annualBrackets() -> [TaxBracket] {
        [
            TaxBracket(minAmount: 0, maxAmount: 360_000_000, rate: 0.02),
            TaxBracket(minAmount: 360_000_000, maxAmount: 900_000_000, rate: 0.04),
            TaxBracket(minAmount: 900_000_000, maxAmount: 1_800_000_000, rate: 0.07),
            TaxBracket(minAmount: 1_800_000_000, maxAmount: 3_600_000_000, rate: 0.11),
            TaxBracket(minAmount: 3_600_000_000, maxAmount: 7_200_000_000, rate: 0.15),
            TaxBracket(minAmount: 720_000_000, maxAmount: 13_500_000_000, rate: 0.20),
            TaxBracket(minAmount: 13_500_000_000, maxAmount: .greatestFiniteMagnitude, rate: 0.25)
        ]
    }

    static func calculate(
        gross: Double,
        maritalStatus: MaritalStatus,
        childrenCount: Int,
        month: Int,
        nssfRegistered: Bool,
        useFamilyRebates: Bool,
        period: SalaryPeriod,
        lawConfig: LawConfig = LawConfig(),
        sicknessCeilingOverride: Double? = nil,
        familyCeilingOverride: Double? = nil
    ) -> PayrollItem {
        let isAnnual = period == .annual
        let grossSalary = gross
        let sicknessCeiling = sicknessCeilingOverride ?? ((month <= 7 ? lawConfig.nssfSicknessCeilingJanJul : lawConfig.nssfSicknessCeilingAugDec) * (isAnnual ? 12.0 : 1.0))
        let sicknessBase = nssfRegistered ? min(grossSalary, sicknessCeiling) : 0
        let sicknessEmployee = nssfRegistered ? sicknessBase * lawConfig.nssfSicknessRateEmployee : 0
        let sicknessEmployer = nssfRegistered ? sicknessBase * lawConfig.nssfSicknessRateEmployer : 0

        let familyCeiling = familyCeilingOverride ?? ((month <= 6 ? lawConfig.nssfFamilyCeilingJanJul : lawConfig.nssfFamilyCeilingAugDec) * (isAnnual ? 12.0 : 1.0))
        let familyBase = nssfRegistered ? min(grossSalary, familyCeiling) : 0
        let familyEmployer = nssfRegistered ? familyBase * lawConfig.nssfFamilyRateEmployer : 0

        let endServiceBase = nssfRegistered ? grossSalary : 0
        let endServiceEmployer = nssfRegistered ? endServiceBase * lawConfig.nssfEndServiceRateEmployer : 0

        let totalNssfEmployee = sicknessEmployee
        let totalNssfEmployer = sicknessEmployer + familyEmployer + endServiceEmployer

        var wifeBenefit = 0.0
        var childBenefit = 0.0
        if nssfRegistered {
            if maritalStatus == .spouseDependent {
                wifeBenefit = (month <= 6 ? lawConfig.wifeBenefitJanJun : lawConfig.wifeBenefitJulDec) * (isAnnual ? 12.0 : 1.0)
            }
            childBenefit = (month <= 6 ? lawConfig.childBenefitJanJun : lawConfig.childBenefitJulDec) * Double(min(childrenCount, 5)) * (isAnnual ? 12.0 : 1.0)
        }
        let familyBenefits = wifeBenefit + childBenefit

        var rebates = 0.0
        if useFamilyRebates {
            rebates = isAnnual ? lawConfig.rebateSelfAnnual : lawConfig.rebateSelfMonthly
            if maritalStatus == .spouseDependent {
                rebates += isAnnual ? lawConfig.rebateWifeAnnual : lawConfig.rebateWifeMonthly
            }
            let childUnit = isAnnual ? lawConfig.rebateChildAnnual : lawConfig.rebateChildMonthly
            let childFactor = maritalStatus == .spouseWorks ? 0.5 : 1.0
            rebates += childUnit * childFactor * Double(min(childrenCount, 5))
        }

        let taxableSalary = max(0, grossSalary - rebates)
        let taxAmount = roundUpTo10k(calculateProgressiveTax(taxableSalary, brackets: isAnnual ? annualBrackets() : monthlyBrackets()))
        let netSalary = grossSalary - taxAmount - totalNssfEmployee + familyBenefits
        let totalEmployerCost = grossSalary + totalNssfEmployer - familyBenefits
        let minimumWage = (month <= 7 ? lawConfig.minimumWageJanJul : lawConfig.minimumWageAugDec) * (isAnnual ? 12.0 : 1.0)

        return PayrollItem(
            basicSalary: grossSalary,
            grossSalary: grossSalary,
            sicknessMaternityBase: sicknessBase,
            sicknessMaternityEmployee: sicknessEmployee,
            sicknessMaternityEmployer: sicknessEmployer,
            familyAllowanceBase: familyBase,
            familyAllowanceEmployer: familyEmployer,
            endOfServiceBase: endServiceBase,
            endOfServiceEmployer: endServiceEmployer,
            totalNssfEmployee: totalNssfEmployee,
            totalNssfEmployer: totalNssfEmployer,
            wifeBenefitAmount: wifeBenefit,
            childBenefitAmount: childBenefit,
            totalFamilyBenefitsAmount: familyBenefits,
            familyRebatesAmount: rebates,
            taxableSalary: taxableSalary,
            taxAmount: taxAmount,
            netSalary: netSalary,
            totalEmployerCost: totalEmployerCost,
            hasMinimumWageWarning: grossSalary < minimumWage
        )
    }

    private static func calculateProgressiveTax(_ taxableSalary: Double, brackets: [TaxBracket]) -> Double {
        guard taxableSalary > 0 else { return 0 }
        var tax = 0.0
        var remaining = taxableSalary

        for bracket in brackets where taxableSalary > bracket.minAmount {
            let segmentSize = bracket.maxAmount - bracket.minAmount
            let charged = min(remaining, segmentSize)
            tax += charged * bracket.rate
            remaining -= charged
            if remaining <= 0 { break }
        }

        return tax
    }

    private static func roundUpTo10k(_ value: Double) -> Double {
        ceil(value.rounded() / 10_000.0) * 10_000.0
    }
}
