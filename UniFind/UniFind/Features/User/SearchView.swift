
import SwiftUI

struct SearchView: View {
    @State private var searchText = ""
    @State private var selectedStatus = "All"

    private let items: [(name: String, location: String, status: String)] = [
        ("Black Wallet", "Library", "Lost"),
        ("Student ID Card", "Cafeteria", "Found"),
        ("Blue Water Bottle", "Lecture Hall", "Lost"),
        ("Set of Keys", "Parking Area", "Found")
    ]

    private let statuses = ["All", "Lost", "Found"]

    private var filteredItems: [(name: String, location: String, status: String)] {
        items.filter { item in
            let matchesSearch =
                searchText.isEmpty ||
                item.name.localizedCaseInsensitiveContains(searchText) ||
                item.location.localizedCaseInsensitiveContains(searchText)

            let matchesStatus =
                selectedStatus == "All" ||
                item.status == selectedStatus

            return matchesSearch && matchesStatus
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                TextField("Search by item or location", text: $searchText)
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

                List(filteredItems, id: \.name) { item in
                    VStack(alignment: .leading, spacing: 6) {
                        Text(item.name)
                            .font(.headline)

                        Label(item.location, systemImage: "mappin.and.ellipse")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        Text(item.status)
                            .font(.caption.bold())
                            .foregroundStyle(
                                item.status == "Lost" ? .orange : .green
                            )
                    }
                    .padding(.vertical, 4)
                }
                .listStyle(.plain)
            }
            .padding(.top)
            .navigationTitle("Search Items")
        }
    }
}

#Preview {
    SearchView()
}
