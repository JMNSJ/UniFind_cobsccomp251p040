
import SwiftUI

struct PriorityRequestDetailView: View {
    let request: PriorityAlertRequest

    @StateObject private var viewModel = PriorityAlertViewModel()
    @State private var showApprovalConfirmation = false
    @State private var showRejectionConfirmation = false

    var body: some View {
        Form {
            Section("Item details") {
                LabeledContent("Item", value: request.itemName)
                LabeledContent("Location", value: request.location)

                VStack(alignment: .leading, spacing: 6) {
                    Text("Reason for priority")
                        .font(.headline)
                    Text(request.description)
                }

                LabeledContent("Requested by", value: request.requestedBy)
                LabeledContent("Status", value: request.status)

                if let date = request.createdAt {
                    LabeledContent(
                        "Submitted",
                        value: date.formatted(
                            date: .abbreviated,
                            time: .shortened
                        )
                    )
                }
            }

            Section("Admin decision") {
                Button("Approve and Publish Alert") {
                    showApprovalConfirmation = true
                }
                .foregroundStyle(.green)
                .disabled(viewModel.isLoading || request.status != "pending")

                Button("Reject Request", role: .destructive) {
                    showRejectionConfirmation = true
                }
                .disabled(viewModel.isLoading || request.status != "pending")

                if viewModel.isLoading {
                    ProgressView("Processing...")
                }
            }

            if let success = viewModel.successMessage {
                Section {
                    Text(success)
                        .foregroundStyle(.green)
                }
            }

            if let error = viewModel.errorMessage {
                Section {
                    Text(error)
                        .foregroundStyle(.red)
                }
            }
        }
        .navigationTitle("Request Details")
        .confirmationDialog(
            "Approve this high-priority alert?",
            isPresented: $showApprovalConfirmation,
            titleVisibility: .visible
        ) {
            Button("Approve and Publish", role: .none) {
                Task {
                    await viewModel.approve(request)
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("The approved alert will be visible to app users.")
        }
        .confirmationDialog(
            "Reject this request?",
            isPresented: $showRejectionConfirmation,
            titleVisibility: .visible
        ) {
            Button("Reject Request", role: .destructive) {
                Task {
                    await viewModel.reject(request)
                }
            }
            Button("Cancel", role: .cancel) {}
        }
    }
}
