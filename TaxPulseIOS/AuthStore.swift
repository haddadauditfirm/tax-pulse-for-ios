import Foundation

enum AuthStage { case email, code }

/// Passwordless email-OTP sign-in. A session, once established, is kept forever:
/// it is only removed by an explicit sign-out, account deletion, or the server
/// definitively rejecting the refresh token (e.g. the account was deleted
/// elsewhere). Network failures never sign the user out.
@MainActor
final class AuthStore: ObservableObject {
    static let otpLength = 6
    /// Matches Supabase's default 60s minimum interval between OTP emails.
    static let resendSeconds = 60

    @Published private(set) var session: AuthSession? = SessionKeychain.load()
    @Published var stage: AuthStage = .email
    @Published var email: String = UserDefaults.standard.string(forKey: lastEmailKey) ?? ""
    @Published var code: String = ""
    @Published private(set) var isBusy = false
    @Published var error: AuthError?
    /// Bumped on every wrong code so the view can replay its shake animation.
    @Published private(set) var codeErrorTick = 0
    @Published private(set) var resendSecondsLeft = 0
    /// Set when the server revoked the session, so the sign-in screen can explain why.
    @Published private(set) var signedOutReason: AuthError?

    // Profile
    @Published private(set) var name = PersonName()
    @Published private(set) var accountBusy = false
    @Published var accountMessage: AccountMessage?

    enum AccountMessage: Equatable { case saved, saveFailed, deleteFailed }

    private static let lastEmailKey = "authLastEmail"
    private let api = SupabaseAuthAPI()
    private var countdownTask: Task<Void, Never>?
    private var refreshTask: Task<AuthSession, Error>?

    var isSignedIn: Bool { session != nil }

    init() {
        if session != nil { loadProfile() }
    }

    func setEmail(_ value: String) {
        email = String(value.trimmingCharacters(in: .whitespacesAndNewlines).prefix(254))
        error = nil
    }

    func setCode(_ value: String) {
        let digits = String(value.filter(\.isNumber).prefix(Self.otpLength))
        guard digits != code else { return }
        code = digits
        if error == .invalidCode { error = nil }
        if digits.count == Self.otpLength { verifyCode() }
    }

    func backToEmail() {
        stage = .email
        code = ""
        error = nil
    }

    func sendCode() {
        let address = email.lowercased()
        guard Self.isValidEmail(address) else {
            error = .invalidEmail
            return
        }
        guard !isBusy else { return }
        // Same address and the cooldown is still running: just go back to the code screen.
        if resendSecondsLeft > 0, address == UserDefaults.standard.string(forKey: Self.lastEmailKey) {
            stage = .code
            return
        }
        Task {
            isBusy = true
            error = nil
            signedOutReason = nil
            defer { isBusy = false }
            do {
                // Review accounts sign in with a password typed into the code boxes,
                // so no email needs to reach App Store reviewers.
                if !isReviewEmail(address) { try await api.sendOTP(email: address) }
                UserDefaults.standard.set(address, forKey: Self.lastEmailKey)
                email = address
                code = ""
                stage = .code
                startResendCountdown()
            } catch {
                self.error = error as? AuthError ?? .unknown
            }
        }
    }

    func resendCode() {
        guard resendSecondsLeft == 0, !isBusy else { return }
        Task {
            isBusy = true
            error = nil
            defer { isBusy = false }
            do {
                if !isReviewEmail(email) { try await api.sendOTP(email: email) }
                code = ""
                startResendCountdown()
            } catch {
                self.error = error as? AuthError ?? .unknown
            }
        }
    }

    func verifyCode() {
        let entered = code
        guard entered.count == Self.otpLength, !isBusy else { return }
        Task {
            isBusy = true
            error = nil
            defer { isBusy = false }
            do {
                let newSession = isReviewEmail(email)
                    ? try await api.signInWithPassword(email: email, password: entered)
                    : try await api.verifyOTP(email: email, code: entered)
                SessionKeychain.save(newSession)
                // Stage/code are left as-is so the filled code screen slides away
                // cleanly; clearLocalSession() resets them on the next sign-out.
                session = newSession
                countdownTask?.cancel()
                resendSecondsLeft = 0
                loadProfile()
            } catch {
                let authError = error as? AuthError ?? .unknown
                self.error = authError
                if authError == .invalidCode {
                    code = ""
                    codeErrorTick += 1
                }
            }
        }
    }

    func loadProfile() {
        Task {
            if let loaded = try? await withFreshSession({ try await self.api.fetchName($0) }) {
                name = loaded
            }
        }
    }

    func saveName(first: String, last: String) {
        let trimmed = PersonName(
            first: String(first.trimmingCharacters(in: .whitespacesAndNewlines).prefix(50)),
            last: String(last.trimmingCharacters(in: .whitespacesAndNewlines).prefix(50))
        )
        Task {
            accountBusy = true
            defer { accountBusy = false }
            do {
                try await withFreshSession { try await self.api.updateName($0, trimmed) }
                name = trimmed
                accountMessage = .saved
            } catch {
                accountMessage = .saveFailed
            }
        }
    }

    func signOut() {
        guard let current = session else { return }
        clearLocalSession()
        // Best effort: revoke the refresh token server-side. The local sign-out
        // has already happened, so sign-out also works offline.
        Task { try? await api.signOut(accessToken: current.accessToken) }
    }

    func deleteAccount(onDeleted: @escaping () -> Void) {
        Task {
            accountBusy = true
            defer { accountBusy = false }
            do {
                try await withFreshSession { try await self.api.deleteAccount($0) }
                clearLocalSession()
                UserDefaults.standard.removeObject(forKey: Self.lastEmailKey)
                email = ""
                onDeleted()
            } catch {
                accountMessage = .deleteFailed
            }
        }
    }

    /// Runs `block` with a valid access token, refreshing first if needed. Concurrent
    /// callers share one in-flight refresh: Supabase rotates refresh tokens, and two
    /// refreshes with the same token would trip reuse detection and revoke the session.
    private func withFreshSession<T>(_ block: @escaping (AuthSession) async throws -> T) async throws -> T {
        guard let current = session else { throw AuthError.sessionRevoked }
        let usable: AuthSession
        if current.isAccessTokenFresh {
            usable = current
        } else {
            let task = refreshTask ?? Task { try await api.refresh(current) }
            refreshTask = task
            do {
                usable = try await task.value
                refreshTask = nil
                SessionKeychain.save(usable)
                session = usable
            } catch {
                refreshTask = nil
                if error as? AuthError == .sessionRevoked { revoked() }
                throw error
            }
        }
        do {
            return try await block(usable)
        } catch {
            if error as? AuthError == .sessionRevoked { revoked() }
            throw error
        }
    }

    private func revoked() {
        clearLocalSession()
        signedOutReason = .sessionRevoked
    }

    private func clearLocalSession() {
        SessionKeychain.clear()
        session = nil
        name = PersonName()
        accountMessage = nil
        stage = .email
        code = ""
        error = nil
    }

    private func startResendCountdown() {
        countdownTask?.cancel()
        countdownTask = Task {
            for left in stride(from: Self.resendSeconds, to: 0, by: -1) {
                resendSecondsLeft = left
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                if Task.isCancelled { return }
            }
            resendSecondsLeft = 0
        }
    }

    private func isReviewEmail(_ address: String) -> Bool {
        !SupabaseConfig.reviewAccountEmail.isEmpty
            && address.caseInsensitiveCompare(SupabaseConfig.reviewAccountEmail) == .orderedSame
    }

    static func isValidEmail(_ address: String) -> Bool {
        address.range(of: #"^[a-z0-9._%+\-]+@[a-z0-9\-]+(\.[a-z0-9\-]+)*\.[a-z]{2,}$"#, options: .regularExpression) != nil
    }
}

/// Turns the update policy from Firebase Remote Config into a prompt. Fails open:
/// with no published policy (or no connection and no cached one), nothing is shown.
@MainActor
final class UpdateStore: ObservableObject {
    enum Prompt: Equatable {
        case none
        /// Dismissible "Update available".
        case optional(VersionPolicy)
        /// Blocking "Update required" (`force_update` is on).
        case required(VersionPolicy)
    }

    @Published private(set) var prompt: Prompt = .none

    private static let snooze: TimeInterval = 3 * 24 * 60 * 60
    private static let dismissedVersionKey = "updateDismissedVersion"
    private static let dismissedAtKey = "updateDismissedAt"

    static var currentVersion: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "0"
    }

    static var versionLabel: String {
        let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "?"
        return "\(currentVersion) (\(build))"
    }

    /// A blocked user re-fetches on every return to the app, in case the policy was relaxed.
    var isBlocked: Bool {
        if case .required = prompt { return true }
        return false
    }

    func apply(_ policy: VersionPolicy) {
        prompt = decide(policy)
    }

    func dismissOptional() {
        guard case .optional(let policy) = prompt else { return }
        UserDefaults.standard.set(policy.latestVersion, forKey: Self.dismissedVersionKey)
        UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: Self.dismissedAtKey)
        prompt = .none
    }

    private func decide(_ policy: VersionPolicy) -> Prompt {
        // Only installs older than the store version are prompted, so a newer build
        // (in review or TestFlight) never is.
        guard !policy.latestVersion.isEmpty,
              Self.compare(Self.currentVersion, policy.latestVersion) == .orderedAscending
        else { return .none }
        if policy.forceUpdate { return .required(policy) }
        // "Later" snoozes this particular version for 3 days, then asks again.
        let dismissedVersion = UserDefaults.standard.string(forKey: Self.dismissedVersionKey)
        let dismissedAt = UserDefaults.standard.double(forKey: Self.dismissedAtKey)
        let snoozed = dismissedVersion == policy.latestVersion
            && Date().timeIntervalSince1970 - dismissedAt < Self.snooze
        return snoozed ? .none : .optional(policy)
    }

    /// Compares dotted versions numerically ("1.10.0" > "1.9.2"); missing parts count as 0.
    static func compare(_ a: String, _ b: String) -> ComparisonResult {
        let lhs = a.split(separator: ".").map { Int($0.filter(\.isNumber)) ?? 0 }
        let rhs = b.split(separator: ".").map { Int($0.filter(\.isNumber)) ?? 0 }
        for i in 0..<max(lhs.count, rhs.count) {
            let x = i < lhs.count ? lhs[i] : 0, y = i < rhs.count ? rhs[i] : 0
            if x != y { return x < y ? .orderedAscending : .orderedDescending }
        }
        return .orderedSame
    }
}
