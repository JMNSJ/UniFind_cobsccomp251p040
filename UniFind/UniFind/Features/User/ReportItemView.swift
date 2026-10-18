
import SwiftUI

struct ReportItemView: View {
    @State private var reportType = "Lost"
    @State private var itemName = ""
    @State private var category = "Electronics"
    @State private var description = ""
    @State private var location = ""
    @State private var itemDate = Date()
    @State private var isUrgent = false
    @State private var showingConfirmation = false

    private let categories = [
        "Electronics",
        "Identification",
        "Keys",
        "Bags",
        "Clothing",
        "Books",
        "Other"
    ]

    var body: some View {
        NavigationStack {
            Form {
                Section("Report Type") {
                    Picker("Type", selection: $reportType) {
                        Text("Lost").tag("Lost")
                        Text("Found").tag("Found")
                    }
                    .pickerStyle(.segmented)
                }

                Section("Item Details") {
                    TextField("Item name", text: $itemName)

                    Picker("Category", selection: $category) {
                        ForEach(categories, id: \.self) { value in
                            Text(value).tag(value)
                        }
                    }

                    TextField(
                        "Description",
                        text: $description,
                        axis: .vertical
                    )
                    .lineLimit(3...6)
                }

                Section("Date and Location") {
                    DatePicker(
                        reportType == "Lost" ? "Date Lost" : "Date Found",
                        selection: $itemDate,
                        displayedComponents: .date
                    )

                    TextField("Campus location", text: $location)
                }

                Section("Urgent Item") {
                    Toggle("Mark as urgent", isOn: $isUrgent)

                    if isUrgent {
                        Text("Urgent requests may require administrator approval before a campus-wide alert is sent.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                Section {
                    Button("Submit Report") {
                        showingConfirmation = true
                    }
                    .disabled(
                        itemName.trimmingCharacters(in: .whitespaces).isEmpty ||
                        location.trimmingCharacters(in: .whitespaces).isEmpty
                    )
                    .frame(maxWidth: .infinity)
                }
            }
            .navigationTitle("Report an Item")
            .alert("Report Created", isPresented: $showingConfirmation) {
                Button("OK", role: .cancel) {
                    itemName = ""
                    description = ""
                    location = ""
                    isUrgent = false
                }
            } message: {
                Text("This is a UI demonstration. Your report has not been saved to a database.")
            }
        }
    }
}

#Preview {
    ReportItemView()
}
