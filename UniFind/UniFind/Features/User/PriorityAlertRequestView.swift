
import SwiftUI

struct PriorityAlertRequestView: View {
    @State private var itemName = ""
    @State private var description = ""
    @State private var location = ""

    @State private var isSubmitting = false
    @State private var showSuccess = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            Form {
                Section("Important lost item") {
                    TextField("Item name", text: $itemName)

                    TextField(
                        "Where was it lost?",
                        text: $location
                    )

                    TextField(
                        "Why is it urgent?",
                        text: $description,
                        axis: .vertical
                    )
                    .lineLimit(3...5)
                }

                Section {
                    Text(
                        "Your request will be reviewed by a UniFind administrator. " +
                        "It will not be broadcast until approved."
                    )
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                }

                Button {
                    submit()
                } label: {
                    if isSubmitting {
                        ProgressView()
                    } else {
                        Text("Request High-Priority Alert")
                    }
                }
                .disabled(
                    itemName.trimmingCharacters(in: .whitespaces).isEmpty ||
                    location.trimmingCharacters(in: .whitespaces).isEmpty ||
                    description.trimmingCharacters(in: .whitespaces).isEmpty ||
                    isSubmitting
                )
            }
            .navigationTitle("Priority Alert Request")
            .alert("Request Submitted", isPresented: $showSuccess) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("An administrator will review your request.")
            }
            .alert(
                "Unable to Submit",
                isPresented: Binding(
                    get: { errorMessage != nil },
                    set: { if !$0 { errorMessage = nil } }
                )
            ) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage ?? "An unknown error occurred.")
            }
        }
    }

    private func submit() {
        isSubmitting = true

        PriorityAlertService.shared.submitRequest(
            itemName: itemName.trimmingCharacters(in: .whitespaces),
            description: description.trimmingCharacters(in: .whitespaces),
            location: location.trimmingCharacters(in: .whitespaces)
        ) { result in
            DispatchQueue.main.async {
                isSubmitting = false

                switch result {
                case .success:
                    itemName = ""
                    description = ""
                    location = ""
                    showSuccess = true

                case .failure(let error):
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
}
