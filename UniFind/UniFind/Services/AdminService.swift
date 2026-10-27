
import Foundation
import FirebaseFirestore

struct AdminReportStatistics {
    let total: Int
    let pending: Int
    let lost: Int
    let found: Int
    let urgent: Int
}

final class AdminService {
    static let shared = AdminService()

    private let db = Firestore.firestore()

    private init() {}

    func fetchReportStatistics() async throws -> AdminReportStatistics {
        let snapshot = try await db
            .collection("reports")
            .getDocuments()

        let reports = snapshot.documents.map { $0.data() }

        let pending = reports.filter {
            ($0["status"] as? String ?? "Pending")
                .caseInsensitiveCompare("Pending") == .orderedSame
        }.count

        let lost = reports.filter {
            ($0["reportType"] as? String ?? "")
                .caseInsensitiveCompare("Lost") == .orderedSame
        }.count

        let found = reports.filter {
            ($0["reportType"] as? String ?? "")
                .caseInsensitiveCompare("Found") == .orderedSame
        }.count

        let urgent = reports.filter {
            ($0["urgentRequested"] as? Bool ?? false) &&
            !($0["urgentApproved"] as? Bool ?? false)
        }.count

        return AdminReportStatistics(
            total: reports.count,
            pending: pending,
            lost: lost,
            found: found,
            urgent: urgent
        )
    }
}
