import Foundation
import Security

/// Supabase project settings. The anon key is public by design — every
/// authorization rule is enforced server-side by Row Level Security.
/// Fill these in from Dashboard → Project Settings → API.
enum SupabaseConfig {
    private static let projectURL = "https://makupgsrmivjdpszuxgl.supabase.co"
    private static let projectAnonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1ha3VwZ3NybWl2amRwc3p1eGdsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTE2MjE5OTYsImV4cCI6MjEwNzE5Nzk5Nn0.HvMYP5bLm1k2TA-tIRlt5sO2PZV9MBQw7coMNWPUBpY"
    /// Optional App Store review account: its "code" is that account's password,
    /// so reviewers don't need access to an inbox. Leave empty to disable.
    static let reviewAccountEmail = ""

    #if DEBUG
    /// QA hook: `-supabaseURL http://127.0.0.1:54321 -supabaseAnonKey <key>` launch
    /// arguments point a Debug build at a local stack. Compiled out of Release.
    static var url: String { UserDefaults.standard.string(forKey: "supabaseURL") ?? projectURL }
    static var anonKey: String { UserDefaults.standard.string(forKey: "supabaseAnonKey") ?? projectAnonKey }
    static var isConfigured: Bool { (url.hasPrefix("https://") || url.hasPrefix("http://127.0.0.1")) && !anonKey.isEmpty }
    #else
    static let url = projectURL
    static let anonKey = projectAnonKey
    static var isConfigured: Bool { url.hasPrefix("https://") && !anonKey.isEmpty }
    #endif
}

/// A signed-in session. Persisted in the Keychain until the user explicitly signs out.
struct AuthSession: Codable, Equatable {
    var userId: String
    var email: String
    var accessToken: String
    var refreshToken: String
    /// Access-token expiry (epoch seconds). The refresh token itself never expires.
    var expiresAt: TimeInterval

    var isAccessTokenFresh: Bool { Date().timeIntervalSince1970 < expiresAt - 60 }
}

/// The user's name from `public.profiles`.
struct PersonName: Equatable {
    var first = ""
    var last = ""

    var full: String { "\(first) \(last)".trimmingCharacters(in: .whitespaces) }
}

/// Update policy for this platform, published in Firebase Remote Config.
struct VersionPolicy: Equatable {
    /// Store version, e.g. "1.2.0". Empty = no update published.
    var latestVersion: String
    /// When true the prompt can't be dismissed.
    var forceUpdate: Bool
    var storeURL: String
    var notesEn: String
    var notesAr: String
}

enum AuthError: Error, Equatable {
    case notConfigured
    case network
    case invalidEmail
    case disposableEmail
    case rateLimited
    case invalidCode
    /// The server rejected the refresh token (account deleted or session revoked).
    case sessionRevoked
    case unknown
}

/// Thin REST client for Supabase Auth (GoTrue) + PostgREST, so the app keeps
/// its zero-dependency setup instead of adding the Supabase Swift SDK.
struct SupabaseAuthAPI {
    private let session: URLSession = {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 20
        return URLSession(configuration: config)
    }()

    /// Sends a 6-digit code to `email`. Creates the account on first use.
    func sendOTP(email: String) async throws {
        _ = try await call("POST", "/auth/v1/otp", body: ["email": email, "create_user": true])
    }

    func verifyOTP(email: String, code: String) async throws -> AuthSession {
        let data = try await call("POST", "/auth/v1/verify", body: ["type": "email", "email": email, "token": code])
        return try parseSession(data, fallbackEmail: email)
    }

    /// App Review account: the "code" typed in is that account's password.
    func signInWithPassword(email: String, password: String) async throws -> AuthSession {
        let data = try await call("POST", "/auth/v1/token?grant_type=password", body: ["email": email, "password": password])
        return try parseSession(data, fallbackEmail: email)
    }

    func refresh(_ current: AuthSession) async throws -> AuthSession {
        let data = try await call("POST", "/auth/v1/token?grant_type=refresh_token", body: ["refresh_token": current.refreshToken])
        return try parseSession(data, fallbackEmail: current.email)
    }

    /// Revokes this device's refresh token server-side.
    func signOut(accessToken: String) async throws {
        _ = try await call("POST", "/auth/v1/logout?scope=local", body: nil, bearer: accessToken)
    }

    func fetchName(_ s: AuthSession) async throws -> PersonName {
        let data = try await call("GET", "/rest/v1/profiles?select=first_name,last_name&id=eq.\(s.userId)", body: nil, bearer: s.accessToken)
        let row = ((try? JSONSerialization.jsonObject(with: data)) as? [[String: Any]])?.first
        return PersonName(first: row?["first_name"] as? String ?? "", last: row?["last_name"] as? String ?? "")
    }

    func updateName(_ s: AuthSession, _ name: PersonName) async throws {
        _ = try await call("PATCH", "/rest/v1/profiles?id=eq.\(s.userId)",
                           body: ["first_name": name.first, "last_name": name.last], bearer: s.accessToken)
    }

    func deleteAccount(_ s: AuthSession) async throws {
        _ = try await call("POST", "/rest/v1/rpc/delete_my_account", body: [:], bearer: s.accessToken)
    }

    private func parseSession(_ data: Data, fallbackEmail: String) throws -> AuthSession {
        guard let o = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any],
              let access = o["access_token"] as? String,
              let refresh = o["refresh_token"] as? String else { throw AuthError.unknown }
        let user = o["user"] as? [String: Any]
        let expiresIn = (o["expires_in"] as? Double) ?? 3600
        let email = (user?["email"] as? String).flatMap { $0.isEmpty ? nil : $0 } ?? fallbackEmail
        return AuthSession(
            userId: user?["id"] as? String ?? "",
            email: email,
            accessToken: access,
            refreshToken: refresh,
            expiresAt: (o["expires_at"] as? Double) ?? Date().timeIntervalSince1970 + expiresIn
        )
    }

    private func call(_ method: String, _ path: String, body: [String: Any]?, bearer: String? = nil) async throws -> Data {
        guard SupabaseConfig.isConfigured,
              let url = URL(string: SupabaseConfig.url.trimmingCharacters(in: CharacterSet(charactersIn: "/")) + path)
        else { throw AuthError.notConfigured }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue(SupabaseConfig.anonKey, forHTTPHeaderField: "apikey")
        request.setValue("Bearer \(bearer ?? SupabaseConfig.anonKey)", forHTTPHeaderField: "Authorization")
        request.setValue("return=minimal", forHTTPHeaderField: "Prefer")
        if let body {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        }

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            throw AuthError.network
        }
        let status = (response as? HTTPURLResponse)?.statusCode ?? 0
        guard (200..<300).contains(status) else { throw mapError(status: status, path: path, data: data) }
        return data
    }

    private func mapError(status: Int, path: String, data: Data) -> AuthError {
        let text = String(data: data, encoding: .utf8) ?? ""
        let o = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any] ?? [:]
        let code = (o["error_code"] as? String) ?? (o["code"] as? String) ?? (o["error"] as? String) ?? ""
        if text.contains("DISPOSABLE_EMAIL") { return .disposableEmail }
        if status == 429 || code.hasPrefix("over_") { return .rateLimited }
        if code == "email_address_invalid" || code == "validation_failed" || text.localizedCaseInsensitiveContains("valid email") {
            return .invalidEmail
        }
        if code == "otp_expired" || path.hasPrefix("/auth/v1/verify")
            || (path.contains("grant_type=password") && (400...403).contains(status)) {
            return .invalidCode
        }
        if path.contains("grant_type=refresh_token") && (400...403).contains(status) { return .sessionRevoked }
        if status == 401 { return .sessionRevoked }
        return .unknown
    }
}

/// Keychain persistence for the session. `AfterFirstUnlockThisDeviceOnly`: the
/// session survives restarts and app updates, but is never restored onto another
/// device from a backup.
enum SessionKeychain {
    private static let service = "com.haddad.taxpulse.auth"
    private static let account = "session"

    static func load() -> AuthSession? {
        var query = baseQuery
        query[kSecReturnData as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        var item: CFTypeRef?
        guard SecItemCopyMatching(query as CFDictionary, &item) == errSecSuccess, let data = item as? Data else { return nil }
        return try? JSONDecoder().decode(AuthSession.self, from: data)
    }

    static func save(_ session: AuthSession) {
        guard let data = try? JSONEncoder().encode(session) else { return }
        let attributes: [String: Any] = [
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        ]
        if SecItemUpdate(baseQuery as CFDictionary, attributes as CFDictionary) == errSecItemNotFound {
            SecItemAdd(baseQuery.merging(attributes) { $1 } as CFDictionary, nil)
        }
    }

    static func clear() {
        SecItemDelete(baseQuery as CFDictionary)
    }

    private static var baseQuery: [String: Any] {
        [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
    }
}
