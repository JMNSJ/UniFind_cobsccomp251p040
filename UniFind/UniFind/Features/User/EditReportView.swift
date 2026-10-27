
import SwiftUI

struct EditReportView: View {
    @Environment(\.dismiss) private var dismiss

    @ObservedObject private var reportStore = ReportStore.shared

    let report: LostFoundItem

    @State private var itemName: String
    @State private var category: String
    @State private var itemDescription: String
    @State private var location: String
    @State private var reportType: String

    @State private var isSaving = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var showSuccess = false

    private let categories = [
        "Electronics",
        "Bags",
        "Books & Stationery",
        "Clothing",
        "ID Cards",
        "Keys",
        "Accessories",
        "Other"
    ]

    init(report: LostFoundItem) {
        self.report = report

        _itemName = State(initialValue: report.itemName)
        _category = State(initialValue: report.category)
        _itemDescription = State(initialValue: report.description)
        _location = State(initialValue: report.location)
        _reportType = State(initialValue: report.reportType)
    }

    var body: some View {
        Form {
            Section("Report type") {
                Picker("Type", selection: $reportType) {
                    Text("Lost").tag("Lost")
                    Text("Found").tag("Found")
                }
                .pickerStyle(.segmented)
            }

            Section("Item details") {
                TextField("Item name", text: $itemName)

                Picker("Category", selection: $category) {
                    ForEach(categories, id: \.self) { value in
                        Text(value).tag(value)
                    }
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("Description")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    TextEditor(text: $itemDescription)
                        .frame(minHeight: 100)
                }
            }

            Section("Location") {
                TextField(
                    "Location details",
                    text: $location,
                    axis: .vertical
                )
                .lineLimit(2...4)
            }

            Section {
                Text("Your existing photo, map coordinates, report date and status will be preserved.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            Section {
                Button {
                    saveChanges()
                } label: {
                    HStack {
                        Spacer()

                        if isSaving {
                            ProgressView()
                                .padding(.trailing, 6)
                            Text("Saving...")
                        } else {
                            Label("Save Changes", systemImage: "checkmark.circle.fill")
                        }

                        Spacer()
                    }
                }
                .disabled(
                    isSaving ||
                    itemName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
                    location.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                )
            }
        }
        .navigationTitle("Edit Report")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
                .disabled(isSaving)
            }
        }
        .alert("Report Updated", isPresented: $showSuccess) {
            Button("Done") {
                dismiss()
            }
        } message: {
            Text("Your changes have been saved successfully.")
        }
        .alert("Unable to Update", isPresented: $showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
    }

    private func saveChanges() {
        guard !isSaving else { return }

        isSaving = true

        reportStore.updateReport(
            report: report,
            itemName: itemName,
            category: category,
            description: itemDescription,
            location: location,
            reportType: reportType
        ) { result in
            isSaving = false

            switch result {
            case .success:
                showSuccess = true

            case .failure(let error):
                errorMessage = error.localizedDescription
                showError = true
            }
        }
    }
}

#Preview {
    NavigationStack {
        EditReportView(
            report: LostFoundItem(
                itemName: "Black Wallet",
                category: "Accessories",
                description: "Black leather wallet",
                location: "University Library",
                reportType: "Lost"
            )
        )
    }
}
