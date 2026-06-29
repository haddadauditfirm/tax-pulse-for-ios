import SwiftUI

extension Color {
    static let navyDark = Color(red: 0.012, green: 0.086, blue: 0.153)
    static let navyPrimary = Color(red: 0.059, green: 0.173, blue: 0.349)
    static let navyMedium = Color(red: 0.118, green: 0.227, blue: 0.541)
    static let blueAccent = Color(red: 0.008, green: 0.518, blue: 0.780)
    static let slateLight = Color(red: 0.945, green: 0.961, blue: 0.976)
    static let slateBorder = Color(red: 0.886, green: 0.910, blue: 0.941)
    static let slateTextDark = Color(red: 0.059, green: 0.090, blue: 0.165)
    static let slateTextLight = Color(red: 0.392, green: 0.455, blue: 0.545)
    static let slateMuted = Color(red: 0.580, green: 0.639, blue: 0.722)
    static let slate50 = Color(red: 0.973, green: 0.980, blue: 0.988)
    static let successGreen = Color(red: 0.086, green: 0.639, blue: 0.290)
    static let successGreenBg = Color(red: 0.863, green: 0.988, blue: 0.906)
    static let alertGold = Color(red: 0.851, green: 0.467, blue: 0.024)
    static let alertGoldBg = Color(red: 0.996, green: 0.953, blue: 0.780)
    static let dangerRed = Color(red: 0.863, green: 0.149, blue: 0.149)
    static let dangerRedBg = Color(red: 0.996, green: 0.886, blue: 0.886)
    static let orange50 = Color(red: 1.000, green: 0.969, blue: 0.929)
    static let orange800 = Color(red: 0.604, green: 0.204, blue: 0.071)
}

enum Copy {
    static func t(_ key: String, _ language: AppLanguage) -> String {
        let en: [String: String] = [
            "headerTitle": "TAX PULSE",
            "byHaddad": "by Haddad Audit Firm",
            "subtitle": "Lebanese Regulatory Payroll & Tax Engine",
            "activeService": "Active Service",
            "changeService": "Change Service",
            "payroll": "Payroll Tax",
            "profit": "Tax on Profit",
            "penalties": "Tax Penalties",
            "extensions": "Extensions",
            "reset": "Reset",
            "currency": "Salary Currency Designation",
            "lbp": "Lebanese Pound (LBP)",
            "usd": "US Dollar (USD)",
            "marital": "Family Marital Status",
            "single": "Single",
            "spouseWorks": "Wife / Husband Works",
            "spouseDependent": "Wife / Husband Don't Work",
            "children": "Number of Children",
            "childrenMax": "Eligible up to max 5 children",
            "calculate": "CALCULATE",
            "netTakeHome": "NET TAKE-HOME SALARY",
            "mofActive": "MOF Active",
            "contact": "Developed by Haddad Audit Firm",
            "contactSub": "Certified Auditors and Tax Advisors"
        ]
        let ar: [String: String] = [
            "headerTitle": "TAX PULSE",
            "byHaddad": "بواسطة شركة حداد لتدقيق الحسابات",
            "subtitle": "محرك الرواتب والامتثال الضريبي اللبناني",
            "activeService": "الخدمة النشطة",
            "changeService": "تغيير الخدمة",
            "payroll": "ضريبة الرواتب",
            "profit": "ضريبة الأرباح",
            "penalties": "غرامات التأخير",
            "extensions": "تمديد المهل",
            "reset": "إعادة ضبط",
            "currency": "تحديد عملة الراتب",
            "lbp": "الليرة اللبنانية",
            "usd": "الدولار الأميركي",
            "marital": "الوضع العائلي",
            "single": "أعزب/ة",
            "spouseWorks": "الزوج/ة يعمل",
            "spouseDependent": "الزوج/ة لا يعمل",
            "children": "عدد الأولاد",
            "childrenMax": "حتى 5 أولاد كحد أقصى",
            "calculate": "احسب",
            "netTakeHome": "صافي الراتب المستلم",
            "mofActive": "نشط لدى المالية",
            "contact": "تم التطوير بواسطة Haddad Audit Firm",
            "contactSub": "مدققون ومشاورون ضريبيون"
        ]
        return (language == .arabic ? ar[key] : en[key]) ?? key
    }
}
