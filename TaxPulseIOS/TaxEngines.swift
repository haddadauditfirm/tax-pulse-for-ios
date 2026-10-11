import Foundation

struct PropertyTaxBracket {
    let lower: Decimal
    let upper: Decimal?
    let percent: Int
}

struct PropertyTaxAllocation {
    let bracket: PropertyTaxBracket
    let income: Decimal
    let tax: Decimal
}

struct PropertyTaxResult {
    let year: Int
    let revenue: Decimal
    let deduction: Decimal
    let taxableRevenue: Decimal
    let allocations: [PropertyTaxAllocation]
    let totalTax: Decimal
}

/// Supplied Tax on Properties 2024.pdf, used for 2025/2026 by user instruction.
/// Annual LBP, one property, manually entered deduction applied once.
/// Decimal arithmetic preserves the same exact amounts as Android BigDecimal.
enum PropertyTaxEngine {
    static let supportedYears = [2025, 2026]
    static let standardExchangeRate: Decimal = 89_500
    private static let maximumAmount = Decimal(string: "999999999999999999")!
    private static let maximumRate = Decimal(string: "9999999999.9999")!
    private static let pdfBrackets = [
        PropertyTaxBracket(lower: 0, upper: 1_200_000_000, percent: 4),
        PropertyTaxBracket(lower: 1_200_000_000, upper: 2_400_000_000, percent: 6),
        PropertyTaxBracket(lower: 2_400_000_000, upper: 3_600_000_000, percent: 8),
        PropertyTaxBracket(lower: 3_600_000_000, upper: 6_000_000_000, percent: 11),
        PropertyTaxBracket(lower: 6_000_000_000, upper: nil, percent: 14)
    ]
    private static let schedules = [2025: pdfBrackets, 2026: pdfBrackets]

    static func normalizeInput(_ raw: String) -> String {
        var value = ""
        for scalar in raw.unicodeScalars {
            switch scalar.value {
            case 0x30...0x39: value.unicodeScalars.append(scalar)
            case 0x660...0x669: value += String(scalar.value - 0x660)
            case 0x6F0...0x6F9: value += String(scalar.value - 0x6F0)
            case 0x2C, 0x66C: value += ","
            case 0x66B: value += "."
            default:
                if !CharacterSet.whitespacesAndNewlines.contains(scalar) {
                    value.unicodeScalars.append(scalar)
                }
            }
        }
        guard value.contains(",") else { return value }
        let parts = value.split(separator: ".", omittingEmptySubsequences: false)
        guard parts.count <= 2 else { return value }
        let groups = parts[0].split(separator: ",", omittingEmptySubsequences: false)
        let validGrouping = (1...3).contains(groups[0].count) && groups[0].utf8.allSatisfy { (48...57).contains($0) }
            && groups.dropFirst().allSatisfy { $0.count == 3 && $0.utf8.allSatisfy { (48...57).contains($0) } }
        // A decimal comma or malformed grouping must never turn into a larger amount.
        return validGrouping ? groups.joined() + (parts.count == 2 ? "." + String(parts[1]) : "") : value
    }

    static func parseAmount(_ raw: String, blankAsZero: Bool = false) -> Decimal? {
        let normalized = normalizeInput(raw)
        if normalized.isEmpty { return blankAsZero && raw.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Decimal.zero : nil }
        guard normalized.count <= 18, normalized.utf8.allSatisfy({ (48...57).contains($0) }) else { return nil }
        return Decimal(string: normalized, locale: Locale(identifier: "en_US_POSIX"))
    }

    static func parseUsdAmount(_ raw: String, blankAsZero: Bool = false) -> Decimal? {
        guard let value = parseDecimal(raw, blankAsZero: blankAsZero, integerDigits: 18, fractionDigits: 2), value <= maximumAmount else { return nil }
        return value
    }

    static func parseExchangeRate(_ raw: String) -> Decimal? {
        guard let value = parseDecimal(raw, integerDigits: 10, fractionDigits: 4), value > 0 else { return nil }
        return value
    }

    private static func parseDecimal(_ raw: String, blankAsZero: Bool = false, integerDigits: Int, fractionDigits: Int) -> Decimal? {
        let normalized = normalizeInput(raw)
        if normalized.isEmpty { return blankAsZero && raw.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Decimal.zero : nil }
        let pattern = "^[0-9]{1,\(integerDigits)}(\\.[0-9]{1,\(fractionDigits)})?$"
        guard normalized.range(of: pattern, options: .regularExpression) != nil else { return nil }
        return Decimal(string: normalized, locale: Locale(identifier: "en_US_POSIX"))
    }

    static func convertToLbp(_ amount: Decimal, exchangeRate: Decimal) -> Decimal? {
        guard !amount.isNaN, amount >= 0, validDecimal(exchangeRate, maximum: maximumRate, fractionDigits: 4), exchangeRate > 0 else { return nil }
        let converted = amount * exchangeRate
        guard !converted.isNaN, converted <= maximumAmount else { return nil }
        return converted
    }

    static func calculateUsd(year: Int, revenue: Decimal, deduction: Decimal, exchangeRate: Decimal) -> PropertyTaxResult? {
        guard validDecimal(revenue, maximum: maximumAmount, fractionDigits: 2), validDecimal(deduction, maximum: maximumAmount, fractionDigits: 2),
              let revenueLbp = convertToLbp(revenue, exchangeRate: exchangeRate),
              let deductionLbp = convertToLbp(deduction, exchangeRate: exchangeRate) else { return nil }
        return assess(year: year, revenue: revenueLbp, deduction: deductionLbp)
    }

    static func calculate(year: Int, revenue: Decimal, deduction: Decimal) -> PropertyTaxResult? {
        guard validWholeAmount(revenue), validWholeAmount(deduction) else { return nil }
        return assess(year: year, revenue: revenue, deduction: deduction)
    }

    private static func assess(year: Int, revenue: Decimal, deduction: Decimal) -> PropertyTaxResult? {
        guard let brackets = schedules[year] else { return nil }
        let taxable = max(Decimal.zero, revenue - deduction)
        let allocations = brackets.map { bracket in
            let income = max(Decimal.zero, min(taxable, bracket.upper ?? taxable) - bracket.lower)
            return PropertyTaxAllocation(bracket: bracket, income: income, tax: income * Decimal(bracket.percent) / 100)
        }
        return PropertyTaxResult(year: year, revenue: revenue, deduction: deduction,
            taxableRevenue: taxable, allocations: allocations, totalTax: allocations.reduce(Decimal.zero) { $0 + $1.tax })
    }

    private static func validWholeAmount(_ value: Decimal) -> Bool {
        validDecimal(value, maximum: maximumAmount, fractionDigits: 0)
    }

    private static func validDecimal(_ value: Decimal, maximum: Decimal, fractionDigits: Int) -> Bool {
        guard !value.isNaN, value >= 0, value <= maximum else { return false }
        var source = value
        var rounded = Decimal.zero
        NSDecimalRound(&rounded, &source, fractionDigits, .plain)
        return rounded == value
    }
}

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
