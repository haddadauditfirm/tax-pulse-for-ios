import SwiftUI

// MARK: - Copy (EN / AR), mirroring Android's AuthCopy

enum AuthCopy {
    private static let strings: [String: (String, String)] = [
        "signInTitle": ("Sign in to Tax Pulse", "تسجيل الدخول إلى Tax Pulse"),
        "signInSub": ("Enter your email and we'll send you a 6-digit code.",
                      "أدخل بريدك الإلكتروني وسنرسل لك رمزاً من 6 أرقام."),
        "emailLabel": ("Email address", "البريد الإلكتروني"),
        "emailPlaceholder": ("name@company.com", "name@company.com"),
        "sendCode": ("Send code", "إرسال الرمز"),
        "checkEmail": ("Check your email", "تحقق من بريدك الإلكتروني"),
        "codeSentTo": ("We sent a 6-digit code to", "أرسلنا رمزاً من 6 أرقام إلى"),
        "change": ("Change", "تغيير"),
        "verify": ("Verify & continue", "تحقق ومتابعة"),
        "resendIn": ("Resend code in %@", "إعادة إرسال الرمز خلال %@"),
        "resend": ("Didn't get it? Resend code", "لم يصلك؟ أعد إرسال الرمز"),
        "pasteCode": ("Copied the code? Paste it here", "نسخت الرمز؟ الصقه هنا"),
        "spamTip": ("Can't find it? Check your spam or junk folder.",
                    "لم تجده؟ تحقق من مجلد الرسائل غير المرغوب فيها."),
        "errInvalidEmail": ("Please enter a valid email address.", "يرجى إدخال بريد إلكتروني صالح."),
        "errDisposable": ("Temporary or disposable email addresses aren't allowed. Please use your personal or work email.",
                          "لا يُسمح بعناوين البريد المؤقتة. يرجى استخدام بريدك الشخصي أو بريد العمل."),
        "errRateLimited": ("Too many attempts. Please wait a minute and try again.",
                           "محاولات كثيرة. يرجى الانتظار دقيقة ثم المحاولة مجدداً."),
        "errInvalidCode": ("That code is incorrect or has expired. Check the latest email and try again.",
                           "الرمز غير صحيح أو انتهت صلاحيته. تحقق من آخر رسالة وحاول مجدداً."),
        "errNetwork": ("No connection. Check your internet and try again.", "لا يوجد اتصال. تحقق من الإنترنت وحاول مجدداً."),
        "errRevoked": ("You've been signed out. Please sign in again.", "تم تسجيل خروجك. يرجى تسجيل الدخول مجدداً."),
        "errNotConfigured": ("Sign-in isn't configured in this build yet.", "لم يتم إعداد تسجيل الدخول في هذا الإصدار بعد."),
        "errUnknown": ("Something went wrong. Please try again.", "حدث خطأ ما. يرجى المحاولة مجدداً."),
        "account": ("Account", "الحساب"),
        "signedInAs": ("Signed in as", "مسجل الدخول باسم"),
        "fullNamePlaceholder": ("Add your name", "أضف اسمك"),
        "profile": ("Profile", "الملف الشخصي"),
        "close": ("Close", "إغلاق"),
        "personalInfo": ("Personal information", "المعلومات الشخصية"),
        "privacy": ("Privacy & security", "الخصوصية والأمان"),
        "privacySub": ("Your data and account", "بياناتك وحسابك"),
        "firstName": ("First name", "الاسم"),
        "lastName": ("Last name", "اسم العائلة"),
        "firstNamePlaceholder": ("Enter your first name", "أدخل اسمك"),
        "lastNamePlaceholder": ("Enter your last name", "أدخل اسم العائلة"),
        "emailLocked": ("This is the email you sign in with and can't be changed.",
                        "هذا هو البريد الذي تسجل الدخول به ولا يمكن تغييره."),
        "dangerZone": ("Account", "الحساب"),
        "deleteAccountSub": ("Permanently remove your account and profile", "إزالة حسابك وملفك الشخصي نهائياً"),
        "save": ("Save", "حفظ"),
        "saved": ("Saved", "تم الحفظ"),
        "saveFailed": ("Couldn't save. Check your connection.", "تعذر الحفظ. تحقق من الاتصال."),
        "signOut": ("Sign out", "تسجيل الخروج"),
        "signOutTitle": ("Sign out?", "تسجيل الخروج؟"),
        "signOutMsg": ("Are you sure you want to sign out?", "هل أنت متأكد أنك تريد تسجيل الخروج؟"),
        "deleteAccount": ("Delete account", "حذف الحساب"),
        "deleteTitle": ("Delete your account?", "حذف حسابك؟"),
        "deleteMsg": ("This permanently deletes your Tax Pulse account and profile. This can't be undone.",
                      "سيؤدي هذا إلى حذف حسابك وملفك الشخصي في Tax Pulse نهائياً. لا يمكن التراجع عن ذلك."),
        "deleteFailed": ("Couldn't delete your account. Check your connection and try again.",
                         "تعذر حذف الحساب. تحقق من الاتصال وحاول مجدداً."),
        "cancel": ("Cancel", "إلغاء"),
        "version": ("Version %@", "الإصدار %@"),
        "updateAvailable": ("Update available", "تحديث متوفر"),
        "updateAvailableMsg": ("A new version of Tax Pulse is ready with the latest improvements.",
                               "إصدار جديد من Tax Pulse جاهز مع أحدث التحسينات."),
        "updateRequired": ("Update required", "التحديث مطلوب"),
        "updateRequiredMsg": ("This version of Tax Pulse is no longer supported. Please update to keep using the app.",
                              "هذا الإصدار من Tax Pulse لم يعد مدعوماً. يرجى التحديث لمتابعة استخدام التطبيق."),
        "updateNow": ("Update now", "حدّث الآن"),
        "later": ("Later", "لاحقاً"),
        "whatsNew": ("What's new", "ما الجديد")
    ]

    static func t(_ key: String, _ language: AppLanguage) -> String {
        guard let pair = strings[key] else { return key }
        return language == .arabic ? pair.1 : pair.0
    }

    static func error(_ error: AuthError, _ language: AppLanguage) -> String {
        switch error {
        case .invalidEmail: return t("errInvalidEmail", language)
        case .disposableEmail: return t("errDisposable", language)
        case .rateLimited: return t("errRateLimited", language)
        case .invalidCode: return t("errInvalidCode", language)
        case .network: return t("errNetwork", language)
        case .sessionRevoked: return t("errRevoked", language)
        case .notConfigured: return t("errNotConfigured", language)
        case .unknown: return t("errUnknown", language)
        }
    }
}

private let authBlue = Color(hex: 0x3B82F6)
private let authBlueLight = Color(hex: 0x60A5FA)
private let authMuted = Color(hex: 0x94A3B8)
private let authErrorRed = Color(hex: 0xF87171)

// MARK: - Sign-in flow (email → code)

struct AuthFlowView: View {
    @EnvironmentObject private var state: AppState
    @EnvironmentObject private var auth: AuthStore

    var body: some View {
        ZStack {
            AuthBackground()
            switch auth.stage {
            case .email:
                AuthEmailStep(onBack: { state.onboardingStep = 2 })
                    .transition(.asymmetric(insertion: .move(edge: .leading), removal: .move(edge: .leading)).combined(with: .opacity))
            case .code:
                AuthCodeStep()
                    .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .trailing)).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.32), value: auth.stage)
    }
}

private struct AuthEmailStep: View {
    @EnvironmentObject private var state: AppState
    @EnvironmentObject private var auth: AuthStore
    var onBack: () -> Void
    @FocusState private var focused: Bool

    var body: some View {
        let language = state.language
        ZStack(alignment: .top) {
            GeometryReader { viewport in
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    AuthHeroIcon(systemName: "envelope.fill")
                    Spacer().frame(height: 24)
                    Text(AuthCopy.t("signInTitle", language))
                        .font(.app(24, weight: .heavy))
                        .foregroundStyle(Color.white)
                        .multilineTextAlignment(.center)
                    Text(AuthCopy.t("signInSub", language))
                        .font(.app(14))
                        .foregroundStyle(authMuted)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.top, 8)
                        .padding(.bottom, 32)

                    AuthGlassCard {
                        Text(AuthCopy.t("emailLabel", language))
                            .font(.app(12, weight: .bold))
                            .foregroundStyle(authBlueLight)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Spacer().frame(height: 8)
                        AuthEmailField(
                            text: Binding(get: { auth.email }, set: { auth.setEmail($0) }),
                            placeholder: AuthCopy.t("emailPlaceholder", language),
                            isError: auth.error != nil,
                            disabled: auth.isBusy,
                            focused: $focused,
                            onSubmit: submit
                        )
                        if let message = auth.error ?? auth.signedOutReason {
                            AuthInlineError(text: AuthCopy.error(message, language))
                                .transition(.opacity.combined(with: .move(edge: .top)))
                        }
                        Spacer().frame(height: 20)
                        AuthPrimaryButton(
                            title: AuthCopy.t("sendCode", language),
                            loading: auth.isBusy,
                            enabled: !auth.email.isEmpty,
                            action: submit
                        )
                    }
                    .animation(.easeInOut(duration: 0.2), value: auth.error)
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 72)
                // Centred in the viewport like Android's Arrangement.Center; scrolls when taller.
                .frame(minHeight: viewport.size.height)
            }
            .scrollDismissesKeyboard(.interactively)
            }
            TopBackButton {
                focused = false
                onBack()
            }
            .zIndex(1)
        }
        .onAppear { if auth.email.isEmpty { focused = true } }
    }

    private func submit() {
        focused = false
        auth.sendCode()
    }
}

private struct AuthCodeStep: View {
    @EnvironmentObject private var state: AppState
    @EnvironmentObject private var auth: AuthStore
    @State private var shake: CGFloat = 0

    var body: some View {
        let language = state.language
        ZStack(alignment: .top) {
            GeometryReader { viewport in
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    AuthHeroIcon(systemName: "envelope.open.fill")
                    Spacer().frame(height: 24)
                    Text(AuthCopy.t("checkEmail", language))
                        .font(.app(24, weight: .heavy))
                        .foregroundStyle(Color.white)
                    Text(AuthCopy.t("codeSentTo", language))
                        .font(.app(14))
                        .foregroundStyle(authMuted)
                        .padding(.top, 8)
                    Spacer().frame(height: 10)

                    // The email stays on screen, with a one-tap way to fix a typo.
                    Button { auth.backToEmail() } label: {
                        HStack(spacing: 8) {
                            Text(auth.email)
                                .font(.app(14, weight: .bold))
                                .foregroundStyle(Color.white)
                                .lineLimit(1)
                                .truncationMode(.middle)
                                .environment(\.layoutDirection, .leftToRight)
                            Text(AuthCopy.t("change", language))
                                .font(.app(12, weight: .black))
                                .foregroundStyle(Color.white)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(authBlue)
                                .clipShape(Capsule())
                        }
                        .padding(.leading, 14)
                        .padding(.trailing, 6)
                        .padding(.vertical, 6)
                        .background(Color.white.opacity(0.06))
                        .clipShape(Capsule())
                        .overlay(Capsule().stroke(Color.white.opacity(0.12), lineWidth: 1))
                    }
                    .buttonStyle(.plain)
                    .disabled(auth.isBusy)

                    Spacer().frame(height: 28)
                    AuthGlassCard {
                        OTPBoxes(
                            code: Binding(get: { auth.code }, set: { auth.setCode($0) }),
                            isError: auth.error == .invalidCode,
                            disabled: auth.isBusy
                        )
                        .modifier(ShakeEffect(travel: shake))
                        // System paste control: works for codes copied from any mail app
                        // (Gmail, Outlook…), not only the Mail suggestions above the keyboard.
                        if auth.code.count < AuthStore.otpLength && !auth.isBusy {
                            VStack(spacing: 8) {
                                Text(AuthCopy.t("pasteCode", language))
                                    .font(.app(12))
                                    .foregroundStyle(authMuted)
                                PasteButton(payloadType: String.self) { strings in
                                    Task { @MainActor in auth.setCode(strings.first ?? "") }
                                }
                                .labelStyle(.titleAndIcon)
                                .buttonBorderShape(.capsule)
                                .tint(authBlue)
                            }
                            .padding(.top, 14)
                        }
                        if let error = auth.error {
                            AuthInlineError(text: AuthCopy.error(error, language))
                                .transition(.opacity.combined(with: .move(edge: .top)))
                        }
                        Spacer().frame(height: 20)
                        AuthPrimaryButton(
                            title: AuthCopy.t("verify", language),
                            loading: auth.isBusy,
                            enabled: auth.code.count == AuthStore.otpLength,
                            action: auth.verifyCode
                        )
                    }
                    .animation(.easeInOut(duration: 0.2), value: auth.error)

                    Spacer().frame(height: 20)
                    if auth.resendSecondsLeft > 0 {
                        Text(AuthCopy.t("resendIn", language)
                            .replacingOccurrences(of: "%@", with: String(format: "0:%02d", auth.resendSecondsLeft)))
                            .font(.app(13))
                            .foregroundStyle(authMuted)
                            .monospacedDigit()
                    } else {
                        Button(AuthCopy.t("resend", language)) { auth.resendCode() }
                            .font(.app(13, weight: .bold))
                            .foregroundStyle(authBlueLight)
                            .disabled(auth.isBusy)
                    }
                    Text(AuthCopy.t("spamTip", language))
                        .font(.app(12))
                        .foregroundStyle(authMuted.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.top, 8)
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 72)
                // Centred in the viewport like Android's Arrangement.Center; scrolls when taller.
                .frame(minHeight: viewport.size.height)
            }
            .scrollDismissesKeyboard(.interactively)
            }
            TopBackButton { auth.backToEmail() }
                .zIndex(1)
        }
        .onChange(of: auth.codeErrorTick) { _, _ in
            withAnimation(.linear(duration: 0.35)) { shake += 1 }
            UINotificationFeedbackGenerator().notificationOccurred(.error)
        }
    }
}

/// Six digit boxes backed by one hidden text field, so typing, deleting, pasting,
/// and iOS "From Mail" code autofill (`.oneTimeCode`) all work natively.
private struct OTPBoxes: View {
    @Binding var code: String
    var isError: Bool
    var disabled: Bool
    @FocusState private var focused: Bool
    @State private var cursorOn = true

    var body: some View {
        ZStack {
            TextField("", text: $code)
                .keyboardType(.numberPad)
                .textContentType(.oneTimeCode)
                .focused($focused)
                .foregroundStyle(Color.clear)
                .tint(.clear)
                .accentColor(.clear)
                .frame(width: 1, height: 1)
                .opacity(0.02)
                .disabled(disabled)
                .accessibilityLabel("Verification code")

            HStack(spacing: 8) {
                ForEach(0..<AuthStore.otpLength, id: \.self) { index in
                    box(at: index)
                }
            }
            .contentShape(Rectangle())
            .onTapGesture { focused = true }
        }
        .environment(\.layoutDirection, .leftToRight)
        .onAppear {
            focused = true
            withAnimation(.easeInOut(duration: 0.53).repeatForever()) { cursorOn = false }
        }
    }

    private func box(at index: Int) -> some View {
        let chars = Array(code)
        let char: Character? = index < chars.count ? chars[index] : nil
        let active = focused && index == chars.count
        let border: Color = isError ? authErrorRed
            : active ? authBlue
            : char != nil ? Color.white.opacity(0.35) : Color.white.opacity(0.12)
        return ZStack {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(active ? authBlue.opacity(0.12) : Color.white.opacity(0.05))
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(border, lineWidth: active ? 2 : 1)
            if let char {
                Text(String(char))
                    .font(.system(size: 24 * Typography.scale, weight: .black, design: .monospaced))
                    .foregroundStyle(Color.white)
                    .transition(.scale.combined(with: .opacity))
            } else if active {
                RoundedRectangle(cornerRadius: 1)
                    .fill(authBlueLight.opacity(cursorOn ? 1 : 0))
                    .frame(width: 2, height: 22)
            }
        }
        .aspectRatio(0.82, contentMode: .fit)
        .frame(maxWidth: .infinity)
        .animation(.easeOut(duration: 0.15), value: code)
    }
}

private struct ShakeEffect: GeometryEffect {
    var travel: CGFloat
    var animatableData: CGFloat {
        get { travel }
        set { travel = newValue }
    }

    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(CGAffineTransform(translationX: 10 * sin(travel * .pi * 6), y: 0))
    }
}

// MARK: - Shared building blocks (dark onboarding visual language)

/// Android's `AuthBackground`: slate gradient plus a slowly breathing blue glow top-left.
private struct AuthBackground: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var expanded = false

    var body: some View {
        GeometryReader { geometry in
            let diameter = min(geometry.size.width, geometry.size.height)
            ZStack {
                LinearGradient(colors: [Color(hex: 0x0F172A), Color(hex: 0x1E293B)], startPoint: .top, endPoint: .bottom)
                Circle()
                    .fill(authBlue.opacity(0.07))
                    .frame(width: diameter, height: diameter)
                    .scaleEffect(expanded ? 1.15 : 0.85)
                    .position(x: geometry.size.width * 0.15, y: geometry.size.height * 0.12)
            }
        }
        .environment(\.layoutDirection, .leftToRight)
        .ignoresSafeArea()
        .accessibilityHidden(true)
        .onAppear {
            guard !reduceMotion else { return }
            withAnimation(.easeInOut(duration: 4.5).repeatForever(autoreverses: true)) { expanded = true }
        }
    }
}

private struct AuthHeroIcon: View {
    var systemName: String

    var body: some View {
        ZStack {
            Circle()
                .fill(Color.white.opacity(0.03))
                .overlay(
                    Circle().stroke(
                        LinearGradient(colors: [authBlue, authBlueLight.opacity(0.5)], startPoint: .topLeading, endPoint: .bottomTrailing),
                        lineWidth: 1.5
                    )
                )
            Circle()
                .fill(RadialGradient(colors: [authBlue.opacity(0.4), .clear], center: .center, startRadius: 0, endRadius: 30))
                .frame(width: 60, height: 60)
            Image(systemName: systemName)
                .font(.app(28, weight: .semibold))
                .foregroundStyle(Color.white)
        }
        .frame(width: 84, height: 84)
        .accessibilityHidden(true)
    }
}

private struct AuthGlassCard<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        VStack(spacing: 0) { content }
            .padding(20)
            .frame(maxWidth: .infinity)
            .background(Color.white.opacity(0.04))
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 24, style: .continuous).stroke(Color.white.opacity(0.08), lineWidth: 1))
    }
}

private struct AuthEmailField: View {
    @Binding var text: String
    var placeholder: String
    var isError: Bool
    var disabled: Bool
    var focused: FocusState<Bool>.Binding
    var onSubmit: () -> Void

    var body: some View {
        let isFocused = focused.wrappedValue
        HStack(spacing: 12) {
            TextField("", text: $text, prompt: Text(placeholder).foregroundColor(authMuted.opacity(0.6)))
                .font(.app(16, weight: .semibold))
                .foregroundStyle(Color.white)
                .tint(authBlueLight)
                .keyboardType(.emailAddress)
                .textContentType(.emailAddress)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .submitLabel(.go)
                .focused(focused)
                .onSubmit(onSubmit)
                .disabled(disabled)
            if !text.isEmpty && !disabled {
                Button { text = "" } label: {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(authMuted)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Clear")
            }
        }
        .padding(.horizontal, 16)
        .frame(height: 56)
        .background(Color.white.opacity(isFocused ? 0.08 : 0.05))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(isError ? authErrorRed : isFocused ? authBlue : Color.white.opacity(0.15), lineWidth: isFocused ? 2 : 1)
        )
        .animation(.easeInOut(duration: 0.15), value: isFocused)
        // Email addresses are always LTR, even inside the Arabic layout.
        .environment(\.layoutDirection, .leftToRight)
    }
}

private struct AuthInlineError: View {
    var text: String

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "exclamationmark.circle")
                .font(.app(15, weight: .semibold))
                .foregroundStyle(authErrorRed)
            Text(text)
                .font(.app(13))
                .foregroundStyle(Color(hex: 0xFECACA))
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(authErrorRed.opacity(0.10))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous).stroke(authErrorRed.opacity(0.25), lineWidth: 1))
        .padding(.top, 12)
    }
}

/// Same gradient pill as the welcome screen's ENTER button.
struct AuthPrimaryButton: View {
    var title: String
    var loading: Bool
    var enabled: Bool
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if loading {
                    ProgressView().tint(.white)
                } else {
                    Text(title)
                        .font(.app(16, weight: .heavy))
                        .kerning(0.5)
                    Image(systemName: "arrow.forward")
                        .font(.app(17, weight: .semibold))
                        .flipsForRightToLeftLayoutDirection(true)
                }
            }
            .foregroundStyle(Color.white.opacity(enabled ? 1 : 0.6))
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(
                LinearGradient(
                    colors: [Color(hex: 0x1D4ED8), Color(hex: 0x2563EB), Color(hex: 0x3B82F6)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .opacity(enabled ? 1 : 0.35)
            )
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .shadow(color: Color(hex: 0x2563EB).opacity(enabled ? 0.45 : 0), radius: 12, y: 6)
        }
        .buttonStyle(AuthPressStyle())
        .disabled(!enabled || loading)
    }
}

private struct AuthPressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .animation(.spring(response: 0.3, dampingFraction: 0.55), value: configuration.isPressed)
    }
}

// MARK: - Account button + sheet (light calculator visual language)

struct AccountHeaderButton: View {
    var email: String
    var name = PersonName()
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            ProfileInitials(name: name, email: email, size: 34)
                .overlay(Circle().stroke(Color.white, lineWidth: 1.5))
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Account")
    }
}

// MARK: - Profile (full screen: Profile → Personal information / Privacy & security)

/// Opened from the avatar in the calculator header. Sub-pages push inside the
/// screen's own NavigationStack, so the system back swipe works in both languages.
struct ProfileScreen: View {
    @EnvironmentObject private var state: AppState
    @EnvironmentObject private var auth: AuthStore
    @Environment(\.dismiss) private var dismiss
    @State private var confirmSignOut = false
    @State private var path: [Page] = Self.debugInitialPath

    private enum Page: Hashable { case personalInfo, privacy }

    var body: some View {
        let language = state.language
        NavigationStack(path: $path) {
            ZStack {
                ScrollView {
                    VStack(spacing: 16) {
                        profileHeader(language)

                        ProfileGroup {
                            NavigationLink(value: Page.personalInfo) {
                                ProfileRow(icon: "person.fill", tint: .blueAccent,
                                           title: AuthCopy.t("personalInfo", language),
                                           subtitle: auth.name.full.isEmpty ? AuthCopy.t("fullNamePlaceholder", language) : auth.name.full)
                            }
                            ProfileDivider()
                            NavigationLink(value: Page.privacy) {
                                ProfileRow(icon: "lock.shield.fill", tint: .navyMedium,
                                           title: AuthCopy.t("privacy", language),
                                           subtitle: AuthCopy.t("privacySub", language))
                            }
                        }

                        Button { confirmSignOut = true } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                    .flipsForRightToLeftLayoutDirection(true)
                                Text(AuthCopy.t("signOut", language))
                            }
                            .font(.app(15, weight: .black))
                            .foregroundStyle(Color.navyPrimary)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                            .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).stroke(Color.slateBorder, lineWidth: 1))
                        }
                        .buttonStyle(.plain)
                        .disabled(auth.accountBusy)

                        Text(AuthCopy.t("version", language).replacingOccurrences(of: "%@", with: UpdateStore.versionLabel))
                            .font(.app(11))
                            .foregroundStyle(Color.slateMuted)
                    }
                    .padding(16)
                }

                if confirmSignOut {
                    ProfileConfirmOverlay(modal: TaxPulseModal(
                        icon: .triangle(Color.blueAccent),
                        title: AuthCopy.t("signOutTitle", language),
                        message: AuthCopy.t("signOutMsg", language),
                        primaryTitle: AuthCopy.t("signOut", language),
                        primaryAction: {
                            confirmSignOut = false
                            dismiss()
                            auth.signOut()
                        },
                        secondaryTitle: AuthCopy.t("cancel", language),
                        secondaryAction: { confirmSignOut = false }
                    ))
                }
            }
            .animation(.easeInOut(duration: 0.2), value: confirmSignOut)
            .background(Color.slateLight.ignoresSafeArea())
            .navigationTitle(AuthCopy.t("profile", language))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                            .font(.app(14, weight: .bold))
                            .foregroundStyle(Color.navyPrimary)
                            .frame(width: 34, height: 34)
                            .background(Color.white)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.slateBorder, lineWidth: 1))
                    }
                    .accessibilityLabel(AuthCopy.t("close", language))
                }
            }
            .navigationDestination(for: Page.self) { page in
                switch page {
                case .personalInfo: PersonalInfoScreen()
                case .privacy: PrivacyScreen(onDeleted: { dismiss() })
                }
            }
        }
        .tint(Color.navyPrimary)
        .environment(\.layoutDirection, language == .arabic ? .rightToLeft : .leftToRight)
        .onAppear {
            auth.accountMessage = nil
            auth.loadProfile()
        }
    }

    /// QA hook: `-uiProfile personal|privacy` opens straight onto a sub-page in Debug builds.
    private static var debugInitialPath: [Page] {
        #if DEBUG
        let args = ProcessInfo.processInfo.arguments
        if let i = args.firstIndex(of: "-uiProfile"), i + 1 < args.count {
            switch args[i + 1] {
            case "personal": return [.personalInfo]
            case "privacy": return [.privacy]
            default: break
            }
        }
        #endif
        return []
    }

    private func profileHeader(_ language: AppLanguage) -> some View {
        let email = auth.session?.email ?? ""
        return VStack(spacing: 6) {
            ProfileInitials(name: auth.name, email: email, size: 72)
                .padding(.bottom, 6)
            Text(auth.name.full.isEmpty ? AuthCopy.t("account", language) : auth.name.full)
                .font(.app(19, weight: .black))
                .foregroundStyle(Color.navyPrimary)
                .multilineTextAlignment(.center)
            Text(email)
                .font(.app(13, weight: .semibold))
                .foregroundStyle(Color.slateTextLight)
                .environment(\.layoutDirection, .leftToRight)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous).stroke(Color.slateBorder, lineWidth: 1))
    }
}

private struct PersonalInfoScreen: View {
    @EnvironmentObject private var state: AppState
    @EnvironmentObject private var auth: AuthStore
    @State private var first = ""
    @State private var last = ""
    @FocusState private var focused: Field?

    private enum Field { case first, last }

    var body: some View {
        let language = state.language
        let draft = PersonName(first: first.trimmingCharacters(in: .whitespacesAndNewlines),
                               last: last.trimmingCharacters(in: .whitespacesAndNewlines))
        let canSave = !auth.accountBusy && draft != auth.name
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                ProfileGroup {
                    VStack(alignment: .leading, spacing: 14) {
                        nameField(AuthCopy.t("firstName", language), placeholder: AuthCopy.t("firstNamePlaceholder", language),
                                  text: $first, field: .first, contentType: .givenName)
                        nameField(AuthCopy.t("lastName", language), placeholder: AuthCopy.t("lastNamePlaceholder", language),
                                  text: $last, field: .last, contentType: .familyName)

                        VStack(alignment: .leading, spacing: 6) {
                            Text(AuthCopy.t("emailLabel", language))
                                .font(.app(12, weight: .bold))
                                .foregroundStyle(Color.navyMedium)
                            HStack(spacing: 8) {
                                Text(auth.session?.email ?? "")
                                    .font(.app(15))
                                    .foregroundStyle(Color.slateTextLight)
                                    .environment(\.layoutDirection, .leftToRight)
                                Spacer(minLength: 0)
                                Image(systemName: "lock.fill")
                                    .font(.app(12))
                                    .foregroundStyle(Color.slateMuted)
                            }
                            .padding(.horizontal, 14)
                            .frame(height: 48)
                            .background(Color.slate50)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                            .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous).stroke(Color.slateBorder, lineWidth: 1))
                            Text(AuthCopy.t("emailLocked", language))
                                .font(.app(11))
                                .foregroundStyle(Color.slateMuted)
                        }
                    }
                    .padding(16)
                }

                Button {
                    focused = nil
                    auth.saveName(first: first, last: last)
                } label: {
                    HStack(spacing: 8) {
                        if auth.accountBusy { ProgressView().tint(.white).scaleEffect(0.8) }
                        Text(AuthCopy.t("save", language))
                    }
                    .font(.app(15, weight: .black))
                    .foregroundStyle(Color.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(Color.navyPrimary.opacity(canSave ? 1 : 0.4))
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                .buttonStyle(.plain)
                .disabled(!canSave)

                if let message = auth.accountMessage, message != .deleteFailed {
                    Label(AuthCopy.t(message == .saved ? "saved" : "saveFailed", language),
                          systemImage: message == .saved ? "checkmark.circle.fill" : "exclamationmark.circle.fill")
                        .font(.app(13, weight: .bold))
                        .foregroundStyle(message == .saved ? Color.successGreen : Color.dangerRed)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(16)
        }
        .background(Color.slateLight.ignoresSafeArea())
        .navigationTitle(AuthCopy.t("personalInfo", language))
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            first = auth.name.first
            last = auth.name.last
            auth.accountMessage = nil
        }
        .onChange(of: auth.name) { _, loaded in
            // The profile may finish loading after this page opens.
            if focused == nil { first = loaded.first; last = loaded.last }
        }
        .onChange(of: first) { _, _ in auth.accountMessage = nil }
        .onChange(of: last) { _, _ in auth.accountMessage = nil }
    }

    private func nameField(_ title: String, placeholder: String, text: Binding<String>,
                           field: Field, contentType: UITextContentType) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.app(12, weight: .bold))
                .foregroundStyle(Color.navyMedium)
            TextField(placeholder, text: text)
                .font(.app(15))
                .foregroundStyle(Color.slateTextDark)
                .textContentType(contentType)
                .textInputAutocapitalization(.words)
                .autocorrectionDisabled()
                .submitLabel(field == .first ? .next : .done)
                .focused($focused, equals: field)
                .onSubmit { focused = field == .first ? .last : nil }
                .padding(.horizontal, 14)
                .frame(height: 48)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(focused == field ? Color.blueAccent : Color.slateBorder, lineWidth: focused == field ? 2 : 1)
                )
        }
    }
}

private struct PrivacyScreen: View {
    @EnvironmentObject private var state: AppState
    @EnvironmentObject private var auth: AuthStore
    var onDeleted: () -> Void
    @State private var confirmDelete = false

    var body: some View {
        let language = state.language
        ZStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text(AuthCopy.t("dangerZone", language))
                        .font(.app(12, weight: .bold))
                        .foregroundStyle(Color.slateTextLight)
                        .padding(.horizontal, 4)

                    ProfileGroup {
                        Button { confirmDelete = true } label: {
                            ProfileRow(icon: "trash.fill", tint: .dangerRed,
                                       title: AuthCopy.t("deleteAccount", language),
                                       subtitle: AuthCopy.t("deleteAccountSub", language),
                                       titleColor: .dangerRed, showsChevron: false,
                                       busy: auth.accountBusy)
                        }
                        .buttonStyle(.plain)
                        .disabled(auth.accountBusy)
                    }

                    if auth.accountMessage == .deleteFailed {
                        Text(AuthCopy.t("deleteFailed", language))
                            .font(.app(12, weight: .bold))
                            .foregroundStyle(Color.dangerRed)
                    }
                }
                .padding(16)
            }

            if confirmDelete {
                ProfileConfirmOverlay(modal: TaxPulseModal(
                    icon: .triangle(Color.dangerRed),
                    title: AuthCopy.t("deleteTitle", language),
                    message: AuthCopy.t("deleteMsg", language),
                    primaryTitle: AuthCopy.t("deleteAccount", language),
                    primaryAction: {
                        confirmDelete = false
                        auth.deleteAccount(onDeleted: onDeleted)
                    },
                    secondaryTitle: AuthCopy.t("cancel", language),
                    secondaryAction: { confirmDelete = false }
                ))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: confirmDelete)
        .background(Color.slateLight.ignoresSafeArea())
        .navigationTitle(AuthCopy.t("privacy", language))
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { auth.accountMessage = nil }
    }
}

private struct ProfileGroup<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        VStack(spacing: 0) { content }
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(Color.slateBorder, lineWidth: 1))
    }
}

private struct ProfileRow: View {
    var icon: String
    var tint: Color
    var title: String
    var subtitle: String
    var titleColor: Color = .navyPrimary
    var showsChevron = true
    var busy = false

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.app(15))
                .foregroundStyle(tint)
                .frame(width: 36, height: 36)
                .background(tint.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.app(15, weight: .bold))
                    .foregroundStyle(titleColor)
                Text(subtitle)
                    .font(.app(12))
                    .foregroundStyle(Color.slateTextLight)
                    .lineLimit(1)
            }
            Spacer(minLength: 8)
            if busy {
                ProgressView().tint(tint).scaleEffect(0.8)
            } else if showsChevron {
                Image(systemName: "chevron.right")
                    .font(.app(13, weight: .bold))
                    .foregroundStyle(Color.slateMuted)
                    .flipsForRightToLeftLayoutDirection(true)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .contentShape(Rectangle())
    }
}

private struct ProfileDivider: View {
    var body: some View {
        Rectangle().fill(Color.slateBorder).frame(height: 1).padding(.leading, 62)
    }
}

/// Initials avatar: first + last name initials, or the email's first letter.
struct ProfileInitials: View {
    var name: PersonName
    var email: String
    var size: CGFloat

    var body: some View {
        Text(initials)
            .font(.app(size * 0.4, weight: .black))
            .foregroundStyle(Color.white)
            .frame(width: size, height: size)
            .background(LinearGradient(colors: [.navyMedium, .blueAccent], startPoint: .topLeading, endPoint: .bottomTrailing))
            .clipShape(Circle())
    }

    private var initials: String {
        let letters = [name.first.first, name.last.first].compactMap { $0 }
        if !letters.isEmpty { return String(letters).uppercased() }
        return email.first.map { String($0).uppercased() } ?? "?"
    }
}

private struct ProfileConfirmOverlay: View {
    var modal: TaxPulseModal

    var body: some View {
        ZStack {
            Color.black.opacity(0.45).ignoresSafeArea()
            modal.padding(.horizontal, 28)
        }
        .transition(.opacity)
        .zIndex(10)
    }
}

// MARK: - App update prompts

/// Shows the soft "Update available" modal or the blocking "Update required"
/// screen. Mounted once at the root so it also covers onboarding and sign-in.
struct AppUpdateHost: View {
    @EnvironmentObject private var state: AppState
    @EnvironmentObject private var updates: UpdateStore
    @Environment(\.openURL) private var openURL

    var body: some View {
        Group {
            switch updates.prompt {
            case .none:
                EmptyView()
            case .optional(let policy):
                ZStack {
                    Color.black.opacity(0.45).ignoresSafeArea()
                    VStack(spacing: 0) {
                        TaxPulseModal(
                            icon: .triangle(Color.blueAccent),
                            title: AuthCopy.t("updateAvailable", state.language),
                            message: message(AuthCopy.t("updateAvailableMsg", state.language), policy),
                            primaryTitle: AuthCopy.t("updateNow", state.language),
                            primaryAction: { open(policy) },
                            secondaryTitle: AuthCopy.t("later", state.language),
                            secondaryAction: { updates.dismissOptional() }
                        )
                    }
                    .padding(.horizontal, 32)
                }
                .transition(.opacity)
            case .required(let policy):
                ForceUpdateScreen(policy: policy) { open(policy) }
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.25), value: updates.prompt)
        .environment(\.layoutDirection, state.language == .arabic ? .rightToLeft : .leftToRight)
    }

    private func message(_ base: String, _ policy: VersionPolicy) -> String {
        let notes = notes(policy)
        return notes.isEmpty ? base : "\(base)\n\n\(AuthCopy.t("whatsNew", state.language)):\n\(notes)"
    }

    private func notes(_ policy: VersionPolicy) -> String {
        state.language == .arabic && !policy.notesAr.isEmpty ? policy.notesAr : policy.notesEn
    }

    private func open(_ policy: VersionPolicy) {
        if let url = URL(string: policy.storeURL) { openURL(url) }
    }
}

private struct ForceUpdateScreen: View {
    @EnvironmentObject private var state: AppState
    var policy: VersionPolicy
    var onUpdate: () -> Void

    var body: some View {
        let language = state.language
        let notes = language == .arabic && !policy.notesAr.isEmpty ? policy.notesAr : policy.notesEn
        ZStack {
            LinearGradient(colors: [Color(hex: 0x0F172A), Color(hex: 0x1E293B)], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            VStack(spacing: 0) {
                Spacer()
                AuthHeroIcon(systemName: "arrow.down.app.fill")
                Text(AuthCopy.t("updateRequired", language))
                    .font(.app(24, weight: .heavy))
                    .foregroundStyle(Color.white)
                    .padding(.top, 24)
                Text(AuthCopy.t("updateRequiredMsg", language))
                    .font(.app(14))
                    .foregroundStyle(authMuted)
                    .multilineTextAlignment(.center)
                    .padding(.top, 8)
                    .padding(.bottom, 28)
                if !notes.isEmpty {
                    AuthGlassCard {
                        Text(AuthCopy.t("whatsNew", language))
                            .font(.app(12, weight: .bold))
                            .foregroundStyle(authBlueLight)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text(notes)
                            .font(.app(14))
                            .foregroundStyle(Color.white)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top, 6)
                    }
                    .padding(.bottom, 28)
                }
                AuthPrimaryButton(title: AuthCopy.t("updateNow", language), loading: false, enabled: true, action: onUpdate)
                Text(AuthCopy.t("version", language).replacingOccurrences(of: "%@", with: UpdateStore.versionLabel))
                    .font(.app(11))
                    .foregroundStyle(authMuted.opacity(0.7))
                    .padding(.top, 16)
                Spacer()
            }
            .padding(.horizontal, 24)
        }
        .zIndex(100)
    }
}
