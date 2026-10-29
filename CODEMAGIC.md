# Shipping Tax Pulse to the App Store with Codemagic (no Mac needed)

Codemagic builds the app on its own cloud Macs, signs it, and uploads it to
App Store Connect. Everything below runs in a web browser, so a phone or
tablet works.

## What you need

- An **Apple Developer Program** membership (paid, $99/year). The project is
  already set to team `9Z53TXRXSS` and bundle ID `com.haddad.taxpulse`.
- **Admin** or **Account Holder** access in App Store Connect (needed to make an API key).
- A free **Codemagic** account at <https://codemagic.io>. Sign in with GitHub.

## One-time setup

### 1. Register the app in App Store Connect
1. <https://appstoreconnect.apple.com> → **Apps** → **+** → **New App**.
2. Platform iOS, name "Tax Pulse", bundle ID `com.haddad.taxpulse`
   (if it is not in the list, create it first under
   <https://developer.apple.com/account/resources/identifiers>).
3. Open the app → **App Information** → copy the numeric **Apple ID**
   (e.g. `6501234567`). Put it in `codemagic.yaml` as `APP_STORE_APPLE_ID`.

### 2. Create an App Store Connect API key
1. App Store Connect → **Users and Access** → **Integrations** → **App Store Connect API**.
2. **Generate API Key**, access **App Manager**.
3. Note the **Issuer ID** and **Key ID**, and download the `.p8` file
   (it can be downloaded only once).

### 3. Connect the key to Codemagic
1. Codemagic → **Team settings** → **Team integrations** → **Developer Portal** → **Manage keys** → **Add key**.
2. Name it exactly **`TaxPulse ASC Key`** (the name used in `codemagic.yaml`),
   paste the Issuer ID and Key ID, upload the `.p8`.

### 4. Create signing files (Codemagic does it for you)
1. Codemagic → **Team settings** → **Code signing identities**.
2. **iOS certificates** tab → **Generate certificate** → type *Apple Distribution*,
   using the key from step 3. Save the certificate (and its password) in Codemagic.
3. **iOS provisioning profiles** tab → **Fetch profiles** (or create one) →
   pick the *App Store* profile for `com.haddad.taxpulse`.

### 5. Add the repository
Codemagic → **Add application** → GitHub → `haddadauditfirm/tax-pulse-for-ios`
→ project type **iOS App** → it will detect `codemagic.yaml`.

## Releasing a build

- **Start manually:** in Codemagic open the app → **Start new build** →
  workflow **Tax Pulse iOS — App Store** → choose the branch.
- **Or push a tag** starting with `v` (e.g. `v1.0.3`) and the build starts on its own.
  You can create tags from GitHub's website under **Releases**.

The workflow runs the unit tests, builds a signed `.ipa` with the next free
build number, and uploads it to **TestFlight**. Install the TestFlight app on
your iPhone to try it.

To send it for review: in App Store Connect fill in screenshots, description,
privacy details and pricing, pick the uploaded build, then **Submit for Review**.
(Or set `submit_to_app_store: true` in `codemagic.yaml` once the listing is complete.)

To ship a new version (e.g. 1.0.3), change `MARKETING_VERSION` in
`TaxPulseIOS.xcodeproj/project.pbxproj` — or ask Claude to bump it.

## Common errors

| Message | Fix |
|---|---|
| `No matching profiles found` | Repeat step 4; check the bundle ID is `com.haddad.taxpulse`. |
| `Integration "TaxPulse ASC Key" not found` | The key name in step 3 must match `codemagic.yaml` exactly. |
| `The bundle version must be higher` | Set `APP_STORE_APPLE_ID` correctly so the build number auto-increments. |
| Missing compliance prompt in TestFlight | Already handled: `ITSAppUsesNonExemptEncryption = NO`. |
