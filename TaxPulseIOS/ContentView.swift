import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var state: AppState

    var body: some View {
        Group {
            if state.onboardingStep < 4 {
                OnboardingHost()
            } else {
                CalculatorShell()
            }
        }
        .environment(\.layoutDirection, state.language == .arabic ? .rightToLeft : .leftToRight)
    }
}

struct OnboardingHost: View {
    @EnvironmentObject private var state: AppState

    var body: some View {
        ZStack {
            LinearGradient(colors: [Color(red: 0.027, green: 0.043, blue: 0.098), Color(red: 0.118, green: 0.161, blue: 0.231)], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

            switch state.onboardingStep {
            case 1:
                WelcomeScreen()
                    .transition(.move(edge: .trailing).combined(with: .opacity))
            case 2:
                LanguageScreen()
                    .transition(.move(edge: .trailing).combined(with: .opacity))
            default:
                ServiceScreen()
                    .transition(.move(edge: .trailing).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.32), value: state.onboardingStep)
    }
}

struct WelcomeScreen: View {
    @EnvironmentObject private var state: AppState

    var body: some View {
        VStack(spacing: 34) {
            Spacer()
            VStack(spacing: 20) {
                BrandMark(size: 76)
                VStack(spacing: 12) {
                    Text("Welcome to Tax Pulse")
                        .font(.system(size: 30, weight: .black))
                        .foregroundStyle(
                            LinearGradient(colors: [.white, Color(red: 0.576, green: 0.773, blue: 0.992), .blueAccent], startPoint: .leading, endPoint: .trailing)
                        )
                        .multilineTextAlignment(.center)
                    Text("Smarter tax simplified for you.")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(Color.slateMuted)
                    HeartRateLine()
                        .frame(height: 72)
                        .padding(.vertical, 6)
                    Rectangle()
                        .fill(Color.white.opacity(0.14))
                        .frame(width: 96, height: 1)
                    Text("Developed by Haddad Audit Firm")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(Color(red: 0.376, green: 0.647, blue: 0.980))
                    Text("Certified Auditors and Tax Advisors")
                        .font(.system(size: 10))
                        .foregroundStyle(Color.white.opacity(0.58))
                }
                .padding(26)
                .frame(maxWidth: .infinity)
                .background(Color.white.opacity(0.04))
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 24).stroke(Color.white.opacity(0.09), lineWidth: 1))
            }
            .padding(.horizontal, 24)

            PrimaryActionButton(title: "ENTER") {
                state.onboardingStep = 2
            }
            .padding(.horizontal, 46)
            Spacer()
        }
    }
}

struct LanguageScreen: View {
    @EnvironmentObject private var state: AppState

    var body: some View {
        VStack(spacing: 28) {
            TopBackButton { state.onboardingStep = 1 }
            Spacer()
            Image(systemName: "globe")
                .font(.system(size: 58, weight: .semibold))
                .foregroundStyle(Color(red: 0.376, green: 0.647, blue: 0.980))
            VStack(spacing: 8) {
                Text(state.language == .arabic ? "اختر لغتك المفضلة" : "Choose the language")
                    .font(.system(size: 24, weight: .black))
                    .foregroundStyle(Color.white)
                Text(state.language == .arabic ? "يمكنك تغيير هذا الخيار لاحقا" : "You can change this anytime later")
                    .font(.system(size: 14))
                    .foregroundStyle(Color.slateMuted)
            }
            HStack(spacing: 16) {
                LanguageCard(title: "English", subtitle: "Smarter tax simplified", code: "EN", selected: state.language == .english) {
                    state.language = .english
                    state.onboardingStep = 3
                }
                LanguageCard(title: "العربية", subtitle: "الضرائب الذكية مبسطة", code: "AR", selected: state.language == .arabic) {
                    state.language = .arabic
                    state.onboardingStep = 3
                }
            }
            .padding(.horizontal, 24)
            Spacer()
        }
    }
}

struct ServiceScreen: View {
    @EnvironmentObject private var state: AppState

    var body: some View {
        VStack(spacing: 24) {
            TopBackButton { state.onboardingStep = 2 }
            Spacer()
            VStack(spacing: 8) {
                Text(state.language == .arabic ? "اختر نوع الخدمة المطلوبة" : "Choose your service")
                    .font(.system(size: 24, weight: .black))
                    .foregroundStyle(Color.white)
                Text(state.language == .arabic ? "اختر خدمة للبدء مباشرة" : "Select a service below to jump straight in")
                    .font(.system(size: 13))
                    .foregroundStyle(Color.slateMuted)
                    .multilineTextAlignment(.center)
            }
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                ServiceSelectionCard(tab: .payroll, color: .blueAccent, icon: "banknote.fill") { state.chooseService(.payroll) }
                ServiceSelectionCard(tab: .profit, color: .successGreen, icon: "building.columns.fill") { state.chooseService(.profit) }
                ServiceSelectionCard(tab: .penalties, color: .alertGold, icon: "exclamationmark.triangle.fill") { state.chooseService(.penalties) }
                ServiceSelectionCard(tab: .extensions, color: Color(red: 0.925, green: 0.282, blue: 0.600), icon: "calendar.badge.clock") { state.chooseService(.extensions) }
            }
            .padding(.horizontal, 24)
            Spacer()
        }
    }
}

struct CalculatorShell: View {
    @EnvironmentObject private var state: AppState

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                HeaderView()
                ActiveServiceBanner()

                switch state.selectedTab {
                case .payroll: PayrollCalculatorTab()
                case .profit: ProfitCalculatorTab()
                case .penalties: PenaltiesCalculatorTab()
                case .extensions: ExtensionsCalculatorTab()
                }

                ContactCard()
            }
            .padding(16)
        }
        .background(Color.slateLight.ignoresSafeArea())
    }
}

struct HeaderView: View {
    @EnvironmentObject private var state: AppState

    var body: some View {
        HStack(spacing: 10) {
            VStack(alignment: .leading, spacing: 3) {
                Text(Copy.t("headerTitle", state.language))
                    .font(.system(size: 18, weight: .black))
                    .foregroundStyle(Color.navyPrimary)
                Text(Copy.t("byHaddad", state.language))
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(Color.navyMedium)
                    .lineLimit(1)
                Text(Copy.t("subtitle", state.language))
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(Color.blueAccent)
                    .lineLimit(1)
            }
            Spacer()
            OptionRow(options: [("EN", "ENG"), ("AR", "ARB")], selected: state.language.rawValue) { key in
                state.language = key == "AR" ? .arabic : .english
            }
            .frame(width: 132)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        }
    }
}

struct ActiveServiceBanner: View {
    @EnvironmentObject private var state: AppState

    var body: some View {
        let meta = serviceMeta(state.selectedTab, language: state.language)
        HStack(spacing: 12) {
            Image(systemName: meta.icon)
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(Color.white)
                .frame(width: 36, height: 36)
                .background(meta.color)
                .clipShape(Circle())
            VStack(alignment: .leading, spacing: 3) {
                Text(Copy.t("activeService", state.language))
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(Color.slateTextLight)
                Text(meta.title)
                    .font(.system(size: 15, weight: .black))
                    .foregroundStyle(Color.navyPrimary)
            }
            Spacer()
            Button(Copy.t("changeService", state.language)) {
                state.onboardingStep = 3
            }
            .font(.system(size: 12, weight: .black))
            .foregroundStyle(Color.blueAccent)
        }
        .padding(14)
        .background(meta.color.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(meta.color.opacity(0.25), lineWidth: 1)
        )
    }
}

struct PayrollCalculatorTab: View {
    @EnvironmentObject private var state: AppState
    @State private var isCalculated = false

    var body: some View {
        VStack(spacing: 16) {
            SectionIntro(
                title: state.language == .arabic ? "حاسبة ضريبة الرواتب والأجور" : "Payroll Tax Calculator",
                bodyText: state.language == .arabic ? "أداة لحساب ضريبة الرواتب والتعويضات العائلية واشتراكات الضمان الاجتماعي وفق القواعد اللبنانية." : "This tool calculates tax liabilities on employment income, family allowances, and social security contributions using the Lebanese payroll and NSSF rules from the source app."
            )

            AppCard {
                HStack {
                    Text(Copy.t("payroll", state.language))
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(Color.navyPrimary)
                    Spacer()
                    PillButton(title: Copy.t("reset", state.language), systemImage: "arrow.clockwise") {
                        isCalculated = false
                        state.resetPayroll()
                    }
                }

                OptionRow(options: [("MONTHLY", state.language == .arabic ? "شهري" : "Monthly"), ("ANNUAL", state.language == .arabic ? "سنوي" : "Annual")], selected: state.salaryPeriod.rawValue) {
                    state.salaryPeriod = $0 == "ANNUAL" ? .annual : .monthly
                    isCalculated = false
                }

                OptionRow(options: [("LBP", Copy.t("lbp", state.language)), ("USD", Copy.t("usd", state.language))], selected: state.payrollCurrency.rawValue) {
                    state.payrollCurrency = $0 == "USD" ? .usd : .lbp
                    isCalculated = false
                }

                TextField(state.language == .arabic ? "الاسم الكامل للموظف" : "Full Name of Employee", text: $state.employeeName)
                    .font(.system(size: 14))
                    .padding(.horizontal, 12)
                    .frame(height: 48)
                    .background(Color.slate50)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.slateBorder, lineWidth: 1))

                if state.payrollCurrency == .lbp {
                    StyledTextField(title: state.salaryPeriod == .annual ? "Annual Gross Salary LBP" : "Basic Monthly Gross Salary (LBP)", placeholder: "Enter salary numbers...", suffix: "LBP", text: Binding(get: { state.payrollGrossLbp }, set: { state.payrollGrossLbp = sanitizedDigits($0); isCalculated = false }))
                    Text("Current Value: \(lbp(Double(state.payrollGrossLbp) ?? 0))")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle((Double(state.payrollGrossLbp) ?? 0) > 0 ? Color.successGreen : Color.slateTextLight)
                } else {
                    StyledTextField(title: state.salaryPeriod == .annual ? "Annual Gross Salary USD" : "Monthly Dollars Salary (USD)", placeholder: "e.g. 1500", suffix: "USD", text: Binding(get: { state.payrollGrossUsd }, set: { state.payrollGrossUsd = sanitizedDecimal($0); isCalculated = false }), decimal: true)
                    StyledTextField(title: "Custom Dollar Exchange Rate (LBP/USD)", placeholder: "e.g. 89,500", suffix: "LBP/USD", text: Binding(get: { state.payrollExchangeRate }, set: { state.payrollExchangeRate = sanitizedDecimal($0); isCalculated = false }), decimal: true)
                    Button("Use Standard Rate: 89,500") {
                        state.payrollExchangeRate = "89500"
                    }
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(Color.blueAccent)
                    Text("Equivalent LBP Gross: \(lbp(state.payrollGrossLbpValue))")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(state.payrollGrossLbpValue > 0 ? Color.successGreen : Color.slateTextLight)
                }

                OptionRow(
                    options: [
                        ("SINGLE", Copy.t("single", state.language)),
                        ("SPOUSE_WORKS", Copy.t("spouseWorks", state.language)),
                        ("SPOUSE_DEPENDENT", Copy.t("spouseDependent", state.language))
                    ],
                    selected: state.payrollMarital.rawValue
                ) {
                    state.payrollMarital = MaritalStatus(rawValue: $0) ?? .single
                    if state.payrollMarital == .single { state.payrollChildren = 0 }
                    isCalculated = false
                }

                if state.payrollMarital != .single {
                    ChildrenPicker(count: $state.payrollChildren)
                }

                OptionRow(options: [("5", "Jan - Jul (18M min)"), ("10", "Aug - Dec (28M min)")], selected: "\(state.payrollMonth)") {
                    state.payrollMonth = Int($0) ?? 10
                    isCalculated = false
                }

                ToggleLine(title: "Subject To NSSF Law", isOn: $state.isNssfRegistered)
                ToggleLine(title: "Family Rebates", isOn: $state.useFamilyRebates)

                if state.salaryPeriod == .annual {
                    StyledTextField(title: "Annual Sickness Ceiling Override", placeholder: "Optional", suffix: "LBP", text: Binding(get: { state.sicknessCeilingOverride }, set: { state.sicknessCeilingOverride = sanitizedDigits($0) }))
                    StyledTextField(title: "Annual Family Ceiling Override", placeholder: "Optional", suffix: "LBP", text: Binding(get: { state.familyCeilingOverride }, set: { state.familyCeilingOverride = sanitizedDigits($0) }))
                }
            }

            if state.payrollGrossLbpValue > 0 && !isCalculated {
                PrimaryActionButton(title: "\(Copy.t("calculate", state.language)) \(Copy.t("payroll", state.language))") {
                    isCalculated = true
                }
            }

            if isCalculated {
                PayrollResultCard(result: state.payrollResult)
            }
        }
    }
}

struct PayrollResultCard: View {
    @EnvironmentObject private var state: AppState
    var result: PayrollItem

    var body: some View {
        AppCard {
            VStack(spacing: 8) {
                Text(Copy.t("netTakeHome", state.language))
                    .font(.system(size: 12, weight: .black))
                    .foregroundStyle(Color.slateTextDark)
                Text(lbp(result.netSalary))
                    .font(.system(size: 28, weight: .black))
                    .foregroundStyle(Color.successGreen)
                Text(state.employeeName.isEmpty ? "Based on Sandbox Account details" : "Based on \(state.employeeName)'s details")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(Color.slateTextLight)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(Color.slateLight)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

            ResultRow(title: "Base Monthly Salary", value: lbp(result.basicSalary))
            ResultRow(title: "Sickness NSSF (3% Employee)", value: "- \(lbp(result.sicknessMaternityEmployee))", valueColor: .dangerRed)
            ResultRow(title: "MOF Progressive Tax", value: "- \(lbp(result.taxAmount))", valueColor: .dangerRed)
            ResultRow(title: "Family Allowances Added", value: "+ \(lbp(result.totalFamilyBenefitsAmount))", valueColor: .successGreen)
            Divider()
            ResultRow(title: "Total NSSF Employer (22.5%)", value: lbp(result.totalNssfEmployer), isBold: true)
            ResultRow(title: "Total Corporate Cost", value: lbp(result.totalEmployerCost), valueColor: .navyPrimary, isBold: true)

            if result.hasMinimumWageWarning {
                WarningBox(title: "1 Compliance Warning Detected", text: "The base salary is below the legal Lebanese minimum wage rate for this period.")
            } else {
                SuccessBox(title: "0 Compliance Errors Found", text: "This calculation conforms to the standard Lebanese MOF and NSSF wage rules used by the uploaded app.")
            }
        }
    }
}

struct ProfitCalculatorTab: View {
    @EnvironmentObject private var state: AppState
    @State private var isCalculated = false

    var body: some View {
        VStack(spacing: 16) {
            SectionIntro(title: "Tax on Profits Calculator", bodyText: "This tool calculates income and profit tax liabilities with personal, spouse, and children rebates plus official progressive profit brackets.")

            AppCard {
                HStack {
                    Text(Copy.t("profit", state.language))
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(Color.navyPrimary)
                    Spacer()
                    PillButton(title: Copy.t("reset", state.language), systemImage: "arrow.clockwise") {
                        state.profitGrossLbp = ""
                        state.profitGrossUsd = ""
                        state.profitCurrency = .lbp
                        state.profitExchangeRate = ""
                        state.profitMarital = .single
                        state.profitChildren = 0
                        state.profitOwnerName = ""
                        isCalculated = false
                    }
                }

                OptionRow(options: [("LBP", Copy.t("lbp", state.language)), ("USD", Copy.t("usd", state.language))], selected: state.profitCurrency.rawValue) {
                    state.profitCurrency = $0 == "USD" ? .usd : .lbp
                    isCalculated = false
                }

                if state.profitCurrency == .lbp {
                    StyledTextField(title: "Annual Net Taxable Profit (LBP)", placeholder: "Enter annual taxable profit...", suffix: "LBP", text: Binding(get: { state.profitGrossLbp }, set: { state.profitGrossLbp = sanitizedDigits($0); isCalculated = false }))
                } else {
                    StyledTextField(title: "Annual Net Taxable Profit (USD)", placeholder: "Enter annual taxable profit...", suffix: "USD", text: Binding(get: { state.profitGrossUsd }, set: { state.profitGrossUsd = sanitizedDecimal($0); isCalculated = false }), decimal: true)
                    StyledTextField(title: "Custom Dollar Exchange Rate (LBP/USD)", placeholder: "e.g. 89,500", suffix: "LBP/$", text: Binding(get: { state.profitExchangeRate }, set: { state.profitExchangeRate = sanitizedDecimal($0); isCalculated = false }), decimal: true)
                    Button("Use Standard Rate: 89,500") { state.profitExchangeRate = "89500" }
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(Color.blueAccent)
                }

                OptionRow(
                    options: [("SINGLE", Copy.t("single", state.language)), ("SPOUSE_WORKS", Copy.t("spouseWorks", state.language)), ("SPOUSE_DEPENDENT", Copy.t("spouseDependent", state.language))],
                    selected: state.profitMarital.rawValue
                ) {
                    state.profitMarital = MaritalStatus(rawValue: $0) ?? .single
                    if state.profitMarital == .single { state.profitChildren = 0 }
                    isCalculated = false
                }

                if state.profitMarital != .single {
                    ChildrenPicker(count: $state.profitChildren)
                }
            }

            if hasProfitInput && !isCalculated {
                PrimaryActionButton(title: "CALCULATE PROFIT TAX") { isCalculated = true }
            }

            if isCalculated {
                ProfitResultCard(result: state.profitResult)
            }
        }
    }

    private var hasProfitInput: Bool {
        state.profitCurrency == .lbp ? !state.profitGrossLbp.isEmpty : !state.profitGrossUsd.isEmpty
    }
}

struct ProfitResultCard: View {
    var result: ProfitTaxResult

    var body: some View {
        AppCard {
            Text("Profit Tax Assessment Summary")
                .font(.system(size: 14, weight: .black))
                .foregroundStyle(Color.navyPrimary)

            VStack(spacing: 8) {
                Text("Total Profit Tax Due")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(Color.slateTextDark)
                Text(lbp(result.totalTaxDue))
                    .font(.system(size: 25, weight: .black))
                    .foregroundStyle(Color(red: 0.761, green: 0.063, blue: 0.063))
                Divider()
                Text("Remaining Net Profit (After Tax & Rebate)")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(Color.slateTextDark)
                Text(lbp(result.netNetProfit))
                    .font(.system(size: 18, weight: .black))
                    .foregroundStyle(Color.successGreen)
            }
            .frame(maxWidth: .infinity)
            .padding(16)
            .background(Color.slateLight)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

            ResultRow(title: "Personal Rebate (Himself)", value: lbp(result.himselfRebate))
            if result.spouseRebate > 0 {
                ResultRow(title: "Wife / Husband Rebate", value: lbp(result.spouseRebate))
            }
            if result.childrenRebate > 0 {
                ResultRow(title: "Children Rebate", value: lbp(result.childrenRebate))
            }
            ResultRow(title: "Total Family Rebates", value: lbp(result.totalRebates), valueColor: .navyPrimary, isBold: true)
            ResultRow(title: "Net Taxable Profit After Rebates", value: lbp(result.profitAfterRebates), isBold: true)

            Text("Progressive Bracket Allocation Details")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(Color.navyPrimary)
                .padding(.top, 8)
            ForEach(result.bracketAllocations) { bracket in
                BracketRowView(bracket: bracket, total: result.profitAfterRebates)
            }
        }
    }
}

struct PenaltiesCalculatorTab: View {
    @EnvironmentObject private var state: AppState
    @State private var isCalculated = false

    var body: some View {
        VStack(spacing: 16) {
            SectionIntro(title: "Tax Penalties Engine", bodyText: "Calculate late filing verification fines and late payment collection fines for payroll, profit, and VAT categories.")

            AppCard {
                HStack {
                    Text("Tax Penalties Engine")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(Color.navyPrimary)
                    Spacer()
                    PillButton(title: Copy.t("reset", state.language), systemImage: "arrow.clockwise") {
                        state.penaltyCompanyType = "SAL"
                        state.penaltyTaxType = "PAYROLL"
                        state.penaltyAmount = ""
                        state.penaltyPayrollYear = "2026"
                        state.penaltyQuarter = "Q1"
                        state.penaltyProfitYear = "2026"
                        state.syncPenaltyDueDate()
                        isCalculated = false
                    }
                }

                OptionRow(options: [("PAYROLL", "Payroll Tax"), ("PROFIT", "Tax on Profit"), ("VAT", "VAT")], selected: state.penaltyTaxType) {
                    state.penaltyTaxType = $0
                    state.syncPenaltyDueDate()
                    isCalculated = false
                }

                VStack(spacing: 8) {
                    ForEach([["SAL", "SARL"], ["PARTNERSHIP", "INDIVIDUAL"], ["EXEMPT", "OTHER"]], id: \.self) { row in
                        HStack(spacing: 8) {
                            ForEach(row, id: \.self) { item in
                                OptionChip(title: item, isSelected: state.penaltyCompanyType == item) {
                                    state.penaltyCompanyType = item
                                    state.syncPenaltyDueDate()
                                    isCalculated = false
                                }
                            }
                        }
                    }
                }
                .padding(4)
                .background(Color.slateLight)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

                StyledTextField(title: "Tax Amount (LBP)", placeholder: "Enter tax amount", suffix: "LBP", text: Binding(get: { state.penaltyAmount }, set: { state.penaltyAmount = sanitizedDigits($0); isCalculated = false }))

                if state.penaltyTaxType == "PAYROLL" || state.penaltyTaxType == "VAT" {
                    HStack(spacing: 10) {
                        StyledTextField(title: "Year", placeholder: "2026", suffix: nil, text: Binding(get: { state.penaltyPayrollYear }, set: { state.penaltyPayrollYear = sanitizedDigits($0); state.syncPenaltyDueDate(); isCalculated = false }))
                        StyledTextField(title: "Quarter", placeholder: "Q1", suffix: nil, text: $state.penaltyQuarter)
                    }
                    OptionRow(options: [("Q1", "Q1"), ("Q2", "Q2"), ("Q3", "Q3"), ("Q4", "Q4"), ("R5", "R5")], selected: state.penaltyQuarter) {
                        state.penaltyQuarter = $0
                        state.syncPenaltyDueDate()
                        isCalculated = false
                    }
                } else {
                    StyledTextField(title: "Profit Due Year", placeholder: "2026", suffix: nil, text: Binding(get: { state.penaltyProfitYear }, set: { state.penaltyProfitYear = sanitizedDigits($0); state.syncPenaltyDueDate(); isCalculated = false }))
                }

                DateFields(title: "Statutory Due Date", day: $state.penaltyDueDay, month: $state.penaltyDueMonth, year: $state.penaltyDueYear)
                DateFields(title: "Payment Date", day: $state.penaltyPayDay, month: $state.penaltyPayMonth, year: $state.penaltyPayYear)
            }

            if !state.penaltyAmount.isEmpty && !isCalculated {
                PrimaryActionButton(title: "CALCULATE PENALTIES") { isCalculated = true }
            }

            if isCalculated {
                PenaltyResultCard(result: state.penaltyResult)
            }
        }
    }
}

struct PenaltyResultCard: View {
    var result: PenaltyResult

    var body: some View {
        AppCard {
            VStack(spacing: 8) {
                Text("Total Amount Due")
                    .font(.system(size: 12, weight: .black))
                    .foregroundStyle(Color.slateTextDark)
                Text(lbp(result.totalAmount))
                    .font(.system(size: 26, weight: .black))
                    .foregroundStyle(Color.dangerRed)
                Text("\(result.lateMonths) late month\(result.lateMonths == 1 ? "" : "s") counted")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(Color.slateTextLight)
            }
            .frame(maxWidth: .infinity)
            .padding(16)
            .background(Color.slateLight)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

            ResultRow(title: "Minimum Verification Fine", value: lbp(result.minimumThreshold))
            ResultRow(title: "Verification Fine", value: lbp(result.verificationFine), valueColor: .dangerRed, isBold: true)
            ResultRow(title: "Collection Fine", value: lbp(result.collectionFine), valueColor: .dangerRed, isBold: true)
            if result.isDueDateAfterPayment {
                SuccessBox(title: "No delay detected", text: "The payment date is on or before the statutory due date.")
            } else if result.isUnderMinimum {
                WarningBox(title: "Minimum fine applied", text: "The verification fine was raised to the legal minimum for this taxpayer category.")
            } else if result.isCapped {
                WarningBox(title: "Verification fine capped", text: "The verification fine was capped at 100% of the original tax.")
            }
        }
    }
}

struct ExtensionsCalculatorTab: View {
    @EnvironmentObject private var state: AppState

    var body: some View {
        VStack(spacing: 16) {
            SectionIntro(title: "MOF Deadline Extensions Tracker", bodyText: "Monitor and save Lebanese Ministry of Finance deadline extension decisions locally on device.")

            AppCard {
                Text("Select Tax Type for Extension Tracking")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(Color.slateTextDark)
                OptionRow(options: [("PAYROLL", "Payroll Tax"), ("VAT", "VAT"), ("PROFIT", "Profit"), ("AUDIT", "Audit")], selected: state.extensionTaxType) {
                    state.extensionTaxType = $0
                    state.syncExtensionDate()
                }

                StyledTextField(title: "Fiscal Year", placeholder: "2026", suffix: nil, text: Binding(get: { state.extensionYear }, set: { state.extensionYear = sanitizedDigits($0); state.syncExtensionDate() }))

                if state.extensionTaxType == "PAYROLL" || state.extensionTaxType == "VAT" {
                    OptionRow(options: extensionQuarterOptions, selected: state.extensionQuarter) {
                        state.extensionQuarter = $0
                        state.syncExtensionDate()
                    }
                } else {
                    OptionRow(options: [("CAPITAL", "Capital"), ("PARTNERSHIP", "Partnership"), ("SOLE_REAL", "Sole Real"), ("EXEMPT", "Exempt")], selected: state.extensionCompanyType) {
                        state.extensionCompanyType = $0
                        state.syncExtensionDate()
                    }
                }

                let auto = state.extensionAutoDate
                SuccessBox(title: "Primary statutory due date", text: "\(auto.day)/\(auto.month)/\(auto.year)")
                DateFields(title: "Official Extended Date", day: $state.extensionDay, month: $state.extensionMonth, year: $state.extensionYearValue)
                PrimaryActionButton(title: "SAVE OFFICIAL EXTENSION DATE", systemImage: "checkmark.circle.fill") {
                    state.saveExtension()
                }
            }

            AppCard {
                Text("Retrieve Registered MOF Extensions")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(Color.navyPrimary)
                Text("Query and display the saved tax deadline extension for the selected category.")
                    .font(.system(size: 11))
                    .foregroundStyle(Color.slateTextLight)
                PrimaryActionButton(title: "INSTANTLY RETRIEVE & DISPLAY", systemImage: "arrow.clockwise") {
                    state.retrieveExtension()
                }
                if let message = state.extensionMessage {
                    Text(message)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(message.contains("No registered") || message.contains("لا توجد") ? Color.orange800 : Color.successGreen)
                        .padding(14)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(message.contains("No registered") || message.contains("لا توجد") ? Color.orange50 : Color.successGreenBg)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
            }
        }
    }

    private var extensionQuarterOptions: [(String, String)] {
        state.extensionTaxType == "VAT"
            ? [("Q1", "Q1"), ("Q2", "Q2"), ("Q3", "Q3"), ("Q4", "Q4")]
            : [("Q1", "Q1"), ("Q2", "Q2"), ("Q3", "Q3"), ("Q4", "Q4"), ("R5", "R5")]
    }
}

struct ContactCard: View {
    @EnvironmentObject private var state: AppState

    var body: some View {
        AppCard {
            HStack(spacing: 14) {
                BrandMark(size: 44)
                VStack(alignment: .leading, spacing: 4) {
                    Text(Copy.t("contact", state.language))
                        .font(.system(size: 13, weight: .black))
                        .foregroundStyle(Color.navyPrimary)
                    Text(Copy.t("contactSub", state.language))
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(Color.slateTextLight)
                    Text("Secure Audit Trails • MOF Progressive Index FY2024 • Decree 13264")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(Color.blueAccent)
                }
            }
        }
        .padding(.top, 4)
    }
}

struct ChildrenPicker: View {
    @EnvironmentObject private var state: AppState
    @Binding var count: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(Copy.t("children", state.language))
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(Color.slateTextLight)
            Text(Copy.t("childrenMax", state.language))
                .font(.system(size: 10))
                .foregroundStyle(Color.slateTextLight.opacity(0.8))
            HStack(spacing: 6) {
                ForEach(0...5, id: \.self) { number in
                    NumberCircle(number: number, isSelected: count == number) {
                        count = number
                    }
                }
            }
            .environment(\.layoutDirection, .leftToRight)
        }
    }
}

struct DateFields: View {
    var title: String
    @Binding var day: String
    @Binding var month: String
    @Binding var year: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(Color.slateTextLight)
            HStack(spacing: 10) {
                StyledTextField(title: "Day", placeholder: "15", suffix: nil, text: Binding(get: { day }, set: { day = String(sanitizedDigits($0).prefix(2)) }))
                StyledTextField(title: "Month", placeholder: "4", suffix: nil, text: Binding(get: { month }, set: { month = String(sanitizedDigits($0).prefix(2)) }))
                StyledTextField(title: "Year", placeholder: "2026", suffix: nil, text: Binding(get: { year }, set: { year = String(sanitizedDigits($0).prefix(4)) }))
            }
        }
    }
}

struct BracketRowView: View {
    var bracket: BracketAllocation
    var total: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(bracketTitle)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(Color.slateTextDark)
                Spacer()
                Text(lbp(bracket.taxInBracket))
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(bracket.taxInBracket > 0 ? Color.dangerRed : Color.slateTextLight)
            }
            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.slateBorder)
                    Capsule()
                        .fill(bracket.taxInBracket > 0 ? Color.blueAccent : Color.slateTextLight.opacity(0.3))
                        .frame(width: proxy.size.width * CGFloat(total > 0 ? min(bracket.amountInBracket / total, 1) : 0))
                }
            }
            .frame(height: 6)
            ResultRow(title: "Amount charged", value: lbp(bracket.amountInBracket))
        }
        .padding(10)
        .background(Color.slateLight)
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.slateBorder, lineWidth: 1))
    }

    private var bracketTitle: String {
        switch bracket.rate {
        case 0.04: "4% (0 - 540M)"
        case 0.07: "7% (540M - 1.44B)"
        case 0.12: "12% (1.44B - 3.24B)"
        case 0.16: "16% (3.24B - 6.24B)"
        case 0.21: "21% (6.24B - 13.5B)"
        case 0.25: "25% (Above 13.5B)"
        default: "\(Int(bracket.rate * 100))%"
        }
    }
}

struct WarningBox: View {
    var title: String
    var text: String

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "exclamationmark.triangle.fill")
            VStack(alignment: .leading, spacing: 3) {
                Text(title).font(.system(size: 12, weight: .black))
                Text(text).font(.system(size: 11))
            }
        }
        .foregroundStyle(Color.alertGold)
        .padding(13)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.alertGoldBg)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

struct SuccessBox: View {
    var title: String
    var text: String

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "checkmark.seal.fill")
            VStack(alignment: .leading, spacing: 3) {
                Text(title).font(.system(size: 12, weight: .black))
                Text(text).font(.system(size: 11))
            }
        }
        .foregroundStyle(Color.successGreen)
        .padding(13)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.successGreenBg)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

struct BrandMark: View {
    var size: CGFloat

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: size * 0.22, style: .continuous)
                .fill(LinearGradient(colors: [.navyPrimary, .blueAccent], startPoint: .topLeading, endPoint: .bottomTrailing))
            VStack(spacing: 0) {
                Text("H")
                    .font(.system(size: size * 0.42, weight: .black, design: .serif))
                Text("AUDIT")
                    .font(.system(size: size * 0.105, weight: .bold))
            }
            .foregroundStyle(Color.white)
        }
        .frame(width: size, height: size)
        .shadow(color: .blueAccent.opacity(0.28), radius: 18, y: 10)
    }
}

struct HeartRateLine: View {
    var body: some View {
        TimelineView(.animation) { timeline in
            let phase = timeline.date.timeIntervalSinceReferenceDate.truncatingRemainder(dividingBy: 2.2) / 2.2
            Canvas { context, size in
                var path = Path()
                let centerY = size.height / 2
                for index in 0...120 {
                    let ratio = Double(index) / 120.0
                    let x = ratio * size.width
                    let y = centerY + ecgOffset(ratio: ratio, height: size.height)
                    if index == 0 {
                        path.move(to: CGPoint(x: x, y: y))
                    } else {
                        path.addLine(to: CGPoint(x: x, y: y))
                    }
                }
                context.stroke(path, with: .color(.blueAccent.opacity(0.20)), style: StrokeStyle(lineWidth: 3, lineCap: .round))
                let highlightX = size.width * phase
                context.stroke(path, with: .linearGradient(
                    Gradient(colors: [.clear, .blueAccent.opacity(0.25), .blueAccent, .blueAccent.opacity(0.25), .clear]),
                    startPoint: CGPoint(x: highlightX - 120, y: 0),
                    endPoint: CGPoint(x: highlightX + 120, y: 0)
                ), style: StrokeStyle(lineWidth: 4, lineCap: .round))
            }
        }
    }

    private func ecgOffset(ratio: Double, height: CGFloat) -> CGFloat {
        switch ratio {
        case 0.36...0.40:
            return CGFloat(-sin((ratio - 0.36) / 0.04 * .pi) * 12)
        case 0.41...0.43:
            return CGFloat(((ratio - 0.41) / 0.02) * 15)
        case 0.43...0.46:
            return CGFloat(-((ratio - 0.43) / 0.03)) * height * 0.7
        case 0.46...0.49:
            let start = -height * 0.7
            let end = height * 0.35
            return start + CGFloat((ratio - 0.46) / 0.03) * (end - start)
        case 0.49...0.51:
            return height * 0.35 - CGFloat((ratio - 0.49) / 0.02) * height * 0.35
        case 0.53...0.59:
            return CGFloat(-sin((ratio - 0.53) / 0.06 * .pi) * 18)
        default:
            return 0
        }
    }
}

struct LanguageCard: View {
    var title: String
    var subtitle: String
    var code: String
    var selected: Bool
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 14) {
                Text(code)
                    .font(.system(size: 16, weight: .black))
                    .foregroundStyle(Color.white)
                    .frame(width: 48, height: 48)
                    .background(selected ? Color.blueAccent : Color.white.opacity(0.10))
                    .clipShape(Circle())
                Text(title)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(Color.white)
                Text(subtitle)
                    .font(.system(size: 11))
                    .foregroundStyle(Color.slateMuted)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .padding(20)
            .frame(maxWidth: .infinity)
            .background(selected ? Color.navyMedium.opacity(0.34) : Color.white.opacity(0.05))
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 20).stroke(selected ? Color.blueAccent : Color.white.opacity(0.15), lineWidth: selected ? 2 : 1))
        }
        .buttonStyle(.plain)
    }
}

struct ServiceSelectionCard: View {
    @EnvironmentObject private var state: AppState
    var tab: ServiceTab
    var color: Color
    var icon: String
    var action: () -> Void

    var body: some View {
        let meta = serviceMeta(tab, language: state.language)
        Button(action: action) {
            VStack(alignment: .leading, spacing: 14) {
                Image(systemName: icon)
                    .font(.system(size: 19, weight: .bold))
                    .foregroundStyle(Color.white)
                    .frame(width: 40, height: 40)
                    .background(LinearGradient(colors: [color, color.opacity(0.72)], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                Text(meta.title)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(Color.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                Text(meta.description)
                    .font(.system(size: 11))
                    .foregroundStyle(Color.slateMuted)
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)
            }
            .padding(16)
            .frame(maxWidth: .infinity, minHeight: 156, alignment: .leading)
            .background(Color.white.opacity(0.05))
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.white.opacity(0.12), lineWidth: 1))
        }
        .buttonStyle(.plain)
    }
}

struct TopBackButton: View {
    var action: () -> Void

    var body: some View {
        HStack {
            Button(action: action) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .black))
                    .foregroundStyle(Color.white)
                    .frame(width: 42, height: 42)
                    .background(Color.white.opacity(0.08))
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
            .padding(.leading, 16)
            .padding(.top, 16)
            Spacer()
        }
    }
}

func serviceMeta(_ tab: ServiceTab, language: AppLanguage) -> (title: String, description: String, icon: String, color: Color) {
    switch tab {
    case .payroll:
        return (Copy.t("payroll", language), language == .arabic ? "حساب الرواتب والضمان والشرائح" : "Calculate payroll runs, NSSF, and tax brackets", "banknote.fill", .blueAccent)
    case .profit:
        return (Copy.t("profit", language), language == .arabic ? "ضريبة أرباح الشركات والأفراد" : "Assess company net business profits and tax steps", "building.columns.fill", .successGreen)
    case .penalties:
        return (Copy.t("penalties", language), language == .arabic ? "غرامات التحقق والتحصيل" : "Breakdown fiscal late penalties and statutory fines", "exclamationmark.triangle.fill", .alertGold)
    case .extensions:
        return (Copy.t("extensions", language), language == .arabic ? "مهل تقديم التصاريح الممددة" : "Postponed legal filing deadlines and extensions", "calendar.badge.clock", Color(red: 0.925, green: 0.282, blue: 0.600))
    }
}
