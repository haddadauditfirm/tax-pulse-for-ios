import Foundation

/// Firebase project `tax-pulse`. These identifiers are public by design (they
/// ship in every Firebase app's GoogleService-Info.plist).
enum FirebaseConfig {
    static let projectNumber = "534827783286"
    static let appId = "1:534827783286:ios:dd9248abcba65907153b57"
    static let apiKey = "AIzaSyCCYsavbN0vtGNi5zoV8iVH1JT1GLjzC1E"
    static let bundleId = "com.haddad.taxpulse"
}

/// Values edited in Firebase Console → Remote Config, read without an app update.
/// Uses the same fetch endpoint as the Firebase SDK so the app keeps its
/// zero-dependency setup. The last fetched values are cached, so they're
/// available offline and immediately on the next launch.
@MainActor
final class RemoteConfigStore: ObservableObject {
    /// Keys published in Remote Config, with the values used before the first fetch.
    enum Key: String, CaseIterable {
        /// The official extended due date, `DD-MM-YYYY`. Empty = show the statutory due date.
        case extendedDueDate = "extended_due_date"
        /// Version live in the App Store, e.g. "1.2.0". Older installs see the update popup.
        case latestVersion = "ios_latest_version"
        /// "true" makes the update popup impossible to dismiss.
        case forceUpdate = "force_update"
        case storeURL = "ios_store_url"
        case updateNotesEn = "update_notes_en"
        case updateNotesAr = "update_notes_ar"

        var defaultValue: String {
            switch self {
            case .forceUpdate: return "false"
            case .storeURL: return "https://apps.apple.com/app/id6803842823"
            case .extendedDueDate, .latestVersion, .updateNotesEn, .updateNotesAr: return ""
            }
        }
    }

    @Published private(set) var values: [String: String]

    private var lastFetch: Date = .distantPast
    private static let fetchInterval: TimeInterval = 15 * 60
    private static let cacheKey = "remoteConfigValues"
    private static let instanceIdKey = "remoteConfigInstanceId"

    init() {
        values = UserDefaults.standard.dictionary(forKey: Self.cacheKey) as? [String: String] ?? [:]
    }

    func string(_ key: Key) -> String {
        values[key.rawValue].flatMap { $0.isEmpty ? nil : $0 } ?? key.defaultValue
    }

    /// The official extended due date, or nil when none is published (or it's malformed).
    var extendedDueDate: ExtensionDateParts? {
        Self.parseDate(string(.extendedDueDate))
    }

    /// The update policy for this platform; with nothing published, no one is prompted.
    var versionPolicy: VersionPolicy {
        VersionPolicy(
            latestVersion: string(.latestVersion).trimmingCharacters(in: .whitespaces),
            forceUpdate: string(.forceUpdate).trimmingCharacters(in: .whitespaces).lowercased() == "true",
            storeURL: string(.storeURL),
            notesEn: string(.updateNotesEn),
            notesAr: string(.updateNotesAr)
        )
    }

    /// Called on launch and whenever the app returns to the foreground.
    func fetch(force: Bool = false) {
        guard force || Date().timeIntervalSince(lastFetch) > Self.fetchInterval else { return }
        lastFetch = Date()
        Task {
            guard let entries = try? await Self.fetchEntries() else { return }
            values = entries
            UserDefaults.standard.set(entries, forKey: Self.cacheKey)
        }
    }

    private static func fetchEntries() async throws -> [String: String] {
        let url = URL(string: "https://firebaseremoteconfig.googleapis.com/v1/projects/\(FirebaseConfig.projectNumber)/namespaces/firebase:fetch?key=\(FirebaseConfig.apiKey)")!
        var request = URLRequest(url: url, timeoutInterval: 15)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(FirebaseConfig.bundleId, forHTTPHeaderField: "X-Ios-Bundle-Identifier")
        request.httpBody = try JSONSerialization.data(withJSONObject: [
            "appInstanceId": instanceId,
            "appId": FirebaseConfig.appId
        ])
        let (data, response) = try await URLSession.shared.data(for: request)
        guard (response as? HTTPURLResponse)?.statusCode == 200,
              let body = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        else { throw URLError(.badServerResponse) }
        // "NO_TEMPLATE" / "EMPTY_CONFIG" come back without entries: everything falls back to defaults.
        return body["entries"] as? [String: String] ?? [:]
    }

    private static var instanceId: String {
        if let id = UserDefaults.standard.string(forKey: instanceIdKey) { return id }
        let id = UUID().uuidString
        UserDefaults.standard.set(id, forKey: instanceIdKey)
        return id
    }

    /// Parses `DD-MM-YYYY` (`/` also accepted), rejecting impossible dates such as 30-02-2026.
    private static func parseDate(_ text: String) -> ExtensionDateParts? {
        let fields = text.trimmingCharacters(in: .whitespaces).split(whereSeparator: { $0 == "-" || $0 == "/" })
        let parts = fields.compactMap { Int($0) }
        guard fields.count == 3, parts.count == 3, parts[2] >= 1000,
              DateComponents(calendar: Calendar(identifier: .gregorian), year: parts[2], month: parts[1], day: parts[0]).isValidDate
        else { return nil }
        return ExtensionDateParts(day: parts[0], month: parts[1], year: parts[2])
    }
}
