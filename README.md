# Tax Pulse iOS

Native SwiftUI iOS port of the uploaded Android/Kotlin Tax Pulse app.

## What is included

- Onboarding welcome screen with animated Tax Pulse line
- English/Arabic language selection
- Service chooser for Payroll Tax, Tax on Profit, Tax Penalties, and Extensions
- Payroll/NSSF calculation engine ported from the Kotlin source
- Profit tax progressive bracket engine ported from the Kotlin source
- Penalties and deadline extension logic ported from the Kotlin source
- Local saving and retrieval for MOF extension dates with `UserDefaults`

## Open in Xcode

1. Open `TaxPulseIOS.xcodeproj` on a Mac with Xcode.
2. Select the `TaxPulseIOS` scheme.
3. Choose an iPhone simulator.
4. Build and run.

The project targets iOS 17 and uses only SwiftUI/Foundation, with no external dependencies.
