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

/// Welcome screen. Intentionally English-only and LTR in every locale, matching
/// Android where `OnboardingWelcomeScreen` ignores the language argument.
struct WelcomeScreen: View {
    @EnvironmentObject private var state: AppState
    @State private var appeared = false
    @State private var heartbeat = false
    @State private var bgScale1 = false
    @State private var bgScale2 = false

    var body: some View {
        GeometryReader { geo in
            ZStack {
                LinearGradient(
                    colors: [Color(hex: 0x070B19), Color(hex: 0x0F172A), Color(hex: 0x1E293B)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                // Two slow breathing circles, matching Android's bg_pulse transition.
                Circle()
                    .fill(Color(hex: 0x3B82F6).opacity(0.08))
                    .frame(width: geo.size.width, height: geo.size.width)
                    .scaleEffect(bgScale1 ? 1.2 : 0.8)
                    .position(x: geo.size.width * 0.3, y: geo.size.height * 0.3)
                    .animation(.easeInOut(duration: 4).repeatForever(autoreverses: true), value: bgScale1)
                Circle()
                    .fill(Color(hex: 0x60A5FA).opacity(0.04))
                    .frame(width: geo.size.width * 0.9, height: geo.size.width * 0.9)
                    .scaleEffect(bgScale2 ? 0.9 : 1.2)
                    .position(x: geo.size.width * 0.7, y: geo.size.height * 0.6)
                    .animation(.easeInOut(duration: 5).repeatForever(autoreverses: true), value: bgScale2)

                VStack(spacing: 0) {
                    Spacer(minLength: 0)

                    WelcomeBrandLogo(size: 100)
                        .scaleEffect(heartbeat ? 1.15 : 0.9)
                        .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: heartbeat)
                        .opacity(appeared ? 1 : 0)
                        .scaleEffect(appeared ? 1 : 0.6)
                        .animation(.easeOut(duration: 0.7), value: appeared)

                    Spacer().frame(height: 32)

                    welcomeCard
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 30)
                        .animation(.easeOut(duration: 0.8).delay(0.2), value: appeared)

                    Spacer().frame(height: 40)

                    EnterButton { state.onboardingStep = 2 }
                        .frame(width: geo.size.width * 0.75)
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 30)
                        .animation(.easeOut(duration: 0.8).delay(0.5), value: appeared)

                    Spacer(minLength: 0)
                }
                .padding(.horizontal, 24)
                .frame(maxWidth: .infinity)
            }
        }
        .environment(\.layoutDirection, .leftToRight)
        .onAppear {
            appeared = true
            heartbeat = true
            bgScale1 = true
            bgScale2 = true
        }
    }

    private var welcomeCard: some View {
        VStack(spacing: 0) {
            // Forced onto exactly two lines: "Welcome to" / "Tax Pulse".
            VStack(spacing: 0) {
                Text("Welcome to")
                Text("Tax Pulse")
            }
            .font(.app(30, weight: .black))
            .kerning(0.5)
            .multilineTextAlignment(.center)
            .foregroundStyle(
                LinearGradient(
                    colors: [Color.white, Color(hex: 0x93C5FD), Color(hex: 0x2563EB)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .fixedSize(horizontal: false, vertical: true)

            Spacer().frame(height: 10)
            Text("Smarter tax simplified for you.")
                .font(.app(15, weight: .medium))
                .kerning(0.2)
                .foregroundStyle(Color(hex: 0x94A3B8))
                .multilineTextAlignment(.center)

            Spacer().frame(height: 24)
            HeartRateLine(color: Color(hex: 0x3B82F6))
                .frame(height: 96)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 12)

            Spacer().frame(height: 20)
            Rectangle()
                .fill(Color.white.opacity(0.15))
                .frame(width: 96, height: 1.5)

            Spacer().frame(height: 14)
            Text("Developed by Haddad Audit Firm")
                .font(.app(11, weight: .bold))
                .kerning(1)
                .foregroundStyle(Color(hex: 0x60A5FA).opacity(0.85))
                .multilineTextAlignment(.center)

            Spacer().frame(height: 4)
            Text("Certified Auditors and Tax Advisors")
                .font(.app(10))
                .kerning(0.5)
                .foregroundStyle(Color.white.opacity(0.6))
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 32)
        .frame(maxWidth: .infinity)
        .background(Color.white.opacity(0.03))
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.35), radius: 16, y: 8)
    }
}

struct EnterButton: View {
    var action: () -> Void
    @State private var pressed = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Text("ENTER")
                    .font(.app(16, weight: .heavy))
                    .kerning(1.5)
                Image(systemName: "arrow.right")
                    .font(.app(20, weight: .semibold))
            }
            .foregroundStyle(Color.white)
            .frame(maxWidth: .infinity)
            .frame(height: 58)
            .background(
                LinearGradient(
                    colors: [Color(hex: 0x1D4ED8), Color(hex: 0x2563EB), Color(hex: 0x3B82F6)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .shadow(color: Color(hex: 0x2563EB).opacity(0.45), radius: 12, y: 6)
        }
        .buttonStyle(.plain)
        .scaleEffect(pressed ? 0.94 : 1)
        .animation(.spring(response: 0.35, dampingFraction: 0.55), value: pressed)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in pressed = true }
                .onEnded { _ in pressed = false }
        )
        .accessibilityLabel("Enter")
    }
}

/// The circular brand mark used on the welcome screen — a direct port of Android's
/// `ic_launcher_foreground` vector (108×108 viewport) inside Android's glow circle.
struct WelcomeBrandLogo: View {
    var size: CGFloat

    var body: some View {
        ZStack {
            Circle()
                .fill(Color.white.opacity(0.03))
                .overlay(
                    Circle().stroke(
                        LinearGradient(
                            colors: [Color(hex: 0x3B82F6), Color(hex: 0x60A5FA).opacity(0.5)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
                )
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color(hex: 0x3B82F6).opacity(0.4), Color.clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: size * 0.36
                    )
                )
                .frame(width: size * 0.72, height: size * 0.72)
            TPPulseMark()
                .frame(width: size * 0.52, height: size * 0.52)
        }
        .frame(width: size, height: size)
        .accessibilityLabel("Tax Pulse logo")
    }
}

/// Vector "TP + ECG" mark, coordinates taken 1:1 from Android's launcher foreground.
struct TPPulseMark: View {
    var body: some View {
        Canvas { context, size in
            let s = min(size.width, size.height) / 108.0
            func p(_ x: CGFloat, _ y: CGFloat) -> CGPoint { CGPoint(x: x * s, y: y * s) }

            context.fill(
                Path(ellipseIn: CGRect(x: 16 * s, y: 16 * s, width: 76 * s, height: 76 * s)),
                with: .color(Color(hex: 0x0284C7).opacity(0.10))
            )

            var t = Path()
            t.move(to: p(24, 40)); t.addLine(to: p(48, 40))
            t.move(to: p(36, 40)); t.addLine(to: p(36, 68))
            context.stroke(t, with: .color(.white),
                           style: StrokeStyle(lineWidth: 7 * s, lineCap: .round, lineJoin: .round))

            var pp = Path()
            pp.move(to: p(58, 40)); pp.addLine(to: p(58, 68))
            pp.move(to: p(58, 40)); pp.addLine(to: p(68, 40))
            pp.addCurve(to: p(68, 54), control1: p(74, 40), control2: p(74, 54))
            pp.addLine(to: p(58, 54))
            context.stroke(pp, with: .color(Color(hex: 0x38BDF8)),
                           style: StrokeStyle(lineWidth: 7 * s, lineCap: .round, lineJoin: .round))

            var ecg = Path()
            ecg.move(to: p(18, 78))
            ecg.addLine(to: p(38, 78))
            ecg.addLine(to: p(44, 58))
            ecg.addLine(to: p(50, 90))
            ecg.addLine(to: p(56, 78))
            ecg.addLine(to: p(90, 78))
            context.stroke(ecg, with: .color(Color(hex: 0x38BDF8)),
                           style: StrokeStyle(lineWidth: 5 * s, lineCap: .round, lineJoin: .round))
        }
    }
}

struct LanguageScreen: View {
    @EnvironmentObject private var state: AppState

    var body: some View {
        VStack(spacing: 0) {
            TopBackButton { state.onboardingStep = 1 }
            // A small fixed gap (rather than a flexible Spacer) so the title and
            // cards begin higher on screen, matching Android — only the trailing
            // Spacer is flexible, absorbing the remaining space at the bottom.
            Spacer().frame(height: 24)
            Image(systemName: "globe")
                .font(.app(52, weight: .regular))
                .foregroundStyle(Color(hex: 0x60A5FA))
                .frame(height: 64)
                .padding(.bottom, 16)
            Text(state.language == .arabic ? "اختر لغتك المفضلة" : "Choose the language")
                .font(.app(24, weight: .heavy))
                .foregroundStyle(Color.white)
                .multilineTextAlignment(.center)
            Text(state.language == .arabic ? "يمكنك تغيير هذا الخيار لاحقاً في أي وقت" : "You can change this anytime later")
                .font(.app(14))
                .foregroundStyle(Color(hex: 0x94A3B8))
                .multilineTextAlignment(.center)
                .padding(.top, 8)
                .padding(.bottom, 40)

            // English is always physically LEFT and Arabic always RIGHT, in both
            // locales, so the row is pinned to LTR regardless of the app direction.
            HStack(spacing: 16) {
                LanguageCard(title: "English", subtitle: "Smarter tax simplified", code: "EN", selected: state.language == .english) {
                    state.language = .english
                    state.onboardingStep = 3
                }
                LanguageCard(title: "العربية", subtitle: "الضرائب الذكية مبسطة لأجلك", code: "AR", selected: state.language == .arabic) {
                    state.language = .arabic
                    state.onboardingStep = 3
                }
            }
            .environment(\.layoutDirection, .leftToRight)
            Spacer()
        }
        .padding(.horizontal, 24)
    }
}

struct ServiceScreen: View {
    @EnvironmentObject private var state: AppState

    var body: some View {
        VStack(spacing: 0) {
            TopBackButton { state.onboardingStep = 2 }
            Spacer()
            Text(state.language == .arabic ? "اختر نوع الخدمة المطلوبة" : "Choose your service")
                .font(.app(24, weight: .heavy))
                .foregroundStyle(Color.white)
                .multilineTextAlignment(.center)
            Text(state.language == .arabic ? "انقر على إحدى الخدمات للبدء الفوري بحساباتك" : "Select a service below to jump straight in")
                .font(.app(13))
                .foregroundStyle(Color(hex: 0x94A3B8))
                .multilineTextAlignment(.center)
                .padding(.top, 8)
                .padding(.bottom, 32)

            // The 2x2 service grid keeps the same physical arrangement in Arabic as in
            // English (payroll top-left … extensions bottom-right), so it is pinned LTR.
            VStack(spacing: 16) {
                HStack(spacing: 16) {
                    ServiceSelectionCard(tab: .payroll) { state.chooseService(.payroll) }
                    ServiceSelectionCard(tab: .profit) { state.chooseService(.profit) }
                }
                HStack(spacing: 16) {
                    ServiceSelectionCard(tab: .penalties) { state.chooseService(.penalties) }
                    ServiceSelectionCard(tab: .extensions) { state.chooseService(.extensions) }
                }
            }
            .environment(\.layoutDirection, .leftToRight)
            Spacer()
        }
        .padding(.horizontal, 24)
    }
}

struct CalculatorShell: View {
    @EnvironmentObject private var state: AppState

    var body: some View {
        ZStack {
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
            .scrollDismissesKeyboard(.interactively)
            // Android dismisses the keyboard on any tap outside a field; mirror that
            // without swallowing taps on the controls themselves.
            .simultaneousGesture(
                TapGesture().onEnded {
                    UIApplication.shared.sendAction(
                        #selector(UIResponder.resignFirstResponder),
                        to: nil, from: nil, for: nil
                    )
                }
            )

            // Branded modal host — year restriction, extension same-date warning,
            // extension saved. Mounted once here so any tab can trigger it.
            AppModalHost()
        }
    }
}

struct HeaderView: View {
    @EnvironmentObject private var state: AppState

    var body: some View {
        HStack(spacing: 10) {
            VStack(alignment: .leading, spacing: 3) {
                Text(Copy.t("headerTitle", state.language))
                    .font(.app(18, weight: .black))
                    .foregroundStyle(Color.navyPrimary)
                Text(Copy.t("byHaddad", state.language))
                    .font(.app(12, weight: .bold))
                    .foregroundStyle(Color.navyMedium)
                    .lineLimit(1)
                Text(Copy.t("subtitle", state.language))
                    .font(.app(10, weight: .bold))
                    .foregroundStyle(Color.blueAccent)
                    .lineLimit(1)
            }
            Spacer()
            LanguageSegmentedControl(selected: state.language.rawValue) { key in
                state.language = key == "AR" ? .arabic : .english
            }
        }
    }
}

struct ActiveServiceBanner: View {
    @EnvironmentObject private var state: AppState

    var body: some View {
        let meta = serviceMeta(state.selectedTab, language: state.language)
        HStack(spacing: 12) {
            Image(systemName: meta.icon)
                .font(.app(17, weight: .bold))
                .foregroundStyle(Color.white)
                .frame(width: 36, height: 36)
                .background(meta.color)
                .clipShape(Circle())
            VStack(alignment: .leading, spacing: 3) {
                Text(Copy.t("activeService", state.language))
                    .font(.app(11, weight: .bold))
                    .foregroundStyle(Color.slateTextLight)
                Text(meta.title)
                    .font(.app(15, weight: .black))
                    .foregroundStyle(Color.navyPrimary)
            }
            Spacer()
            Button(Copy.t("changeService", state.language)) {
                state.onboardingStep = 3
            }
            .font(.app(12, weight: .black))
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
            if !state.debugResultOnly {
            SectionIntro(
                title: Copy.t("payrollIntroTitle", state.language),
                bodyText: Copy.t("payrollIntroBody", state.language)
            )

            AppCard {
                HStack {
                    Text(Copy.t("payroll", state.language))
                        .font(.app(14, weight: .bold))
                        .foregroundStyle(Color.navyPrimary)
                    Spacer()
                    PillButton(title: Copy.t("reset", state.language), systemImage: "arrow.clockwise") {
                        isCalculated = false
                        state.resetPayroll()
                    }
                }

                Text(Copy.t("salaryPeriod", state.language))
                    .font(.app(11, weight: .bold))
                    .foregroundStyle(Color.slateTextLight)
                HorizontalToggleRow(options: [("MONTHLY", Copy.t("monthly", state.language)), ("ANNUAL", Copy.t("annual", state.language))], selected: state.salaryPeriod.rawValue) {
                    state.salaryPeriod = $0 == "ANNUAL" ? .annual : .monthly
                    isCalculated = false
                }

                Text(Copy.t("currency", state.language))
                    .font(.app(11, weight: .bold))
                    .foregroundStyle(Color.slateTextLight)
                HorizontalToggleRow(options: [("LBP", Copy.t("lbp", state.language)), ("USD", Copy.t("usd", state.language))], selected: state.payrollCurrency.rawValue) {
                    state.payrollCurrency = $0 == "USD" ? .usd : .lbp
                    isCalculated = false
                }

                if state.payrollCurrency == .lbp {
                    StyledTextField(title: state.salaryPeriod == .annual ? Copy.t("annualSalaryLbp", state.language) : Copy.t("basicSalaryLbp", state.language), placeholder: state.salaryPeriod == .annual ? Copy.t("enterAnnualSalary", state.language) : Copy.t("enterMonthlySalary", state.language), suffix: state.language == .arabic ? "ل.ل" : "LBP", text: Binding(get: { state.payrollGrossLbp }, set: { state.payrollGrossLbp = sanitizedDigits($0); isCalculated = false }), leadingSystemImage: "creditcard.fill", textAlignment: state.language == .arabic ? .right : .left)
                    CurrentValueLine(
                        label: Copy.t("currentValue", state.language),
                        amount: Double(state.payrollGrossLbp) ?? 0,
                        language: state.language,
                        color: (Double(state.payrollGrossLbp) ?? 0) > 0 ? Color.successGreen : Color.slateTextLight
                    )
                } else {
                    StyledTextField(title: state.salaryPeriod == .annual ? Copy.t("annualSalaryUsd", state.language) : Copy.t("monthlyUsd", state.language), placeholder: state.salaryPeriod == .annual ? Copy.t("enterAnnualSalary", state.language) : Copy.t("enterMonthlySalary", state.language), suffix: "USD", text: Binding(get: { state.payrollGrossUsd }, set: { state.payrollGrossUsd = sanitizedDecimal($0); isCalculated = false }), decimal: true, leadingSystemImage: "creditcard.fill", textAlignment: state.language == .arabic ? .right : .left)
                    StyledTextField(title: Copy.t("customRate", state.language), placeholder: Copy.t("enterExchangeRate", state.language), suffix: state.language == .arabic ? "ل.ل/$" : "LBP/USD", text: Binding(get: { state.payrollExchangeRate }, set: { state.payrollExchangeRate = sanitizedDecimal($0); isCalculated = false }), decimal: true, textAlignment: state.language == .arabic ? .right : .left)
                    BorderedPillButton(title: Copy.t("useStandardRate", state.language)) {
                        state.payrollExchangeRate = "89500"
                        isCalculated = false
                    }
                    // The equivalent LBP gross stays hidden until a rate is actually
                    // supplied — either typed or via "Use Standard Rate". Entering only
                    // a USD salary shows the prompt instead of an implied conversion.
                    if state.payrollExchangeRate.isEmpty {
                        if (Double(state.payrollGrossUsd) ?? 0) > 0 {
                            Text(Copy.t("putRateWarning", state.language))
                                .font(.app(12, weight: .medium))
                                .foregroundStyle(Color.dangerRed)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    } else {
                        Text("\(Copy.t("equivalentLbp", state.language)) \(money(result: state.payrollBasicSalaryLbpValue, language: state.language))")
                            .font(.app(11, weight: .medium))
                            .foregroundStyle(state.payrollBasicSalaryLbpValue > 0 ? Color.successGreen : Color.slateTextLight)
                    }
                }

                MaritalStatusSelector(language: state.language, selected: state.payrollMarital.rawValue) {
                    state.payrollMarital = MaritalStatus(rawValue: $0) ?? .single
                    if state.payrollMarital == .single { state.payrollChildren = 0 }
                    isCalculated = false
                }

                if state.payrollMarital != .single {
                    ChildrenPicker(count: Binding(
                        get: { state.payrollChildren },
                        set: { state.payrollChildren = $0; isCalculated = false }
                    ))
                }

                AndroidToggleCard(icon: "shield.fill", title: Copy.t("nssfReg", state.language), subtitle: nil, isOn: Binding(
                    get: { state.isNssfRegistered },
                    set: { state.isNssfRegistered = $0; isCalculated = false }
                ))
                AndroidToggleCard(icon: "person.2.fill", title: Copy.t("familyRebates", state.language), subtitle: Copy.t("familyRebatesSub", state.language), isOn: Binding(
                    get: { state.useFamilyRebates },
                    set: { state.useFamilyRebates = $0; isCalculated = false }
                ))

                if state.salaryPeriod == .annual {
                    Text(Copy.t("annualNssfCeiling", state.language))
                        .font(.app(11, weight: .bold))
                        .foregroundStyle(Color.slateTextLight)
                    StyledTextField(title: Copy.t("annualSicknessCeiling", state.language), placeholder: Copy.t("optional", state.language), suffix: state.language == .arabic ? "ل.ل" : "LBP", text: Binding(get: { state.sicknessCeilingOverride }, set: { state.sicknessCeilingOverride = sanitizedDigits($0); isCalculated = false }))
                    StyledTextField(title: Copy.t("annualFamilyCeiling", state.language), placeholder: Copy.t("optional", state.language), suffix: state.language == .arabic ? "ل.ل" : "LBP", text: Binding(get: { state.familyCeilingOverride }, set: { state.familyCeilingOverride = sanitizedDigits($0); isCalculated = false }))
                    InfoNoteBox(text: Copy.t("annualNssfNote", state.language))
                }
            }

            }

            // Android blocks the CTA until the salary — and, in USD mode, the exchange
            // rate — are both present, so the results can never be built from an
            // implied rate.
            if !isPayrollInputIncomplete && !isCalculated {
                AnimatedCalculateButton(title: Copy.t("payrollCalculateShort", state.language)) {
                    isCalculated = true
                }
                // The two Android placeholder cards that sit under the button before
                // a result exists: a plain instruction card, then the "ready" state card.
                CenteredInfoCard(text: Copy.t("payrollPlaceholderInfo", state.language))
                CenteredInfoCard(
                    title: Copy.t("readyTitle", state.language),
                    text: Copy.t("readyDesc", state.language)
                )
            }

            if isCalculated || state.debugPreCalculated {
                PayrollResultCard(result: state.payrollResult)
            }
        }
    }

    /// Mirrors Android's `isInputIncomplete` gate for the payroll CTA.
    private var isPayrollInputIncomplete: Bool {
        if state.payrollCurrency == .usd {
            return state.payrollGrossUsd.isEmpty
                || (Double(state.payrollGrossUsd) ?? 0) == 0
                || state.payrollExchangeRate.isEmpty
                || (Double(state.payrollExchangeRate) ?? 0) == 0
        }
        return state.payrollGrossLbp.isEmpty || (Double(state.payrollGrossLbp) ?? 0) == 0
    }
}

struct PayrollResultCard: View {
    @EnvironmentObject private var state: AppState
    var result: PayrollItem

    var body: some View {
        AppCard {
            Text(Copy.t("complianceSummary", state.language))
                .font(.app(15, weight: .black))
                .foregroundStyle(Color.navyPrimary)

            VStack(spacing: 8) {
                Text(state.salaryPeriod == .annual ? (state.language == .arabic ? "صافي الراتب السنوي للقبض" : "ANNUAL NET TO BE CASHED") : Copy.t("netWithFamily", state.language).uppercased())
                    .font(.app(12, weight: .black))
                    .foregroundStyle(Color.navyPrimary)
                    .multilineTextAlignment(.center)
                Text(money(result: result.netSalary, language: state.language))
                    .font(.app(26, weight: .black))
                    .foregroundStyle(Color.successGreen)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                    // Sign + digits + currency must render as one bidi-safe unit —
                    // RTL context must never split "ل.ل" onto another line/position.
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .environment(\.layoutDirection, .leftToRight)
                // Android shows this approximate USD line only when the salary was
                // originally entered in USD, using the same rate the user supplied.
                if state.payrollCurrency == .usd {
                    let rate = Double(state.payrollExchangeRate) ?? 89_500
                    if rate > 0 {
                        Text(Copy.t("approxUsdEquivalent", state.language)
                            .replacingOccurrences(of: "%@", with: usdAmountText(result.netSalary / rate)))
                            .font(.app(12, weight: .bold))
                            .foregroundStyle(Color.slateTextDark)
                            .environment(\.layoutDirection, .leftToRight)
                    }
                }
                Text(Copy.t("basedOnEmployee", state.language))
                    .font(.app(11, weight: .medium))
                    .foregroundStyle(Color.slateTextDark)
            }
            .frame(maxWidth: .infinity)
            .padding(16)
            .background(Color.slateLight)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.slateBorder, lineWidth: 1))

            ResultRow(
                title: state.salaryPeriod == .annual ? Copy.t("annualGrossSalary", state.language) : Copy.t("baseMonthly", state.language),
                value: money(result: result.basicSalary, language: state.language),
                isBold: true,
                titleFontSize: state.salaryPeriod == .annual ? 12 : 14
            )
            TaxHighlightRow(title: state.salaryPeriod == .annual ? (state.language == .arabic ? "ضريبة الرواتب السنوية" : "Annual Salary Income Tax") : Copy.t("mofTax", state.language), value: signedMoney(result.taxAmount, isDeduction: true, language: state.language), hasTax: result.taxAmount > 0)
            ResultRow(title: state.salaryPeriod == .annual ? (state.language == .arabic ? "الضمان الصحي السنوي (الموظف)" : "Annual Sickness & Maternity NSSF") : Copy.t("sicknessNssf", state.language), value: signedMoney(result.sicknessMaternityEmployee, isDeduction: true, language: state.language), valueColor: result.sicknessMaternityEmployee > 0 ? .dangerRed : .slateTextDark)
            ResultRow(title: state.salaryPeriod == .annual ? (state.language == .arabic ? "التعويضات السنوية العائلية" : "Annual Family Allowances") : Copy.t("familyAllowances", state.language), value: signedMoney(result.totalFamilyBenefitsAmount, isDeduction: false, language: state.language), valueColor: result.totalFamilyBenefitsAmount > 0 ? .successGreen : .slateTextDark)
            // "Taxable Salary After Rebates" is intentionally NOT surfaced here. The
            // value is still computed by the engine (`result.taxableSalary`) and feeds
            // the tax calculation — it is only hidden from the summary.
            // This card renders for both periods. The manual override fields only
            // exist in the annual section of the form, so they only apply there —
            // annual's default is the latest approved monthly ceiling annualized
            // (not tied to `payrollMonth`), matching PayrollEngine's annual default.
            // Monthly has no override UI, so it mirrors PayrollEngine's monthly
            // default exactly (the same Jan–Jul/Aug–Dec tiered ceiling the engine
            // already used to compute `result`), instead of the annual figure.
            let lawConfig = LawConfig()
            let sicknessCeiling = state.salaryPeriod == .annual
                ? (Double(state.sicknessCeilingOverride) ?? (120_000_000.0 * 12.0))
                : (state.payrollMonth <= 7 ? lawConfig.nssfSicknessCeilingJanJul : lawConfig.nssfSicknessCeilingAugDec)
            let familyCeiling = state.salaryPeriod == .annual
                ? (Double(state.familyCeilingOverride) ?? (28_000_000.0 * 12.0))
                : (state.payrollMonth <= 6 ? lawConfig.nssfFamilyCeilingJanJul : lawConfig.nssfFamilyCeilingAugDec)
            Text(Copy.t("nssfBranches", state.language))
                .font(.app(14, weight: .black))
                .foregroundStyle(Color.navyPrimary)
                .padding(.top, 8)
            NssfBranchCard(
                title: Copy.t("sicknessBranch", state.language),
                mainAmount: result.sicknessMaternityEmployee + result.sicknessMaternityEmployer,
                base: result.sicknessMaternityBase,
                ratio: sicknessCeiling > 0 ? result.sicknessMaternityBase / sicknessCeiling : 0,
                barColor: (result.sicknessMaternityEmployee + result.sicknessMaternityEmployer) > 0 ? .blueAccent : Color.slateTextLight.opacity(0.3),
                baseLabel: Copy.t("subjectBaseSickness", state.language),
                ceilingLabel: Copy.t("ceilingSickness", state.language),
                ceilingValue: money(result: sicknessCeiling, language: state.language),
                ceilingValueColor: .slateTextDark,
                employeeLabel: Copy.t("empContrib3", state.language),
                employee: result.sicknessMaternityEmployee,
                employerLabel: Copy.t("emprContrib8", state.language),
                employer: result.sicknessMaternityEmployer,
                language: state.language
            )
            NssfBranchCard(
                title: Copy.t("familyBranchNumbered", state.language),
                mainAmount: result.familyAllowanceEmployer,
                base: result.familyAllowanceBase,
                ratio: familyCeiling > 0 ? result.familyAllowanceBase / familyCeiling : 0,
                barColor: result.familyAllowanceEmployer > 0 ? .blueAccent : Color.slateTextDark.opacity(0.3),
                baseLabel: Copy.t("subjectBaseFamily", state.language),
                ceilingLabel: Copy.t("ceilingFamily", state.language),
                ceilingValue: money(result: familyCeiling, language: state.language),
                ceilingValueColor: .slateTextDark,
                employeeLabel: Copy.t("empContrib0", state.language),
                employee: 0,
                employerLabel: Copy.t("emprContrib6", state.language),
                employer: result.familyAllowanceEmployer,
                language: state.language
            )
            NssfBranchCard(
                title: Copy.t("endServiceBranch", state.language),
                mainAmount: result.endOfServiceEmployer,
                base: result.endOfServiceBase,
                ratio: 1,
                barColor: result.endOfServiceEmployer > 0 ? .successGreen : Color.slateTextLight.opacity(0.3),
                baseLabel: Copy.t("subjectBase", state.language),
                ceilingLabel: Copy.t("ceilingLimit", state.language),
                ceilingValue: Copy.t("fullWageNoCeiling", state.language),
                ceilingValueColor: .successGreen,
                employeeLabel: Copy.t("empContrib0", state.language),
                employee: 0,
                employerLabel: Copy.t("emprContrib85", state.language),
                employer: result.endOfServiceEmployer,
                language: state.language
            )

            EmployerCostBox(result: result, language: state.language)

            if result.hasMinimumWageWarning {
                // Android hard-codes these figures per language, with Arabic-Indic
                // digits and a trailing period in Arabic.
                let wage: String = {
                    if state.language == .arabic {
                        return state.payrollMonth <= 7
                            ? "١٨,٠٠٠,٠٠٠ ل.ل."
                            : "٢٨,٠٠٠,٠٠٠ ل.ل."
                    }
                    return state.payrollMonth <= 7 ? "18,000,000 LBP" : "28,000,000 LBP"
                }()
                ComplianceBanner(
                    systemImage: "exclamationmark.triangle.fill",
                    title: Copy.t("warningCount", state.language),
                    text: Copy.t("warningDesc", state.language).replacingOccurrences(of: "%@", with: wage),
                    color: .alertGold,
                    background: .alertGoldBg
                )
            } else {
                ComplianceBanner(
                    systemImage: "checkmark.seal.fill",
                    title: Copy.t("secureCount", state.language),
                    text: Copy.t("secureDesc", state.language),
                    color: .successGreen,
                    background: .successGreenBg
                )
            }
        }
    }
}

struct ProfitCalculatorTab: View {
    @EnvironmentObject private var state: AppState
    @State private var isCalculated = false

    var body: some View {
        VStack(spacing: 16) {
            if !state.debugResultOnly {
            SectionIntro(title: Copy.t("profitIntroTitle", state.language), bodyText: Copy.t("profitIntroBody", state.language))

            AppCard {
                HStack {
                    Text(Copy.t("profit", state.language))
                        .font(.app(14, weight: .bold))
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

                Text(Copy.t("selectCurrency", state.language))
                    .font(.app(11, weight: .bold))
                    .foregroundStyle(Color.slateTextLight)
                // Side-by-side segmented control, matching Android and the payroll tab —
                // never a vertical stack.
                HorizontalToggleRow(options: [("LBP", Copy.t("lbp", state.language)), ("USD", Copy.t("usd", state.language))], selected: state.profitCurrency.rawValue) {
                    state.profitCurrency = $0 == "USD" ? .usd : .lbp
                    isCalculated = false
                }

                if state.profitCurrency == .lbp {
                    StyledTextField(title: "\(Copy.t("annualNetProfit", state.language)) \(state.language == .arabic ? "(ل.ل)" : "(LBP)")", placeholder: Copy.t("enterAnnualNetProfit", state.language), suffix: state.language == .arabic ? "ل.ل" : "LBP", text: Binding(get: { state.profitGrossLbp }, set: { state.profitGrossLbp = sanitizedDigits($0); isCalculated = false }), trailingSystemImage: "chart.line.uptrend.xyaxis", trailingColor: .successGreen, textAlignment: state.language == .arabic ? .right : .left)
                } else {
                    StyledTextField(title: "\(Copy.t("annualNetProfit", state.language)) \(state.language == .arabic ? "(دولار)" : "(USD)")", placeholder: Copy.t("enterAnnualNetProfit", state.language), suffix: "USD", text: Binding(get: { state.profitGrossUsd }, set: { state.profitGrossUsd = sanitizedDecimal($0); isCalculated = false }), decimal: true, trailingSystemImage: "chart.line.uptrend.xyaxis", trailingColor: .successGreen, textAlignment: state.language == .arabic ? .right : .left)
                    StyledTextField(title: Copy.t("customRate", state.language), placeholder: Copy.t("enterExchangeRate", state.language), suffix: state.language == .arabic ? "ل.ل/$" : "LBP/$", text: Binding(get: { state.profitExchangeRate }, set: { state.profitExchangeRate = sanitizedDecimal($0); isCalculated = false }), decimal: true, textAlignment: state.language == .arabic ? .right : .left)
                    BorderedPillButton(title: Copy.t("useStandardRate", state.language)) {
                        state.profitExchangeRate = "89500"
                        isCalculated = false
                    }
                    if state.profitExchangeRate.isEmpty {
                        if (Double(state.profitGrossUsd) ?? 0) > 0 {
                            Text(Copy.t("putRateWarning", state.language))
                                .font(.app(12, weight: .medium))
                                .foregroundStyle(Color.dangerRed)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    } else {
                        let usdAmount = Double(state.profitGrossUsd) ?? 0
                        let rate = Double(state.profitExchangeRate) ?? 0
                        Text("\(Copy.t("equivalentLbp", state.language)) \(money(result: usdAmount * rate, language: state.language))")
                            .font(.app(11, weight: .medium))
                            .foregroundStyle(usdAmount * rate > 0 ? Color.successGreen : Color.slateTextLight)
                    }
                }

                MaritalStatusSelector(language: state.language, selected: state.profitMarital.rawValue) {
                    state.profitMarital = MaritalStatus(rawValue: $0) ?? .single
                    if state.profitMarital == .single { state.profitChildren = 0 }
                    isCalculated = false
                }

                if state.profitMarital != .single {
                    ChildrenPicker(count: Binding(
                        get: { state.profitChildren },
                        set: { state.profitChildren = $0; isCalculated = false }
                    ))
                }
            }

            }

            if state.profitMarital == .spouseWorks && state.profitChildren > 0 {
                WarningBox(title: "", text: Copy.t("splitWarning", state.language))
            }

            if hasProfitInput && !isCalculated {
                AnimatedCalculateButton(title: Copy.t("calculateProfitTaxBtn", state.language)) { isCalculated = true }
            }

            if isCalculated || state.debugPreCalculated {
                ProfitResultCard(result: state.profitResult)
            }
        }
    }

    private var hasProfitInput: Bool {
        state.profitCurrency == .lbp ? !state.profitGrossLbp.isEmpty : !state.profitGrossUsd.isEmpty
    }
}

struct ProfitResultCard: View {
    @EnvironmentObject private var state: AppState
    var result: ProfitTaxResult

    var body: some View {
        AppCard {
            VStack(alignment: .leading, spacing: 3) {
                Text(Copy.t("profitSummary", state.language))
                    .font(.app(14, weight: .black))
                    .foregroundStyle(Color.navyPrimary)
                Text(Copy.t("profitDisclaimer", state.language))
                    .font(.app(10, weight: .medium))
                    .foregroundStyle(Color.slateTextLight)
            }

            VStack(spacing: 8) {
                Text(Copy.t("totalTaxDue", state.language))
                    .font(.app(11, weight: .bold))
                    .foregroundStyle(Color.slateTextDark)
                Text(money(result: result.totalTaxDue, language: state.language))
                    .font(.app(25, weight: .black))
                    .foregroundStyle(Color(red: 0.761, green: 0.063, blue: 0.063))
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .environment(\.layoutDirection, .leftToRight)
                Divider()
                Text(Copy.t("remainingNetProfit", state.language))
                    .font(.app(11, weight: .bold))
                    .foregroundStyle(Color.slateTextDark)
                Text(money(result: result.netNetProfit, language: state.language))
                    .font(.app(18, weight: .black))
                    .foregroundStyle(Color.successGreen)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .environment(\.layoutDirection, .leftToRight)
            }
            .frame(maxWidth: .infinity)
            .padding(16)
            .background(Color.slateLight)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.slateBorder, lineWidth: 1))

            Text(Copy.t("totalFamilyRebates", state.language))
                .font(.app(12, weight: .bold))
                .foregroundStyle(Color.navyPrimary)
            ResultRow(title: Copy.t("rebateHimself", state.language), value: money(result: result.himselfRebate, language: state.language))
            // Gate on the selected marital status, not on the amount: a working
            // spouse legitimately yields a 0 rebate, and the row must still be shown
            // carrying the user's selected spouse status. Statuses with no spouse
            // (single / divorced / widowed) show no row at all.
            if state.profitMarital == .spouseDependent || state.profitMarital == .spouseWorks {
                ResultRow(
                    title: spouseRebateTitle(status: state.profitMarital, language: state.language),
                    value: money(result: result.spouseRebate, language: state.language)
                )
            }
            // Always shown, including "× 0", so the max-5 allowance and the currently
            // selected count are both always visible.
            ResultRow(
                title: childRebateTitle(count: state.profitChildren, language: state.language),
                value: money(result: result.childrenRebate, language: state.language)
            )
            Divider()
            ResultRow(title: Copy.t("totalAnnualDeductibleRebate", state.language), value: money(result: result.totalRebates, language: state.language), valueColor: .navyPrimary, isBold: true)
            ResultRow(title: Copy.t("taxableProfitAfterRebates", state.language), value: money(result: result.profitAfterRebates, language: state.language), isBold: true)

            Text(Copy.t("profitBracketsDetail", state.language))
                .font(.app(12, weight: .bold))
                .foregroundStyle(Color.navyPrimary)
                .padding(.top, 8)
            ForEach(result.bracketAllocations) { bracket in
                BracketRowView(bracket: bracket, total: result.profitAfterRebates, language: state.language)
            }
        }
    }
}

struct PenaltiesCalculatorTab: View {
    @EnvironmentObject private var state: AppState
    @State private var isCalculated = false

    var body: some View {
        VStack(spacing: 16) {
            if !state.debugResultOnly {
            SectionIntro(title: Copy.t("penaltiesIntroTitle", state.language), bodyText: Copy.t("penaltiesIntroBody", state.language))

            AppCard {
                HStack {
                    Text(Copy.t("penaltiesIntroTitle", state.language))
                        .font(.app(14, weight: .bold))
                        .foregroundStyle(Color.navyPrimary)
                    Spacer()
                    PillButton(title: Copy.t("reset", state.language), systemImage: "arrow.clockwise") {
                        state.resetPenalties()
                        isCalculated = false
                    }
                }

                Text(Copy.t("taxTypeLabel", state.language))
                    .font(.app(11, weight: .bold))
                    .foregroundStyle(Color.slateTextLight)
                    .frame(maxWidth: .infinity, alignment: .leading)
                HorizontalToggleRow(options: [("PAYROLL", Copy.t("payrollTax", state.language)), ("PROFIT", Copy.t("profit", state.language)), ("VAT", Copy.t("vatPenalties", state.language))], selected: state.penaltyTaxType) {
                    state.penaltyTaxType = $0
                    // VAT has no annual R5 period; Android snaps back to Q1.
                    if $0 == "VAT" && state.penaltyQuarter == "R5" { state.penaltyQuarter = "Q1" }
                    state.syncPenaltyDueDate()
                    isCalculated = false
                }

                Text(Copy.t("companyTaxpayerType", state.language))
                    .font(.app(11, weight: .bold))
                    .foregroundStyle(Color.slateTextLight)
                    .frame(maxWidth: .infinity, alignment: .leading)
                SelectableCardGrid(options: penaltyCompanyOptions, selected: state.penaltyCompanyType) {
                    state.penaltyCompanyType = $0
                    state.syncPenaltyDueDate()
                    isCalculated = false
                }

                // Auditor-report note: profit tax only, and only for the entity types
                // that must file a statutory auditor's report.
                if state.penaltyTaxType == "PROFIT",
                   ["SAL", "SARL", "PARTNERSHIP"].contains(state.penaltyCompanyType) {
                    InfoNoteBox(
                        text: Copy.t("corporateNote", state.language),
                        fontSize: 10.5,
                        background: Color.slate50,
                        borderColor: Color.slateBorder.opacity(0.5)
                    )
                }

                StyledTextField(title: Copy.t("taxAmount", state.language), placeholder: Copy.t("enterTaxAmount", state.language), suffix: state.language == .arabic ? "ل.ل" : "LBP", text: Binding(get: { state.penaltyAmount }, set: { state.penaltyAmount = sanitizedDigits($0); isCalculated = false }), textAlignment: state.language == .arabic ? .right : .left)
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "info.circle.fill")
                        .foregroundStyle(Color.orange800)
                    Text(Copy.t("zeroTaxNote", state.language))
                        .font(.app(11, weight: .bold))
                        .foregroundStyle(Color.orange800)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(10)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.orange50)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.orange100, lineWidth: 1))
                Text("\(Copy.t("currentValueLower", state.language)) \(money(result: Double(state.penaltyAmount) ?? 0, language: state.language))")
                    .font(.app(11, weight: .medium))
                    .foregroundStyle(Color.slateTextLight)

                if state.penaltyTaxType == "PAYROLL" || state.penaltyTaxType == "VAT" {
                    YearPickerField(
                        title: Copy.t("year", state.language),
                        year: Binding(
                            get: { state.penaltyPayrollYear },
                            set: {
                                state.updatePenaltyFiscalYear($0)
                                isCalculated = false
                            }
                        ),
                        years: state.selectablePenaltyYears
                    )
                    CompactOptionRow(options: penaltyQuarterOptions, selected: state.penaltyQuarter) {
                        state.penaltyQuarter = $0
                        state.syncPenaltyDueDate()
                        isCalculated = false
                    }
                    if state.penaltyTaxType == "PAYROLL" && state.penaltyQuarter == "R5" {
                        AndroidToggleCard(
                            icon: "checkmark.seal.fill",
                            title: Copy.t("r5PrincipalTaxPaymentStatus", state.language),
                            subtitle: Copy.t(
                                state.penaltyR5PrincipalTaxPaid ? "r5TaxPaidDescription" : "r5TaxUnpaidDescription",
                                state.language
                            ),
                            subtitleLineLimit: nil,
                            isOn: Binding(
                                get: { state.penaltyR5PrincipalTaxPaid },
                                set: {
                                    state.penaltyR5PrincipalTaxPaid = $0
                                    isCalculated = false
                                }
                            )
                        )
                    }
                } else {
                    YearPickerField(
                        title: Copy.t("profitDueYear", state.language),
                        year: Binding(
                            get: { state.penaltyProfitYear },
                            set: {
                                state.updatePenaltyFiscalYear($0)
                                isCalculated = false
                            }
                        ),
                        years: state.selectablePenaltyYears
                    )
                }

                DateFields(
                    title: state.language == .arabic ? "تاريخ الاستحقاق القانوني" : "Statutory Due Date",
                    day: $state.penaltyDueDay,
                    month: $state.penaltyDueMonth,
                    year: Binding(
                        get: { state.penaltyDueYear },
                        set: {
                            state.updatePenaltyDueYear($0)
                            isCalculated = false
                        }
                    ),
                    showsTitle: false,
                    onChange: { isCalculated = false }
                )
                Button {
                    prefillPenaltyAutoDate()
                    isCalculated = false
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "calendar.badge.clock")
                            .font(.app(16, weight: .bold))
                        Text(Copy.t("standardDueDate", state.language).replacingOccurrences(of: "%@", with: formattedPenaltyAutoDate))
                            .font(.app(12, weight: .black))
                            .multilineTextAlignment(.leading)
                        Spacer()
                    }
                    .foregroundStyle(Color.blueAccent)
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.blueAccent.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.blueAccent.opacity(0.25), lineWidth: 1))
                }
                .buttonStyle(.plain)
                DateFields(title: Copy.t("paymentDate", state.language), day: $state.penaltyPayDay, month: $state.penaltyPayMonth, year: $state.penaltyPayYear, onChange: { isCalculated = false })
            }

            }

            // Normal text-field input is clamped immediately. This visibility gate
            // also protects against direct/debug state mutation below the legal floor.
            if !state.penaltyAmount.isEmpty && !isCalculated && !state.isPenaltyYearBlocked {
                AnimatedCalculateButton(title: Copy.t("calculatePenaltiesBtn", state.language)) {
                    guard state.validatePenaltyYearsBeforeCalculation() else {
                        isCalculated = false
                        return
                    }
                    isCalculated = true
                }
            }

            if (isCalculated || state.debugPreCalculated) && !state.isPenaltyYearBlocked {
                PenaltyResultCard(result: state.penaltyResult)
            }
        }
    }

    private var penaltyCompanyOptions: [(key: String, title: String, subtitle: String)] {
        [
            ("SAL", Copy.t("companySal", state.language), minSubtitle(for: "SAL")),
            ("SARL", Copy.t("companySarl", state.language), minSubtitle(for: "SARL")),
            ("PARTNERSHIP", Copy.t("companyPartnership", state.language), minSubtitle(for: "PARTNERSHIP")),
            ("INDIVIDUAL", Copy.t("companyIndividual", state.language), minSubtitle(for: "INDIVIDUAL")),
            ("EXEMPT", Copy.t("companyExempt", state.language), minSubtitle(for: "EXEMPT")),
            ("OTHER", Copy.t("companyOther", state.language), minSubtitle(for: "OTHER"))
        ]
    }

    private func minSubtitle(for company: String) -> String {
        Copy.t("minPrefix", state.language)
            .replacingOccurrences(of: "%@", with: minFineText(for: company))
    }

    private var penaltyQuarterOptions: [(String, String, String?)] {
        state.penaltyTaxType == "VAT"
            ? [("Q1", "Q1", "3/31"), ("Q2", "Q2", "6/30"), ("Q3", "Q3", "9/30"), ("Q4", "Q4", "12/31")]
            : [("Q1", "Q1", "3/31"), ("Q2", "Q2", "6/30"), ("Q3", "Q3", "9/30"), ("Q4", "Q4", "12/31"), ("R5", "R5", "Annual")]
    }

    private var penaltyAutoDate: ExtensionDateParts {
        TaxEngines.statutoryDueDate(
            taxType: state.penaltyTaxType,
            payrollYear: Int(state.penaltyPayrollYear) ?? 2026,
            quarter: state.penaltyQuarter,
            profitDueYear: Int(state.penaltyProfitYear) ?? 2026,
            companyType: state.penaltyCompanyType
        )
    }

    private var formattedPenaltyAutoDate: String {
        formatDateParts(penaltyAutoDate, language: state.language)
    }

    private func prefillPenaltyAutoDate() {
        let date = penaltyAutoDate
        state.penaltyDueDay = "\(date.day)"
        state.penaltyDueMonth = "\(date.month)"
        state.penaltyDueYear = "\(date.year)"
    }

    /// Android hard-codes these threshold labels per language, using Arabic-Indic
    /// digits and the words مليون / ألف in Arabic rather than a number formatter.
    private func minFineText(for company: String) -> String {
        let selectedYear = (state.penaltyTaxType == "PAYROLL" || state.penaltyTaxType == "VAT")
            ? (Int(state.penaltyPayrollYear) ?? 2026)
            : (Int(state.penaltyProfitYear) ?? 2026)
        let legacy = selectedYear == 2024 || selectedYear == 2025
        let arabic = state.language == .arabic
        switch company {
        case "SAL":
            if legacy { return arabic ? "٦.٧٥ مليون" : "6.75M" }
            return arabic ? "١٨.٧٥ مليون" : "18.75M"
        case "SARL", "PARTNERSHIP", "EXEMPT":
            if legacy { return arabic ? "٤.٥ مليون" : "4.5M" }
            return arabic ? "١٢.٥ مليون" : "12.5M"
        default:
            if legacy { return arabic ? "٧٥٠ ألف" : "750K" }
            return arabic ? "٢.٥ مليون" : "2.5M"
        }
    }
}

/// "Fiscal Penalty Assessment" — a structural port of Android's
/// `tax_penalties_report_statement_card`.
struct PenaltyResultCard: View {
    @EnvironmentObject private var state: AppState
    var result: PenaltyResult

    private var isLate: Bool { result.lateMonths > 0 }
    private var accent: Color { isLate ? .orange800 : .successGreen }
    private var taxAmount: Double { Double(state.penaltyAmount) ?? 0 }

    private var dueText: String {
        penaltyDateText(result.statutoryDate, language: state.language)
    }
    private var payText: String {
        penaltyDateText(result.payDate, language: state.language)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 8) {
                Image(systemName: "calendar")
                    .font(.app(18, weight: .semibold))
                    .foregroundStyle(Color.navyPrimary)
                Text(Copy.t("fiscalPenaltyAssessment", state.language))
                    .font(.app(13, weight: .black))
                    .foregroundStyle(Color.navyPrimary)
                    .fixedSize(horizontal: false, vertical: true)
                Spacer(minLength: 0)
            }
            .padding(.bottom, 12)

            Rectangle().fill(Color.slateBorder).frame(height: 1)
                .padding(.bottom, 12)

            ResultRow(title: Copy.t("legalDueDateRow", state.language), value: dueText, isBold: true)
            ResultRow(title: Copy.t("actualPaymentDateRow", state.language), value: payText, isBold: true)

            Spacer().frame(height: 8)
            delayCard

            Spacer().frame(height: 12)
            ResultRow(title: Copy.t("principalTaxAmount", state.language),
                      value: money(result: taxAmount, language: state.language),
                      valueColor: .navyPrimary, isBold: true)

            if result.isUnderMinimum {
                InfoNoteBox(
                    text: minimumFloorText,
                    fontSize: 11,
                    background: Color.orange50,
                    borderColor: Color.orange100,
                    textColor: Color.orange800,
                    iconColor: Color.orange800
                )
                .padding(.vertical, 4)
            }

            ResultRow(title: verificationLabel,
                      value: money(result: result.verificationFine, language: state.language),
                      valueColor: result.verificationFine > 0 ? Color(hex: 0xC21010) : .slateTextLight,
                      isBold: true)
            ResultRow(title: collectionLabel,
                      value: money(result: result.collectionFine, language: state.language),
                      valueColor: result.collectionFine > 0 ? Color(hex: 0xC21010) : .slateTextLight,
                      isBold: true)

            if result.isCapped {
                InfoNoteBox(
                    text: Copy.t("capAlert", state.language)
                        .replacingOccurrences(of: "%@", with: money(result: taxAmount, language: state.language)),
                    fontSize: 11,
                    background: Color.orange50,
                    borderColor: Color.orange100,
                    textColor: Color.orange800,
                    iconColor: Color.orange800
                )
                .padding(.vertical, 6)
            }

            Rectangle().fill(Color.slateBorder).frame(height: 1)
                .padding(.vertical, 10)

            HStack(alignment: .top, spacing: 8) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(Copy.t("grandTotalToRepay", state.language))
                        .font(.app(12, weight: .heavy))
                        .foregroundStyle(Color.navyPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                    Text(principalPlusFinesText)
                        .font(.app(9.5, weight: .bold))
                        .foregroundStyle(Color.slateTextLight)
                }
                Spacer(minLength: 0)
                Text(money(result: result.totalAmount, language: state.language))
                    .font(.app(17, weight: .black))
                    .foregroundStyle(isLate ? Color(hex: 0xC21010) : Color.navyPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                    .layoutPriority(1)
                    .multilineTextAlignment(.trailing)
                    .environment(\.layoutDirection, .leftToRight)
            }
            .padding(.vertical, 8)

            Spacer().frame(height: 12)
            Text(Copy.t("compliancePenaltyWarning", state.language))
                .font(.app(9))
                .foregroundStyle(Color.navyPrimary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .padding(8)
                .background(Color.navyPrimary.opacity(0.05))
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.slate50)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color.navyPrimary.opacity(0.1), lineWidth: 1.5)
        )
    }

    private var delayCard: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Label and month count share one row, matching Android — the count must
            // never be pushed onto its own line below the label.
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text(Copy.t("totalDelayPeriod", state.language))
                    .font(.app(11.5, weight: .bold))
                    .foregroundStyle(accent)
                    .fixedSize(horizontal: false, vertical: true)
                Spacer(minLength: 8)
                Text("\(result.lateMonths) \(Copy.t("monthsSuffix", state.language))")
                    .font(.app(14, weight: .black))
                    .foregroundStyle(accent)
                    .lineLimit(1)
            }
            Text(delayExplanation)
                .font(.app(11))
                .foregroundStyle(isLate ? Color.orange800.opacity(0.9) : Color.successGreen)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(isLate ? Color.orange50 : Color.successGreenBg)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(isLate ? Color.orange100 : Color.successGreen.opacity(0.2), lineWidth: 1)
        )
    }

    private var delayExplanation: String {
        guard isLate else { return Copy.t("noDelayExplain", state.language) }
        // Android's template carries two positional dates.
        var text = Copy.t("delayExplain", state.language)
        if let first = text.range(of: "%@") {
            text.replaceSubrange(first, with: dueText)
        }
        if let second = text.range(of: "%@") {
            text.replaceSubrange(second, with: payText)
        }
        return text
    }

    private var verificationLabel: String {
        if result.isUnderMinimum { return Copy.t("verificationFineMinimum", state.language) }
        let isPayrollR5 = state.penaltyTaxType == "PAYROLL" && state.penaltyQuarter == "R5"
        return (state.penaltyTaxType == "PAYROLL" && !isPayrollR5)
            ? Copy.t("verificationFine5", state.language)
            : Copy.t("verificationFine10", state.language)
    }

    /// Text only — the grand-total figure above it is unaffected. The Annual
    /// Payroll R5 case nets the verification and collection fines against the
    /// already-paid principal, so its explanatory line differs from every other
    /// penalty case's plain "(principal + fines)".
    private var principalPlusFinesText: String {
        let isPayrollR5 = state.penaltyTaxType == "PAYROLL" && state.penaltyQuarter == "R5"
        guard isPayrollR5 else { return Copy.t("principalPlusFines", state.language) }
        return state.language == .arabic
            ? "(غرامة التحقق + غرامة التحصيل - أصل الضريبة مسدد)"
            : "(Verification Fine + Collection Fine - Principal Tax Paid)"
    }

    private var collectionLabel: String {
        (state.penaltyTaxType == "PAYROLL" || state.penaltyTaxType == "VAT")
            ? Copy.t("collectionFine3", state.language)
            : Copy.t("collectionFine2", state.language)
    }

    private var minimumFloorText: String {
        let threshold = money(result: result.minimumThreshold, language: state.language)
        let key: String
        if taxAmount == 0 {
            key = "minFloorZero"
        } else if taxAmount < result.minimumThreshold {
            key = "minFloorBelow"
        } else {
            key = "minFloorCalc"
        }
        return Copy.t(key, state.language).replacingOccurrences(of: "%@", with: threshold)
    }
}

struct ExtensionsCalculatorTab: View {
    @EnvironmentObject private var state: AppState

    var body: some View {
        VStack(spacing: 16) {
            SectionIntro(title: Copy.t("extensionsIntroTitle", state.language), bodyText: Copy.t("extensionsIntroBody", state.language))

            AppCard {
                Text(Copy.t("selectExtensionTaxType", state.language))
                    .font(.app(13, weight: .bold))
                    .foregroundStyle(Color.slateTextDark)
                SelectableCardGrid(
                    options: [
                        ("PAYROLL", Copy.t("payrollTax", state.language), ""),
                        ("VAT", Copy.t("vat", state.language), ""),
                        ("PROFIT", Copy.t("profit", state.language), ""),
                        ("AUDIT", Copy.t("auditReport", state.language), "")
                    ],
                    selected: state.extensionTaxType,
                    selectedFill: .navyPrimary
                ) {
                    state.extensionTaxType = $0
                    state.syncExtensionDate()
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text(Copy.t("fiscalYear", state.language))
                        .font(.app(11, weight: .bold))
                        .foregroundStyle(Color.slateTextLight)
                    Picker(Copy.t("fiscalYear", state.language), selection: Binding(get: { state.extensionYear }, set: { state.extensionYear = $0; state.syncExtensionDate() })) {
                        ForEach(extensionYears, id: \.self) { year in
                            Text(year).tag(year)
                        }
                    }
                    .pickerStyle(.menu)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 12)
                    .frame(height: 46)
                    .background(Color.slateLight)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.slateBorder, lineWidth: 1))
                }

                if state.extensionTaxType == "PAYROLL" || state.extensionTaxType == "VAT" {
                    Text(Copy.t("filingQuarter", state.language))
                        .font(.app(11, weight: .bold))
                        .foregroundStyle(Color.slateTextLight)
                    CompactOptionRow(options: extensionQuarterOptions, selected: state.extensionQuarter) {
                        state.extensionQuarter = $0
                        state.syncExtensionDate()
                    }
                } else {
                    Text(state.extensionTaxType == "AUDIT" ? Copy.t("companyCategoryAudit", state.language) : Copy.t("companyCategoryProfit", state.language))
                        .font(.app(12, weight: .bold))
                        .foregroundStyle(Color.slateTextDark)
                    SelectableCardGrid(options: extensionEntityOptions, selected: state.extensionCompanyType) {
                        state.extensionCompanyType = $0
                        state.syncExtensionDate()
                    }
                }

                let auto = state.extensionAutoDate
                HStack(alignment: .center, spacing: 12) {
                    VStack(alignment: .leading, spacing: 3) {
                        Text(Copy.t("primaryStatutoryDueDate", state.language))
                            .font(.app(11, weight: .bold))
                            .foregroundStyle(Color.slateTextLight)
                        Text(Copy.t("originalDueDate", state.language))
                            .font(.app(10, weight: .medium))
                            .foregroundStyle(Color.slateMuted)
                    }
                    Spacer()
                    Text(formatDateParts(auto, language: state.language))
                        .font(.app(18, weight: .black))
                        .foregroundStyle(Color.navyPrimary)
                        .multilineTextAlignment(.trailing)
                }
                .padding(14)
                .background(Color.slateLight)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.slateBorder, lineWidth: 1))
                DateFields(title: Copy.t("officialExtendedDate", state.language), day: $state.extensionDay, month: $state.extensionMonth, year: $state.extensionYearValue)
                PrimaryActionButton(title: Copy.t("saveExtension", state.language), systemImage: "checkmark.circle.fill", color: .navyPrimary, cornerRadius: 12, iconOnLeading: true) {
                    state.handleSaveExtensionTap()
                }
            }

            AppCard {
                Text(Copy.t("retrieveExtensions", state.language))
                    .font(.app(14, weight: .bold))
                    .foregroundStyle(Color.navyPrimary)
                Text(Copy.t("retrieveExtensionsBody", state.language))
                    .font(.app(11))
                    .foregroundStyle(Color.slateTextLight)
                PrimaryActionButton(title: Copy.t("retrieveNow", state.language), systemImage: "arrow.clockwise", color: .blueAccent, cornerRadius: 12, iconOnLeading: true) {
                    state.retrieveExtension()
                }
                if let message = state.extensionMessage {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(Copy.t("retrievedRecord", state.language))
                            .font(.app(11, weight: .bold))
                            .foregroundStyle(Color.slateTextDark)
                        Text(message)
                            .font(.app(13, weight: .bold))
                            .foregroundStyle(message.contains("No registered") || message.contains("لا توجد") ? Color.orange800 : Color.successGreen)
                    }
                    .padding(14)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(message.contains("No registered") || message.contains("لا توجد") ? Color.orange50 : Color.successGreenBg)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
            }
        }
    }

    private var extensionQuarterOptions: [(String, String, String?)] {
        state.extensionTaxType == "VAT"
            ? [("Q1", "Q1", nil), ("Q2", "Q2", nil), ("Q3", "Q3", nil), ("Q4", "Q4", nil)]
            : [("Q1", "Q1", nil), ("Q2", "Q2", nil), ("Q3", "Q3", nil), ("Q4", "Q4", nil), ("R5", "R5", nil)]
    }

    private var extensionYears: [String] {
        let current = Calendar.current.component(.year, from: Date())
        return Array(2025...max(2026, current)).map(String.init)
    }

    private var extensionEntityOptions: [(key: String, title: String, subtitle: String)] {
        if state.extensionTaxType == "AUDIT" {
            return [
                ("CAPITAL", state.language == .arabic ? "شركات أموال\n(SAL / SARL)" : "Capital Companies\n(SAL, SARL)", state.language == .arabic ? "مهلتها القانونية ٣١ آب من العام التالي" : "Due August 31 of next year"),
                ("PARTNERSHIP", state.language == .arabic ? "شركات أشخاص" : "Partnerships", state.language == .arabic ? "مهلتها القانونية ٣٠ حزيران من العام التالي" : "Due June 30 of next year")
            ]
        }

        return [
            ("CAPITAL", state.language == .arabic ? "شركات أموال\n(SAL / SARL)" : "Capital Companies\n(SAL, SARL)", state.language == .arabic ? "مهلتها القانونية ٣١ أيار من العام التالي" : "Due May 31 of next year"),
            ("PARTNERSHIP", state.language == .arabic ? "شركات أشخاص" : "Partnerships", state.language == .arabic ? "مهلتها القانونية ٣١ آذار من العام التالي" : "Due March 31 of next year"),
            ("SOLE_REAL", state.language == .arabic ? "مؤسسة فردية\n(الربح الحقيقي)" : "Sole Proprietorship\n(Real Profit Method)", state.language == .arabic ? "مهلتها القانونية ٣١ آذار من العام التالي" : "Due March 31 of next year"),
            ("SOLE_LUMP", state.language == .arabic ? "مؤسسة فردية\n(الربح المقطوع)" : "Sole Proprietorship\n(Lump Sum Method)", state.language == .arabic ? "مهلتها القانونية ٣١ كانون الثاني من العام التالي" : "Due January 31 of next year"),
            ("EXEMPT", state.language == .arabic ? "مؤسسة مستثناة\n(الربح المقطوع)" : "Exempt Institution\n(Lump Sum Method)", state.language == .arabic ? "مهلتها القانونية ٣١ كانون الثاني من العام التالي" : "Due January 31 of next year"),
            ("EXEMPT_REAL", state.language == .arabic ? "مؤسسة مستثناة\n(الربح الحقيقي)" : "Exempt Institution\n(Real Profit Method)", state.language == .arabic ? "مهلتها القانونية ٣١ آذار من العام التالي" : "Due March 31 of next year")
        ]
    }
}

struct ContactCard: View {
    @EnvironmentObject private var state: AppState

    var body: some View {
        AppCard {
            VStack(spacing: 12) {
                Text(Copy.t("contactHeading", state.language))
                    .font(.app(13, weight: .bold))
                    .foregroundStyle(Color.navyPrimary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .fixedSize(horizontal: false, vertical: true)
                // Phone / email / URL are LTR tokens; Android pins this whole block
                // to LTR so they read correctly under Arabic.
                VStack(alignment: .leading, spacing: 8) {
                    ContactLine(systemImage: "phone.fill", text: "+961 03 177 352")
                    ContactLine(systemImage: "envelope.fill", text: "info@haddadaudit.com")
                    Link(destination: URL(string: "https://www.haddadaudit.com")!) {
                        HStack(spacing: 10) {
                            Image(systemName: "globe")
                                .font(.app(16))
                                .foregroundStyle(Color.navyMedium)
                            Text("www.haddadaudit.com")
                                .font(.app(12, weight: .bold))
                                .foregroundStyle(Color.navyMedium)
                        }
                        // Unlike ContactLine (which centers itself), this Link's HStack
                        // has no width constraint of its own, so it hugs the leading
                        // edge inside the outer .leading VStack — visually shifting the
                        // website row out of alignment with the phone/email rows above.
                        .frame(maxWidth: .infinity)
                    }
                }
                .environment(\.layoutDirection, .leftToRight)
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.top, 4)
    }
}

struct ContactLine: View {
    var systemImage: String
    var text: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: systemImage)
                .foregroundStyle(Color.navyPrimary)
            Text(text)
                .foregroundStyle(Color.slateTextDark)
        }
        .font(.app(13, weight: .bold))
        .frame(maxWidth: .infinity)
        .multilineTextAlignment(.center)
    }
}

struct ChildrenPicker: View {
    @EnvironmentObject private var state: AppState
    @Binding var count: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(Copy.t("children", state.language))
                .font(.app(11, weight: .bold))
                .foregroundStyle(Color.slateTextLight)
            // No "eligible up to max 5" helper text by design. The 5-child cap is
            // still enforced by the `0...5` range below and by the engine.
            HStack(spacing: 4) {
                ForEach(0...5, id: \.self) { number in
                    NumberCircle(number: number, isSelected: count == number) {
                        count = number
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 2)
        }
    }
}

struct TaxHighlightRow: View {
    var title: String
    var value: String
    var hasTax: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "building.columns.fill")
                .font(.app(18, weight: .bold))
                .foregroundStyle(hasTax ? Color.dangerRed : Color.slateMuted)
                .padding(.top, 2)
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.app(14, weight: .bold))
                    .foregroundStyle(hasTax ? Color.dangerRed : Color.slateTextDark)
                Text(value)
                    .font(.app(18, weight: .black))
                    .foregroundStyle(hasTax ? Color.dangerRed : Color.slateTextDark)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                    // Keep sign + digits + currency together as one bidi-safe unit
                    // inside the red highlight box (Android's screenshot order).
                    .environment(\.layoutDirection, .leftToRight)
            }
            Spacer()
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(hasTax ? Color.dangerRed.opacity(0.05) : Color.slateLight.opacity(0.6))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(hasTax ? Color.dangerRed.opacity(0.25) : Color.clear, lineWidth: 1)
        )
    }
}

struct EmployerCostBox: View {
    var result: PayrollItem
    var language: AppLanguage

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(Copy.t("employerCostBreakdown", language))
                .font(.app(11, weight: .bold))
                .foregroundStyle(Color.navyMedium)
            ResultRow(title: Copy.t("grossSalary", language), value: money(result: result.grossSalary, language: language), valueColor: .navyMedium)
            ResultRow(title: Copy.t("totalNssfEmployer", language), value: money(result: result.totalNssfEmployer, language: language), valueColor: .navyMedium)
            if result.totalFamilyBenefitsAmount > 0 {
                ResultRow(title: Copy.t("lessFamilyAllowances", language), value: signedMoney(result.totalFamilyBenefitsAmount, isDeduction: true, language: language), valueColor: .dangerRed)
            }
            Divider()
            ResultRow(title: Copy.t("totalCorpCost", language), value: money(result: result.totalEmployerCost, language: language), valueColor: .successGreen, isBold: true)
        }
        .padding(12)
        .background(Color.slate50.opacity(0.7))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.slateBorder.opacity(0.8), lineWidth: 1))
    }
}

struct ComplianceBanner: View {
    var systemImage: String
    var title: String
    var text: String
    var color: Color
    var background: Color

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: systemImage)
                .font(.app(22, weight: .bold))
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.app(12, weight: .bold))
                Text(text)
                    .font(.app(11, weight: .medium))
            }
            Spacer()
        }
        .foregroundStyle(color)
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(background)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(color.opacity(0.45), lineWidth: 1))
    }
}

/// One NSSF branch card. Android gives each branch its own row labels (the Arabic
/// strings differ per branch) and draws a capsule accent bar rather than a stock
/// progress indicator, so both are passed/rendered explicitly here.
struct NssfBranchCard: View {
    var title: String
    var mainAmount: Double
    var base: Double
    /// Bar fill fraction, 0...1. End-of-service is always full in Android.
    var ratio: Double
    var barColor: Color
    var baseLabel: String
    var ceilingLabel: String
    /// Rendered as-is; end-of-service shows "Full Wage (No Ceiling)" instead of a number.
    var ceilingValue: String
    var ceilingValueColor: Color
    var employeeLabel: String
    var employee: Double
    var employerLabel: String
    var employer: Double
    var language: AppLanguage = .english

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top, spacing: 8) {
                Text(title)
                    .font(.app(12, weight: .bold))
                    .foregroundStyle(Color.navyPrimary)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text(money(result: mainAmount, language: language))
                    .font(.app(12, weight: .bold))
                    .foregroundStyle(mainAmount > 0 ? Color.blueAccent : Color.slateTextLight)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                    .environment(\.layoutDirection, .leftToRight)
            }

            Spacer().frame(height: 6)
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.slateBorder)
                    Capsule()
                        .fill(barColor)
                        .frame(width: max(0, min(1, ratio)) * geo.size.width)
                }
            }
            .frame(height: 6)

            Spacer().frame(height: 8)
            ResultRow(title: baseLabel, value: money(result: base, language: language))
            ResultRow(title: ceilingLabel, value: ceilingValue, valueColor: ceilingValueColor, isBold: true)
            ResultRow(title: employeeLabel,
                      value: money(result: employee, language: language),
                      valueColor: employee > 0 ? .blueAccent : .slateTextLight)
            ResultRow(title: employerLabel,
                      value: money(result: employer, language: language),
                      valueColor: employer > 0 ? .blueAccent : .slateTextLight)
        }
        .padding(12)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(Color.slateBorder, lineWidth: 1)
        )
    }
}

struct DateFields: View {
    @EnvironmentObject private var state: AppState
    var title: String
    @Binding var day: String
    @Binding var month: String
    @Binding var year: String
    var showsTitle = true
    /// Fired whenever any of the three fields changes, so a caller whose
    /// calculation depends on this date can invalidate a stale result.
    var onChange: () -> Void = {}

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if showsTitle {
                Text(title)
                    .font(.app(11, weight: .bold))
                    .foregroundStyle(Color.slateTextLight)
            }
            // Day/month/year must never be comma-grouped, and Android weights the
            // three columns 1 / 1.2 / 1.3 so the year field is widest.
            HStack(spacing: 8) {
                StyledTextField(title: Copy.t("day", state.language), placeholder: "15", suffix: nil, text: Binding(get: { day }, set: { day = String(sanitizedDigits($0).prefix(2)); onChange() }), grouping: false, maxDigits: 2)
                    .frame(maxWidth: .infinity)
                StyledTextField(title: Copy.t("month", state.language), placeholder: "4", suffix: nil, text: Binding(get: { month }, set: { month = String(sanitizedDigits($0).prefix(2)); onChange() }), grouping: false, maxDigits: 2)
                    .frame(maxWidth: .infinity)
                StyledTextField(title: Copy.t("year", state.language), placeholder: "2026", suffix: nil, text: Binding(get: { year }, set: { year = String(sanitizedDigits($0).prefix(4)); onChange() }), grouping: false, maxDigits: 4)
                    .frame(maxWidth: .infinity)
            }
        }
    }
}

struct BracketRowView: View {
    var bracket: BracketAllocation
    var total: Double
    var language: AppLanguage = .english

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(bracketTitle)
                    .font(.app(12, weight: .bold))
                    .foregroundStyle(Color.slateTextDark)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text(money(result: bracket.taxInBracket, language: language))
                    .font(.app(12, weight: .bold))
                    .foregroundStyle(bracket.taxInBracket > 0 ? Color.dangerRed : Color.slateTextLight)
                    .multilineTextAlignment(.trailing)
                    .lineLimit(1)
                    .environment(\.layoutDirection, .leftToRight)
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
            ResultRow(title: language == .arabic ? "المبلغ المحتسب" : "Amount charged", value: money(result: bracket.amountInBracket, language: language))
        }
        .padding(10)
        .background(Color.slateLight)
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.slateBorder, lineWidth: 1))
    }

    private var bracketTitle: String {
        if language == .arabic {
            switch bracket.rate {
            case 0.04: return "شريحة ٤٪ (لغاية ٥٤٠ مليون)"
            case 0.07: return "شريحة ٧٪ (٥٤٠ مليون - ١.٤٤ مليار)"
            case 0.12: return "شريحة ١٢٪ (١.٤٤ مليار - ٣.٢٤ مليار)"
            case 0.16: return "شريحة ١٦٪ (٣.٢٤ مليار - ٦.٢٤ مليار)"
            case 0.21: return "شريحة ٢١٪ (٦.٢٤ مليار - ١٣.٥ مليار)"
            case 0.25: return "شريحة ٢٥٪ (فوق ١٣.٥ مليار)"
            default: return "\(Int(bracket.rate * 100))%"
            }
        }
        switch bracket.rate {
        case 0.04: return "4% (0 - 540M)"
        case 0.07: return "7% (540M - 1.44B)"
        case 0.12: return "12% (1.44B - 3.24B)"
        case 0.16: return "16% (3.24B - 6.24B)"
        case 0.21: return "21% (6.24B - 13.5B)"
        case 0.25: return "25% (Above 13.5B)"
        default: return "\(Int(bracket.rate * 100))%"
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
                if !title.isEmpty {
                    Text(title).font(.app(12, weight: .black))
                }
                Text(text).font(.app(11))
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
                Text(title).font(.app(12, weight: .black))
                Text(text).font(.app(11))
            }
        }
        .foregroundStyle(Color.successGreen)
        .padding(13)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.successGreenBg)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

struct TaxPulseLogo: View {
    var size: CGFloat

    var body: some View {
        Image("TaxPulseBrand")
            .resizable()
            .scaledToFill()
            .frame(width: size, height: size)
            .clipShape(RoundedRectangle(cornerRadius: size * 0.22, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: size * 0.22, style: .continuous)
                    .stroke(Color.blueAccent.opacity(0.75), lineWidth: 1.5)
            )
            .shadow(color: .blueAccent.opacity(0.42), radius: 24, y: 10)
            .accessibilityLabel("Tax Pulse logo")
    }
}

struct MiniEcgLine: View {
    var body: some View {
        Canvas { context, size in
            var path = Path()
            let y = size.height * 0.55
            path.move(to: CGPoint(x: 0, y: y))
            path.addLine(to: CGPoint(x: size.width * 0.24, y: y))
            path.addLine(to: CGPoint(x: size.width * 0.34, y: size.height * 0.22))
            path.addLine(to: CGPoint(x: size.width * 0.44, y: size.height * 0.82))
            path.addLine(to: CGPoint(x: size.width * 0.55, y: y))
            path.addLine(to: CGPoint(x: size.width, y: y))
            context.stroke(path, with: .color(.blueAccent), style: StrokeStyle(lineWidth: 2.2, lineCap: .round, lineJoin: .round))
        }
    }
}

struct HeartRateLine: View {
    /// Defaults to the in-app accent; the welcome screen passes Android's #3B82F6.
    var color: Color = .blueAccent

    var body: some View {
        TimelineView(.animation) { timeline in
            // Android sweeps a 250pt-wide highlight from -300 to 1200 over 2200ms, linear.
            let progress = timeline.date.timeIntervalSinceReferenceDate.truncatingRemainder(dividingBy: 2.2) / 2.2
            let sweepX = -300 + progress * 1500
            Canvas { context, size in
                var path = Path()
                // `ecgOffset` rises to 0.70 × waveformHeight above the baseline at
                // the R-wave tip and falls to 0.35 × below it at the S-wave trough.
                // Centre that whole excursion so both extremes keep equal, generous
                // clearance instead of the spike crowding the top edge.
                let peakRise: CGFloat = 0.70
                let peakFall: CGFloat = 0.35
                let waveformHeight = size.height * 0.56
                let excursion = (peakRise + peakFall) * waveformHeight
                let centerY = (size.height - excursion) / 2 + peakRise * waveformHeight

                // The R-wave is a narrow triangle spanning only ~3% of the width. At
                // the old 120 samples just three points landed on it, so the true
                // apex fell between samples and the tip rendered as a blunt, flat
                // stub — the "cut off" look. Denser sampling resolves it to a clean
                // point that actually reaches full height.
                let sampleCount = 600
                for index in 0...sampleCount {
                    let ratio = Double(index) / Double(sampleCount)
                    let x = ratio * size.width
                    let y = centerY + ecgOffset(ratio: ratio, height: waveformHeight)
                    if index == 0 {
                        path.move(to: CGPoint(x: x, y: y))
                    } else {
                        path.addLine(to: CGPoint(x: x, y: y))
                    }
                }
                // `lineJoin: .round` keeps the now-sharp apex from being sheared by a
                // miter-limit bevel.
                context.stroke(
                    path,
                    with: .color(color.opacity(0.15)),
                    style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round)
                )
                context.stroke(path, with: .linearGradient(
                    Gradient(colors: [.clear, color.opacity(0.2), color, color.opacity(0.2), .clear]),
                    startPoint: CGPoint(x: sweepX, y: 0),
                    endPoint: CGPoint(x: sweepX + 250, y: 0)
                ), style: StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round))
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

/// Formats the "≈ $X,XXX.XX USD" figure with thousands grouping, matching Android's
/// example ("$1,455.00") rather than a bare two-decimal string with no separators.
func usdAmountText(_ amount: Double) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    formatter.minimumFractionDigits = 2
    formatter.maximumFractionDigits = 2
    formatter.locale = Locale(identifier: "en_US")
    return formatter.string(from: NSNumber(value: amount)) ?? String(format: "%.2f", amount)
}

func money(result amount: Double, language: AppLanguage) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    formatter.maximumFractionDigits = 0
    formatter.locale = Locale(identifier: "en_US")
    let number = formatter.string(from: NSNumber(value: amount.rounded())) ?? "0"
    // Money keeps Western digits with comma grouping in both languages (Android
    // uses NumberFormat.getIntegerInstance(Locale.US)). The currency word attaches
    // with a non-breaking space. In Arabic the whole "number currency" run is
    // wrapped in a LEFT-TO-RIGHT ISOLATE (U+2066…U+2069): a single LRM alone is not
    // enough — SwiftUI's Text still resolves paragraph-level bidi from the Arabic
    // "ل.ل" run and can flip the visual order; the isolate forces the whole unit to
    // render in strict logical order as one atomic block, pinned to the left.
    if language == .arabic {
        // Arabic still leads with the number, then the currency symbol, both pinned
        // to the left: "2,600,000,000 ل.ل".
        let lrm = number.hasPrefix("-") ? "\u{200E}" : ""
        let content = "\(lrm)\(number)\u{00A0}\u{0644}.\u{0644}"
        return "\u{2066}\(content)\u{2069}"
    }
    return "\(number)\u{00A0}LBP"
}

/// Western → Arabic-Indic digit substitution, matching Android's
/// `convertToArabicDigits`. Used for dates only; money keeps Western digits.
func arabicDigits(_ input: String) -> String {
    let map: [Character: Character] = [
        "0": "٠", "1": "١", "2": "٢", "3": "٣", "4": "٤",
        "5": "٥", "6": "٦", "7": "٧", "8": "٨", "9": "٩"
    ]
    return String(input.map { map[$0] ?? $0 })
}

private let penaltyMonthsEn = ["", "Jan", "Feb", "Mar", "Apr", "May", "Jun",
                               "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
private let penaltyMonthsAr = ["", "كانون الثاني", "شباط", "آذار", "نيسان", "أيار", "حزيران",
                               "تموز", "آب", "أيلول", "تشرين الأول", "تشرين الثاني", "كانون الأول"]

/// Formats a penalty date as "day month year" in both languages — abbreviated month
/// names in English, full Levantine month names plus Arabic-Indic digits in Arabic.
func penaltyDateText(_ components: DateComponents, language: AppLanguage) -> String {
    let day = components.day ?? 1
    let month = components.month ?? 1
    let year = components.year ?? 2026
    let names = language == .arabic ? penaltyMonthsAr : penaltyMonthsEn
    let monthName = (1...12).contains(month) ? names[month] : (language == .arabic ? "الشهر" : "Month")
    if language == .arabic {
        return "\(arabicDigits("\(day)")) \(monthName) \(arabicDigits("\(year)"))"
    }
    return "\(day) \(monthName) \(year)"
}

func childRebateTitle(count: Int, language: AppLanguage) -> String {
    let localizedCount = language == .arabic ? arabicDigits("\(count)") : "\(count)"
    let maximum = language == .arabic ? arabicDigits("5") : "5"
    let maximumLabel = language == .arabic ? "حد أقصى" : "Maximum"
    return "\(Copy.t("rebateChildren", language)) (\(maximumLabel) \(maximum)) × \(localizedCount)"
}

func spouseRebateTitle(status: MaritalStatus, language: AppLanguage) -> String {
    let statusKey = status == .spouseWorks ? "spouseStatusWorks" : "spouseStatusDependent"
    return "\(Copy.t("rebateWife", language)) (\(Copy.t(statusKey, language)))"
}

/// Signed money, e.g. "- 1,234 LBP". Zero renders unsigned, matching Android's
/// `formatWithSign`; Arabic gets an LRM prefix so the sign stays left of the digits.
func signedMoney(_ amount: Double, isDeduction: Bool, language: AppLanguage) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    formatter.maximumFractionDigits = 0
    formatter.locale = Locale(identifier: "en_US")
    let number = formatter.string(from: NSNumber(value: amount.rounded())) ?? "0"
    let currency = language == .arabic ? "\u{0644}.\u{0644}" : "LBP"
    let sign = isDeduction ? "-" : "+"
    if language == .arabic {
        // Sign, then digits, then the currency symbol, all pinned to the left:
        // "- 2,930,000 ل.ل".
        let signPart = amount == 0 ? "" : "\u{200E}\(sign)\u{00A0}"
        return "\u{2066}\(signPart)\(number)\u{00A0}\(currency)\u{2069}"
    }
    if amount == 0 { return "\(number)\u{00A0}\(currency)" }
    return "\(sign)\u{00A0}\(number)\u{00A0}\(currency)"
}

func formatDateParts(_ date: ExtensionDateParts, language: AppLanguage = .english) -> String {
    let enMonthNames = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
    let arMonthNames = ["كانون الثاني", "شباط", "آذار", "نيسان", "أيار", "حزيران", "تموز", "آب", "أيلول", "تشرين الأول", "تشرين الثاني", "كانون الأول"]
    let months = language == .arabic ? arMonthNames : enMonthNames
    let month = (1...12).contains(date.month) ? months[date.month - 1] : (language == .arabic ? "الشهر" : "Month")
    return language == .arabic ? "\(date.day) \(month) \(date.year)" : "\(month) \(date.day), \(date.year)"
}

struct LanguageCard: View {
    var title: String
    var subtitle: String
    var code: String
    var selected: Bool
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 0) {
                Text(code)
                    .font(.app(16, weight: .black))
                    .foregroundStyle(Color.white)
                    .frame(width: 48, height: 48)
                    .background(selected ? Color(hex: 0x2563EB) : Color.white.opacity(0.10))
                    .clipShape(Circle())
                Spacer().frame(height: 16)
                Text(title)
                    .font(.app(18, weight: .bold))
                    .foregroundStyle(Color.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
                Spacer().frame(height: 4)
                Text(subtitle)
                    .font(.app(11))
                    .foregroundStyle(Color(hex: 0x94A3B8))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(20)
            .frame(maxWidth: .infinity)
            .background(selected ? Color(hex: 0x1D4ED8).opacity(0.25) : Color.white.opacity(0.05))
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(selected ? Color(hex: 0x3B82F6) : Color.white.opacity(0.15), lineWidth: selected ? 2 : 1)
            )
        }
        .buttonStyle(.plain)
        .scaleEffect(selected ? 1.04 : 1)
        .animation(.spring(response: 0.5, dampingFraction: 0.7), value: selected)
        .accessibilityLabel(code == "EN" ? "English" : "Arabic")
        .accessibilityAddTraits(selected ? .isSelected : [])
    }
}

struct ServiceSelectionCard: View {
    @EnvironmentObject private var state: AppState
    var tab: ServiceTab
    var action: () -> Void

    var body: some View {
        let meta = serviceMeta(tab, language: state.language)
        Button(action: action) {
            VStack(alignment: .leading, spacing: 0) {
                Image(systemName: meta.icon)
                    .font(.app(20, weight: .bold))
                    .foregroundStyle(Color.white)
                    .frame(width: 40, height: 40)
                    .background(
                        LinearGradient(
                            colors: meta.gradient,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                Spacer().frame(height: 14)
                Text(meta.title)
                    .font(.app(15, weight: .bold))
                    .foregroundStyle(Color.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                Spacer().frame(height: 4)
                Text(meta.description)
                    .font(.app(11))
                    .foregroundStyle(Color(hex: 0x94A3B8))
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                Spacer(minLength: 0)
            }
            .padding(16)
            // Fixed height keeps all four cards uniform without letting the grid
            // stretch to fill the screen (Android sizes them to content).
            .frame(maxWidth: .infinity, alignment: .topLeading)
            .frame(height: 152)
            .background(Color.white.opacity(0.05))
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(Color.white.opacity(0.12), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        // Card content stays left-aligned and readable in Arabic even though the
        // grid itself is pinned LTR.
        .environment(\.layoutDirection, state.language == .arabic ? .rightToLeft : .leftToRight)
    }
}

struct TopBackButton: View {
    var action: () -> Void

    var body: some View {
        HStack {
            Button(action: action) {
                Image(systemName: "chevron.left")
                    .font(.app(16, weight: .black))
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

/// Icon and two-stop gradient per service, matching Android's `ServiceItem` list.
func serviceMeta(_ tab: ServiceTab, language: AppLanguage) -> (title: String, description: String, icon: String, color: Color, gradient: [Color]) {
    switch tab {
    case .payroll:
        return (Copy.t("payrollFull", language),
                language == .arabic ? "رواتب الموظفين والضمان الاجتماعي والشرائح الضريبية" : "Calculate payroll runs, NSSF, and tax brackets",
                "banknote.fill", .blueAccent,
                [Color(hex: 0x3B82F6), Color(hex: 0x1D4ED8)])
    case .profit:
        return (Copy.t("profit", language),
                language == .arabic ? "ضريبة الأرباح للشركات والأفراد والشطور التصاعدية" : "Assess company net business profits and tax steps",
                "building.columns.fill", .successGreen,
                [Color(hex: 0x10B981), Color(hex: 0x047857)])
    case .penalties:
        return (Copy.t("penalties", language),
                language == .arabic ? "بيان غرامات التحقق والتحصيل لمتأخرات الدفع" : "Breakdown fiscal late penalties and statutory fines",
                "exclamationmark.triangle.fill", .alertGold,
                [Color(hex: 0xF59E0B), Color(hex: 0xD97706)])
    case .extensions:
        return (Copy.t("extensions", language),
                language == .arabic ? "استعلام مهل تقديم التصاريح الممددة من المالية" : "Postponed legal filing deadlines and extensions",
                "calendar.badge.clock", Color(hex: 0xEC4899),
                [Color(hex: 0xEC4899), Color(hex: 0xBE185D)])
    }
}
