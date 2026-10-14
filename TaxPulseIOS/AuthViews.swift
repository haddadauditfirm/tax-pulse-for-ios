import SwiftUI

// MARK: - Copy (EN / AR), mirroring Android's AuthCopy

enum AuthCopy {
    private static let strings: [String: (String, String)] = [
        "signInTitle": ("Sign in to Tax Pulse", "تسجيل الدخول إلى Tax Pulse"),
        "signInSub": ("Enter your email and we'll send you a 6-digit code. No password needed.",
                      "أدخل بريدك الإلكتروني وسنرسل لك رمزاً من 6 أرقام. لا حاجة لكلمة مرور."),
        "emailLabel": ("Email address", "البريد الإلكتروني"),
        "emailPlaceholder": ("name@company.com", "name@company.com"),
        "sendCode": ("Send code", "إرسال الرمز"),
        "staySignedIn": ("You'll stay signed in on this device until you sign out.",
                         "ستبقى مسجلاً على هذا الجهاز حتى تختار تسجيل الخروج."),
        "checkEmail": ("Check your email", "تحقق من بريدك الإلكتروني"),
        "codeSentTo": ("We sent a 6-digit code to", "أرسلنا رمزاً من 6 أرقام إلى"),
        "change": ("Change", "تغيير"),
        "verify": ("Verify & continue", "تحقق ومتابعة"),
        "resendIn": ("Resend code in %@", "إعادة إرسال الرمز خلال %@"),
        "resend": ("Didn't get it? Resend code", "لم يصلك؟ أعد إرسال الرمز"),
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
        "fullName": ("Full name", "الاسم الكامل"),
        "fullNamePlaceholder": ("Add your name", "أضف اسمك"),
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
        VStack(spacing: 0) {
            TopBackButton(action: onBack)
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    Spacer().frame(height: 24)
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

                    Spacer().frame(height: 20)
                    HStack(spacing: 6) {
                        Image(systemName: "lock.fill").font(.app(11))
                        Text(AuthCopy.t("staySignedIn", language)).font(.app(12))
                    }
                    .foregroundStyle(authMuted)
                    .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
            .scrollDismissesKeyboard(.interactively)
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
        VStack(spacing: 0) {
            TopBackButton { auth.backToEmail() }
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    Spacer().frame(height: 24)
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
                .padding(.bottom, 24)
            }
            .scrollDismissesKeyboard(.interactively)
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
            .shadow(color: .black.opacity(0.3), radius: 16, y: 8)
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
            Image(systemName: "at")
                .font(.app(17, weight: .semibold))
                .foregroundStyle(isFocused ? authBlueLight : authMuted)
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
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(email.first.map { String($0).uppercased() } ?? "?")
                .font(.app(14, weight: .black))
                .foregroundStyle(Color.white)
                .frame(width: 34, height: 34)
                .background(LinearGradient(colors: [.navyMedium, .blueAccent], startPoint: .topLeading, endPoint: .bottomTrailing))
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.white, lineWidth: 1.5))
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Account")
    }
}

struct AccountSheet: View {
    @EnvironmentObject private var state: AppState
    @EnvironmentObject private var auth: AuthStore
    @Environment(\.dismiss) private var dismiss
    @State private var nameDraft = ""
    @State private var confirmSignOut = false
    @State private var confirmDelete = false
    @FocusState private var nameFocused: Bool

    var body: some View {
        let language = state.language
        let email = auth.session?.email ?? ""
        ZStack {
            ScrollView {
                VStack(spacing: 0) {
                    Text(String((auth.fullName.first ?? email.first) ?? "?").uppercased())
                        .font(.app(26, weight: .black))
                        .foregroundStyle(Color.white)
                        .frame(width: 64, height: 64)
                        .background(LinearGradient(colors: [.navyMedium, .blueAccent], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .clipShape(Circle())
                        .padding(.top, 28)
                    Text(auth.fullName.isEmpty ? AuthCopy.t("account", language) : auth.fullName)
                        .font(.app(18, weight: .black))
                        .foregroundStyle(Color.navyPrimary)
                        .padding(.top, 12)
                    Text(AuthCopy.t("signedInAs", language))
                        .font(.app(11, weight: .bold))
                        .foregroundStyle(Color.slateTextLight)
                        .padding(.top, 6)
                    Text(email)
                        .font(.app(14, weight: .semibold))
                        .foregroundStyle(Color.slateTextDark)
                        .environment(\.layoutDirection, .leftToRight)

                    nameCard(language)
                        .padding(.top, 20)

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
                        .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).stroke(Color.slateBorder, lineWidth: 1.5))
                    }
                    .buttonStyle(.plain)
                    .disabled(auth.accountBusy)
                    .padding(.top, 16)

                    Button { confirmDelete = true } label: {
                        HStack(spacing: 8) {
                            if auth.accountBusy { ProgressView().tint(.dangerRed).scaleEffect(0.8) }
                            Text(AuthCopy.t("deleteAccount", language))
                        }
                        .font(.app(13, weight: .bold))
                        .foregroundStyle(Color.dangerRed)
                        .frame(height: 44)
                    }
                    .buttonStyle(.plain)
                    .disabled(auth.accountBusy)
                    .padding(.top, 4)

                    if auth.accountMessage == .deleteFailed {
                        Text(AuthCopy.t("deleteFailed", language))
                            .font(.app(12, weight: .bold))
                            .foregroundStyle(Color.dangerRed)
                            .multilineTextAlignment(.center)
                    }

                    Text(AuthCopy.t("version", language).replacingOccurrences(of: "%@", with: UpdateStore.versionLabel))
                        .font(.app(11))
                        .foregroundStyle(Color.slateMuted)
                        .padding(.top, 8)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
            }

            if confirmSignOut {
                confirmOverlay(
                    TaxPulseModal(
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
                    )
                )
            }
            if confirmDelete {
                confirmOverlay(
                    TaxPulseModal(
                        icon: .triangle(Color.dangerRed),
                        title: AuthCopy.t("deleteTitle", language),
                        message: AuthCopy.t("deleteMsg", language),
                        primaryTitle: AuthCopy.t("deleteAccount", language),
                        primaryAction: {
                            confirmDelete = false
                            auth.deleteAccount { dismiss() }
                        },
                        secondaryTitle: AuthCopy.t("cancel", language),
                        secondaryAction: { confirmDelete = false }
                    )
                )
            }
        }
        .background(Color.white.ignoresSafeArea())
        .animation(.easeInOut(duration: 0.2), value: confirmSignOut)
        .animation(.easeInOut(duration: 0.2), value: confirmDelete)
        .environment(\.layoutDirection, language == .arabic ? .rightToLeft : .leftToRight)
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        .presentationCornerRadius(28)
        .onAppear {
            nameDraft = auth.fullName
            auth.accountMessage = nil
            auth.loadProfile()
        }
        .onChange(of: auth.fullName) { _, newValue in
            if !nameFocused { nameDraft = newValue }
        }
    }

    private func nameCard(_ language: AppLanguage) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(AuthCopy.t("fullName", language))
                .font(.app(12, weight: .bold))
                .foregroundStyle(Color.navyMedium)
            HStack(spacing: 10) {
                TextField(AuthCopy.t("fullNamePlaceholder", language), text: $nameDraft)
                    .font(.app(15))
                    .foregroundStyle(Color.slateTextDark)
                    .textContentType(.name)
                    .submitLabel(.done)
                    .focused($nameFocused)
                    .padding(.horizontal, 14)
                    .frame(height: 48)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(nameFocused ? Color.blueAccent : Color.slateBorder, lineWidth: nameFocused ? 2 : 1)
                    )
                let canSave = !auth.accountBusy
                    && nameDraft.trimmingCharacters(in: .whitespacesAndNewlines) != auth.fullName
                Button {
                    nameFocused = false
                    auth.saveFullName(nameDraft)
                } label: {
                    Text(AuthCopy.t("save", language))
                        .font(.app(14, weight: .bold))
                        .foregroundStyle(Color.white)
                        .padding(.horizontal, 18)
                        .frame(height: 48)
                        .background(Color.navyPrimary.opacity(canSave ? 1 : 0.4))
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
                .buttonStyle(.plain)
                .disabled(!canSave)
            }
            if let message = auth.accountMessage, message != .deleteFailed {
                Text(AuthCopy.t(message == .saved ? "saved" : "saveFailed", language))
                    .font(.app(12, weight: .bold))
                    .foregroundStyle(message == .saved ? Color.successGreen : Color.dangerRed)
            }
        }
        .padding(16)
        .background(Color.slate50)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(Color.slateBorder, lineWidth: 1))
    }

    private func confirmOverlay(_ modal: TaxPulseModal) -> some View {
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
