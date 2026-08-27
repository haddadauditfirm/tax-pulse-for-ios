import Foundation

struct TaxPulseSnapshot: Codable {
    var users: [UserRecord]
    var companies: [CompanyRecord]
    var employees: [EmployeeRecord]
    var payrollRuns: [PayrollRunRecord]
    var auditLogs: [AuditLogRecord]
}

final class TaxPulseLocalStore {
    private let fileURL: URL

    init(fileManager: FileManager = .default) {
        let base = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? fileManager.temporaryDirectory
        let directory = base.appendingPathComponent("TaxPulseIOS", isDirectory: true)
        try? fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
        fileURL = directory.appendingPathComponent("business-layer.json")
    }

    func load() -> TaxPulseSnapshot? {
        guard let data = try? Data(contentsOf: fileURL) else { return nil }
        return try? JSONDecoder().decode(TaxPulseSnapshot.self, from: data)
    }

    func save(_ snapshot: TaxPulseSnapshot) {
        guard let data = try? JSONEncoder().encode(snapshot) else { return }
        try? data.write(to: fileURL, options: [.atomic])
    }
}
