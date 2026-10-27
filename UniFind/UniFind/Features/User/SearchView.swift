import SwiftUI
import FirebaseFirestore

struct SearchView: View {

    @State private var searchText = ""
    @State private var selectedStatus = "All"

    @State private var items: [LostFoundItem] = []
    @State private var isLoading = true
    @State private var errorMessage: String?

    @State private var listener: ListenerRegistration?

    private let statuses = ["All", "Lost", "Found"]

    private var filteredItems: [LostFoundItem] {
        items.filter { item in

            let matchesSearch =
                searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
                item.itemName.localizedCaseInsensitiveContains(searchText) ||
                item.location.localizedCaseInsensitiveContains(searchText) ||
                item.category.localizedCaseInsensitiveContains(searchText) ||
                item.description.localizedCaseInsensitiveContains(searchText)

            let matchesStatus =
                selectedStatus == "All" ||
                item.reportType.caseInsensitiveCompare(selectedStatus) == .orderedSame

            return matchesSearch && matchesStatus
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {

                TextField(
                    "Search by item, category or location",
                    text: $searchText
                )
                .padding()
                .background(.gray.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal)

                Picker("Status", selection: $selectedStatus) {
                    ForEach(statuses, id: \.self) { status in
                        Text(status).tag(status)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)

                if isLoading {
                    Spacer()
                    ProgressView("Loading reports...")
                    Spacer()

                } else if let errorMessage = errorMessage {
                    Spacer()

                    ContentUnavailableView(
                        "Unable to Load Reports",
                        systemImage: "exclamationmark.icloud",
                        description: Text(errorMessage)
                    )

                    Button("Retry") {
                        startListening()
                    }
                    .buttonStyle(.borderedProminent)

                    Spacer()

                } else if filteredItems.isEmpty {
                    Spacer()

                    ContentUnavailableView(
                        "No Reports Found",
                        systemImage: "magnifyingglass",
                        description: Text(
                            searchText.isEmpty
                                ? "No lost or found reports are available yet."
                                : "Try another item name, category or location."
                        )
                    )

                    Spacer()

                } else {
                    List(filteredItems) { item in
                        VStack(alignment: .leading, spacing: 7) {

                            Text(item.itemName)
                                .font(.headline)

                            Label(
                                item.location,
                                systemImage: "mappin.and.ellipse"
                            )
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                            Text(item.category)
                                .font(.caption)
                                .foregroundStyle(.secondary)

                            HStack {
                                Text(item.reportType)
                                    .font(.caption.bold())
                                    .foregroundStyle(
                                        item.reportType.caseInsensitiveCompare("Lost") == .orderedSame
                                            ? .orange : .green
                                    )

                                Spacer()

                                Text(item.dateReported, style: .date)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(.vertical, 5)
                    }
                    .listStyle(.plain)
                }
            }
            .padding(.top)
            .navigationTitle("Search Items")
            .onAppear {
                startListening()
            }
            .onDisappear {
                listener?.remove()
                listener = nil
            }
        }
    }

    private func startListening() {
        guard listener == nil else { return }

        isLoading = true
        errorMessage = nil

        listener = Firestore.firestore()
            .collection("reports")
            .addSnapshotListener { snapshot, error in

                if let error = error {
                    print("Firestore Search Error: \(error.localizedDescription)")

                    errorMessage = error.localizedDescription
                    isLoading = false
                    listener?.remove()
                    listener = nil
                    return
                }

                guard let documents = snapshot?.documents else {
                    items = []
                    isLoading = false
                    return
                }

                items = documents.compactMap { document in
                    guard let item = LostFoundItem(document: document) else {
                        print(
                            "Could not decode report document: \(document.documentID)"
                        )
                        return nil
                    }

                    return item
                }

                isLoading = false
                errorMessage = nil
            }
    }
}

#Preview {
    SearchView()
}
