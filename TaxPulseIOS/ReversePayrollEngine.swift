import Foundation

struct ReversePayrollResult {
    let targetLbp: Double
    let transportLbp: Double
    let includesFamilyBenefits: Bool
    let payroll: PayrollItem
    /// Salary and exempt transportation, before employee deductions.
    var amountBeforeDeductionsLbp: Double { payroll.basicSalary + transportLbp }
    var matchedNetLbp: Double {
        payroll.netSalary + transportLbp - (includesFamilyBenefits ? 0 : payroll.totalFamilyBenefitsAmount)
    }
    var roundingDifferenceLbp: Double { max(0, matchedNetLbp - targetLbp) }
}

enum ReversePayrollEngine {
    static let dailyTransportLbp = 450_000.0
    static let exchangeRate = 89_500.0
    static let maximumLbp = 1_000_000_000_000.0
    static let maximumWorkingDays = 30

    static func target(_ raw: String, usd: Bool) -> Double? {
        guard let amount = usd ? PropertyTaxEngine.parseUsdAmount(raw) : PropertyTaxEngine.parseAmount(raw) else { return nil }
        let result = NSDecimalNumber(decimal: amount).doubleValue * (usd ? exchangeRate : 1)
        return result.isFinite && result > 0 && result <= maximumLbp ? result : nil
    }

    static func workingDays(_ raw: String) -> Int? {
        let normalized = PropertyTaxEngine.normalizeInput(raw)
        guard !normalized.isEmpty, normalized.allSatisfy({ $0 >= "0" && $0 <= "9" }),
              let days = Int(normalized), (0...maximumWorkingDays).contains(days) else { return nil }
        return days
    }

    /// Use forward deductions, not binary search: rounded tax makes net pay discontinuous.
    static func calculate(targetLbp: Double, workingDays: Int, usd: Bool,
                          includeFamilyBenefits: Bool = true,
                          forward: (Double) -> PayrollItem) -> ReversePayrollResult? {
        guard targetLbp.isFinite, targetLbp > 0, targetLbp <= maximumLbp,
              (0...maximumWorkingDays).contains(workingDays) else { return nil }
        let transport = Double(workingDays) * dailyTransportLbp
        let benefits = includeFamilyBenefits ? forward(0).totalFamilyBenefitsAmount : 0
        let base = targetLbp - transport - benefits
        guard base.isFinite, base > 0 else { return nil }
        let step = usd ? exchangeRate / 100 : 1
        var units = ceil(base / step)
        for _ in 0..<256 {
            let gross = units * step
            guard gross <= maximumLbp else { return nil }
            let payroll = forward(gross)
            let deductions = payroll.taxAmount + payroll.totalNssfEmployee
            guard deductions.isFinite, deductions >= 0 else { return nil }
            let next = ceil((base + deductions) / step)
            if next <= units {
                let result = ReversePayrollResult(targetLbp: targetLbp, transportLbp: transport,
                    includesFamilyBenefits: includeFamilyBenefits, payroll: payroll)
                return result.matchedNetLbp.isFinite && result.matchedNetLbp >= targetLbp - 0.0001 ? result : nil
            }
            units = next
        }
        return nil
    }
}
