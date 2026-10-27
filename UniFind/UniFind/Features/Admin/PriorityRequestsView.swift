
import SwiftUI
import FirebaseFirestore

struct PriorityRequestsView: View {
    @State private var requests: [PriorityAlertRequest] = []
    @State private var listener: ListenerRegistration?
    @State private var errorMessage: String?
    @State private var isProcessing = false

    var body: some View {
        NavigationStack {
            Group {
                if requests.isEmpty {
                    ContentUnavailableView(
                        "No Pending Requests",
                        systemImage: "checkmark.circle",
                        description: Text(
                            "New priority alert requests will appear here."
                        )
                    )
                } else {
                    List(requests) { request in
                        VStack(alignment: .leading, spacing: 8) {
                            Text(request.itemName)
                                .font(.headline)

                            Text(request.description)
                                .font(.subheadline)

                            Label(
                                request.location,
                                systemImage: "mappin.and.ellipse"
                            )
                            .font(.caption)
                            .foregroundStyle(.secondary)

                            Text("Requested by: \(request.requestedBy)")
                                .font(.caption2)
                                .foregroundStyle(.secondary)

                            HStack {
                                Button("Approve") {
                                    process(request, approve: true)
                                }
                                .buttonStyle(.borderedProminent)
                                .tint(.green)

                                Button("Reject", role: .destructive) {
                                    process(request, approve: false)
                                }
                                .buttonStyle(.bordered)
                            }
                            .disabled(isProcessing)
                        }
                        .padding(.vertical, 8)
                    }
                }
            }
            .navigationTitle("Priority Requests")
            .overlay {
                if isProcessing {
                    ProgressView("Processing...")
                }
            }
            .onAppear(perform: startListening)
            .onDisappear {
                listener?.remove()
                listener = nil
            }
            .alert(
                "Request Error",
                isPresented: Binding(
                    get: { errorMessage != nil },
                    set: { if !$0 { errorMessage = nil } }
                )
            ) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage ?? "")
            }
        }
    }

    private func startListening() {
        guard listener == nil else { return }

        listener = PriorityAlertService.shared
            .listenForPendingRequests { newRequests in
                DispatchQueue.main.async {
                    requests = newRequests
                }
            } onError: { error in
                DispatchQueue.main.async {
                    errorMessage = error.localizedDescription
                }
            }
    }

    private func process(
        _ request: PriorityAlertRequest,
        approve: Bool
    ) {
        isProcessing = true

        let completion: (Result<Void, Error>) -> Void = { result in
            DispatchQueue.main.async {
                isProcessing = false

                if case .failure(let error) = result {
                    errorMessage = error.localizedDescription
                }
            }
        }

        if approve {
            PriorityAlertService.shared.approveRequest(
                request,
                completion: completion
            )
        } else {
            PriorityAlertService.shared.rejectRequest(
                request,
                completion: completion
            )
        }
    }
}
