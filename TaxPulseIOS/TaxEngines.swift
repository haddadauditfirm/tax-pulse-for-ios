import Foundation

enum TaxEngines {
    static func calculateProfitTax(
        rawProfitInput: String,
        currency: CurrencyMode,
        maritalStatus: MaritalStatus,
        childrenCount: Int,
        exchangeRate: Double
    ) -> ProfitTaxResult {
        let parsedProfit = Double(rawProfitInput.replacingOccurrences(of: ",", with: "")) ?? 0
        let netTaxableProfit = currency == .usd ? parsedProfit * exchangeRate : parsedProfit
        let himselfRebate = 450_000_000.0
        let spouseRebate = maritalStatus == .spouseDependent ? 225_000_000.0 : 0
        let childRateUsed = maritalStatus == .spouseWorks ? 22_500_000.0 : 45_000_000.0
        let childrenRebate = childRateUsed * Double(childrenCount)
        let totalRebates = himselfRebate + spouseRebate + childrenRebate
        let profitAfterRebates = max(0, netTaxableProfit - totalRebates)

        let brackets: [(Double, Double, Double)] = [
            (0.04, 0, 540_000_000),
            (0.07, 540_000_000, 1_440_000_000),
            (0.12, 1_440_000_000, 3_240_000_000),
            (0.16, 3_240_000_000, 6_240_000_000),
            (0.21, 6_240_000_000, 13_500_000_000),
            (0.25, 13_500_000_000, .greatestFiniteMagnitude)
        ]

        var remaining = profitAfterRebates
        var totalTaxDue = 0.0
        var allocations: [BracketAllocation] = []

        for (rate, from, to) in brackets {
            if remaining > 0 {
                let amount = min(remaining, to - from)
                let tax = amount * rate
                totalTaxDue += tax
                allocations.append(BracketAllocation(rate: rate, from: from, to: to, amountInBracket: amount, taxInBracket: tax))
                remaining -= amount
            } else {
                allocations.append(BracketAllocation(rate: rate, from: from, to: to, amountInBracket: 0, taxInBracket: 0))
            }
        }

        return ProfitTaxResult(
            netTaxableProfit: netTaxableProfit,
            himselfRebate: himselfRebate,
            spouseRebate: spouseRebate,
            childrenRebate: childrenRebate,
            childRateUsed: childRateUsed,
            totalRebates: totalRebates,
            profitAfterRebates: profitAfterRebates,
            totalTaxDue: totalTaxDue,
            netNetProfit: max(0, netTaxableProfit - totalTaxDue),
            bracketAllocations: allocations
        )
    }

    static func calculatePenalties(
        companyType: String,
        taxType: String,
        taxAmount: Double,
        payrollYear: Int,
        quarter: String,
        profitDueYear: Int,
        payDay: Int,
        payMonth: Int,
        payYear: Int,
        dueDayOverride: Int?,
        dueMonthOverride: Int?,
        dueYearOverride: Int?,
        r5PrincipalTaxPaid: Bool = false
    ) -> PenaltyResult {
        let autoDue = statutoryDueDate(taxType: taxType, payrollYear: payrollYear, quarter: quarter, profitDueYear: profitDueYear, companyType: companyType)
        let dueDay = dueDayOverride ?? autoDue.day
        let dueMonth = dueMonthOverride ?? autoDue.month
        let dueYear = dueYearOverride ?? autoDue.year
        let selectedYear = (taxType == "PAYROLL" || taxType == "VAT") ? payrollYear : profitDueYear
        let minimumThreshold: Double

        if selectedYear == 2024 || selectedYear == 2025 {
            switch companyType {
            case "SAL": minimumThreshold = 6_750_000
            case "SARL", "PARTNERSHIP", "EXEMPT": minimumThreshold = 4_500_000
            default: minimumThreshold = 750_000
            }
        } else {
            switch companyType {
            case "SAL": minimumThreshold = 18_750_000
            case "SARL", "PARTNERSHIP", "EXEMPT": minimumThreshold = 12_500_000
            default: minimumThreshold = 2_500_000
            }
        }

        let dateAfterPayment: Bool
        let lateMonths: Int
        if payYear < dueYear || (payYear == dueYear && payMonth < dueMonth) || (payYear == dueYear && payMonth == dueMonth && payDay <= dueDay) {
            dateAfterPayment = true
            lateMonths = 0
        } else {
            dateAfterPayment = false
            let base = (payYear - dueYear) * 12 + (payMonth - dueMonth)
            lateMonths = payDay > dueDay ? base + 1 : base
        }

        let p1Rate = taxType == "PAYROLL" && quarter != "R5" ? 0.05 : 0.10
        let p2Rate = (taxType == "PAYROLL" || taxType == "VAT") ? 0.03 : 0.02
        let rawPenalty1 = lateMonths > 0 ? taxAmount * p1Rate * Double(lateMonths) : 0
        let cappedPenalty1 = taxAmount > 0 && lateMonths > 0 ? min(rawPenalty1, taxAmount) : 0
        let finalPenalty1Raw = lateMonths > 0 ? max(cappedPenalty1, minimumThreshold) : 0
        let verificationFine = finalPenalty1Raw > 0 ? ceil(finalPenalty1Raw / 10_000.0) * 10_000.0 : 0
        let usesPaidR5Rules = taxType == "PAYROLL" && quarter == "R5" && r5PrincipalTaxPaid
        let collectionPenaltyBase = usesPaidR5Rules ? verificationFine : taxAmount + verificationFine
        let collectionFineRaw = lateMonths > 0 ? collectionPenaltyBase * p2Rate * Double(lateMonths) : 0
        let collectionFine = collectionFineRaw > 0 ? ceil(collectionFineRaw / 10_000.0) * 10_000.0 : 0
        let principalTaxDue = usesPaidR5Rules ? 0 : taxAmount

        return PenaltyResult(
            statutoryDate: DateComponents(year: dueYear, month: dueMonth, day: dueDay),
            payDate: DateComponents(year: payYear, month: payMonth, day: payDay),
            lateMonths: lateMonths,
            minimumThreshold: minimumThreshold,
            verificationFine: verificationFine,
            collectionFine: collectionFine,
            totalAmount: principalTaxDue + verificationFine + collectionFine,
            isDueDateAfterPayment: dateAfterPayment,
            isUnderMinimum: lateMonths > 0 && finalPenalty1Raw == minimumThreshold,
            isCapped: lateMonths > 0 && finalPenalty1Raw != minimumThreshold && rawPenalty1 > taxAmount
        )
    }

    static func statutoryDueDate(taxType: String, payrollYear: Int, quarter: String, profitDueYear: Int, companyType: String) -> ExtensionDateParts {
        if taxType == "PAYROLL" || taxType == "VAT" {
            if taxType == "VAT" {
                if payrollYear == 2024 || payrollYear == 2025 {
                    switch quarter {
                    case "Q2": return ExtensionDateParts(day: 20, month: 7, year: payrollYear)
                    case "Q3": return ExtensionDateParts(day: 20, month: 10, year: payrollYear)
                    case "Q4": return ExtensionDateParts(day: 20, month: 1, year: payrollYear + 1)
                    default: return ExtensionDateParts(day: 20, month: 4, year: payrollYear)
                    }
                }
                switch quarter {
                case "Q2": return ExtensionDateParts(day: 31, month: 7, year: payrollYear)
                case "Q3": return ExtensionDateParts(day: 31, month: 10, year: payrollYear)
                case "Q4": return ExtensionDateParts(day: 31, month: 1, year: payrollYear + 1)
                default: return ExtensionDateParts(day: 30, month: 4, year: payrollYear)
                }
            }
            switch quarter {
            case "Q2": return ExtensionDateParts(day: 15, month: 7, year: payrollYear)
            case "Q3": return ExtensionDateParts(day: 15, month: 10, year: payrollYear)
            case "Q4": return ExtensionDateParts(day: 15, month: 1, year: payrollYear + 1)
            case "R5":
                let nextYear = payrollYear + 1
                return ExtensionDateParts(day: isLeapYear(nextYear) ? 29 : 28, month: 2, year: nextYear)
            default: return ExtensionDateParts(day: 15, month: 4, year: payrollYear)
            }
        }

        if taxType == "AUDIT" {
            return companyType == "PARTNERSHIP"
                ? ExtensionDateParts(day: 30, month: 6, year: profitDueYear + 1)
                : ExtensionDateParts(day: 31, month: 8, year: profitDueYear + 1)
        }

        switch companyType {
        case "CAPITAL", "SAL", "SARL": return ExtensionDateParts(day: 31, month: 5, year: profitDueYear + 1)
        case "PARTNERSHIP", "SOLE_REAL", "INDIVIDUAL", "EXEMPT_REAL": return ExtensionDateParts(day: 31, month: 3, year: profitDueYear + 1)
        default: return ExtensionDateParts(day: 31, month: 1, year: profitDueYear + 1)
        }
    }

    private static func isLeapYear(_ year: Int) -> Bool {
        (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0)
    }
}
