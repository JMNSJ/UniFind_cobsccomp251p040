import Combine
import Foundation
import FirebaseFirestore

@MainActor
final class PriorityAlertViewModel: ObservableObject {
    @Published var requests: [PriorityAlertRequest] = []
    @Published var alerts: [PriorityAlert] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var successMessage: String?

    private var requestListener: ListenerRegistration?
    private var alertListener: ListenerRegistration?

    func startListeningForRequests() {
        guard requestListener == nil else { return }

        requestListener = PriorityAlertService.shared
            .listenForPendingRequests { [weak self] requests in
                Task { @MainActor in
                    self?.requests = requests.sorted {
                        ($0.createdAt ?? .distantPast) >
                        ($1.createdAt ?? .distantPast)
                    }
                }
            } onError: { [weak self] error in
                Task { @MainActor in
                    self?.errorMessage = error.localizedDescription
                }
            }
    }

    func startListeningForAlerts() {
        guard alertListener == nil else { return }

        alertListener = PriorityAlertService.shared
            .listenForActiveAlerts { [weak self] alerts in
                Task { @MainActor in
                    self?.alerts = alerts
                }
            } onError: { [weak self] error in
                Task { @MainActor in
                    self?.errorMessage = error.localizedDescription
                }
            }
    }

    func submitRequest(
        itemName: String,
        description: String,
        location: String,
        reportId: String? = nil
    ) async {
        isLoading = true
        defer { isLoading = false }

        do {
            try await PriorityAlertService.shared.submitRequest(
                itemName: itemName,
                description: description,
                location: location,
                reportId: reportId
            )
            successMessage = "Your request has been submitted for review."
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func approve(_ request: PriorityAlertRequest) async {
        await process(request, approve: true)
    }

    func reject(_ request: PriorityAlertRequest) async {
        await process(request, approve: false)
    }

    private func process(
        _ request: PriorityAlertRequest,
        approve: Bool
    ) async {
        isLoading = true
        defer { isLoading = false }

        do {
            if approve {
                try await PriorityAlertService.shared.approveRequest(request)
                successMessage = "The alert has been approved and published."
            } else {
                try await PriorityAlertService.shared.rejectRequest(request)
                successMessage = "The request has been rejected."
            }

            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func stopListening() {
        requestListener?.remove()
        requestListener = nil

        alertListener?.remove()
        alertListener = nil
    }
}
