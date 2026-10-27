
import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct AdminDashboardView: View {
    @State private var reports: [[String: Any]] = []
    @State private var isLoading = true
    @State private var errorMessage: String?

    private let db = Firestore.firestore()

    private var pendingCount: Int {
        reports.filter {
            ($0["status"] as? String ?? "Pending") == "Pending"
        }.count
    }

    private var lostCount: Int {
        reports.filter {
            ($0["reportType"] as? String ?? "") == "Lost"
        }.count
    }

    private var foundCount: Int {
        reports.filter {
            ($0["reportType"] as? String ?? "") == "Found"
        }.count
    }

    private var urgentCount: Int {
        reports.filter {
            ($0["urgentRequested"] as? Bool ?? false) &&
            !($0["urgentApproved"] as? Bool ?? false)
        }.count
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Admin Overview")
                        .font(.largeTitle.bold())

                    Text("Monitor UniFind activity and review reports.")
                        .foregroundStyle(.secondary)
                }

                LazyVGrid(
                    columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ],
                    spacing: 12
                ) {
                    statisticCard(
                        title: "Total Reports",
                        count: reports.count,
                        symbol: "doc.text"
                    )

                    statisticCard(
                        title: "Pending",
                        count: pendingCount,
                        symbol: "clock"
                    )

                    statisticCard(
                        title: "Lost Items",
                        count: lostCount,
                        symbol: "magnifyingglass"
                    )

                    statisticCard(
                        title: "Found Items",
                        count: foundCount,
                        symbol: "checkmark.circle"
                    )

                    statisticCard(
                        title: "Urgent Reviews",
                        count: urgentCount,
                        symbol: "bell.badge"
                    )
                }

                if let errorMessage {
                    Text(errorMessage)
                        .font(.footnote)
                        .foregroundStyle(.red)
                }

                Text("Admin responsibilities")
                    .font(.title3.bold())

                Label("Review submitted reports", systemImage: "doc.text.magnifyingglass")
                Label("Approve or reject urgent alerts", systemImage: "bell.badge")
                Label("Track item return status", systemImage: "checkmark.circle")
            }
            .padding()
        }
        .navigationTitle("Dashboard")
        .task {
            await loadReports()
        }
        .refreshable {
            await loadReports()
        }
    }

    private func statisticCard(
        title: String,
        count: Int,
        symbol: String
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: symbol)
                .font(.title2)

            Text("\(count)")
                .font(.largeTitle.bold())

            Text(title)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    @MainActor
    private func loadReports() async {
        guard Auth.auth().currentUser != nil else {
            errorMessage = "Please sign in again."
            isLoading = false
            return
        }

        do {
            let snapshot = try await db
                .collection("reports")
                .getDocuments()

            reports = snapshot.documents.map { $0.data() }
            errorMessage = nil
        } catch {
            errorMessage = "Could not load reports. Check your connection and Firestore rules."
        }

        isLoading = false
    }
}
