import SwiftUI

enum TutorialTopic: Int, CaseIterable, Identifiable {
    case payroll = 0
    case profit = 1
    case penalties = 2
    case extensions = 3
    case property = 4
    case reversePayroll = 5

    var id: Int { rawValue }
    var service: ServiceTab? { self == .reversePayroll ? .payroll : ServiceTab(rawValue: rawValue) }

    static func forService(_ service: ServiceTab) -> TutorialTopic {
        switch service {
        case .payroll: return .payroll
        case .profit: return .profit
        case .penalties: return .penalties
        case .extensions: return .extensions
        case .property: return .property
        }
    }
}

private struct TutorialText {
    let english: String
    let arabic: String

    func localized(_ language: AppLanguage) -> String {
        language == .arabic ? arabic : english
    }
}

private struct TutorialStep {
    let title: TutorialText
    let body: TutorialText
}

private struct TutorialGuide {
    let topic: TutorialTopic
    let title: TutorialText
    let description: TutorialText
    let steps: [TutorialStep]
    let tip: TutorialText
}

private enum TutorialContent {
    static let labels: [String: TutorialText] = [
        "title": TutorialText(english: "How to Use Tax Pulse", arabic: "كيفية استخدام Tax Pulse"),
        "link": TutorialText(english: "How to use the app", arabic: "كيفية استخدام التطبيق"),
        "intro": TutorialText(english: "Choose a guide below. Follow the steps, then open the service to try it yourself.", arabic: "اختر دليلاً أدناه. اتبع الخطوات، ثم افتح الخدمة لتجربتها بنفسك."),
        "close": TutorialText(english: "Close guide", arabic: "إغلاق الدليل"),
        "tip": TutorialText(english: "Helpful tip", arabic: "نصيحة مفيدة"),
        "open": TutorialText(english: "Open this service", arabic: "فتح هذه الخدمة"),
        "openReverse": TutorialText(english: "Open reverse calculation", arabic: "فتح الاحتساب العكسي")
    ]

    static let guides: [TutorialGuide] = [
        TutorialGuide(
            topic: .payroll,
            title: TutorialText(english: "Payroll: normal calculation", arabic: "الرواتب: الاحتساب العادي"),
            description: TutorialText(english: "Calculate salary tax, NSSF contributions, and net salary.", arabic: "احتسب ضريبة الراتب واشتراكات الضمان وصافي الراتب."),
            steps: [
                TutorialStep(title: TutorialText(english: "Choose monthly or annual", arabic: "اختر الاحتساب الشهري أو السنوي"), body: TutorialText(english: "Select the salary period. For Monthly, enter the gross salary for one month. For Annual, enter the gross salary for the full year.", arabic: "اختر دورية الراتب. للاحتساب الشهري، أدخل إجمالي راتب شهر واحد. للاحتساب السنوي، أدخل إجمالي الراتب للسنة كاملة.")),
                TutorialStep(title: TutorialText(english: "Enter the salary and currency", arabic: "أدخل الراتب وحدد العملة"), body: TutorialText(english: "Select LBP or USD and enter the gross salary. For USD, enter an exchange rate or tap Use Standard Rate. The equivalent LBP amount appears below.", arabic: "اختر الليرة اللبنانية أو الدولار وأدخل إجمالي الراتب. عند اختيار الدولار، أدخل سعر الصرف أو اضغط على استخدام السعر القياسي. سيظهر المبلغ المقابل بالليرة أدناه.")),
                TutorialStep(title: TutorialText(english: "Set family details", arabic: "حدد الوضع العائلي"), body: TutorialText(english: "Choose the marital status and, when applicable, the number of children from 0 to 5. Family Rebates controls whether personal and family deductions are applied to the tax calculation.", arabic: "اختر الوضع العائلي وعدد الأولاد من صفر إلى خمسة عند الاقتضاء. يحدد خيار التنزيلات العائلية تطبيق تنزيل المكلف والتنزيلات العائلية في احتساب الضريبة.")),
                TutorialStep(title: TutorialText(english: "Check NSSF options", arabic: "راجع خيارات الضمان الاجتماعي"), body: TutorialText(english: "Set Subject To NSSF Law according to the employee's situation. For Annual, you can enter annual sickness and family contribution ceilings when an adjustment is needed.", arabic: "حدد الخضوع لقانون الضمان الاجتماعي وفق وضع الموظف. في الاحتساب السنوي، يمكنك إدخال سقوف اشتراكات المرض والأمومة والتعويضات العائلية عند الحاجة إلى تعديلها.")),
                TutorialStep(title: TutorialText(english: "Calculate and read the breakdown", arabic: "احتسب واقرأ التفاصيل"), body: TutorialText(english: "Tap Calculate. Review net salary, salary tax, employee NSSF deductions, family allowances, and employer costs. Check any minimum wage warning shown below.", arabic: "اضغط على زر الاحتساب. راجع صافي الراتب والضريبة واقتطاعات الضمان من الموظف والتعويضات العائلية وأعباء صاحب العمل. انتبه إلى أي تحذير يتعلق بالحد الأدنى للأجور."))
            ],
            tip: TutorialText(english: "Annual amounts are entered for the full year. Use Reset to start a new calculation, and press Calculate again after changing any input.", arabic: "أدخل المبالغ السنوية للسنة كاملة. استخدم إعادة الضبط لبدء احتساب جديد، واضغط على زر الاحتساب مجدداً بعد تعديل أي بيانات.")
        ),
        TutorialGuide(
            topic: .reversePayroll,
            title: TutorialText(english: "Payroll: reverse calculation", arabic: "الرواتب: الاحتساب العكسي"),
            description: TutorialText(english: "Find the monthly salary to record from the employee's desired take-home amount.", arabic: "احسب الراتب الشهري الواجب تسجيله انطلاقاً من المبلغ الذي تريد أن يقبضه الموظف."),
            steps: [
                TutorialStep(title: TutorialText(english: "Choose reverse calculation", arabic: "اختر الاحتساب العكسي"), body: TutorialText(english: "Choose Reverse calculation above the payroll form. This mode works with monthly salaries only; choosing it switches the salary period to Monthly.", arabic: "اختر الاحتساب العكسي فوق نموذج الرواتب. هذا الخيار مخصص للرواتب الشهرية فقط؛ عند اختياره تصبح دورية الراتب شهرية.")),
                TutorialStep(title: TutorialText(english: "Enter the desired monthly net", arabic: "أدخل الصافي الشهري المطلوب"), body: TutorialText(english: "Enter what the employee should receive, including transportation, and select LBP or USD. In USD, tap Use Standard Rate: 89,500 to see the equivalent net target in LBP.", arabic: "أدخل المبلغ الذي تريد أن يقبضه الموظف، شاملاً بدل النقل، واختر LBP أو USD. للدولار، اضغط استخدام السعر القياسي: 89,500 لعرض ما يعادل الصافي المطلوب بالليرة.")),
                TutorialStep(title: TutorialText(english: "Enter working days", arabic: "أدخل عدد أيام العمل"), body: TutorialText(english: "Choose 22 or 26 days, or enter a whole number from 0 to 30. Transportation is working days × 450,000 LBP. It remains separate from the salary and is excluded from salary tax and NSSF.", arabic: "اختر 22 أو 26 يوماً، أو أدخل عدداً صحيحاً من 0 إلى 30. بدل النقل يساوي عدد أيام العمل × 450,000 ل.ل. يبقى منفصلاً عن الراتب ولا يخضع لضريبة الرواتب أو للضمان.")),
                TutorialStep(title: TutorialText(english: "Review family and NSSF options", arabic: "راجع خيارات العائلة والضمان"), body: TutorialText(english: "Set marital status, children, family rebates and NSSF according to the employee. Choose whether NSSF family allowances are included in the desired net or paid on top. The existing payroll rules apply.", arabic: "حدد الوضع العائلي والأولاد والتنزيلات العائلية والخضوع للضمان حسب وضع الموظف. اختر تضمين التعويضات العائلية للضمان ضمن الصافي المطلوب أو دفعها فوقه. تُطبق قواعد حاسبة الرواتب الحالية.")),
                TutorialStep(title: TutorialText(english: "Calculate the amount to record", arabic: "احسب المبلغ الواجب تسجيله"), body: TutorialText(english: "Tap Calculate amount to record. The bold result is the amount before deductions: salary plus transportation. Review payroll tax, the employee NSSF deduction, family allowances and the net to be cashed.", arabic: "اضغط احسب المبلغ الواجب تسجيله. الرقم بالخط العريض هو المبلغ قبل الاقتطاعات: الراتب مع بدل النقل. راجع ضريبة الرواتب وحصة الموظف من الضمان والتعويضات العائلية والصافي المطلوب قبضه.")),
                TutorialStep(title: TutorialText(english: "Read the payroll details below", arabic: "راجع تفاصيل الرواتب أدناه"), body: TutorialText(english: "The normal payroll calculation appears automatically below the reverse summary. Review salary tax, employee and employer NSSF contributions, family allowances and employer cost. Transportation stays separate and exempt.", arabic: "تظهر تفاصيل الاحتساب العادي تلقائياً تحت ملخص الاحتساب العكسي. راجع ضريبة الرواتب وحصة الموظف وصاحب العمل من الضمان والتعويضات العائلية وكلفة صاحب العمل. يبقى بدل النقل منفصلاً ومعفى."))
            ],
            tip: TutorialText(english: "After any input change, calculate again. The net target must exceed transportation and any family allowances included in it.", arabic: "أعد الاحتساب بعد تعديل أي بيانات. يجب أن يتجاوز الصافي المطلوب بدل النقل والتعويضات العائلية المضمّنة فيه.")
        ),
        TutorialGuide(
            topic: .profit,
            title: TutorialText(english: "Tax on Profit", arabic: "ضريبة الأرباح"),
            description: TutorialText(english: "Review profit tax and how the progressive brackets apply.", arabic: "راجع ضريبة الأرباح وتوزيع الربح على الشطور التصاعدية."),
            steps: [
                TutorialStep(title: TutorialText(english: "Enter annual taxable profit", arabic: "أدخل الربح السنوي الخاضع للضريبة"), body: TutorialText(english: "Choose LBP or USD and enter annual net taxable profit. Enter the profit amount, rather than total sales or revenue.", arabic: "اختر الليرة اللبنانية أو الدولار وأدخل صافي الربح السنوي الخاضع للضريبة. أدخل مبلغ الربح، وليس إجمالي المبيعات أو الإيرادات.")),
                TutorialStep(title: TutorialText(english: "Set the USD exchange rate", arabic: "حدد سعر صرف الدولار"), body: TutorialText(english: "If you choose USD, enter the exchange rate you want to use or tap Use Standard Rate. Review the equivalent LBP amount before calculating.", arabic: "عند اختيار الدولار، أدخل سعر الصرف المطلوب أو اضغط على استخدام السعر القياسي. راجع المبلغ المقابل بالليرة قبل الاحتساب.")),
                TutorialStep(title: TutorialText(english: "Choose family details", arabic: "اختر البيانات العائلية"), body: TutorialText(english: "Select the marital status and the number of children when applicable. A working spouse changes the child rebate split; the screen shows a note when this applies.", arabic: "اختر الوضع العائلي وعدد الأولاد عند الاقتضاء. يؤثر عمل الزوج أو الزوجة في توزيع تنزيل الأولاد، وتظهر ملاحظة على الشاشة عند تطبيق هذا التوزيع.")),
                TutorialStep(title: TutorialText(english: "Calculate and review the brackets", arabic: "احتسب وراجع الشطور"), body: TutorialText(english: "Tap Calculate Profit Tax. Review the tax due, remaining profit after tax, family rebates, and the amount allocated to each progressive bracket.", arabic: "اضغط على احتساب ضريبة الأرباح. راجع الضريبة المتوجبة وصافي الربح بعد الضريبة والتنزيلات العائلية والمبلغ الموزع على كل شطر تصاعدي."))
            ],
            tip: TutorialText(english: "This screen uses the displayed progressive profit brackets and family rebates. It does not offer a separate corporate flat-rate selector.", arabic: "تستخدم هذه الشاشة شطور الأرباح التصاعدية والتنزيلات العائلية المعروضة. لا تتضمن خياراً منفصلاً لتحديد نسبة ضريبة ثابتة للشركات.")
        ),
        TutorialGuide(
            topic: .penalties,
            title: TutorialText(english: "Tax Penalties", arabic: "غرامات التأخير"),
            description: TutorialText(english: "Estimate late filing and collection penalties.", arabic: "احتسب غرامات التأخر في التصريح والتحصيل."),
            steps: [
                TutorialStep(title: TutorialText(english: "Choose the tax and taxpayer type", arabic: "اختر نوع الضريبة والمكلف"), body: TutorialText(english: "Select Payroll Tax, Tax on Profit, or VAT, then choose the company or taxpayer category. The category and fiscal year affect the minimum penalty.", arabic: "اختر ضريبة الرواتب والأجور، أو ضريبة الأرباح، أو الضريبة المضافة، ثم حدد فئة الشركة أو المكلف. تؤثر الفئة والسنة المالية في الحد الأدنى للغرامة.")),
                TutorialStep(title: TutorialText(english: "Enter the tax amount", arabic: "أدخل مبلغ الضريبة"), body: TutorialText(english: "Enter the principal tax amount in LBP. If no tax is due, type 0 so the app can calculate any minimum filing penalty.", arabic: "أدخل أصل مبلغ الضريبة بالليرة اللبنانية. إذا لم تكن هناك ضريبة متوجبة، أدخل صفر ليتمكن التطبيق من احتساب الحد الأدنى لغرامة التصريح عند الاقتضاء.")),
                TutorialStep(title: TutorialText(english: "Select the year and period", arabic: "حدد السنة والفترة"), body: TutorialText(english: "Choose the fiscal year. Payroll and VAT also use a quarter. For annual payroll R5, specify whether the principal tax has been paid, and still enter its amount.", arabic: "اختر السنة المالية. تتطلب ضريبة الرواتب والضريبة المضافة تحديد الفصل أيضاً. للتصريح السنوي عن الرواتب R5، حدد ما إذا كان أصل الضريبة مسدداً، وأدخل مبلغه حتى عند تسديده.")),
                TutorialStep(title: TutorialText(english: "Confirm both dates", arabic: "تحقق من التاريخين"), body: TutorialText(english: "Review the statutory due date and edit it if an extension applies. Enter the actual payment or calculation date. Tap the suggested statutory date to prefill it.", arabic: "راجع تاريخ الاستحقاق القانوني وعدّله إذا كانت هناك مهلة ممددة. أدخل تاريخ السداد الفعلي أو الاحتساب. اضغط على المهلة القانونية المقترحة لتعبئتها تلقائياً.")),
                TutorialStep(title: TutorialText(english: "Calculate the amount due", arabic: "احتسب المبلغ المتوجب"), body: TutorialText(english: "Tap Calculate Penalties. Review the delay period, filing penalty, collection penalty, and grand total. Check the notes about minimum penalties and caps.", arabic: "اضغط على احتساب الغرامات. راجع مدة التأخير وغرامة التحقق وغرامة التحصيل والمجموع المستحق، وانتبه إلى ملاحظات الحد الأدنى والسقف الأقصى للغرامات."))
            ],
            tip: TutorialText(english: "Saved extension dates are not applied here automatically. Enter the applicable extended deadline yourself in Statutory Due Date.", arabic: "لا تُطبّق تواريخ التمديد المحفوظة هنا تلقائياً. أدخل المهلة الممددة المناسبة بنفسك في حقل تاريخ الاستحقاق القانوني.")
        ),
        TutorialGuide(
            topic: .property,
            title: TutorialText(english: "Property Tax", arabic: "ضريبة الأملاك المبنية"),
            description: TutorialText(english: "Calculate annual built property tax for one property in LBP or USD.", arabic: "احتسب ضريبة الأملاك المبنية السنوية لعقار واحد بالليرة اللبنانية أو الدولار."),
            steps: [
                TutorialStep(title: TutorialText(english: "Select the year", arabic: "اختر السنة"), body: TutorialText(english: "Choose 2025 or 2026. Both years use the supplied 2024 property tax table.", arabic: "اختر 2025 أو 2026. تعتمد السنتان جدول ضريبة الأملاك المبنية لعام 2024 المرفق.")),
                TutorialStep(title: TutorialText(english: "Enter annual revenue", arabic: "أدخل الإيرادات السنوية"), body: TutorialText(english: "Choose LBP or USD and enter the annual net revenue for one property before the tax deduction. LBP uses whole amounts; USD accepts up to two decimal places.", arabic: "اختر الليرة أو الدولار وأدخل الإيرادات السنوية الصافية لعقار واحد قبل التنزيل. أدخل الليرة بأرقام صحيحة، والدولار حتى رقمين بعد الفاصلة.")),
                TutorialStep(title: TutorialText(english: "Enter the deduction once", arabic: "أدخل التنزيل مرة واحدة"), body: TutorialText(english: "Enter the applicable deduction in the selected currency. For USD, enter its USD equivalent. Leave blank or enter 0 if none applies. The conditional 360 million LBP allowance is not added automatically.", arabic: "أدخل التنزيل المستحق بالعملة المختارة. للدولار، أدخل ما يعادله بالدولار. اترك الخانة فارغة أو أدخل 0 إذا لم يكن هناك تنزيل. لا يُضاف تنزيل الـ360 مليون المشروط تلقائياً.")),
                TutorialStep(title: TutorialText(english: "Set the exchange rate", arabic: "حدد سعر الصرف"), body: TutorialText(english: "For USD, enter the LBP per USD exchange rate or tap Use Standard Rate. Both revenue and deduction are converted to LBP before applying the tax brackets.", arabic: "عند اختيار الدولار، أدخل سعر الصرف بالليرة لكل دولار أو استخدم السعر القياسي. تُحوّل الإيرادات والتنزيل إلى الليرة قبل تطبيق الشطور الضريبية.")),
                TutorialStep(title: TutorialText(english: "Calculate and review", arabic: "احسب وراجع"), body: TutorialText(english: "Tap Calculate. Revenue minus deduction is taxed progressively at 4%, 6%, 8%, 11%, and 14%. Review the total and each bracket. Calculate again after changing an input.", arabic: "اضغط احسب. تُفرض الضريبة على الإيرادات بعد التنزيل بالشطور التصاعدية 4% و6% و8% و11% و14%. راجع المجموع وكل شطر. أعد الاحتساب بعد تعديل أي بيانات."))
            ],
            tip: TutorialText(english: "If the deduction equals or exceeds the revenue, taxable revenue and tax are zero. Use Reset for a new calculation.", arabic: "إذا ساوى التنزيل الإيرادات أو تجاوزها، تكون الإيرادات الخاضعة والضريبة صفراً. استخدم إعادة الضبط لاحتساب جديد.")
        ),
        TutorialGuide(
            topic: .extensions,
            title: TutorialText(english: "Extensions", arabic: "تمديد المهل"),
            description: TutorialText(english: "Save and retrieve filing deadlines on your device.", arabic: "احفظ مهل تقديم التصاريح واسترجعها على جهازك."),
            steps: [
                TutorialStep(title: TutorialText(english: "Choose the deadline category", arabic: "اختر فئة المهلة"), body: TutorialText(english: "Select Payroll Tax, VAT, Tax on Profit, or Audit Report. Choose the fiscal year and the quarter or taxpayer category shown for that service.", arabic: "اختر ضريبة الرواتب والأجور، أو الضريبة المضافة، أو ضريبة الأرباح، أو تقرير التدقيق. حدد السنة المالية والفصل أو فئة المكلف الظاهرة لهذه الخدمة.")),
                TutorialStep(title: TutorialText(english: "Review the original deadline", arabic: "راجع المهلة الأصلية"), body: TutorialText(english: "Read Primary Statutory Due Date. This is the app's base deadline for the selected period and category, before any extension you enter.", arabic: "راجع تاريخ الاستحقاق القانوني الأساسي. هذه هي المهلة الأصلية التي يعرضها التطبيق للفترة والفئة المحددتين، قبل إدخال أي تمديد.")),
                TutorialStep(title: TutorialText(english: "Enter the extended date", arabic: "أدخل التاريخ الممدد"), body: TutorialText(english: "Enter the day, month, and year of the extension you want to record. The app records dates you supply; it does not download MOF decisions.", arabic: "أدخل اليوم والشهر والسنة للمهلة الممددة التي تريد تسجيلها. يحفظ التطبيق التواريخ التي تدخلها، ولا ينزّل قرارات وزارة المالية تلقائياً.")),
                TutorialStep(title: TutorialText(english: "Save the date", arabic: "احفظ التاريخ"), body: TutorialText(english: "Tap Save Extension Date. If the date matches the original deadline, confirm whether to save it anyway. Close the success message after saving.", arabic: "اضغط على حفظ مهلة التمديد. إذا كان التاريخ مطابقاً للمهلة الأصلية، أكد رغبتك في حفظه. أغلق رسالة النجاح بعد الحفظ.")),
                TutorialStep(title: TutorialText(english: "Retrieve the saved deadline", arabic: "استرجع المهلة المحفوظة"), body: TutorialText(english: "Choose the same tax type, year, and quarter or category, then tap Instantly Retrieve & Display. The saved date appears in the retrieved record.", arabic: "اختر نوع الضريبة والسنة والفصل أو الفئة نفسها، ثم اضغط على استرجاع وعرض المهلة فوراً. سيظهر التاريخ المحفوظ في النتيجة المسترجعة."))
            ],
            tip: TutorialText(english: "Extension dates are stored on this device. To use one in Tax Penalties, enter it manually as the statutory due date.", arabic: "تُحفظ تواريخ التمديد على هذا الجهاز. لاستخدام أحدها في حاسبة الغرامات، أدخله يدوياً كتاريخ الاستحقاق القانوني.")
        )
    ]

    static func label(_ key: String, _ language: AppLanguage) -> String {
        labels[key]?.localized(language) ?? key
    }

    static func guide(_ topic: TutorialTopic) -> TutorialGuide {
        guides.first { $0.topic == topic } ?? guides[0]
    }
}

struct TutorialLink: View {
    @EnvironmentObject private var state: AppState
    var onDarkBackground = false
    let onOpen: () -> Void

    var body: some View {
        Button {
            UIApplication.shared.sendAction(
                #selector(UIResponder.resignFirstResponder),
                to: nil, from: nil, for: nil
            )
            onOpen()
        } label: {
            HStack(spacing: 8) {
                TutorialBookIcon()
                    .frame(width: 22, height: 22)
                Text(TutorialContent.label("link", state.language))
            }
                .font(.app(13, weight: .bold))
                .padding(.vertical, 12)
                .padding(.horizontal, 8)
                .frame(minHeight: 44)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .foregroundStyle(onDarkBackground ? Color(hex: 0x93C5FD) : Color.blueAccent)
        .accessibilityIdentifier("tutorial_open")
    }
}

struct TutorialView: View {
    @EnvironmentObject private var state: AppState
    @State private var selectedTopic: TutorialTopic

    init(initialTopic: TutorialTopic) {
        _selectedTopic = State(initialValue: initialTopic)
    }

    private var guide: TutorialGuide { TutorialContent.guide(selectedTopic) }
    private let columns = [
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible(), spacing: 8)
    ]

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                Text(TutorialContent.label("title", state.language))
                    .font(.app(19, weight: .bold))
                    .foregroundStyle(Color.navyPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
                Button { state.tutorialTopic = nil } label: {
                    Image(systemName: "xmark")
                        .font(.app(19, weight: .semibold))
                        .foregroundStyle(Color.navyPrimary)
                        .frame(width: 44, height: 44)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(TutorialContent.label("close", state.language))
                .accessibilityIdentifier("tutorial_close")
            }
            .padding(.leading, 20)
            .padding(.trailing, 8)
            .padding(.vertical, 8)
            .background(Color.white)

            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 14) {
                        Text(TutorialContent.label("intro", state.language))
                            .font(.app(14))
                            .foregroundStyle(Color.slateTextLight)
                            .id("tutorial_top")

                        VStack(spacing: 8) {
                            LazyVGrid(columns: columns, spacing: 8) {
                                ForEach([TutorialTopic.payroll, .reversePayroll, .profit, .penalties, .property, .extensions]) { topic in
                                    topicButton(topic)
                                }
                            }
                        }

                        VStack(alignment: .leading, spacing: 6) {
                            Text(guide.title.localized(state.language))
                                .font(.app(22, weight: .bold))
                                .foregroundStyle(Color.navyPrimary)
                                .accessibilityAddTraits(.isHeader)
                            Text(guide.description.localized(state.language))
                                .font(.app(14))
                                .foregroundStyle(Color.slateTextLight)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)

                        ForEach(guide.steps.indices, id: \.self) { index in
                            stepCard(guide.steps[index], number: index + 1)
                        }

                        VStack(alignment: .leading, spacing: 6) {
                            Text(TutorialContent.label("tip", state.language))
                                .font(.app(16, weight: .bold))
                                .foregroundStyle(Color.navyPrimary)
                            Text(guide.tip.localized(state.language))
                                .font(.app(14))
                                .foregroundStyle(Color.slateTextDark)
                                .lineSpacing(4)
                        }
                        .padding(16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.blueAccent.opacity(0.08), in: RoundedRectangle(cornerRadius: 16))

                        if let service = selectedTopic.service {
                            Button {
                                state.chooseService(service)
                                state.payrollReverseMode = selectedTopic == .reversePayroll
                                if state.payrollReverseMode { state.salaryPeriod = .monthly }
                                state.tutorialTopic = nil
                            } label: {
                                Text(TutorialContent.label(selectedTopic == .reversePayroll ? "openReverse" : "open", state.language))
                                    .font(.app(15, weight: .bold))
                                    .foregroundStyle(Color.white)
                                    .padding(16)
                                    .frame(maxWidth: .infinity)
                                    .background(Color.navyPrimary, in: RoundedRectangle(cornerRadius: 12))
                            }
                            .buttonStyle(.plain)
                            .accessibilityIdentifier("tutorial_launch_service")
                        }
                    }
                    .padding(20)
                }
                .accessibilityIdentifier("tutorial_screen")
                .onChange(of: selectedTopic) { _, _ in
                    proxy.scrollTo("tutorial_top", anchor: .top)
                }
            }
        }
        .background(Color.slateLight.ignoresSafeArea())
        .environment(\.layoutDirection, state.language == .arabic ? .rightToLeft : .leftToRight)
    }

    private func topicButton(_ topic: TutorialTopic) -> some View {
        let selected = selectedTopic == topic
        return Button { selectedTopic = topic } label: {
            Text(TutorialContent.guide(topic).title.localized(state.language))
                .font(.app(13, weight: .bold))
                .multilineTextAlignment(.center)
                .foregroundStyle(selected ? Color.white : Color.navyPrimary)
                .padding(.horizontal, 12)
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity, minHeight: 48)
                .background(selected ? Color.navyPrimary : Color.white, in: RoundedRectangle(cornerRadius: 12))
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.slateBorder, lineWidth: 1))
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(selected ? .isSelected : [])
        .accessibilityIdentifier("tutorial_topic_\(topic.rawValue)")
    }

    private func stepCard(_ step: TutorialStep, number: Int) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Text(stepNumber(number))
                .font(.app(16, weight: .bold))
                .foregroundStyle(Color.blueAccent)
                .frame(width: 32, height: 32)
                .background(Color.blueAccent.opacity(0.1), in: Circle())
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 6) {
                Text(step.title.localized(state.language))
                    .font(.app(16, weight: .bold))
                    .foregroundStyle(Color.navyPrimary)
                Text(step.body.localized(state.language))
                    .font(.app(14))
                    .foregroundStyle(Color.slateTextDark)
                    .lineSpacing(4)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white, in: RoundedRectangle(cornerRadius: 16))
        .accessibilityElement(children: .combine)
    }

    private func stepNumber(_ number: Int) -> String {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: state.language == .arabic ? "ar" : "en")
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: number)) ?? String(number)
    }
}
