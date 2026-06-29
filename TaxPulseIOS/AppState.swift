import Foundation

final class AppState: ObservableObject {
    @Published var onboardingStep = 1
    @Published var selectedTab: ServiceTab = .payroll
    @Published var language: AppLanguage = .english

    @Published var employeeName = ""
    @Published var salaryPeriod: SalaryPeriod = .monthly
    @Published var payrollCurrency: CurrencyMode = .lbp
    @Published var payrollGrossLbp = ""
    @Published var payrollGrossUsd = ""
    @Published var payrollExchangeRate = ""
    @Published var payrollMarital: MaritalStatus = .single
    @Published var payrollChildren = 0
    @Published var payrollMonth = 10
    @Published var isNssfRegistered = true
    @Published var useFamilyRebates = true
    @Published var sicknessCeilingOverride = ""
    @Published var familyCeilingOverride = ""

    @Published var profitCurrency: CurrencyMode = .lbp
    @Published var profitGrossLbp = ""
    @Published var profitGrossUsd = ""
    @Published var profitExchangeRate = ""
    @Published var profitMarital: MaritalStatus = .single
    @Published var profitChildren = 0
    @Published var profitOwnerName = ""

    @Published var penaltyCompanyType = "SAL"
    @Published var penaltyTaxType = "PAYROLL"
    @Published var penaltyAmount = ""
    @Published var penaltyPayrollYear = "2026"
    @Published var penaltyQuarter = "Q1"
    @Published var penaltyProfitYear = "2026"
    @Published var penaltyPayDay = "\(Calendar.current.component(.day, from: Date()))"
    @Published var penaltyPayMonth = "\(Calendar.current.component(.month, from: Date()))"
    @Published var penaltyPayYear = "\(Calendar.current.component(.year, from: Date()))"
    @Published var penaltyDueDay = "15"
    @Published var penaltyDueMonth = "4"
    @Published var penaltyDueYear = "2026"

    @Published var extensionTaxType = "PAYROLL"
    @Published var extensionYear = "2026"
    @Published var extensionQuarter = "Q1"
    @Published var extensionCompanyType = "CAPITAL"
    @Published var extensionDay = "15"
    @Published var extensionMonth = "4"
    @Published var extensionYearValue = "2026"
    @Published var extensionMessage: String?

    private let defaults = UserDefaults.standard

    var payrollGrossLbpValue: Double {
        if payrollCurrency == .usd {
            let amount = Double(payrollGrossUsd) ?? 0
            let rate = Double(payrollExchangeRate) ?? 89_500
            return amount * rate
        }
        return Double(payrollGrossLbp) ?? 0
    }

    var payrollResult: PayrollItem {
        PayrollEngine.calculate(
            gross: payrollGrossLbpValue,
            maritalStatus: payrollMarital,
            childrenCount: payrollMarital == .single ? 0 : payrollChildren,
            month: payrollMonth,
            nssfRegistered: isNssfRegistered,
            useFamilyRebates: useFamilyRebates,
            period: salaryPeriod,
            sicknessCeilingOverride: salaryPeriod == .annual ? Double(sicknessCeilingOverride) : nil,
            familyCeilingOverride: salaryPeriod == .annual ? Double(familyCeilingOverride) : nil
        )
    }

    var profitResult: ProfitTaxResult {
        TaxEngines.calculateProfitTax(
            rawProfitInput: profitCurrency == .lbp ? profitGrossLbp : profitGrossUsd,
            currency: profitCurrency,
            maritalStatus: profitMarital,
            childrenCount: profitMarital == .single ? 0 : profitChildren,
            exchangeRate: Double(profitExchangeRate) ?? 89_500
        )
    }

    var penaltyResult: PenaltyResult {
        TaxEngines.calculatePenalties(
            companyType: penaltyCompanyType,
            taxType: penaltyTaxType,
            taxAmount: Double(penaltyAmount) ?? 0,
            payrollYear: Int(penaltyPayrollYear) ?? 2026,
            quarter: penaltyQuarter,
            profitDueYear: Int(penaltyProfitYear) ?? 2026,
            payDay: Int(penaltyPayDay) ?? 1,
            payMonth: Int(penaltyPayMonth) ?? 1,
            payYear: Int(penaltyPayYear) ?? 2026,
            dueDayOverride: Int(penaltyDueDay),
            dueMonthOverride: Int(penaltyDueMonth),
            dueYearOverride: Int(penaltyDueYear)
        )
    }

    var extensionAutoDate: ExtensionDateParts {
        TaxEngines.statutoryDueDate(
            taxType: extensionTaxType,
            payrollYear: Int(extensionYear) ?? 2026,
            quarter: extensionQuarter,
            profitDueYear: Int(extensionYear) ?? 2026,
            companyType: extensionCompanyType
        )
    }

    func chooseService(_ tab: ServiceTab) {
        selectedTab = tab
        onboardingStep = 4
    }

    func resetPayroll() {
        employeeName = ""
        salaryPeriod = .monthly
        payrollCurrency = .lbp
        payrollGrossLbp = ""
        payrollGrossUsd = ""
        payrollExchangeRate = ""
        payrollMarital = .single
        payrollChildren = 0
        payrollMonth = 10
        isNssfRegistered = true
        useFamilyRebates = true
        sicknessCeilingOverride = ""
        familyCeilingOverride = ""
    }

    func syncPenaltyDueDate() {
        let auto = TaxEngines.statutoryDueDate(
            taxType: penaltyTaxType,
            payrollYear: Int(penaltyPayrollYear) ?? 2026,
            quarter: penaltyQuarter,
            profitDueYear: Int(penaltyProfitYear) ?? 2026,
            companyType: penaltyCompanyType
        )
        penaltyDueDay = "\(auto.day)"
        penaltyDueMonth = "\(auto.month)"
        penaltyDueYear = "\(auto.year)"
    }

    func syncExtensionDate() {
        let auto = extensionAutoDate
        extensionDay = "\(auto.day)"
        extensionMonth = "\(auto.month)"
        extensionYearValue = "\(auto.year)"
    }

    func saveExtension() {
        let key = extensionKey
        let value = "\(extensionDay)/\(extensionMonth)/\(extensionYearValue)"
        defaults.set(value, forKey: key)
        defaults.set(key, forKey: "taxpulse.latestExtensionKey")
        extensionMessage = language == .arabic ? "تم الحفظ بنجاح: \(value)" : "Saved successfully: \(value)"
    }

    func retrieveExtension() {
        let key = extensionKey
        if let value = defaults.string(forKey: key), !value.isEmpty {
            extensionMessage = language == .arabic ? "المهلة الرسمية المسجلة هي: \(value)" : "The official registered extended deadline is: \(value)"
        } else {
            extensionMessage = language == .arabic ? "لا توجد مهلة مسجلة بعد." : "No registered deadline extensions found yet."
        }
    }

    private var extensionKey: String {
        if extensionTaxType == "PROFIT" || extensionTaxType == "AUDIT" {
            return "taxpulse.extension.\(extensionTaxType).\(extensionYear).\(extensionCompanyType)"
        }
        return "taxpulse.extension.\(extensionTaxType).\(extensionYear).\(extensionQuarter)"
    }
}
