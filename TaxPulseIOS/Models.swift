import Foundation

enum AppLanguage: String, CaseIterable, Identifiable {
    case english = "EN"
    case arabic = "AR"
    var id: String { rawValue }
}

enum ServiceTab: Int, CaseIterable, Identifiable {
    case payroll
    case profit
    case penalties
    case extensions

    var id: Int { rawValue }
}

enum CurrencyMode: String, CaseIterable, Identifiable {
    case lbp = "LBP"
    case usd = "USD"
    var id: String { rawValue }
}

enum SalaryPeriod: String, CaseIterable, Identifiable {
    case monthly = "MONTHLY"
    case annual = "ANNUAL"
    var id: String { rawValue }
}

enum EmploymentType: String, CaseIterable, Identifiable, Codable {
    case monthly = "MONTHLY"
    case daily = "DAILY"
    case hourly = "HOURLY"
    case lumpSumWages = "LUMP_SUM_WAGES"

    var id: String { rawValue }
}

enum MaritalStatus: String, CaseIterable, Identifiable, Codable {
    case single = "SINGLE"
    case spouseWorks = "SPOUSE_WORKS"
    case spouseDependent = "SPOUSE_DEPENDENT"
    case divorced = "DIVORCED"
    case widowed = "WIDOWED"

    var id: String { rawValue }

    var payrollKey: String {
        switch self {
        case .single: "SINGLE"
        case .spouseWorks: "MARRIED_WIFE_WORKING"
        case .spouseDependent: "MARRIED_WIFE_NOT_WORKING"
        case .divorced: "DIVORCED"
        case .widowed: "WIDOWED"
        }
    }
}

struct LawConfig: Codable {
    var version = 2025
    var minimumWageJanJul = 18_000_000.0
    var minimumWageAugDec = 28_000_000.0
    var nssfSicknessRateEmployee = 0.03
    var nssfSicknessRateEmployer = 0.08
    var nssfSicknessCeilingJanJul = 90_000_000.0
    var nssfSicknessCeilingAugDec = 120_000_000.0
    var nssfFamilyRateEmployer = 0.06
    var nssfFamilyCeilingJanJul = 12_000_000.0
    var nssfFamilyCeilingAugDec = 28_000_000.0
    var nssfEndServiceRateEmployer = 0.085
    var wifeBenefitJanJun = 2_100_000.0
    var wifeBenefitJulDec = 2_100_000.0
    var childBenefitJanJun = 1_155_000.0
    var childBenefitJulDec = 1_155_000.0
    var rebateSelfMonthly = 37_500_000.0
    var rebateWifeMonthly = 18_750_000.0
    var rebateChildMonthly = 3_750_000.0
    var rebateDailyEmployeeFixed = 1_500_000.0
    var rebateSelfAnnual = 450_000_000.0
    var rebateWifeAnnual = 225_000_000.0
    var rebateChildAnnual = 45_000_000.0
    var lumpSumFlatTaxRate = 0.03
}

struct TaxBracket: Identifiable, Codable {
    let id = UUID()
    var minAmount: Double
    var maxAmount: Double
    var rate: Double

    enum CodingKeys: String, CodingKey {
        case minAmount, maxAmount, rate
    }
}

struct PayrollItem: Codable {
    var employmentType: EmploymentType
    var basicSalary: Double
    var allowances: Double
    var bonuses: Double
    var overtime: Double
    var grossSalary: Double
    var sicknessMaternityBase: Double
    var sicknessMaternityEmployee: Double
    var sicknessMaternityEmployer: Double
    var familyAllowanceBase: Double
    var familyAllowanceEmployer: Double
    var endOfServiceBase: Double
    var endOfServiceEmployer: Double
    var totalNssfEmployee: Double
    var totalNssfEmployer: Double
    var wifeBenefitAmount: Double
    var childBenefitAmount: Double
    var totalFamilyBenefitsAmount: Double
    var familyRebatesAmount: Double
    var taxableSalary: Double
    var taxAmount: Double
    var netSalary: Double
    var totalEmployerCost: Double
    var hasMinimumWageWarning: Bool
    var isDailyTaxApplied: Bool
    var isLumpSumApplied: Bool
}

struct UserRecord: Identifiable, Codable {
    var id: String
    var fullName: String
    var passwordHash: String
    var role: String
    var companyId: Int?
    var is2FAEnabled: Bool
    var status: String
}

struct CompanyRecord: Identifiable, Codable {
    var id: Int
    var name: String
    var arabicName: String
    var registrationNumber: String
    var nssfNumber: String
    var address: String
    var phone: String
    var isBlocked: Bool
}

struct EmployeeRecord: Identifiable, Codable {
    var id: Int
    var companyId: Int
    var employeeNumber: String
    var fullName: String
    var arabicName: String
    var email: String
    var jobTitle: String
    var department: String
    var startDate: String
    var employmentType: EmploymentType
    var basicSalary: Double
    var allowances: Double
    var isNssfRegistered: Bool
    var isTaxable: Bool
    var maritalStatus: MaritalStatus
    var childrenCount: Int
    var bankName: String
    var bankIban: String
    var status: String
}

struct PayrollRunRecord: Identifiable, Codable {
    var id: Int
    var companyId: Int
    var title: String
    var month: Int
    var year: Int
    var status: String
    var totalGross: Double
    var totalNet: Double
    var totalTax: Double
    var totalNssfEmployee: Double
    var totalNssfEmployer: Double
    var totalEmployerCost: Double
}

struct AuditLogRecord: Identifiable, Codable {
    var id: Int
    var userId: String
    var userName: String
    var userRole: String
    var companyId: Int?
    var action: String
    var oldValue: String
    var newValue: String
    var reason: String
    var timestamp: Date
    var ipAddress: String
}

struct ProfitTaxResult: Codable {
    var netTaxableProfit: Double
    var himselfRebate: Double
    var spouseRebate: Double
    var childrenRebate: Double
    var childRateUsed: Double
    var totalRebates: Double
    var profitAfterRebates: Double
    var totalTaxDue: Double
    var netNetProfit: Double
    var bracketAllocations: [BracketAllocation]
}

struct BracketAllocation: Identifiable, Codable {
    let id = UUID()
    var rate: Double
    var from: Double
    var to: Double
    var amountInBracket: Double
    var taxInBracket: Double

    enum CodingKeys: String, CodingKey {
        case rate, from, to, amountInBracket, taxInBracket
    }
}

struct PenaltyResult {
    var statutoryDate: DateComponents
    var payDate: DateComponents
    var lateMonths: Int
    var minimumThreshold: Double
    var verificationFine: Double
    var collectionFine: Double
    var totalAmount: Double
    var isDueDateAfterPayment: Bool
    var isUnderMinimum: Bool
    var isCapped: Bool
}

struct ExtensionDateParts {
    var day: Int
    var month: Int
    var year: Int
}

func sanitizedDigits(_ value: String) -> String {
    String(value.filter(\.isNumber))
}

func sanitizedDecimal(_ value: String) -> String {
    var hasDot = false
    var result = ""
    for char in value {
        if char.isNumber {
            result.append(char)
        } else if char == "." && !hasDot {
            result.append(char)
            hasDot = true
        }
    }
    return result
}

func lbp(_ amount: Double) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    formatter.maximumFractionDigits = 0
    formatter.locale = Locale(identifier: "en_US")
    return "\(formatter.string(from: NSNumber(value: amount.rounded())) ?? "0") LBP"
}

func usd(_ amount: Double) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    formatter.minimumFractionDigits = 2
    formatter.maximumFractionDigits = 2
    formatter.locale = Locale(identifier: "en_US")
    return "$\(formatter.string(from: NSNumber(value: amount)) ?? "0.00")"
}
