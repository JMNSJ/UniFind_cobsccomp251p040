import Combine
import Foundation

@MainActor
final class AdminViewModel: ObservableObject {
    @Published var statistics = AdminReportStatistics(
        total: 0,
        pending: 0,
        lost: 0,
        found: 0,
        urgent: 0
    )

    @Published var pendingPriorityCount = 0
    @Published var isAdmin = false
    @Published var isLoading = false
    @Published var errorMessage: String?

    func checkAdminAccess() async -> Bool {
        do {
            isAdmin = try await AdminAccessService.shared
                .isCurrentUserAdmin()
            return isAdmin
        } catch {
            isAdmin = false
            errorMessage = error.localizedDescription
            return false
        }
    }

    func loadStatistics() async {
        isLoading = true
        defer { isLoading = false }

        do {
            guard try await AdminAccessService.shared.isCurrentUserAdmin() else {
                isAdmin = false
                errorMessage = "Admin access is required."
                return
            }

            isAdmin = true
            statistics = try await AdminService.shared
                .fetchReportStatistics()
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func updatePendingPriorityCount(_ count: Int) {
        pendingPriorityCount = count
    }
}
