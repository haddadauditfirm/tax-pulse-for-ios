# Tax Pulse iOS

Native SwiftUI iOS port of the uploaded Android/Kotlin Tax Pulse app.

## What is included

- Onboarding welcome screen with animated Tax Pulse line
- English/Arabic language selection
- Service chooser for Payroll Tax, Tax on Profit, Tax Penalties, and Extensions
- Payroll/NSSF calculation engine ported from the Kotlin source
- Android-style vertical selector rows with selected radio/check indicators
- Monthly, annual, daily, hourly, and lump-sum payroll branches
- Basic salary, allowances, bonuses, overtime, NSSF, family rebate, and annual ceiling inputs
- Profit tax progressive bracket engine ported from the Kotlin source
- Penalties and deadline extension logic ported from the Kotlin source
- Seeded Android-equivalent users, companies, employees, law data, and 63 audit logs
- Local saving, auto-loading, and retrieval for MOF extension dates with `UserDefaults`
- App icon asset catalog and starter `en`/`ar` localization structure
- Unit tests for Android/iOS calculation parity, including the 75,000,000 LBP reference sample

## Open in Xcode

1. Open `TaxPulseIOS.xcodeproj` on a Mac with Xcode.
2. Select the `TaxPulseIOS` scheme.
3. Choose an iPhone simulator.
4. Build and run.

The project targets iOS 17 and uses only SwiftUI/Foundation, with no external dependencies.
