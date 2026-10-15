import SwiftUI
import UIKit

enum ReversePayrollCopy {
    private static let text: [String: (String, String)] = [
        "title": ("Reverse calculation", "الاحتساب العكسي"),
        "regular": ("Return to regular calculation", "العودة إلى الاحتساب العادي"),
        "how": ("How does reverse calculation work?", "كيف يعمل الاحتساب العكسي؟"),
        "intro": ("Enter the monthly amount the employee should receive. We find the amount to record before deductions: salary plus transportation. After salary tax and employee NSSF, the net matches your target, with family allowances handled as you choose.", "أدخل المبلغ الشهري الذي تريد أن يقبضه الموظف. نحسب لك المبلغ الواجب تسجيله قبل الاقتطاعات: الراتب مع بدل النقل. بعد حسم ضريبة الرواتب وحصة الموظف من الضمان، يصل الصافي إلى المبلغ المطلوب، مع احتساب التعويضات العائلية حسب اختيارك."),
        "target": ("Desired monthly net (including transport)", "الصافي الشهري المطلوب (شامل بدل النقل)"),
        "targetPlaceholder": ("Enter salary amount", "أدخل مبلغ الراتب"),
        "targetSummary": ("Desired monthly net", "الصافي الشهري المطلوب"),
        "targetTransport": ("(Including transportation)", "(شامل بدل النقل)"),
        "days": ("Number of working days", "عدد أيام العمل"),
        "daysPlaceholder": ("Enter working days", "أدخل عدد أيام العمل"),
        "daysHint": ("Maximum 30 days. Choose 22 or 26, or enter another number.", "الحد الأقصى 30 يوماً. اختر 22 أو 26، أو أدخل عدداً آخر."),
        "transport": ("Transportation allowance", "بدل النقل"),
        "dailyTransport": ("Daily transportation allowance", "بدل النقل اليومي"),
        "dailyTransportPlaceholder": ("Enter daily transportation amount", "أدخل مبلغ بدل النقل اليومي"),
        "transportExempt": ("Transportation = working days × the daily amount you enter in LBP. It is excluded from salary tax and NSSF.", "بدل النقل = عدد أيام العمل × المبلغ اليومي الذي تدخله بالليرة اللبنانية. لا يخضع لضريبة الرواتب ولا للضمان."),
        "family": ("Include NSSF family allowances in the target", "تضمين التعويضات العائلية للضمان ضمن الصافي المطلوب"),
        "familyHint": ("When off, family allowances are paid in addition to your target. Existing family rebate and NSSF rules still apply.", "عند إطفاء الخيار، تُضاف التعويضات العائلية فوق الصافي المطلوب. تبقى قواعد التنزيلات العائلية والضمان الحالية مطبقة."),
        "rateHint": ("Reverse calculation in USD uses 89,500 LBP per USD.", "الاحتساب العكسي بالدولار يعتمد 89,500 ل.ل. لكل دولار."),
        "equivalent": ("Net target equivalent in LBP", "ما يعادل الصافي المطلوب بالليرة"),
        "displayCurrency": ("Display amounts in", "عرض المبالغ بـ"),
        "exemptTitle": ("Exempt transportation", "بدل النقل المعفى"),
        "normalTitle": ("Normal monthly payroll calculation", "تفاصيل الاحتساب العادي الشهري"),
        "normalHint": ("This breakdown excludes transportation. Transportation is added separately in the reverse summary above.", "هذه التفاصيل لا تشمل بدل النقل. يُضاف بدل النقل بشكل منفصل في ملخص الاحتساب العكسي أعلاه."),
        "salaryNet": ("Net salary before transportation", "صافي الراتب قبل إضافة بدل النقل"),
        "minimumTitle": ("Minimum wage check", "مراجعة الحد الأدنى للأجور"),
        "calculate": ("Calculate amount to record", "احسب المبلغ الواجب تسجيله"),
        "summary": ("Monthly reverse calculation summary", "ملخص الاحتساب العكسي الشهري"),
        "record": ("Amount to record before deductions", "المبلغ الواجب تسجيله قبل الاقتطاعات"),
        "recordHint": ("Salary + transportation allowance", "الراتب + بدل النقل"),
        "breakdown": ("Salary and transportation", "تفاصيل الراتب وبدل النقل"),
        "deductions": ("Deductions and allowances", "الاقتطاعات والتعويضات"),
        "gross": ("Salary excluding transportation", "الراتب دون بدل النقل"),
        "tax": ("Payroll tax", "ضريبة الرواتب والأجور"),
        "nssf": ("Employee NSSF deduction", "حصة الموظف من الضمان"),
        "benefits": ("NSSF family allowances", "التعويضات العائلية للضمان"),
        "matched": ("Net to be cashed", "الصافي المطلوب قبضه"),
        "familyOnTop": ("Family allowances paid on top", "تعويضات عائلية تُدفع فوق الصافي المطلوب"),
        "actual": ("Total take-home including family allowances", "إجمالي المقبوض مع التعويضات العائلية"),
        "rounding": ("Rounding difference above target", "فرق التقريب فوق الصافي المطلوب"),
        "roundingHint": ("Gross salary is rounded up to a whole LBP or USD cent so net pay is not below your target.", "يُقرّب الراتب الإجمالي للأعلى إلى ليرة كاملة أو سنت دولار حتى لا يقل الصافي عن المطلوب."),
        "error": ("Enter a positive valid net amount (whole LBP or up to 2 USD decimals), 0–30 working days, and select 89,500 for USD. The target must exceed transport plus any included family allowances; supported gross is up to 1 trillion LBP.", "أدخل صافياً موجباً صحيحاً (ليرة كاملة أو حتى رقمين عشريين بالدولار)، وأيام عمل من 0 إلى 30، واختر سعر 89,500 للدولار. يجب أن يتجاوز الصافي بدل النقل والتعويضات المضمّنة؛ الحد المدعوم للراتب الإجمالي تريليون ليرة."),
        "invalidTarget": ("Enter a positive net amount: whole LBP or up to 2 decimal places in USD.", "أدخل صافياً موجباً: ليرة كاملة أو حتى رقمين عشريين بالدولار."),
        "invalidDays": ("Enter a whole number of working days from 0 to 30.", "أدخل عدد أيام العمل برقم صحيح من 0 إلى 30."),
        "invalidTransport": ("Enter a valid daily transportation amount in whole LBP, including 0 if none.", "أدخل مبلغ بدل النقل اليومي بالليرة اللبنانية دون كسور، أو 0 في حال عدم وجود بدل نقل."),
        "rateRequired": ("Tap Use Standard Rate: 89,500 to continue in USD.", "اضغط على استخدام السعر القياسي: 89,500 للمتابعة بالدولار."),
        "targetTooLow": ("The net target must exceed transport plus any family allowances included in it.", "يجب أن يتجاوز الصافي المطلوب بدل النقل والتعويضات العائلية المضمّنة فيه."),
        "unsupported": ("No supported salary was found. The gross salary limit is 1 trillion LBP.", "تعذّر إيجاد راتب ضمن الحد المدعوم. الحد الأقصى للراتب الإجمالي تريليون ليرة."),
        "minimum": ("The calculated gross salary is below the current calculator's minimum wage. Review before using it.", "الراتب الإجمالي الناتج أقل من الحد الأدنى للأجور المعتمد في الحاسبة الحالية. راجعه قبل استخدامه."),
        "review": ("Take-home including transportation", "الصافي النهائي مع بدل النقل"),
        "net": ("Net salary from regular calculation", "صافي الراتب من الاحتساب العادي"),
    ]
    static func t(_ key: String, _ language: AppLanguage) -> String {
        guard let pair = text[key] else { return key }
        return language == .arabic ? pair.1 : pair.0
    }
}

private func reverseMoney(_ value: Double, _ language: AppLanguage, usd: Bool) -> String {
    let formatter = NumberFormatter()
    formatter.locale = Locale(identifier: "en_US")
    formatter.numberStyle = .decimal
    formatter.maximumFractionDigits = 2
    formatter.minimumFractionDigits = usd ? 2 : 0
    let unit = usd ? "USD" : (language == .arabic ? "ل.ل" : "LBP")
    let number = formatter.string(from: NSNumber(value: usd ? value / ReversePayrollEngine.exchangeRate : value)) ?? "0"
    return "\u{2066}\(number) \(unit)\u{2069}"
}

private struct ReversePayrollRow: View {
    let title: String
    let value: String
    var valueColor: Color = .slateTextDark
    var body: some View {
        ViewThatFits(in: .horizontal) {
            HStack(alignment: .firstTextBaseline, spacing: 12) {
                Text(title).font(.app(11, weight: .medium)).foregroundStyle(Color.slateTextDark)
                    .fixedSize(horizontal: true, vertical: true)
                Spacer(minLength: 0)
                Text(value).font(.app(11.5, weight: .bold)).monospacedDigit().foregroundStyle(valueColor)
                    .environment(\.layoutDirection, .leftToRight).fixedSize(horizontal: true, vertical: true)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(title).font(.app(11, weight: .medium)).foregroundStyle(Color.slateTextDark)
                    .fixedSize(horizontal: false, vertical: true)
                Text(value).font(.app(13, weight: .bold)).monospacedDigit().foregroundStyle(valueColor)
                    .environment(\.layoutDirection, .leftToRight).fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
        }
        .padding(.vertical, 3)
    }
}

private struct ReversePayrollTax: View {
    let title: String
    let value: String
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title).font(.app(13, weight: .bold)).foregroundStyle(Color.navyPrimary)
                .fixedSize(horizontal: false, vertical: true)
            Text(value).font(.app(18, weight: .bold)).monospacedDigit().foregroundStyle(Color.orange800)
                .environment(\.layoutDirection, .leftToRight).fixedSize(horizontal: false, vertical: true)
                .accessibilityIdentifier("reverse_payroll_tax_amount")
        }
        .padding(14).frame(maxWidth: .infinity, alignment: .leading).background(Color.alertGoldBg)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.alertGold.opacity(0.3), lineWidth: 1))
    }
}

private struct ReversePayrollTarget: View {
    let title: String
    let subtitle: String
    let value: String
    private var heading: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title).font(.app(11, weight: .medium)).foregroundStyle(Color.slateTextDark)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityIdentifier("reverse_requested_net_title")
            Text(subtitle).font(.app(10)).foregroundStyle(Color.slateTextLight)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityIdentifier("reverse_requested_net_transport")
        }
    }
    private var amount: some View {
        Text(value).font(.app(11.5, weight: .bold)).monospacedDigit().foregroundStyle(Color.slateTextDark)
            .environment(\.layoutDirection, .leftToRight).fixedSize(horizontal: true, vertical: true)
            .accessibilityIdentifier("reverse_requested_net")
    }
    var body: some View {
        ViewThatFits(in: .horizontal) {
            HStack(alignment: .top, spacing: 12) {
                heading.fixedSize(horizontal: true, vertical: true)
                Spacer(minLength: 0)
                amount
            }
            VStack(alignment: .leading, spacing: 6) {
                heading
                Text(value).font(.app(13, weight: .bold)).monospacedDigit().foregroundStyle(Color.slateTextDark)
                    .environment(\.layoutDirection, .leftToRight).fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .accessibilityIdentifier("reverse_requested_net")
            }
        }
        .padding(.vertical, 3)
    }
}

private struct ReversePayrollSection<Content: View>: View {
    let title: String
    let icon: String
    let tint: Color
    @ViewBuilder var content: Content
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .center, spacing: 8) {
                Image(systemName: icon).font(.app(17)).foregroundStyle(tint)
                    .frame(width: 30, height: 30).background(tint.opacity(0.09)).clipShape(Circle())
                Text(title).font(.app(12, weight: .bold)).foregroundStyle(Color.navyPrimary)
                    .fixedSize(horizontal: false, vertical: true).frame(maxWidth: .infinity, alignment: .leading)
            }
            content
        }
        .padding(14).frame(maxWidth: .infinity, alignment: .leading).background(tint.opacity(0.045))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(tint.opacity(0.18), lineWidth: 1))
    }
}

private struct ReversePayrollNote: View {
    let title: String
    let bodyText: String
    var tint: Color = .blueAccent
    var value: String? = nil
    var identifier = ""
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "info.circle").font(.app(17)).foregroundStyle(tint).padding(.top, 1)
            VStack(alignment: .leading, spacing: 5) {
                Text(title).font(.app(11, weight: .bold)).foregroundStyle(Color.navyPrimary).fixedSize(horizontal: false, vertical: true)
                if let value {
                    Text(value).font(.app(13, weight: .bold)).monospacedDigit().foregroundStyle(Color.navyPrimary)
                        .environment(\.layoutDirection, .leftToRight).fixedSize(horizontal: false, vertical: true)
                        .accessibilityIdentifier(identifier + "_amount")
                }
                Text(bodyText).font(.app(10)).foregroundStyle(Color.slateTextDark).fixedSize(horizontal: false, vertical: true)
            }.frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(12).frame(maxWidth: .infinity, alignment: .leading).background(tint.opacity(0.055))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(tint.opacity(0.18), lineWidth: 1))
        .accessibilityIdentifier(identifier)
    }
}

private struct ReversePayrollCurrency: View {
    @Binding var usd: Bool
    let language: AppLanguage
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(ReversePayrollCopy.t("displayCurrency", language)).font(.app(11, weight: .bold)).foregroundStyle(Color.navyPrimary)
            HStack(spacing: 8) {
                ForEach([true, false], id: \.self) { dollar in
                    Button { usd = dollar } label: {
                        Text(dollar ? "USD" : "LBP").font(.app(11, weight: .bold))
                            .foregroundStyle(usd == dollar ? Color.white : Color.navyPrimary)
                            .frame(maxWidth: .infinity, minHeight: 40)
                            .background(usd == dollar ? Color.navyPrimary : Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(usd == dollar ? Color.navyPrimary : Color.slateBorder, lineWidth: 1))
                            .contentShape(Rectangle())
                    }.buttonStyle(.plain)
                        .accessibilityAddTraits(usd == dollar ? .isSelected : [])
                        .accessibilityIdentifier(dollar ? "reverse_display_usd" : "reverse_display_lbp")
                }
            }
            Text("\u{2066}1 USD = 89,500 LBP\u{2069}").font(.app(10)).foregroundStyle(Color.slateTextLight)
                .environment(\.layoutDirection, .leftToRight)
        }
        .padding(12).frame(maxWidth: .infinity, alignment: .leading).background(Color.slate50)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

private struct ReversePayrollHighlight: View {
    let title: String
    var hint: String? = nil
    let value: String
    let identifier: String
    var net = false
    var targetTitle: String? = nil
    var targetSubtitle: String? = nil
    var targetValue: String? = nil
    private var tint: Color { net ? .successGreen : .blueAccent }
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top, spacing: 8) {
                Image(systemName: net ? "checkmark.circle" : "creditcard").font(.app(18)).foregroundStyle(tint).padding(.top, 1)
                Text(title).font(.app(12, weight: .bold)).foregroundStyle(Color.navyPrimary)
                    .fixedSize(horizontal: false, vertical: true).frame(maxWidth: .infinity, alignment: .leading)
            }
            Text(value).font(.app(22, weight: .bold)).monospacedDigit()
                .foregroundStyle(net ? Color.successGreen : Color.navyPrimary)
                .fixedSize(horizontal: false, vertical: true).environment(\.layoutDirection, .leftToRight)
                .accessibilityIdentifier(identifier)
            if let hint {
                Text(hint).font(.app(10)).foregroundStyle(Color.slateTextDark).fixedSize(horizontal: false, vertical: true)
                    .padding(8).frame(maxWidth: .infinity, alignment: .leading).background(Color.white.opacity(0.6))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            if let targetTitle, let targetSubtitle, let targetValue {
                Rectangle().fill(tint.opacity(0.15)).frame(height: 1)
                ReversePayrollTarget(title: targetTitle, subtitle: targetSubtitle, value: targetValue)
            }
        }
        .padding(16).frame(maxWidth: .infinity, alignment: .leading)
        .background(tint.opacity(0.075))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(tint.opacity(0.22), lineWidth: 1))
    }
}

struct ReversePayrollFields: View {
    @EnvironmentObject private var state: AppState
    private var usd: Bool { state.payrollCurrency == .usd }
    private func label(_ key: String) -> String { ReversePayrollCopy.t(key, state.language) }
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "info.circle").foregroundStyle(Color.blueAccent).font(.app(18))
                    Text(label("how")).font(.app(12, weight: .bold)).foregroundStyle(Color.navyPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Text(label("intro")).font(.app(11)).foregroundStyle(Color.slateTextDark).fixedSize(horizontal: false, vertical: true)
            }
            .padding(14).frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.blueAccent.opacity(0.05)).clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.blueAccent.opacity(0.16), lineWidth: 1))
            StyledTextField(title: label("target"), placeholder: label("targetPlaceholder"), suffix: usd ? "USD" : "LBP",
                text: Binding(get: { state.reverseNetTarget }, set: { state.reverseNetTarget = PropertyTaxEngine.normalizeInput($0) }),
                decimal: usd, textAlignment: state.language == .arabic ? .right : .left)
                .accessibilityIdentifier("reverse_target")
            if usd, state.payrollExchangeRate == "89500", let equivalent = ReversePayrollEngine.target(state.reverseNetTarget, usd: true) {
                (Text(label("equivalent") + ": ") + Text(reverseMoney(equivalent, state.language, usd: false)).bold())
                    .font(.app(11, weight: .medium))
                    .foregroundStyle(equivalent > 0 ? Color.successGreen : Color.slateTextLight)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityIdentifier("reverse_target_lbp_equivalent_amount")
            }
            StyledTextField(title: label("days"), placeholder: label("daysPlaceholder"), suffix: nil,
                text: Binding(get: { state.reverseWorkingDays }, set: { state.reverseWorkingDays = PropertyTaxEngine.normalizeInput($0) }),
                grouping: false, textAlignment: state.language == .arabic ? .right : .left)
                .accessibilityIdentifier("reverse_days")
            HStack(spacing: 10) {
                ForEach([22, 26], id: \.self) { days in
                    Button { state.reverseWorkingDays = String(days) } label: {
                        Text(String(days)).font(.app(12, weight: .bold)).foregroundStyle(Color.blueAccent)
                            .frame(maxWidth: .infinity, minHeight: 44)
                            .background(state.reverseWorkingDays == String(days) ? Color.blueAccent.opacity(0.08) : Color.clear)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(state.reverseWorkingDays == String(days) ? Color.blueAccent : Color.slateBorder, lineWidth: 1))
                            .contentShape(Rectangle())
                    }.buttonStyle(.plain)
                        .accessibilityIdentifier("reverse_days_\(days)")
                        .accessibilityAddTraits(state.reverseWorkingDays == String(days) ? .isSelected : [])
                }
            }
            Text(label("daysHint")).font(.app(10)).foregroundStyle(Color.slateTextLight).fixedSize(horizontal: false, vertical: true)
            StyledTextField(title: label("dailyTransport"), placeholder: label("dailyTransportPlaceholder"), suffix: "LBP",
                text: Binding(get: { state.reverseDailyTransport }, set: { state.reverseDailyTransport = PropertyTaxEngine.normalizeInput($0) }),
                textAlignment: state.language == .arabic ? .right : .left)
                .accessibilityIdentifier("reverse_daily_transport")
            if let days = ReversePayrollEngine.workingDays(state.reverseWorkingDays),
               let dailyAmount = ReversePayrollEngine.dailyTransportation(state.reverseDailyTransport) {
                ReversePayrollRow(title: label("transport"), value: reverseMoney(Double(days) * dailyAmount, state.language, usd: usd), valueColor: .blueAccent)
                    .accessibilityIdentifier("reverse_transport")
            }
            Text(label("transportExempt")).font(.app(10)).foregroundStyle(Color.slateTextLight)
                .fixedSize(horizontal: false, vertical: true)
            if usd {
                Text(label("rateHint")).font(.app(11)).foregroundStyle(Color.slateTextLight)
                BorderedPillButton(title: Copy.t("useStandardRate", state.language)) { state.payrollExchangeRate = "89500" }
                    .accessibilityIdentifier("reverse_standard_rate")
            }
            AndroidToggleCard(icon: "person.2.fill", title: label("family"), subtitle: label("familyHint"), subtitleLineLimit: nil, isOn: $state.reverseIncludeFamily)
                .accessibilityIdentifier("reverse_include_family")
        }
    }
}

struct ReversePayrollOutcome: View {
    @EnvironmentObject private var state: AppState
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var result: ReversePayrollResult?
    @State private var error: String?
    @State private var displayUsd = true
    private var usd: Bool { state.payrollCurrency == .usd }
    private var summaryUsd: Bool { usd && displayUsd }
    private func label(_ key: String) -> String { ReversePayrollCopy.t(key, state.language) }
    private func amount(_ value: Double) -> String { reverseMoney(value, state.language, usd: summaryUsd) }
    var body: some View {
        VStack(spacing: 12) {
            if result == nil {
                AnimatedCalculateButton(title: label("calculate")) {
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    error = nil
                    guard let target = ReversePayrollEngine.target(state.reverseNetTarget, usd: usd) else { error = "invalidTarget"; return }
                    guard let days = ReversePayrollEngine.workingDays(state.reverseWorkingDays) else { error = "invalidDays"; return }
                    guard let dailyAmount = ReversePayrollEngine.dailyTransportation(state.reverseDailyTransport) else { error = "invalidTransport"; return }
                    guard !usd || state.payrollExchangeRate == "89500" else { error = "rateRequired"; return }
                    let forward: (Double) -> PayrollItem = { gross in
                        PayrollEngine.calculate(basicSalary: gross, employmentType: .monthly,
                            maritalStatus: state.payrollMarital,
                            childrenCount: state.payrollMarital == .single ? 0 : state.payrollChildren,
                            month: state.payrollMonth, nssfRegistered: state.isNssfRegistered,
                            useFamilyRebates: state.useFamilyRebates, period: .monthly)
                    }
                    let benefits = state.reverseIncludeFamily ? forward(0).totalFamilyBenefitsAmount : 0
                    guard target > Double(days) * dailyAmount + benefits else { error = "targetTooLow"; return }
                    withAnimation(reduceMotion ? nil : TaxPulseMotion.curve(duration: 0.18)) {
                        result = ReversePayrollEngine.calculate(targetLbp: target, workingDays: days, usd: usd,
                        includeFamilyBenefits: state.reverseIncludeFamily, forward: forward, dailyTransportationLbp: dailyAmount)
                    }
                    if result == nil { error = "unsupported" }
                }.accessibilityIdentifier("reverse_calculate")
            }
            if let error {
                Text(label(error)).font(.app(11)).foregroundStyle(Color.dangerRed).fixedSize(horizontal: false, vertical: true)
                    .accessibilityIdentifier("reverse_error")
            }
            if let result {
                AppCard(padding: 20) {
                    Text(label("summary")).font(.app(14, weight: .bold)).foregroundStyle(Color.navyPrimary)
                    if usd { ReversePayrollCurrency(usd: $displayUsd, language: state.language) }
                    ReversePayrollHighlight(title: label("record"), hint: label("recordHint"), value: amount(result.amountBeforeDeductionsLbp), identifier: "reverse_record_amount")
                    ReversePayrollSection(title: label("breakdown"), icon: "creditcard", tint: .blueAccent) {
                        ReversePayrollRow(title: label("gross"), value: amount(result.payroll.basicSalary))
                            .accessibilityIdentifier("reverse_gross")
                        Rectangle().fill(Color.blueAccent.opacity(0.1)).frame(height: 1)
                        ReversePayrollRow(title: label("transport"), value: amount(result.transportLbp))
                        ReversePayrollNote(title: label("exemptTitle"), bodyText: label("transportExempt"))
                    }
                    ReversePayrollSection(title: label("deductions"), icon: "doc.text", tint: .alertGold) {
                        ReversePayrollTax(title: label("tax"), value: amount(-result.payroll.taxAmount))
                        Rectangle().fill(Color.alertGold.opacity(0.12)).frame(height: 1)
                        ReversePayrollRow(title: label("nssf"), value: amount(-result.payroll.totalNssfEmployee), valueColor: .orange800)
                        if result.includesFamilyBenefits && result.payroll.totalFamilyBenefitsAmount > 0 {
                            Rectangle().fill(Color.alertGold.opacity(0.12)).frame(height: 1)
                            ReversePayrollRow(title: label("benefits"), value: amount(result.payroll.totalFamilyBenefitsAmount), valueColor: .navyPrimary)
                        }
                    }
                    ReversePayrollHighlight(title: label("matched"), value: amount(result.matchedNetLbp), identifier: "reverse_net_amount", net: true,
                        targetTitle: label("targetSummary"), targetSubtitle: label("targetTransport"), targetValue: amount(result.targetLbp))
                    if !result.includesFamilyBenefits && result.payroll.totalFamilyBenefitsAmount > 0 {
                        ReversePayrollSection(title: label("benefits"), icon: "person.2", tint: .blueAccent) {
                            ReversePayrollRow(title: label("familyOnTop"), value: amount(result.payroll.totalFamilyBenefitsAmount))
                            Rectangle().fill(Color.blueAccent.opacity(0.1)).frame(height: 1)
                            ReversePayrollRow(title: label("actual"), value: amount(result.payroll.netSalary + result.transportLbp), valueColor: .navyPrimary)
                        }
                    }
                    if result.roundingDifferenceLbp > 0.0001 {
                        ReversePayrollNote(title: label("rounding"), bodyText: label("roundingHint"), tint: .alertGold,
                            value: amount(result.roundingDifferenceLbp))
                    }
                    if result.payroll.hasMinimumWageWarning {
                        ReversePayrollNote(title: label("minimumTitle"), bodyText: label("minimum"), tint: .alertGold)
                    }
                }.accessibilityIdentifier("reverse_result").transition(.opacity)
                PayrollResultCard(result: result.payroll, reverseCalculation: true)
                    .accessibilityIdentifier("reverse_normal_calculation")
            }
        }
    }
}

struct PayrollCalculationModeSelector: View {
    let reverse: Bool
    let language: AppLanguage
    let onSelect: (Bool) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(language == .arabic ? "طريقة الاحتساب" : "Calculation method")
                .font(.app(11, weight: .bold)).foregroundStyle(Color.slateTextLight)
            ViewThatFits(in: .horizontal) {
                HStack(alignment: .top, spacing: 10) {
                    modeCard(false).frame(minWidth: 136)
                    modeCard(true).frame(minWidth: 136)
                }
                VStack(spacing: 10) {
                    modeCard(false)
                    modeCard(true)
                }
            }
        }
    }

    private func modeCard(_ isReverse: Bool) -> some View {
        let active = isReverse == reverse
        let title = isReverse ? ReversePayrollCopy.t("title", language)
            : (language == .arabic ? "الاحتساب العادي" : "Normal calculation")
        let caption = isReverse
            ? (language == .arabic ? "من الصافي إلى الراتب الإجمالي" : "Net pay to monthly salary")
            : (language == .arabic ? "من الراتب الإجمالي إلى الصافي" : "Gross salary to net pay")
        return Button { onSelect(isReverse) } label: {
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Group {
                        if isReverse {
                            Image("ReversePayrollCalculator")
                                .renderingMode(.template)
                                .resizable()
                                .scaledToFit()
                        } else {
                            CalculatorIcon(color: .blueAccent)
                        }
                    }
                    .foregroundStyle(Color.blueAccent)
                    .frame(width: 20, height: 20)
                    .accessibilityHidden(true)
                    Spacer()
                    if active {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.app(18)).foregroundStyle(Color.blueAccent)
                    }
                }
                Text(title).font(.app(12, weight: .bold)).foregroundStyle(Color.navyPrimary)
                    .fixedSize(horizontal: false, vertical: true)
                Text(caption).font(.app(10)).foregroundStyle(Color.slateTextLight)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(14)
            .frame(maxWidth: .infinity, minHeight: 100, alignment: .topLeading)
            .background(active ? Color.blueAccent.opacity(0.08) : Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(RoundedRectangle(cornerRadius: 16)
                .stroke(active ? Color.blueAccent : Color.slateBorder, lineWidth: active ? 1.5 : 1))
            .contentShape(RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier(isReverse ? "payroll_reverse_mode" : "payroll_normal_mode")
        .accessibilityAddTraits(active ? .isSelected : [])
    }
}
