import XCTest
import SwiftUI
import UIKit
@testable import TaxPulseIOS

final class InputAndIconRenderingTests: XCTestCase {
    @MainActor
    func testEmptyNumericFieldKeepsReadableHintsInBothLanguagesAndAppearanceModes() throws {
        let expectedColor = UIColor(Color.slateTextLight)
        for hint in ["Enter salary amount", "أدخل مبلغ الراتب"] {
            for appearance in [UIUserInterfaceStyle.light, .dark] {
                let host = UIHostingController(rootView: NumericTextField(
                    text: .constant(""), placeholder: hint, decimal: true
                ))
                host.overrideUserInterfaceStyle = appearance
                host.loadViewIfNeeded()
                host.view.frame = CGRect(x: 0, y: 0, width: 320, height: 60)
                host.view.layoutIfNeeded()
                let field = try XCTUnwrap(findTextField(in: host.view))
                XCTAssertEqual(field.attributedPlaceholder?.string, hint)
                let color = try XCTUnwrap(field.attributedPlaceholder?.attribute(
                    .foregroundColor, at: 0, effectiveRange: nil
                ) as? UIColor)
                XCTAssertEqual(color, expectedColor)
                XCTAssertEqual(field.overrideUserInterfaceStyle, .light)
                XCTAssertEqual(field.backgroundColor, .clear)
            }
        }
    }

    @MainActor
    func testAndroidMatchingIconAssetsAreAvailableInTheAppBundle() {
        for name in ["LanguageGlobe", "PayrollCalculator", "ReversePayrollWallet", "PropertyTax", "WelcomeBrand"] {
            XCTAssertNotNil(UIImage(named: name), "Missing image asset: \(name)")
        }
    }

    @MainActor
    private func findTextField(in view: UIView) -> UITextField? {
        if let field = view as? UITextField { return field }
        for child in view.subviews {
            if let field = findTextField(in: child) { return field }
        }
        return nil
    }
}

final class PropertyTaxEngineTests: XCTestCase {
    private func decimal(_ value: String) -> Decimal { Decimal(string: value, locale: Locale(identifier: "en_US_POSIX"))! }

    func testPdfTotalsAndMarginalBoundariesForBothYears() throws {
        let cases = [
            ("0", "0"), ("1", "0.04"),
            ("1199999999", "47999999.96"), ("1200000000", "48000000"), ("1200000001", "48000000.06"),
            ("2399999999", "119999999.94"), ("2400000000", "120000000"), ("2400000001", "120000000.08"),
            ("3599999999", "215999999.92"), ("3600000000", "216000000"), ("3600000001", "216000000.11"),
            ("5999999999", "479999999.89"), ("6000000000", "480000000"), ("6000000001", "480000000.14"),
            ("7000000000", "620000000"), ("10000000000", "1040000000")
        ]
        for year in [2025, 2026] {
            for (income, expected) in cases {
                let result = try XCTUnwrap(PropertyTaxEngine.calculate(year: year, revenue: decimal(income), deduction: 0))
                XCTAssertEqual(result.totalTax, decimal(expected))
                XCTAssertEqual(result.allocations.reduce(Decimal.zero) { $0 + $1.income }, decimal(income))
            }
        }
    }

    func testManualDeductionAppliedOnceAndZeroWhenCovered() throws {
        for year in [2025, 2026] {
            let result = try XCTUnwrap(PropertyTaxEngine.calculate(year: year, revenue: 1_560_000_000, deduction: 360_000_000))
            XCTAssertEqual(result.taxableRevenue, 1_200_000_000)
            XCTAssertEqual(result.totalTax, 48_000_000)
            XCTAssertEqual(PropertyTaxEngine.calculate(year: year, revenue: 1_560_000_000, deduction: 0)?.totalTax, 69_600_000)
            for deduction in [Decimal(500), Decimal(501), decimal("999999999999999999")] {
                let zero = try XCTUnwrap(PropertyTaxEngine.calculate(year: year, revenue: 500, deduction: deduction))
                XCTAssertEqual(zero.taxableRevenue, 0)
                XCTAssertEqual(zero.totalTax, 0)
            }
        }
    }

    func testLocalizedAndInvalidAmounts() {
        for value in ["1,560,000,000", "١٬٥٦٠٬٠٠٠٬٠٠٠", "۱٬۵۶۰٬۰۰۰٬۰۰۰", " 1 560 000 000 "] {
            XCTAssertEqual(PropertyTaxEngine.parseAmount(value), 1_560_000_000)
        }
        XCTAssertNil(PropertyTaxEngine.parseAmount(""))
        XCTAssertEqual(PropertyTaxEngine.parseAmount("", blankAsZero: true), 0)
        for value in ["-1", "abc", "1.5", "1e6", ",", "1,5", "1,,000", "1,000,", "9999999999999999999"] {
            XCTAssertNil(PropertyTaxEngine.parseAmount(value, blankAsZero: true))
        }
        for year in [2024, 2027] { XCTAssertNil(PropertyTaxEngine.calculate(year: year, revenue: 1, deduction: 0)) }
        XCTAssertNil(PropertyTaxEngine.calculate(year: 2025, revenue: -1, deduction: 0))
        XCTAssertNil(PropertyTaxEngine.calculate(year: 2025, revenue: 1, deduction: -1))
        XCTAssertNil(PropertyTaxEngine.calculate(year: 2025, revenue: decimal("1.5"), deduction: 0))
        XCTAssertNil(PropertyTaxEngine.calculate(year: 2025, revenue: decimal("1000000000000000000"), deduction: 0))
    }

    func testLargeAmountsRetainExactPrecision() throws {
        let result = try XCTUnwrap(PropertyTaxEngine.calculate(year: 2026,
            revenue: decimal("999999999999999999"), deduction: decimal("999999993999999998")))
        XCTAssertEqual(result.taxableRevenue, 6_000_000_001)
        XCTAssertEqual(result.totalTax, decimal("480000000.14"))
    }

    func testUsdConversionBeforeDeductionAndBracketsForBothYears() throws {
        for year in [2025, 2026] {
            let result = try XCTUnwrap(PropertyTaxEngine.calculateUsd(year: year, revenue: decimal("15600.25"), deduction: decimal("3600.25"), exchangeRate: 100_000))
            XCTAssertEqual(result.revenue, 1_560_025_000)
            XCTAssertEqual(result.deduction, 360_025_000)
            XCTAssertEqual(result.taxableRevenue, 1_200_000_000)
            XCTAssertEqual(result.totalTax, 48_000_000)
            let fractional = try XCTUnwrap(PropertyTaxEngine.calculateUsd(year: year, revenue: decimal("0.01"), deduction: 0, exchangeRate: decimal("89500.5")))
            XCTAssertEqual(fractional.revenue, decimal("895.005"))
            XCTAssertEqual(fractional.totalTax, decimal("35.8002"))
            XCTAssertEqual(PropertyTaxEngine.calculateUsd(year: year, revenue: 1, deduction: 10, exchangeRate: 89_500)?.totalTax, 0)
        }
    }

    func testUsdAndRateParsingAndInvalidConversions() {
        for raw in ["1,560.25", "١٬٥٦٠٫٢٥", "۱٬۵۶۰٫۲۵"] { XCTAssertEqual(PropertyTaxEngine.parseUsdAmount(raw), decimal("1560.25")) }
        XCTAssertEqual(PropertyTaxEngine.parseExchangeRate("٨٩٬٥٠٠٫٥"), decimal("89500.5"))
        XCTAssertEqual(PropertyTaxEngine.parseUsdAmount("", blankAsZero: true), 0)
        for invalid in ["-1", "1,5", "1,00.50", "1.234", "1e6", "abc", "9999999999999999999"] { XCTAssertNil(PropertyTaxEngine.parseUsdAmount(invalid)) }
        for invalid in ["", "0", "-1", "1,5", "89500.12345", "10000000000"] { XCTAssertNil(PropertyTaxEngine.parseExchangeRate(invalid)) }
        for invalid in ["0", "-1", "1.23456", "10000000000"] {
            XCTAssertNil(PropertyTaxEngine.convertToLbp(1, exchangeRate: decimal(invalid)))
            XCTAssertNil(PropertyTaxEngine.calculateUsd(year: 2025, revenue: 1, deduction: 0, exchangeRate: decimal(invalid)))
        }
        XCTAssertNil(PropertyTaxEngine.convertToLbp(decimal("999999999999999999"), exchangeRate: 89_500))
        XCTAssertNil(PropertyTaxEngine.calculateUsd(year: 2025, revenue: -1, deduction: 0, exchangeRate: 89_500))
        XCTAssertNil(PropertyTaxEngine.calculateUsd(year: 2025, revenue: 1, deduction: -1, exchangeRate: 89_500))
        XCTAssertNil(PropertyTaxEngine.calculateUsd(year: 2025, revenue: decimal("1.001"), deduction: 0, exchangeRate: 89_500))
    }
}

final class PayrollEngineParityTests: XCTestCase {
    func testAndroidReferenceMonthlyPayrollSample() {
        let result = PayrollEngine.calculate(
            basicSalary: 75_000_000,
            allowances: 0,
            bonuses: 0,
            overtime: 0,
            employmentType: .monthly,
            maritalStatus: .spouseDependent,
            childrenCount: 2,
            month: 10,
            nssfRegistered: true,
            useFamilyRebates: true,
            period: .monthly
        )

        XCTAssertEqual(result.sicknessMaternityEmployee, 2_250_000, accuracy: 0.001)
        XCTAssertEqual(result.taxableSalary, 11_250_000, accuracy: 0.001)
        XCTAssertEqual(result.taxAmount, 230_000, accuracy: 0.001)
    }

    func testAnnualBracketSixStartsAtSevenPointTwoBillion() {
        let bracket = PayrollEngine.annualBrackets()[5]

        XCTAssertEqual(bracket.minAmount, 7_200_000_000, accuracy: 0.001)
        XCTAssertEqual(bracket.maxAmount, 13_500_000_000, accuracy: 0.001)
        XCTAssertEqual(bracket.rate, 0.20, accuracy: 0.000_001)
    }

    func testDailyAndLumpSumBranchesMatchAndroidFlags() {
        let daily = PayrollEngine.calculate(
            basicSalary: 2_000_000,
            allowances: 500_000,
            employmentType: .daily,
            maritalStatus: .single,
            childrenCount: 0,
            month: 10,
            nssfRegistered: false,
            useFamilyRebates: true,
            period: .monthly
        )

        let lump = PayrollEngine.calculate(
            basicSalary: 50_000_000,
            employmentType: .lumpSumWages,
            maritalStatus: .single,
            childrenCount: 2,
            month: 10,
            nssfRegistered: false,
            useFamilyRebates: true,
            period: .monthly
        )

        XCTAssertTrue(daily.isDailyTaxApplied)
        XCTAssertEqual(daily.familyRebatesAmount, 1_500_000, accuracy: 0.001)
        XCTAssertTrue(lump.isLumpSumApplied)
        XCTAssertEqual(lump.taxAmount, 1_500_000, accuracy: 0.001)
    }

    func testProfitSummaryCopyAndLocalizedChildCount() {
        XCTAssertEqual(Copy.t("remainingNetProfit", .english), "Remaining Net Profit (After Tax)")
        XCTAssertEqual(Copy.t("remainingNetProfit", .arabic), "صافي الأرباح النهائية (بعد تنزيل الضريبة)")
        XCTAssertEqual(childRebateTitle(count: 0, language: .english), "Children Rebate (Maximum 5) × 0")
        XCTAssertEqual(childRebateTitle(count: 2, language: .english), "Children Rebate (Maximum 5) × 2")
        XCTAssertEqual(childRebateTitle(count: 5, language: .arabic), "تنزيل الأولاد (حد أقصى ٥) × ٥")
    }

    func testProfitSpouseLabelsFollowSelectedStatus() {
        XCTAssertEqual(
            spouseRebateTitle(status: .spouseDependent, language: .english),
            "Wife / Husband Rebate (Does Not Work)"
        )
        XCTAssertEqual(
            spouseRebateTitle(status: .spouseWorks, language: .english),
            "Wife / Husband Rebate (Works)"
        )
        XCTAssertEqual(
            spouseRebateTitle(status: .spouseDependent, language: .arabic),
            "تنزيل الزوج/الزوجة (لا يعمل/تعمل)"
        )
        XCTAssertEqual(
            spouseRebateTitle(status: .spouseWorks, language: .arabic),
            "تنزيل الزوج/الزوجة (يعمل/تعمل)"
        )
    }

    func testRefinedPayrollAndProfitCopy() {
        XCTAssertEqual(Copy.t("nssfBranches", .arabic), "اشتراكات فروع الضمان الاجتماعي (ل.ل)")
        XCTAssertEqual(Copy.t("nssfBranches", .english), "NSSF Branches & Contributions (LBP)")
        XCTAssertEqual(Copy.t("selectCurrency", .arabic), "تحديد العملة")
        XCTAssertEqual(Copy.t("selectCurrency", .english), "Select Currency")
        // Placeholders all end in an ellipsis.
        XCTAssertTrue(Copy.t("enterTaxAmount", .english).hasSuffix("..."))
        XCTAssertTrue(Copy.t("enterTaxAmount", .arabic).hasSuffix("..."))
        XCTAssertTrue(Copy.t("enterSalary", .english).hasSuffix("..."))
        XCTAssertTrue(Copy.t("enterAnnualNetProfit", .english).hasSuffix("..."))
    }

    func testPaidR5CollectionPenaltyExcludesPrincipalTaxForEveryCompanyTypeAndFinancialYear() {
        let companyTypes = ["SAL", "SARL", "PARTNERSHIP", "INDIVIDUAL", "EXEMPT", "OTHER"]
        let financialYears = [2024, 2025, 2026, 2027]

        for financialYear in financialYears {
            for companyType in companyTypes {
                let result = TaxEngines.calculatePenalties(
                    companyType: companyType,
                    taxType: "PAYROLL",
                    taxAmount: 100_000_000,
                    payrollYear: financialYear,
                    quarter: "R5",
                    profitDueYear: financialYear,
                    payDay: 1,
                    payMonth: 3,
                    payYear: financialYear,
                    dueDayOverride: 1,
                    dueMonthOverride: 1,
                    dueYearOverride: financialYear,
                    r5PrincipalTaxPaid: true
                )

                let expectedCollectionFine = (
                    result.verificationFine * 0.03 * Double(result.lateMonths) / 10_000
                ).rounded(.up) * 10_000
                XCTAssertEqual(result.collectionFine, expectedCollectionFine, accuracy: 0.001)
                XCTAssertEqual(
                    result.totalAmount,
                    result.verificationFine + result.collectionFine,
                    accuracy: 0.001
                )
            }
        }
    }

    func testUnpaidR5KeepsLegacyPenaltyAndGrandTotalCalculation() {
        let result = TaxEngines.calculatePenalties(
            companyType: "SAL",
            taxType: "PAYROLL",
            taxAmount: 100_000_000,
            payrollYear: 2026,
            quarter: "R5",
            profitDueYear: 2026,
            payDay: 1,
            payMonth: 3,
            payYear: 2026,
            dueDayOverride: 1,
            dueMonthOverride: 1,
            dueYearOverride: 2026,
            r5PrincipalTaxPaid: false
        )

        XCTAssertEqual(result.verificationFine, 20_000_000, accuracy: 0.001)
        XCTAssertEqual(result.collectionFine, 7_200_000, accuracy: 0.001)
        XCTAssertEqual(result.totalAmount, 127_200_000, accuracy: 0.001)
    }

    func testPaidStatusDoesNotChangeNonR5PayrollCalculations() {
        let result = TaxEngines.calculatePenalties(
            companyType: "SAL",
            taxType: "PAYROLL",
            taxAmount: 100_000_000,
            payrollYear: 2026,
            quarter: "Q1",
            profitDueYear: 2026,
            payDay: 1,
            payMonth: 3,
            payYear: 2026,
            dueDayOverride: 1,
            dueMonthOverride: 1,
            dueYearOverride: 2026,
            r5PrincipalTaxPaid: true
        )

        XCTAssertEqual(result.verificationFine, 18_750_000, accuracy: 0.001)
        XCTAssertEqual(result.collectionFine, 7_130_000, accuracy: 0.001)
        XCTAssertEqual(result.totalAmount, 125_880_000, accuracy: 0.001)
    }

    func testPenaltyFiscalYearClampsBelow2024ForAllTaxTypes() {
        XCTAssertEqual(AppState.minimumPenaltyYear, 2024)

        for taxType in ["PAYROLL", "PROFIT", "VAT"] {
            for invalidYear in ["2023", "2020"] {
                let state = AppState()
                state.penaltyTaxType = taxType

                XCTAssertFalse(state.updatePenaltyFiscalYear(invalidYear))
                // No alert: the year picker cannot offer a year below the floor, so
                // this path only has to clamp silently.
                XCTAssertNil(state.activeModal)
                if taxType == "PROFIT" {
                    XCTAssertEqual(state.penaltyProfitYear, "2024")
                } else {
                    XCTAssertEqual(state.penaltyPayrollYear, "2024")
                }
                state.activeModal = nil
                if taxType == "PROFIT" {
                    XCTAssertEqual(state.penaltyProfitYear, "2024")
                } else {
                    XCTAssertEqual(state.penaltyPayrollYear, "2024")
                }
                XCTAssertFalse(state.isPenaltyYearBlocked)
            }
        }
    }

    func testPenaltyFiscalYears2024And2026RemainAllowedForAllTaxTypes() {
        for taxType in ["PAYROLL", "PROFIT", "VAT"] {
            for validYear in ["2024", "2026"] {
                let state = AppState()
                state.penaltyTaxType = taxType

                XCTAssertTrue(state.updatePenaltyFiscalYear(validYear))
                XCTAssertNil(state.activeModal)
                if taxType == "PROFIT" {
                    XCTAssertEqual(state.penaltyProfitYear, validYear)
                } else {
                    XCTAssertEqual(state.penaltyPayrollYear, validYear)
                }
            }
        }
    }

    /// Drives the real UITextField path used by the penalty year inputs. Reproduces
    /// the reported bug: the alert fired but the field kept showing the rejected
    /// year. The hard case is when the clamped result equals the value already in
    /// state — SwiftUI then sees no change and never calls `updateUIView`, so the
    /// coordinator itself has to re-assert the authoritative text.
    private func assertFieldRejects(
        _ typed: String,
        expecting expected: String,
        taxType: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let state = AppState()
        state.penaltyTaxType = taxType
        // Pre-seed at the floor so the clamp produces no net state change.
        state.penaltyPayrollYear = "2024"
        state.penaltyProfitYear = "2024"

        let binding = Binding<String>(
            get: { taxType == "PROFIT" ? state.penaltyProfitYear : state.penaltyPayrollYear },
            set: { state.updatePenaltyFiscalYear($0) }
        )
        let sut = NumericTextField(
            text: binding, placeholder: "2026", decimal: false,
            grouping: false, maxDigits: 4
        )
        let coordinator = sut.makeCoordinator()
        let field = UITextField()
        field.text = typed
        coordinator.editingChanged(field)

        let stored = taxType == "PROFIT" ? state.penaltyProfitYear : state.penaltyPayrollYear
        XCTAssertEqual(stored, expected, "\(taxType): state must clamp", file: file, line: line)
        XCTAssertEqual(field.text, expected,
                       "\(taxType): the field must not keep displaying the rejected year",
                       file: file, line: line)
        XCTAssertNil(state.activeModal,
                     "\(taxType): clamping is silent now that the picker gates the year",
                     file: file, line: line)
        XCTAssertFalse(state.isPenaltyYearBlocked,
                       "\(taxType): state is clamped, so nothing stays blocked",
                       file: file, line: line)
    }

    func testYearFieldVisiblySnapsBackTo2024ForEveryPenaltyTaxType() {
        for taxType in ["PAYROLL", "PROFIT", "VAT"] {
            assertFieldRejects("2023", expecting: "2024", taxType: taxType)
            assertFieldRejects("2020", expecting: "2024", taxType: taxType)
        }
    }

    func testYearFieldKeepsValidYearsExactlyAsTypedForEveryPenaltyTaxType() {
        for taxType in ["PAYROLL", "PROFIT", "VAT"] {
            for validYear in ["2024", "2026"] {
                let state = AppState()
                state.penaltyTaxType = taxType
                let binding = Binding<String>(
                    get: { taxType == "PROFIT" ? state.penaltyProfitYear : state.penaltyPayrollYear },
                    set: { state.updatePenaltyFiscalYear($0) }
                )
                let sut = NumericTextField(
                    text: binding, placeholder: "2026", decimal: false,
                    grouping: false, maxDigits: 4
                )
                let coordinator = sut.makeCoordinator()
                let field = UITextField()
                field.text = validYear
                coordinator.editingChanged(field)

                XCTAssertEqual(field.text, validYear, "\(taxType) \(validYear) must be preserved")
                XCTAssertNil(state.activeModal, "\(taxType) \(validYear) must not alert")
            }
        }
    }

    /// Mid-typing partial years (1-3 digits) must pass through untouched, otherwise
    /// the field would fight the user on every keystroke before the 4th digit.
    func testPartialYearEntryIsNotClampedWhileTyping() {
        for partial in ["2", "20", "202"] {
            let state = AppState()
            state.penaltyTaxType = "PAYROLL"
            let binding = Binding<String>(
                get: { state.penaltyPayrollYear },
                set: { state.updatePenaltyFiscalYear($0) }
            )
            let sut = NumericTextField(
                text: binding, placeholder: "2026", decimal: false,
                grouping: false, maxDigits: 4
            )
            let coordinator = sut.makeCoordinator()
            let field = UITextField()
            field.text = partial
            coordinator.editingChanged(field)

            XCTAssertEqual(field.text, partial, "partial year \(partial) must survive")
            XCTAssertNil(state.activeModal, "partial year \(partial) must not alert")
        }
    }

    func testPenaltyPrecalculationGuardClampsDirectInvalidStateAndBlocksCalculation() {
        for taxType in ["PAYROLL", "PROFIT", "VAT"] {
            let state = AppState()
            state.penaltyTaxType = taxType
            if taxType == "PROFIT" {
                state.penaltyProfitYear = "2023"
            } else {
                state.penaltyPayrollYear = "2023"
            }
            state.penaltyDueYear = "2023"

            XCTAssertFalse(state.validatePenaltyYearsBeforeCalculation())
            XCTAssertNil(state.activeModal)
            XCTAssertEqual(state.penaltyDueYear, "2024")
            if taxType == "PROFIT" {
                XCTAssertEqual(state.penaltyProfitYear, "2024")
            } else {
                XCTAssertEqual(state.penaltyPayrollYear, "2024")
            }
        }
    }

    // MARK: - Penalty year picker

    /// The picker list is what actually enforces the floor now, so it must never
    /// offer anything below it and must always include the current year.
    func testSelectablePenaltyYearsStartAtTheFloorAndCoverToday() {
        let years = AppState().selectablePenaltyYears
        XCTAssertEqual(years.first, "\(AppState.minimumPenaltyYear)")
        XCTAssertFalse(years.contains("2023"))
        XCTAssertFalse(years.contains("2020"))
        let currentYear = Calendar.current.component(.year, from: Date())
        XCTAssertTrue(years.contains("\(currentYear)"),
                      "the current year must be selectable: \(years)")
        XCTAssertEqual(years, years.sorted(), "years must be ascending")
        XCTAssertEqual(Set(years).count, years.count, "no duplicate years")
    }

    // MARK: - Refinement pass: wording and dynamic labels

    func testSocialSecuritySectionTitleIsConciseWithParenthesisedCurrency() {
        let arabic = Copy.t("nssfBranches", .arabic)
        XCTAssertEqual(arabic, "اشتراكات فروع الضمان الاجتماعي (ل.ل)")
        XCTAssertFalse(arabic.contains("تفاصيل"), "the title must not say تفاصيل")
        XCTAssertFalse(arabic.contains("فروع)"), "the title must not enumerate ثلاثة فروع")
        XCTAssertFalse(arabic.contains("٣ فروع"))
        XCTAssertEqual(Copy.t("nssfBranches", .english), "NSSF Branches & Contributions (LBP)")
    }

    func testProfitTaxCurrencyLabelIsNotSalarySpecific() {
        XCTAssertEqual(Copy.t("selectCurrency", .arabic), "تحديد العملة")
        XCTAssertEqual(Copy.t("selectCurrency", .english), "Select Currency")
        // The payroll-specific wording must still exist untouched for the payroll tab.
        XCTAssertEqual(Copy.t("currency", .arabic), "تحديد عملة الراتب")
    }

    func testChildRebateLabelShowsMaximumAndTracksSelectedCount() {
        for count in 0...5 {
            let english = childRebateTitle(count: count, language: .english)
            XCTAssertTrue(english.contains("(Maximum 5)"), "EN must state the max: \(english)")
            XCTAssertTrue(english.hasSuffix("× \(count)"), "EN must end with the live count: \(english)")

            let arabic = childRebateTitle(count: count, language: .arabic)
            XCTAssertTrue(arabic.contains("(حد أقصى ٥)"), "AR must state the max: \(arabic)")
            XCTAssertTrue(arabic.hasSuffix("× \(arabicDigits("\(count)"))"),
                          "AR must end with the live count in Arabic-Indic digits: \(arabic)")
        }
        // Guard against the previously hardcoded "3".
        XCTAssertNotEqual(childRebateTitle(count: 0, language: .arabic),
                          childRebateTitle(count: 3, language: .arabic))
    }

    func testSpouseRebateLabelReflectsTheSelectedMaritalStatus() {
        XCTAssertEqual(spouseRebateTitle(status: .spouseDependent, language: .arabic),
                       "تنزيل الزوج/الزوجة (لا يعمل/تعمل)")
        XCTAssertEqual(spouseRebateTitle(status: .spouseWorks, language: .arabic),
                       "تنزيل الزوج/الزوجة (يعمل/تعمل)")
        XCTAssertEqual(spouseRebateTitle(status: .spouseDependent, language: .english),
                       "Wife / Husband Rebate (Does Not Work)")
        XCTAssertEqual(spouseRebateTitle(status: .spouseWorks, language: .english),
                       "Wife / Husband Rebate (Works)")
        // The two statuses must never collapse to the same label.
        XCTAssertNotEqual(spouseRebateTitle(status: .spouseDependent, language: .arabic),
                          spouseRebateTitle(status: .spouseWorks, language: .arabic))
    }

    /// A working spouse legitimately yields a zero rebate, but the row is still shown
    /// (gated on marital status, not amount) so the selected status stays visible.
    func testWorkingSpouseYieldsZeroRebateWhileDependentSpouseDoesNot() {
        func rebate(_ status: MaritalStatus) -> Double {
            TaxEngines.calculateProfitTax(
                rawProfitInput: "5000000000", currency: .lbp,
                maritalStatus: status, childrenCount: 0, exchangeRate: 89_500
            ).spouseRebate
        }
        XCTAssertEqual(rebate(.spouseWorks), 0, accuracy: 0.001)
        XCTAssertEqual(rebate(.spouseDependent), 225_000_000, accuracy: 0.001)
        XCTAssertEqual(rebate(.single), 0, accuracy: 0.001)
    }

    // MARK: - Android parity: number input formatting (spec item 5)

    func testThousandsGroupingMatchesAndroidVisualTransformation() {
        XCTAssertEqual(NumericTextField.group("1500", grouping: true), "1,500")
        XCTAssertEqual(NumericTextField.group("120000000", grouping: true), "120,000,000")
        XCTAssertEqual(NumericTextField.group("230000000", grouping: true), "230,000,000")
        XCTAssertEqual(NumericTextField.group("0", grouping: true), "0")
        XCTAssertEqual(NumericTextField.group("", grouping: true), "")
        // Only the integer part is grouped; a trailing dot survives mid-typing.
        XCTAssertEqual(NumericTextField.group("1500.", grouping: true), "1,500.")
        XCTAssertEqual(NumericTextField.group("1234567.89", grouping: true), "1,234,567.89")
        // Grouping off for day/month/year style fields.
        XCTAssertEqual(NumericTextField.group("2026", grouping: false), "2026")
    }

    func testSanitizeKeepsAtMostOneDecimalPointAndDropsJunk() {
        XCTAssertEqual(NumericTextField.sanitize("1,500", decimal: false), "1500")
        XCTAssertEqual(NumericTextField.sanitize("1.5.7", decimal: true), "1.57")
        XCTAssertEqual(NumericTextField.sanitize("12.34", decimal: false), "1234")
        XCTAssertEqual(NumericTextField.sanitize("abc12x3", decimal: true), "123")
    }

    // MARK: - Android parity: bidi-safe money (spec item 15)

    func testMoneyUsesWesternDigitsAndNonBreakingSpaceInBothLanguages() {
        XCTAssertEqual(money(result: 221_370_000, language: .english), "221,370,000\u{00A0}LBP")
        XCTAssertEqual(money(result: 221_370_000, language: .arabic), "\u{2066}\u{0644}.\u{0644}\u{00A0}221,370,000\u{2069}")
    }

    /// A single LRM is not enough to stop SwiftUI's Text from reordering the sign,
    /// number, and currency to match the surrounding Arabic paragraph direction — the
    /// whole value must be wrapped in a LEFT-TO-RIGHT ISOLATE so it renders as one
    /// atomic block, in the exact order Android's screenshots show.
    func testNegativeArabicMoneyIsWrappedInLeftToRightIsolate() {
        let value = money(result: -9_440_000, language: .arabic)
        XCTAssertTrue(value.hasPrefix("\u{2066}"), "Arabic money must be wrapped in a LEFT-TO-RIGHT ISOLATE")
        XCTAssertTrue(value.hasSuffix("\u{2069}"), "the isolate must be closed with POP DIRECTIONAL ISOLATE")
        XCTAssertTrue(value.contains("\u{200E}"), "the sign itself still carries an LRM")
        XCTAssertTrue(value.contains("-9,440,000"))
        // Currency leads in Arabic.
        XCTAssertTrue(value.hasPrefix("\u{2066}\u{0644}.\u{0644}"), "ل.ل must come first: \(value)")
    }

    func testSignedMoneyKeepsSignAttachedAndLeavesZeroUnsigned() {
        XCTAssertEqual(signedMoney(9_440_000, isDeduction: true, language: .english), "-\u{00A0}9,440,000\u{00A0}LBP")
        XCTAssertEqual(signedMoney(4_410_000, isDeduction: false, language: .english), "+\u{00A0}4,410,000\u{00A0}LBP")
        XCTAssertEqual(signedMoney(9_440_000, isDeduction: true, language: .arabic), "\u{2066}\u{0644}.\u{0644}\u{00A0}\u{200E}-\u{00A0}9,440,000\u{2069}")
        XCTAssertEqual(signedMoney(4_410_000, isDeduction: false, language: .arabic), "\u{2066}\u{0644}.\u{0644}\u{00A0}\u{200E}+\u{00A0}4,410,000\u{2069}")
        // Zero is unsigned in both languages, matching formatWithSign.
        XCTAssertEqual(signedMoney(0, isDeduction: true, language: .english), "0\u{00A0}LBP")
        XCTAssertFalse(signedMoney(0, isDeduction: true, language: .arabic).contains("-"))
    }

    // MARK: - Android parity: Arabic dates (spec items 23, 28)

    func testPenaltyDatesUseAbbreviatedEnglishAndArabicIndicArabic() {
        // English: abbreviated month, Western digits, day first, no comma.
        XCTAssertEqual(penaltyDateText(DateComponents(year: 2026, month: 1, day: 20), language: .english), "20 Jan 2026")
        XCTAssertEqual(penaltyDateText(DateComponents(year: 2026, month: 4, day: 15), language: .english), "15 Apr 2026")
        XCTAssertEqual(penaltyDateText(DateComponents(year: 2026, month: 5, day: 31), language: .english), "31 May 2026")

        // Arabic: full Levantine month name, Arabic-Indic digits for day and year.
        let april = penaltyDateText(DateComponents(year: 2026, month: 4, day: 15), language: .arabic)
        XCTAssertEqual(april, "\(arabicDigits("15")) نيسان \(arabicDigits("2026"))")
        XCTAssertTrue(april.contains("نيسان"))
        XCTAssertFalse(april.contains("15"), "Arabic dates must not keep Western digits")

        let january = penaltyDateText(DateComponents(year: 2026, month: 1, day: 20), language: .arabic)
        XCTAssertEqual(january, "\(arabicDigits("20")) كانون الثاني \(arabicDigits("2026"))")
    }

    func testArabicDigitConversion() {
        XCTAssertEqual(arabicDigits("2026"), "\u{0662}\u{0660}\u{0662}\u{0666}")
        XCTAssertEqual(arabicDigits("15/4"), "\u{0661}\u{0665}/\u{0664}")
    }

    // MARK: - Android parity: localization completeness (spec items 19, 20, 25)

    func testVatArabicLabelIsAddedValueTaxNotTva() {
        XCTAssertEqual(Copy.t("vatPenalties", .arabic), "\u{0627}\u{0644}\u{0636}\u{0631}\u{064A}\u{0628}\u{0629} \u{0627}\u{0644}\u{0645}\u{0636}\u{0627}\u{0641}\u{0629}")
        XCTAssertFalse(Copy.t("vatPenalties", .arabic).contains("TVA"))
    }

    func testEveryCopyKeyResolvesInBothLanguages() {
        // A key that falls through returns itself; assert none of the keys the parity
        // pass added silently regress to that fallback.
        let keys = [
            "taxTypeLabel", "companyTaxpayerType", "companySal", "companySarl",
            "companyPartnership", "companyIndividual", "companyExempt", "companyOther",
            "minPrefix", "corporateNote", "fiscalPenaltyAssessment", "legalDueDateRow",
            "actualPaymentDateRow", "totalDelayPeriod", "monthsSuffix", "delayExplain",
            "noDelayExplain", "principalTaxAmount", "verificationFineMinimum",
            "verificationFine5", "verificationFine10", "collectionFine3", "collectionFine2",
            "grandTotalToRepay", "principalPlusFines", "compliancePenaltyWarning",
            "calculatePenaltiesBtn", "calculatePayrollTaxes", "calculateProfitTaxBtn",
            "annualNssfNote", "putRateWarning", "contactHeading", "familyBranchNumbered",
            "subjectBaseSickness", "ceilingSickness", "empContrib3", "emprContrib8",
            "subjectBaseFamily", "ceilingFamily", "empContrib0", "emprContrib6",
            "emprContrib85", "minFloorZero", "minFloorBelow", "minFloorCalc", "capAlert",
            "selectCurrency", "spouseStatusDependent", "spouseStatusWorks"
        ]
        for key in keys {
            XCTAssertNotEqual(Copy.t(key, .english), key, "missing EN copy for \(key)")
            XCTAssertNotEqual(Copy.t(key, .arabic), key, "missing AR copy for \(key)")
        }
    }

    func testCorporateNoteAndAnnualNssfNoteMatchAndroidWording() {
        XCTAssertTrue(Copy.t("corporateNote", .english).hasPrefix("Important Corporate/Partnership Note:"))
        XCTAssertTrue(Copy.t("corporateNote", .english).contains("statutory auditor's report"))
        XCTAssertTrue(Copy.t("annualNssfNote", .english).hasPrefix("Annual NSSF Note:"))
        XCTAssertTrue(Copy.t("annualNssfNote", .english).contains("monthly ceiling multiplied by 12"))
    }

    func testPenaltyResultTitlesMatchSpec() {
        XCTAssertEqual(Copy.t("fiscalPenaltyAssessment", .english), "Fiscal Penalty Assessment")
        XCTAssertEqual(
            Copy.t("fiscalPenaltyAssessment", .arabic),
            "\u{0628}\u{064A}\u{0627}\u{0646} \u{063A}\u{0631}\u{0627}\u{0645}\u{0627}\u{062A} \u{0627}\u{0644}\u{062A}\u{0623}\u{062E}\u{064A}\u{0631} \u{0648}\u{0627}\u{0644}\u{0645}\u{0633}\u{062A}\u{062D}\u{0642}\u{0627}\u{062A}"
        )
    }

    // MARK: - Regression examples from the parity spec (item 24)

    func testSpecRegressionExampleA_VatIndividual2026() {
        let result = TaxEngines.calculatePenalties(
            companyType: "OTHER", taxType: "VAT", taxAmount: 15_000_000,
            payrollYear: 2026, quarter: "Q1", profitDueYear: 2026,
            payDay: 21, payMonth: 8, payYear: 2026,
            dueDayOverride: 20, dueMonthOverride: 1, dueYearOverride: 2026
        )
        XCTAssertEqual(result.lateMonths, 8)
        XCTAssertEqual(result.verificationFine, 12_000_000, accuracy: 0.001)
        XCTAssertEqual(result.collectionFine, 6_480_000, accuracy: 0.001)
        XCTAssertEqual(result.totalAmount, 33_480_000, accuracy: 0.001)
    }

    func testSpecRegressionExampleB_ProfitSal2026() {
        let result = TaxEngines.calculatePenalties(
            companyType: "SAL", taxType: "PROFIT", taxAmount: 250_000_000,
            payrollYear: 2026, quarter: "Q1", profitDueYear: 2026,
            payDay: 21, payMonth: 8, payYear: 2026,
            dueDayOverride: 31, dueMonthOverride: 5, dueYearOverride: 2026
        )
        XCTAssertEqual(result.lateMonths, 3)
        XCTAssertEqual(result.verificationFine, 75_000_000, accuracy: 0.001)
        XCTAssertEqual(result.collectionFine, 19_500_000, accuracy: 0.001)
        XCTAssertEqual(result.totalAmount, 344_500_000, accuracy: 0.001)
    }

    func testSpecRegressionExampleC_PayrollQ1Sal2026() {
        let result = TaxEngines.calculatePenalties(
            companyType: "SAL", taxType: "PAYROLL", taxAmount: 650_000_000,
            payrollYear: 2026, quarter: "Q1", profitDueYear: 2026,
            payDay: 21, payMonth: 8, payYear: 2026,
            dueDayOverride: 15, dueMonthOverride: 4, dueYearOverride: 2026
        )
        XCTAssertEqual(result.lateMonths, 5)
        XCTAssertEqual(result.verificationFine, 162_500_000, accuracy: 0.001)
        XCTAssertEqual(result.collectionFine, 121_880_000, accuracy: 0.001)
        XCTAssertEqual(result.totalAmount, 934_380_000, accuracy: 0.001)
    }
}

final class ReversePayrollParityTests: XCTestCase {
    private func forward(month: Int = 10, marital: MaritalStatus = .single, children: Int = 0,
                         nssf: Bool = true, rebates: Bool = true) -> (Double) -> PayrollItem {
        { gross in
            PayrollEngine.calculate(basicSalary: gross, employmentType: .monthly,
                maritalStatus: marital, childrenCount: children, month: month,
                nssfRegistered: nssf, useFamilyRebates: rebates, period: .monthly)
        }
    }

    func testTwoThousandDollarReferenceAndLbpHandoff() throws {
        let f = forward()
        let result = try XCTUnwrap(ReversePayrollEngine.calculate(targetLbp: 179_000_000, workingDays: 22, usd: true, forward: f))
        XCTAssertEqual(result.payroll.basicSalary, 179_820_715, accuracy: 0.0001)
        XCTAssertEqual(result.amountBeforeDeductionsLbp, 189_720_715, accuracy: 0.0001)
        XCTAssertEqual(result.matchedNetLbp, result.amountBeforeDeductionsLbp - result.payroll.taxAmount - result.payroll.totalNssfEmployee, accuracy: 0.0001)
        XCTAssertEqual(result.payroll.taxAmount, 7_120_000, accuracy: 0.0001)
        XCTAssertEqual(result.payroll.totalNssfEmployee, 3_600_000, accuracy: 0.0001)
        XCTAssertEqual(result.matchedNetLbp, 179_000_715, accuracy: 0.0001)
        XCTAssertEqual(f(2009.17 * 89_500).netSalary + result.transportLbp, result.matchedNetLbp, accuracy: 0.0001)
        let lbp = try XCTUnwrap(ReversePayrollEngine.calculate(targetLbp: 179_000_000, workingDays: 22, usd: false, forward: f))
        XCTAssertEqual(lbp.payroll.basicSalary, 179_820_000, accuracy: 0.0001)
        XCTAssertEqual(lbp.matchedNetLbp, 179_000_000, accuracy: 0.0001)
    }

    func testFamilyAllowancesAreOptionalWithoutChangingExistingRebates() throws {
        let f = forward(marital: .spouseDependent, children: 2)
        let included = try XCTUnwrap(ReversePayrollEngine.calculate(targetLbp: 179_000_000, workingDays: 26, usd: true,
            includeFamilyBenefits: true, forward: f))
        let onTop = try XCTUnwrap(ReversePayrollEngine.calculate(targetLbp: 179_000_000, workingDays: 26, usd: true,
            includeFamilyBenefits: false, forward: f))
        XCTAssertEqual(included.payroll.totalFamilyBenefitsAmount, 4_410_000, accuracy: 0.0001)
        XCTAssertEqual(included.payroll.familyRebatesAmount, onTop.payroll.familyRebatesAmount, accuracy: 0.0001)
        XCTAssertGreaterThan(onTop.payroll.basicSalary, included.payroll.basicSalary)
        XCTAssertGreaterThanOrEqual(included.matchedNetLbp, included.targetLbp)
        XCTAssertGreaterThanOrEqual(onTop.matchedNetLbp, onTop.targetLbp)
        XCTAssertEqual(onTop.matchedNetLbp + 4_410_000, onTop.payroll.netSalary + onTop.transportLbp, accuracy: 0.0001)
    }

    func testRoundedTaxBoundariesRemainAboveTargetAndUseTheLowestPayableUnit() throws {
        for marital in MaritalStatus.allCases {
            for rebates in [true, false] {
                for month in [6, 7, 8, 12] {
                    let f = forward(month: month, marital: marital, children: marital == .single ? 0 : 3, rebates: rebates)
                    for gross in [28_000_000.0, 67_500_001, 112_500_001, 187_500_001, 337_500_001,
                                  637_500_001, 1_162_500_001, 999_000_000_000] {
                        let target = f(gross).netSalary + 9_900_000
                        for usd in [false, true] {
                            let result = try XCTUnwrap(ReversePayrollEngine.calculate(targetLbp: target, workingDays: 22, usd: usd, forward: f))
                            XCTAssertGreaterThanOrEqual(result.matchedNetLbp, target - 0.0001)
                            let unit = usd ? 895.0 : 1.0
                            XCTAssertLessThan(f(result.payroll.basicSalary - unit).netSalary + result.transportLbp, target - 0.0001)
                            if usd {
                                let raw = String(format: "%.2f", locale: Locale(identifier: "en_US_POSIX"), result.payroll.basicSalary / 89_500)
                                let handoff = try XCTUnwrap(Double(raw)) * 89_500
                                XCTAssertEqual(f(handoff).netSalary + result.transportLbp, result.matchedNetLbp, accuracy: 0.001)
                            }
                        }
                    }
                }
            }
        }
    }

    func testTransportIsExcludedFromSalaryTaxAndEveryNssfBase() throws {
        for marital in [MaritalStatus.single, .spouseDependent] {
            for registered in [true, false] {
                let f = forward(marital: marital, children: marital == .single ? 0 : 2, nssf: registered)
                let salaryOnly = f(40_000_000)
                for includeFamily in [true, false] {
                    for days in [0, 22, 26, 30] {
                        let transport = Double(days) * 450_000
                        let target = salaryOnly.netSalary + transport - (includeFamily ? 0 : salaryOnly.totalFamilyBenefitsAmount)
                        let result = try XCTUnwrap(ReversePayrollEngine.calculate(targetLbp: target, workingDays: days,
                            usd: false, includeFamilyBenefits: includeFamily, forward: f))
                        XCTAssertEqual(result.payroll.grossSalary, 40_000_000, accuracy: 0.0001)
                        XCTAssertEqual(result.amountBeforeDeductionsLbp, 40_000_000 + transport, accuracy: 0.0001)
                        XCTAssertEqual(target, result.amountBeforeDeductionsLbp - result.payroll.taxAmount - result.payroll.totalNssfEmployee + (includeFamily ? result.payroll.totalFamilyBenefitsAmount : 0), accuracy: 0.0001)
                        XCTAssertEqual(result.payroll.taxableSalary, salaryOnly.taxableSalary, accuracy: 0.0001)
                        XCTAssertEqual(result.payroll.taxAmount, salaryOnly.taxAmount, accuracy: 0.0001)
                        XCTAssertEqual(result.payroll.sicknessMaternityBase, salaryOnly.sicknessMaternityBase, accuracy: 0.0001)
                        XCTAssertEqual(result.payroll.familyAllowanceBase, salaryOnly.familyAllowanceBase, accuracy: 0.0001)
                        XCTAssertEqual(result.payroll.endOfServiceBase, salaryOnly.endOfServiceBase, accuracy: 0.0001)
                        XCTAssertEqual(result.payroll.totalNssfEmployee, salaryOnly.totalNssfEmployee, accuracy: 0.0001)
                        XCTAssertEqual(result.payroll.totalNssfEmployer, salaryOnly.totalNssfEmployer, accuracy: 0.0001)
                        XCTAssertEqual(result.matchedNetLbp, target, accuracy: 0.0001)
                    }
                }
            }
        }
        let reference = try XCTUnwrap(ReversePayrollEngine.calculate(targetLbp: 50_450_000, workingDays: 26,
            usd: false, forward: forward()))
        XCTAssertEqual(reference.payroll.taxAmount, 50_000, accuracy: 0.0001)
        XCTAssertEqual(reference.payroll.totalNssfEmployee, 1_200_000, accuracy: 0.0001)
        XCTAssertEqual(reference.payroll.totalNssfEmployer, 8_280_000, accuracy: 0.0001)
        XCTAssertEqual(reference.payroll.netSalary, 38_750_000, accuracy: 0.0001)
        XCTAssertEqual(reference.transportLbp, 11_700_000, accuracy: 0.0001)
    }

    @MainActor
    func testCurrencyTargetsStaySeparateAndResetClearsBoth() {
        let state = AppState()
        state.payrollCurrency = .lbp
        state.reverseNetTarget = "179000000"
        state.payrollCurrency = .usd
        XCTAssertEqual(state.reverseNetTarget, "")
        state.reverseNetTarget = "2000"
        state.payrollCurrency = .lbp
        XCTAssertEqual(state.reverseNetTarget, "179000000")
        state.payrollCurrency = .usd
        XCTAssertEqual(state.reverseNetTarget, "2000")
        state.reverseWorkingDays = "26"
        state.reverseIncludeFamily = false
        state.resetPayroll()
        XCTAssertEqual(state.reverseNetTargetLbp, "")
        XCTAssertEqual(state.reverseNetTargetUsd, "")
        XCTAssertEqual(state.reverseWorkingDays, "")
        XCTAssertTrue(state.reverseIncludeFamily)
    }

    func testTransportNssfCapsAndValidation() throws {
        let july = try XCTUnwrap(ReversePayrollEngine.calculate(targetLbp: 179_000_000, workingDays: 22, usd: false, forward: forward(month: 7)))
        let august = try XCTUnwrap(ReversePayrollEngine.calculate(targetLbp: 179_000_000, workingDays: 22, usd: false, forward: forward(month: 8)))
        XCTAssertEqual(july.payroll.totalNssfEmployee, 2_700_000, accuracy: 0.0001)
        XCTAssertEqual(august.payroll.totalNssfEmployee, 3_600_000, accuracy: 0.0001)
        let f = forward(marital: .spouseDependent, children: 5, nssf: false)
        let noNssf = try XCTUnwrap(ReversePayrollEngine.calculate(targetLbp: 179_000_000, workingDays: 26, usd: false, forward: f))
        XCTAssertEqual(noNssf.payroll.totalNssfEmployee, 0)
        XCTAssertEqual(noNssf.payroll.totalFamilyBenefitsAmount, 0)
        XCTAssertEqual(noNssf.transportLbp, 11_700_000)
        XCTAssertEqual(ReversePayrollEngine.target("٢٬٠٠٠٫٠٠", usd: true), 179_000_000)
        XCTAssertEqual(ReversePayrollEngine.workingDays("٢٦"), 26)
        XCTAssertEqual(ReversePayrollEngine.workingDays("٣٠"), 30)
        for raw in ["", "-1", "NaN", "Infinity", "1e8", "2a000", "12,34", "0", "2000.001"] {
            XCTAssertNil(ReversePayrollEngine.target(raw, usd: true))
        }
        for raw in ["", "-1", "31", "٣١", "32", "22.5", "2a2"] { XCTAssertNil(ReversePayrollEngine.workingDays(raw)) }
        XCTAssertNil(ReversePayrollEngine.calculate(targetLbp: 179_000_000, workingDays: 31, usd: true, forward: forward()))
        XCTAssertNil(ReversePayrollEngine.calculate(targetLbp: 9_900_000, workingDays: 22, usd: false, forward: forward()))
        XCTAssertNil(ReversePayrollEngine.calculate(targetLbp: 1_000_000_000_000, workingDays: 0, usd: false, forward: forward()))
    }
}
