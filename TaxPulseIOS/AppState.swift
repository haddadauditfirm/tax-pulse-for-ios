import Foundation

/// A branded Tax Pulse modal currently on screen, if any. Hosted once at the
/// calculator shell (`AppModalHost`) rather than per-tab, so only one can show
/// at a time — matching Android, which never stacks these dialogs.
enum AppModal: Identifiable, Equatable {
    case extensionSaved
    case extensionSameDate(dateText: String)

    var id: String {
        switch self {
        case .extensionSaved: return "extensionSaved"
        case .extensionSameDate: return "extensionSameDate"
        }
    }
}

final class AppState: ObservableObject {
    static let minimumPenaltyYear = 2024
    @Published var activeModal: AppModal?
    /// DEBUG-only: makes result cards render on launch so QA can screenshot them.
    @Published var debugPreCalculated = false
    /// DEBUG-only: hides the input cards so a result card can be captured on screen.
    @Published var debugResultOnly = false
    @Published var onboardingStep = 1
    @Published var selectedTab: ServiceTab = .payroll
    @Published var language: AppLanguage = .english

    @Published var salaryPeriod: SalaryPeriod = .monthly
    @Published var employmentType: EmploymentType = .monthly
    @Published var payrollCurrency: CurrencyMode = .lbp
    @Published var payrollGrossLbp = ""
    @Published var payrollGrossUsd = ""
    @Published var payrollExchangeRate = ""
    @Published var payrollAllowances = ""
    @Published var payrollBonuses = ""
    @Published var payrollOvertime = ""
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
    @Published var penaltyR5PrincipalTaxPaid = true

    @Published var extensionTaxType = "PAYROLL"
    @Published var extensionYear = "2026"
    @Published var extensionQuarter = "Q1"
    @Published var extensionCompanyType = "CAPITAL"
    @Published var extensionDay = "15"
    @Published var extensionMonth = "4"
    @Published var extensionYearValue = "2026"
    @Published var extensionMessage: String?
    @Published private(set) var users: [UserRecord] = DemoSeed.users
    @Published private(set) var companies: [CompanyRecord] = DemoSeed.companies
    @Published private(set) var employees: [EmployeeRecord] = DemoSeed.employees
    @Published private(set) var payrollRuns: [PayrollRunRecord] = []
    @Published private(set) var auditLogs: [AuditLogRecord] = DemoSeed.auditLogs

    private let defaults = UserDefaults.standard
    private let localStore = TaxPulseLocalStore()

    /// QA hook: lets a simulator launch jump straight to an onboarding step, language
    /// or tab so every screen can be captured without tapping through the flow.
    /// Compiled out of Release builds entirely.
    private func applyDebugLaunchOverrides() {
        #if DEBUG
        let args = ProcessInfo.processInfo.arguments
        func value(after flag: String) -> String? {
            guard let index = args.firstIndex(of: flag), index + 1 < args.count else { return nil }
            return args[index + 1]
        }
        if let raw = value(after: "-uiStep"), let step = Int(raw) {
            onboardingStep = step
        }
        if let raw = value(after: "-uiLang") {
            language = raw.uppercased() == "AR" ? .arabic : .english
        }
        if let raw = value(after: "-uiTab") {
            switch raw.lowercased() {
            case "payroll": selectedTab = .payroll
            case "profit": selectedTab = .profit
            case "penalties": selectedTab = .penalties
            case "extensions": selectedTab = .extensions
            default: break
            }
        }
        if let raw = value(after: "-uiPenaltyAmount") { penaltyAmount = raw }
        if let raw = value(after: "-uiPayrollGross") { payrollGrossLbp = raw }
        if let raw = value(after: "-uiPayrollUsd") {
            payrollCurrency = .usd
            payrollGrossUsd = raw
            payrollExchangeRate = "89500"
        }
        if args.contains("-uiAnnual") { salaryPeriod = .annual }
        if let raw = value(after: "-uiProfitLbp") { profitGrossLbp = raw }
        if let raw = value(after: "-uiProfitMarital") {
            profitMarital = MaritalStatus(rawValue: raw) ?? .single
        }
        if let raw = value(after: "-uiProfitChildren"), let n = Int(raw) { profitChildren = n }
        if args.contains("-uiCalculated") { debugPreCalculated = true }
        if args.contains("-uiResultOnly") { debugPreCalculated = true; debugResultOnly = true }
        if let raw = value(after: "-uiModal") {
            switch raw {
            case "extensionSaved": activeModal = .extensionSaved
            case "extensionSameDate": activeModal = .extensionSameDate(dateText: "15 نيسان، 2026")
            default: break
            }
        }
        #endif
    }

    init() {
        applyDebugLaunchOverrides()
        if let snapshot = localStore.load() {
            users = snapshot.users
            companies = snapshot.companies
            employees = snapshot.employees
            payrollRuns = snapshot.payrollRuns
            auditLogs = snapshot.auditLogs
        } else {
            persistBusinessLayer()
        }
    }

    var payrollBasicSalaryLbpValue: Double {
        if payrollCurrency == .usd {
            let amount = Double(payrollGrossUsd) ?? 0
            let rate = Double(payrollExchangeRate) ?? 89_500
            return amount * rate
        }
        return Double(payrollGrossLbp) ?? 0
    }

    var payrollGrossLbpValue: Double {
        payrollBasicSalaryLbpValue + (Double(payrollAllowances) ?? 0) + (Double(payrollBonuses) ?? 0) + (Double(payrollOvertime) ?? 0)
    }

    var payrollResult: PayrollItem {
        PayrollEngine.calculate(
            basicSalary: payrollBasicSalaryLbpValue,
            allowances: Double(payrollAllowances) ?? 0,
            bonuses: Double(payrollBonuses) ?? 0,
            overtime: Double(payrollOvertime) ?? 0,
            employmentType: employmentType,
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
        let minimumYear = Self.minimumPenaltyYear
        return TaxEngines.calculatePenalties(
            companyType: penaltyCompanyType,
            taxType: penaltyTaxType,
            taxAmount: Double(penaltyAmount) ?? 0,
            payrollYear: max(Int(penaltyPayrollYear) ?? 2026, minimumYear),
            quarter: penaltyQuarter,
            profitDueYear: max(Int(penaltyProfitYear) ?? 2026, minimumYear),
            payDay: Int(penaltyPayDay) ?? 1,
            payMonth: Int(penaltyPayMonth) ?? 1,
            payYear: Int(penaltyPayYear) ?? 2026,
            dueDayOverride: Int(penaltyDueDay),
            dueMonthOverride: Int(penaltyDueMonth),
            dueYearOverride: max(Int(penaltyDueYear) ?? minimumYear, minimumYear),
            r5PrincipalTaxPaid: penaltyR5PrincipalTaxPaid
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
        salaryPeriod = .monthly
        employmentType = .monthly
        payrollCurrency = .lbp
        payrollGrossLbp = ""
        payrollGrossUsd = ""
        payrollExchangeRate = ""
        payrollAllowances = ""
        payrollBonuses = ""
        payrollOvertime = ""
        payrollMarital = .single
        payrollChildren = 0
        payrollMonth = 10
        isNssfRegistered = true
        useFamilyRebates = true
        sicknessCeilingOverride = ""
        familyCeilingOverride = ""
    }

    /// Full reset for the Tax Penalties tab: every numeric/date field returns to its
    /// default, and — unlike the other fields, which have fixed defaults — the
    /// Actual Payment Date always resets to today's real device date, never a
    /// hardcoded value.
    func resetPenalties() {
        penaltyCompanyType = "SAL"
        penaltyTaxType = "PAYROLL"
        penaltyAmount = ""
        penaltyPayrollYear = "2026"
        penaltyQuarter = "Q1"
        penaltyR5PrincipalTaxPaid = true
        penaltyProfitYear = "2026"
        let now = Date()
        let calendar = Calendar.current
        penaltyPayDay = "\(calendar.component(.day, from: now))"
        penaltyPayMonth = "\(calendar.component(.month, from: now))"
        penaltyPayYear = "\(calendar.component(.year, from: now))"
        syncPenaltyDueDate()
    }

    /// Fiscal years offered by the penalty year picker. Starting the list at the
    /// legal floor is what makes an out-of-range year unreachable through the UI,
    /// which is why the old year-restriction alert is gone.
    var selectablePenaltyYears: [String] {
        let currentYear = Calendar.current.component(.year, from: Date())
        let upperBound = max(currentYear, Self.minimumPenaltyYear + 2)
        return (Self.minimumPenaltyYear...upperBound).map(String.init)
    }

    /// Single entry point for Payroll, Profit and VAT fiscal-year edits. A complete
    /// year below the legal floor never survives in app state — it is clamped to the
    /// floor silently, since the picker already prevents choosing one.
    @discardableResult
    func updatePenaltyFiscalYear(_ input: String) -> Bool {
        let sanitized = String(sanitizedDigits(input).prefix(4))
        let isInvalid = sanitized.count == 4
            && (Int(sanitized) ?? Self.minimumPenaltyYear) < Self.minimumPenaltyYear
        let accepted = isInvalid ? "\(Self.minimumPenaltyYear)" : sanitized

        if penaltyTaxType == "PAYROLL" || penaltyTaxType == "VAT" {
            penaltyPayrollYear = accepted
        } else {
            penaltyProfitYear = accepted
        }
        syncPenaltyDueDate()
        return !isInvalid
    }

    /// Applies the same floor to the still-editable statutory due-date year.
    @discardableResult
    func updatePenaltyDueYear(_ input: String) -> Bool {
        let sanitized = String(sanitizedDigits(input).prefix(4))
        let isInvalid = sanitized.count == 4
            && (Int(sanitized) ?? Self.minimumPenaltyYear) < Self.minimumPenaltyYear
        penaltyDueYear = isInvalid ? "\(Self.minimumPenaltyYear)" : sanitized
        return !isInvalid
    }

    /// Final pre-calculation guard. It also protects against direct/debug state
    /// mutation that bypasses the text-field setters.
    @discardableResult
    func validatePenaltyYearsBeforeCalculation() -> Bool {
        let activeFiscalText = (penaltyTaxType == "PAYROLL" || penaltyTaxType == "VAT")
            ? penaltyPayrollYear
            : penaltyProfitYear
        let fiscalIsInvalid = activeFiscalText.count == 4
            && (Int(activeFiscalText) ?? Self.minimumPenaltyYear) < Self.minimumPenaltyYear
        let dueIsInvalid = penaltyDueYear.count == 4
            && (Int(penaltyDueYear) ?? Self.minimumPenaltyYear) < Self.minimumPenaltyYear

        if fiscalIsInvalid {
            if penaltyTaxType == "PAYROLL" || penaltyTaxType == "VAT" {
                penaltyPayrollYear = "\(Self.minimumPenaltyYear)"
            } else {
                penaltyProfitYear = "\(Self.minimumPenaltyYear)"
            }
        }
        if fiscalIsInvalid || dueIsInvalid {
            if fiscalIsInvalid { syncPenaltyDueDate() }
            if dueIsInvalid {
                penaltyDueYear = "\(Self.minimumPenaltyYear)"
            }
            return false
        }
        return true
    }

    /// Defensive visibility gate: invalid direct/debug state must never render a
    /// result even though normal UI input is clamped immediately.
    var isPenaltyYearBlocked: Bool {
        let yearText = (penaltyTaxType == "PAYROLL" || penaltyTaxType == "VAT") ? penaltyPayrollYear : penaltyProfitYear
        let fiscalBlocked = yearText.count == 4
            && (Int(yearText) ?? Self.minimumPenaltyYear) < Self.minimumPenaltyYear
        let dueBlocked = penaltyDueYear.count == 4
            && (Int(penaltyDueYear) ?? Self.minimumPenaltyYear) < Self.minimumPenaltyYear
        return fiscalBlocked || dueBlocked
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
        if let savedValue = defaults.string(forKey: extensionKey), !savedValue.isEmpty {
            let parts = savedValue.split(separator: "/").map(String.init)
            if parts.count == 3 {
                extensionDay = parts[0]
                extensionMonth = parts[1]
                extensionYearValue = parts[2]
            }
        } else {
            extensionDay = "\(auto.day)"
            extensionMonth = "\(auto.month)"
            extensionYearValue = "\(auto.year)"
        }
        extensionMessage = nil
    }

    /// Entry point for the Save button. If the entered date matches the base
    /// statutory due date, Android asks for confirmation first instead of saving
    /// immediately; otherwise it saves right away.
    func handleSaveExtensionTap() {
        let auto = extensionAutoDate
        if extensionDay == "\(auto.day)" && extensionMonth == "\(auto.month)" && extensionYearValue == "\(auto.year)" {
            activeModal = .extensionSameDate(dateText: formatDateParts(auto, language: language))
        } else {
            performSaveExtension()
        }
    }

    /// Actually persists the extension date and shows the branded success modal.
    /// Called directly for a non-matching date, or from the same-date warning's
    /// "Save" button once the user confirms.
    func performSaveExtension() {
        let key = extensionKey
        let value = "\(extensionDay)/\(extensionMonth)/\(extensionYearValue)"
        defaults.set(value, forKey: key)
        defaults.set(key, forKey: "taxpulse.latestExtensionKey")
        activeModal = .extensionSaved
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

    private func persistBusinessLayer() {
        localStore.save(
            TaxPulseSnapshot(
                users: users,
                companies: companies,
                employees: employees,
                payrollRuns: payrollRuns,
                auditLogs: auditLogs
            )
        )
    }
}

enum DemoSeed {
    static let users = [
        UserRecord(id: "admin@haddad.com", fullName: "Haddad Super Admin", passwordHash: "admin123", role: "SUPER_ADMIN", companyId: nil, is2FAEnabled: true, status: "ACTIVE"),
        UserRecord(id: "auditor@haddad.com", fullName: "Chief Internal Auditor", passwordHash: "auditor123", role: "AUDITOR", companyId: nil, is2FAEnabled: false, status: "ACTIVE"),
        UserRecord(id: "accounting@levant.com", fullName: "Levant Finance Manager", passwordHash: "levant123", role: "ACCOUNTANT", companyId: 1, is2FAEnabled: false, status: "ACTIVE"),
        UserRecord(id: "hr@cedars.com", fullName: "Cedars HR Lead", passwordHash: "cedars123", role: "HR_MANAGER", companyId: 2, is2FAEnabled: false, status: "ACTIVE"),
        UserRecord(id: "employee@haddad.com", fullName: "Samer Salhab (Employee)", passwordHash: "samer123", role: "EMPLOYEE", companyId: 1, is2FAEnabled: false, status: "ACTIVE")
    ]

    static let companies = [
        CompanyRecord(id: 1, name: "Levant Trade SARL", arabicName: "شركة ليفانت للتجارة ش.م.م.", registrationNumber: "CR-195822/B", nssfNumber: "NSSF-492041", address: "Downtown Beirut, Lebanon", phone: "+961 1 980 120", isBlocked: false),
        CompanyRecord(id: 2, name: "Cedars Foods SAL", arabicName: "شركة أرز لبنان للأغذية ش.م.ل.", registrationNumber: "CR-104928/A", nssfNumber: "NSSF-839219", address: "Zouk Mosbeh Industrial Area, Lebanon", phone: "+961 9 224 885", isBlocked: false)
    ]

    static let employees = [
        EmployeeRecord(id: 1, companyId: 1, employeeNumber: "EMP001", fullName: "Jihad Al-Amin", arabicName: "جهاد الأمين", email: "jihad@levant.com", jobTitle: "Senior Operations Manager", department: "Operations", startDate: "2022-03-01", employmentType: .monthly, basicSalary: 80_000_000, allowances: 20_000_000, isNssfRegistered: true, isTaxable: true, maritalStatus: .spouseDependent, childrenCount: 3, bankName: "Bank Audi", bankIban: "LB84000200010192847123", status: "ACTIVE"),
        EmployeeRecord(id: 2, companyId: 1, employeeNumber: "EMP002", fullName: "Rania Haddad", arabicName: "رانيا حداد", email: "rania@levant.com", jobTitle: "Financial Accountant", department: "Finance", startDate: "2024-05-15", employmentType: .monthly, basicSalary: 110_000_000, allowances: 0, isNssfRegistered: true, isTaxable: true, maritalStatus: .spouseWorks, childrenCount: 0, bankName: "BLOM Bank", bankIban: "LB49001400030092817263", status: "ACTIVE"),
        EmployeeRecord(id: 3, companyId: 1, employeeNumber: "EMP003", fullName: "Omar Kassem", arabicName: "عمر قاسم", email: "omar@levant.com", jobTitle: "Site Guard (Daily Contractor)", department: "Security", startDate: "2025-01-10", employmentType: .daily, basicSalary: 2_000_000, allowances: 500_000, isNssfRegistered: false, isTaxable: true, maritalStatus: .single, childrenCount: 0, bankName: "Byblos Bank", bankIban: "LB12001500040009283741", status: "ACTIVE"),
        EmployeeRecord(id: 4, companyId: 2, employeeNumber: "EMP004", fullName: "Nour El-Khoury", arabicName: "نور الخوري", email: "nour@cedars.com", jobTitle: "VP of Food Engineering", department: "R&D", startDate: "2020-01-01", employmentType: .monthly, basicSalary: 330_000_000, allowances: 50_000_000, isNssfRegistered: true, isTaxable: true, maritalStatus: .spouseDependent, childrenCount: 5, bankName: "SGBL", bankIban: "LB38000500021029381273", status: "ACTIVE"),
        EmployeeRecord(id: 5, companyId: 2, employeeNumber: "EMP005", fullName: "Samer Salhab", arabicName: "سامر سلهب", email: "samer@cedars.com", jobTitle: "Special Project Advisor (Lump-Sum)", department: "Advisory", startDate: "2025-02-15", employmentType: .lumpSumWages, basicSalary: 50_000_000, allowances: 0, isNssfRegistered: false, isTaxable: true, maritalStatus: .single, childrenCount: 2, bankName: "Cash payout", bankIban: "", status: "ACTIVE")
    ]

    static let auditLogs: [AuditLogRecord] = (1...63).map { index in
        AuditLogRecord(
            id: index,
            userId: index.isMultiple(of: 2) ? "admin@haddad.com" : "analyst@haddad.com",
            userName: index.isMultiple(of: 2) ? "Haddad Super Admin" : "Chief Internal Auditor",
            userRole: index.isMultiple(of: 2) ? "SUPER_ADMIN" : "AUDITOR",
            companyId: nil,
            action: ["SYSTEM_INIT", "TAX_TABLE_LOADED", "CHILD_REBATE_SYNC", "NSSF_CEILING_REFRESH", "REGULATORY_AUDIT", "COMPLIANCE_PASS"][index % 6],
            oldValue: "",
            newValue: "Automated compliance verification check \(index) of 63",
            reason: "Seeded Android parity audit trail",
            timestamp: Date().addingTimeInterval(Double(index - 64) * 600),
            ipAddress: "127.0.0.1"
        )
    }
}
