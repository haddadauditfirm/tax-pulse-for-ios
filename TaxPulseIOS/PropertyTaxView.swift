import SwiftUI

enum PropertyTaxCopy {
    private static let text: [String: (String, String)] = [
        "currency": ("Select currency", "اختيار العملة"),
        "exchangeRate": ("Exchange rate", "سعر الصرف"),
        "rateHint": ("Enter the rate used to convert revenue and deduction to LBP.", "أدخل سعر الصرف لتحويل الإيرادات والتنزيل إلى الليرة اللبنانية."),
        "ratePlaceholder": ("e.g. 89,500", "مثال: 89,500"),
        "standardRate": ("Use Standard Rate (89,500)", "استخدام السعر القياسي (89,500)"),
        "invalidRate": ("Enter a positive exchange rate (up to 4 decimal places).", "أدخل سعر صرف موجباً، حتى 4 أرقام بعد الفاصلة."),
        "invalidUsdRevenue": ("Enter a valid non-negative USD amount (up to 2 decimal places).", "أدخل مبلغاً صحيحاً غير سالب بالدولار، حتى رقمين بعد الفاصلة."),
        "invalidUsdDeduction": ("Enter a valid non-negative USD deduction, or leave it blank.", "أدخل تنزيلاً صحيحاً غير سالب بالدولار، أو اترك الخانة فارغة."),
        "usdDeductionHint": ("Enter the USD equivalent of the applicable LBP deduction, or leave blank.", "أدخل ما يعادل التنزيل المستحق بالليرة بالدولار، أو اترك الخانة فارغة."),
        "revenueEquivalent": ("Revenue equivalent in LBP", "ما يعادل الإيرادات بالليرة"),
        "deductionEquivalent": ("Deduction equivalent in LBP", "ما يعادل التنزيل بالليرة"),
        "conversionLimit": ("The converted amount exceeds the supported LBP limit (18 digits).", "المبلغ بعد التحويل يتجاوز الحد المدعوم بالليرة (18 رقماً)."),
        "rateUsed": ("Exchange rate used", "سعر الصرف المعتمد"),
        "title": ("Property Tax", "ضريبة الأملاك المبنية"),
        "calculatorTitle": ("Property Tax Calculator", "حاسبة ضريبة الأملاك المبنية"),
        "selectYear": ("Select year", "اختيار السنة"),
        "summaryTitle": ("Property Tax Assessment Summary", "ملخص احتساب ضريبة الأملاك المبنية"),
        "summarySubtitle": ("Calculated using the supplied progressive property tax table.", "احتساب وفق جدول الشطور التصاعدية لضريبة الأملاك المبنية."),
        "remaining": ("Remaining Revenue (After Tax)", "الإيرادات المتبقية بعد تنزيل الضريبة"),
        "revenueSummary": ("Revenue & Tax Deduction", "الإيرادات والتنزيل الضريبي"),
        "deductionNoteTitle": ("Residential tax deduction", "تنزيل الوحدة السكنية"),
        "zeroTitle": ("No property tax due", "لا توجد ضريبة أملاك متوجبة"),
        "readyTitle": ("Ready for Property Tax Calculation", "جاهز لاحتساب ضريبة الأملاك المبنية"),
        "readyBody": ("Tap Calculate to see the tax summary and the allocation across progressive brackets.", "اضغط احسب لعرض ملخص الضريبة وتوزيع الإيرادات على الشطور التصاعدية."),
        "bracket4": ("4% (0 - 1.2B)", "شريحة ٤٪ (لغاية ١.٢ مليار)"),
        "bracket6": ("6% (1.2B - 2.4B)", "شريحة ٦٪ (١.٢ - ٢.٤ مليار)"),
        "bracket8": ("8% (2.4B - 3.6B)", "شريحة ٨٪ (٢.٤ - ٣.٦ مليار)"),
        "bracket11": ("11% (3.6B - 6B)", "شريحة ١١٪ (٣.٦ - ٦ مليارات)"),
        "bracket14": ("14% (Above 6B)", "شريحة ١٤٪ (فوق ٦ مليارات)"),
        "intro": ("Calculate annual built property tax for one property in LBP or USD.", "احتسب ضريبة الأملاك المبنية السنوية لعقار واحد بالليرة اللبنانية أو الدولار."),
        "year": ("Tax year", "السنة الضريبية"),
        "revenue": ("Enter revenue", "أدخل الإيرادات"),
        "revenueHint": ("Annual net revenue before the tax deduction", "الإيرادات السنوية الصافية قبل التنزيل الضريبي"),
        "deduction": ("Enter tax deduction", "أدخل التنزيل الضريبي"),
        "deductionHint": ("Leave blank or enter 0 if no deduction applies.", "اتركها فارغة أو أدخل 0 إذا لم يكن هناك تنزيل."),
        "calculate": ("Calculate", "احسب"),
        "reset": ("Reset", "إعادة ضبط"),
        "invalidRevenue": ("Enter a valid non-negative whole LBP amount (up to 18 digits).", "أدخل مبلغاً صحيحاً بالليرة، غير سالب، حتى 18 رقماً."),
        "invalidDeduction": ("Enter a valid non-negative deduction, or leave it blank.", "أدخل تنزيلاً صحيحاً غير سالب، أو اترك الخانة فارغة."),
        "result": ("Property tax result", "نتيجة ضريبة الأملاك المبنية"),
        "annualRevenue": ("Annual revenue", "الإيرادات السنوية"),
        "enteredDeduction": ("Entered tax deduction", "التنزيل الضريبي المدخل"),
        "taxable": ("Taxable revenue after deduction", "الإيرادات الخاضعة للضريبة بعد التنزيل"),
        "tax": ("Total property tax due", "إجمالي ضريبة الأملاك المبنية المتوجبة"),
        "brackets": ("Progressive bracket breakdown", "تفاصيل الشطور التصاعدية"),
        "allocated": ("Revenue in this bracket", "الإيرادات ضمن هذا الشطر"),
        "bracketTax": ("Tax for this bracket", "ضريبة هذا الشطر"),
        "above": ("Above", "أكثر من"),
        "zero": ("The deduction covers the revenue. Taxable revenue and tax are zero.", "التنزيل يغطي الإيرادات. الإيرادات الخاضعة والضريبة تساويان صفراً."),
        "allowance": ("An amount of 360,000,000 Lebanese pounds is deducted from net taxable revenue for each residential unit occupied by a natural person as an owner, a co-owner, or a person deemed to be an owner.", "ينزل مبلغ 360,000,000 ليرة من الإيرادات الصافية الخاضعة للضريبة لكل وحدة سكنية يشغلها شخص طبيعي بصفة مالك أو أحد الشركاء في الملكية أو من هو في حكم المالك.")
    ]
    static func t(_ key: String, _ language: AppLanguage) -> String {
        guard let value = text[key] else { return key }
        return language == .arabic ? value.1 : value.0
    }
}

private func propertyMoney(_ amount: Decimal, _ language: AppLanguage) -> String {
    let formatter = NumberFormatter()
    formatter.locale = Locale(identifier: "en_US")
    formatter.numberStyle = .decimal
    formatter.maximumFractionDigits = 2
    let digits = formatter.string(from: NSDecimalNumber(decimal: amount)) ?? "0"
    return "\u{2066}\(digits) \(language == .arabic ? "ل.ل" : "LBP")\u{2069}"
}

private func propertyUsdMoney(_ amount: Decimal, _ rate: Decimal) -> String {
    let formatter = NumberFormatter()
    formatter.locale = Locale(identifier: "en_US")
    formatter.numberStyle = .decimal
    formatter.minimumFractionDigits = 2
    formatter.maximumFractionDigits = 2
    formatter.roundingMode = .halfUp
    let digits = formatter.string(from: NSDecimalNumber(decimal: amount / rate)) ?? "0.00"
    return "\u{2066}≈ \(digits) USD\u{2069}"
}

struct PropertyTaxCalculatorTab: View {
    @EnvironmentObject private var state: AppState
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var result: PropertyTaxResult?
    @State private var attempted = false
    @State private var calculatedRate: Decimal?
    private enum Field: Hashable { case revenue, deduction, exchangeRate }
    @FocusState private var focusedField: Field?

    private func label(_ key: String) -> String { PropertyTaxCopy.t(key, state.language) }
    private var usd: Bool { state.propertyCurrency == .usd }
    private var revenue: Decimal? { usd ? PropertyTaxEngine.parseUsdAmount(state.propertyRevenueUsd) : PropertyTaxEngine.parseAmount(state.propertyRevenue) }
    private var deduction: Decimal? { usd ? PropertyTaxEngine.parseUsdAmount(state.propertyDeductionUsd, blankAsZero: true) : PropertyTaxEngine.parseAmount(state.propertyDeduction, blankAsZero: true) }
    private var rate: Decimal? { PropertyTaxEngine.parseExchangeRate(state.propertyExchangeRate) }
    private var revenueLbp: Decimal? {
        guard let revenue else { return nil }
        return usd ? rate.flatMap { PropertyTaxEngine.convertToLbp(revenue, exchangeRate: $0) } : revenue
    }
    private var deductionLbp: Decimal? {
        guard let deduction else { return nil }
        return usd ? rate.flatMap { PropertyTaxEngine.convertToLbp(deduction, exchangeRate: $0) } : deduction
    }

    var body: some View {
        VStack(spacing: 16) {
            SectionIntro(title: label("calculatorTitle"), bodyText: label("intro"))
            AppCard(padding: 20) {
                HStack {
                    Text(label("title")).font(.app(14, weight: .bold)).foregroundStyle(Color.navyPrimary)
                    Spacer()
                    PillButton(title: label("reset"), systemImage: "arrow.clockwise") {
                        focusedField = nil; state.resetPropertyTax(); invalidate()
                    }.accessibilityIdentifier("property_reset")
                }
                YearPickerField(title: label("year"), year: Binding(get: { String(state.propertyYear) }, set: {
                    focusedField = nil; state.propertyYear = Int($0) ?? 2025; invalidate()
                }), years: PropertyTaxEngine.supportedYears.map(String.init))
                    .accessibilityIdentifier("property_year_dropdown")
                Text(label("currency")).font(.app(11, weight: .bold)).foregroundStyle(Color.slateTextLight)
                HorizontalToggleRow(options: [("LBP", Copy.t("lbp", state.language)), ("USD", Copy.t("usd", state.language))], selected: state.propertyCurrency.rawValue) {
                    focusedField = nil; state.propertyCurrency = $0 == "USD" ? .usd : .lbp; invalidate()
                }.accessibilityIdentifier("property_currency")
                amountField(field: .revenue, key: "revenue", hint: "revenueHint", error: usd ? "invalidUsdRevenue" : "invalidRevenue", invalid: revenue == nil,
                    icon: "chart.line.uptrend.xyaxis", text: Binding(get: { usd ? state.propertyRevenueUsd : state.propertyRevenue }, set: {
                        if usd { state.propertyRevenueUsd = PropertyTaxEngine.normalizeInput($0) } else { state.propertyRevenue = PropertyTaxEngine.normalizeInput($0) }
                        invalidate()
                    }))
                amountField(field: .deduction, key: "deduction", hint: usd ? "usdDeductionHint" : "deductionHint", error: usd ? "invalidUsdDeduction" : "invalidDeduction", invalid: deduction == nil,
                    icon: "minus.circle", text: Binding(get: { usd ? state.propertyDeductionUsd : state.propertyDeduction }, set: {
                        if usd { state.propertyDeductionUsd = PropertyTaxEngine.normalizeInput($0) } else { state.propertyDeduction = PropertyTaxEngine.normalizeInput($0) }
                        invalidate()
                    }))
                if usd {
                    amountField(field: .exchangeRate, key: "exchangeRate", hint: "rateHint", error: "invalidRate", invalid: rate == nil,
                        icon: "arrow.left.arrow.right", text: Binding(get: { state.propertyExchangeRate }, set: { state.propertyExchangeRate = PropertyTaxEngine.normalizeInput($0); invalidate() }),
                        unit: "LBP/USD", placeholder: label("ratePlaceholder"))
                    BorderedPillButton(title: label("standardRate")) {
                        focusedField = nil; state.propertyExchangeRate = NSDecimalNumber(decimal: PropertyTaxEngine.standardExchangeRate).stringValue; invalidate()
                    }.accessibilityIdentifier("property_standard_rate")
                    if let revenueLbp {
                        Text("\(label("revenueEquivalent")): \(propertyMoney(revenueLbp, state.language))")
                            .font(.app(11, weight: .medium)).foregroundStyle(Color.successGreen).fixedSize(horizontal: false, vertical: true)
                            .accessibilityIdentifier("property_revenue_equivalent")
                    }
                    if !state.propertyDeductionUsd.isEmpty, let deductionLbp {
                        Text("\(label("deductionEquivalent")): \(propertyMoney(deductionLbp, state.language))")
                            .font(.app(11, weight: .medium)).foregroundStyle(Color.successGreen).fixedSize(horizontal: false, vertical: true)
                            .accessibilityIdentifier("property_deduction_equivalent")
                    }
                    if attempted && revenue != nil && deduction != nil && rate != nil && (revenueLbp == nil || deductionLbp == nil) {
                        Text(label("conversionLimit")).font(.app(10)).foregroundStyle(Color.dangerRed).fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
            PropertyNote(title: label("deductionNoteTitle"), text: label("allowance"), warning: true)
                .accessibilityIdentifier("property_deduction_note")
            if result == nil {
                AnimatedCalculateButton(title: label("calculate")) {
                    focusedField = nil; attempted = true
                    if let revenue, let deduction {
                        withAnimation(reduceMotion ? nil : TaxPulseMotion.curve(duration: 0.18)) {
                            calculatedRate = usd ? rate : nil
                            if usd, let rate {
                                result = PropertyTaxEngine.calculateUsd(year: state.propertyYear, revenue: revenue, deduction: deduction, exchangeRate: rate)
                            } else if !usd {
                                result = PropertyTaxEngine.calculate(year: state.propertyYear, revenue: revenue, deduction: deduction)
                            }
                        }
                    }
                }.accessibilityIdentifier("property_calculate")
                CenteredInfoCard(title: label("readyTitle"), text: label("readyBody"))
            }
            if let result {
                PropertyResultCard(result: result, language: state.language, exchangeRate: calculatedRate)
                    .transition(.opacity).accessibilityIdentifier("property_result")
            }
        }
    }

    private func invalidate() { result = nil; attempted = false }

    private func amountField(field: Field, key: String, hint: String, error: String, invalid: Bool, icon: String, text: Binding<String>, unit: String? = nil, placeholder: String? = nil) -> some View {
        let currency = unit ?? (usd ? "USD" : state.language == .arabic ? "ل.ل" : "LBP")
        let isFocused = focusedField == field
        let display = Binding<String>(get: {
            let raw = text.wrappedValue
            let groupable = raw.range(of: "^[0-9]+(\\.[0-9]*)?$", options: .regularExpression) != nil
            return !isFocused && groupable ? NumericTextField.group(raw, grouping: true) : raw
        }, set: { text.wrappedValue = $0 })
        return VStack(alignment: .leading, spacing: 6) {
            Text("\(label(key)) (\(currency))").font(.app(11, weight: .bold)).foregroundStyle(Color.slateTextLight)
            HStack(spacing: 8) {
                TextField(label(key), text: display, prompt: Text(placeholder ?? label(key)).foregroundStyle(Color.slateTextLight))
                    .keyboardType(usd || field == .exchangeRate ? .decimalPad : .numberPad).focused($focusedField, equals: field).tint(Color.blueAccent)
                    .font(.app(14)).foregroundStyle(Color.slateTextDark)
                    .multilineTextAlignment(state.language == .arabic ? .trailing : .leading)
                    .environment(\.layoutDirection, .leftToRight)
                    .accessibilityIdentifier(field == .exchangeRate ? "property_exchange_rate" : "property_\(key)")
                Image(systemName: icon).font(.app(16, weight: .semibold)).foregroundStyle(Color.navyMedium)
            }
            .padding(.horizontal, 12).frame(minHeight: 48)
            .background(isFocused ? Color.slateLight.opacity(0.3) : Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(attempted && invalid ? Color.dangerRed : isFocused ? Color.blueAccent : Color.slateBorder, lineWidth: isFocused ? 2 : 1))
            Text(label(attempted && invalid ? error : hint)).font(.app(10))
                .foregroundStyle(attempted && invalid ? Color.dangerRed : Color.slateTextLight)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

private struct PropertyResultCard: View {
    let result: PropertyTaxResult
    let language: AppLanguage
    let exchangeRate: Decimal?
    private func label(_ key: String) -> String { PropertyTaxCopy.t(key, language) }

    var body: some View {
        AppCard(padding: 20) {
            VStack(alignment: .leading, spacing: 3) {
                Text(label("summaryTitle")).font(.app(14, weight: .black)).foregroundStyle(Color.navyPrimary)
                    .accessibilityIdentifier("property_summary_title")
                Text("\(label("year")) \(result.year) · \(label("summarySubtitle"))")
                    .font(.app(10)).foregroundStyle(Color.slateTextLight).fixedSize(horizontal: false, vertical: true)
                    .accessibilityIdentifier("property_summary_subtitle")
                if let exchangeRate {
                    Text("\(label("rateUsed")): \u{2066}\(NSDecimalNumber(decimal: exchangeRate).stringValue) LBP/USD\u{2069}")
                        .font(.app(10)).foregroundStyle(Color.slateTextLight).fixedSize(horizontal: false, vertical: true)
                }
            }
            VStack(spacing: 8) {
                Text(label("tax")).font(.app(11, weight: .bold)).foregroundStyle(Color.slateTextDark)
                Text(propertyMoney(result.totalTax, language)).font(.app(24, weight: .black)).foregroundStyle(Color(hex: 0xC21010))
                    .multilineTextAlignment(.center).frame(maxWidth: .infinity)
                    .accessibilityIdentifier("property_total_tax_value")
                if let exchangeRate {
                    Text(propertyUsdMoney(result.totalTax, exchangeRate)).font(.app(11, weight: .bold)).foregroundStyle(Color.slateTextDark)
                        .accessibilityIdentifier("property_tax_usd_equivalent")
                }
                Divider()
                Text(label("remaining")).font(.app(11, weight: .bold)).foregroundStyle(Color.slateTextDark)
                Text(propertyMoney(max(Decimal.zero, result.revenue - result.totalTax), language))
                    .font(.app(18, weight: .black)).foregroundStyle(Color.successGreen).multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity).padding(16).background(Color.slateLight)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.slateBorder, lineWidth: 1))
            .accessibilityIdentifier("property_total_tax")
            Text(label("revenueSummary")).font(.app(12, weight: .bold)).foregroundStyle(Color.navyPrimary)
            ResultRow(title: label("annualRevenue"), value: propertyMoney(result.revenue, language))
            ResultRow(title: label("enteredDeduction"), value: propertyMoney(result.deduction, language))
            Divider()
            ResultRow(title: label("taxable"), value: propertyMoney(result.taxableRevenue, language), isBold: true)
            if result.taxableRevenue == 0 {
                PropertyNote(title: label("zeroTitle"), text: label("zero"))
            }
            Text(label("brackets")).font(.app(12, weight: .bold)).foregroundStyle(Color.navyPrimary).padding(.top, 6)
            VStack(spacing: 8) {
                ForEach(result.allocations.indices, id: \.self) { index in
                    let allocation = result.allocations[index]
                    PropertyBracketCard(allocation: allocation, total: result.taxableRevenue, language: language)
                }
            }
        }
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.navyPrimary.opacity(0.1), lineWidth: 1.5))
    }
}

private struct PropertyBracketCard: View {
    let allocation: PropertyTaxAllocation
    let total: Decimal
    let language: AppLanguage
    private var ratio: CGFloat {
        total > 0 ? CGFloat(min(1, NSDecimalNumber(decimal: allocation.income / total).doubleValue)) : 0
    }
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .top) {
                Text(PropertyTaxCopy.t("bracket\(allocation.bracket.percent)", language))
                    .font(.app(13, weight: .bold)).foregroundStyle(Color.slateTextDark)
                    .frame(maxWidth: .infinity, alignment: .leading).fixedSize(horizontal: false, vertical: true)
                Text(propertyMoney(allocation.tax, language)).font(.app(13, weight: .bold))
                    .foregroundStyle(allocation.tax > 0 ? Color(hex: 0xC21010) : Color.slateTextLight)
                    .multilineTextAlignment(.trailing).fixedSize(horizontal: false, vertical: true)
            }
            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.slateBorder)
                    Capsule().fill(Color.blueAccent).frame(width: proxy.size.width * ratio)
                }
            }.frame(height: 6)
            ResultRow(title: PropertyTaxCopy.t("allocated", language), value: propertyMoney(allocation.income, language))
        }
        .padding(10).background(Color.slateLight).clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.slateBorder, lineWidth: 1))
        .accessibilityIdentifier("property_bracket_\(allocation.bracket.percent)")
    }
}

private struct PropertyNote: View {
    let title: String
    let text: String
    var warning = false
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "info.circle.fill").font(.app(24)).foregroundStyle(warning ? Color.alertGold : Color.navyMedium)
            VStack(alignment: .leading, spacing: 4) {
                Text(title).font(.app(11, weight: .bold)).foregroundStyle(warning ? Color.alertGold : Color.navyMedium)
                Text(text).font(.app(11)).foregroundStyle(warning ? Color.alertGold : Color.slateTextDark)
                    .fixedSize(horizontal: false, vertical: true)
            }.frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(14).frame(maxWidth: .infinity, alignment: .leading)
        .background(warning ? Color.alertGoldBg : Color.slateLight).clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(warning ? Color.alertGold : Color.slateBorder, lineWidth: 1))
    }
}
