
import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct AdminReportsView: View {
    @State private var reports: [AdminReportRow] = []
    @State private var isLoading = true
    @State private var errorMessage: String?

    private let db = Firestore.firestore()

    var body: some View {
        List {
            if let errorMessage {
                Text(errorMessage)
                    .foregroundStyle(.red)
            }

            if isLoading {
                ProgressView("Loading reports...")
            }

            if !isLoading && reports.isEmpty {
                ContentUnavailableView(
                    "No Reports",
                    systemImage: "doc.text",
                    description: Text("Submitted reports will appear here.")
                )
            }

            ForEach(reports) { report in
                VStack(alignment: .leading, spacing: 10) {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(report.itemName)
                                .font(.headline)

                            Text("\(report.reportType) · \(report.category)")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        Text(report.status)
                            .font(.caption.bold())
                            .padding(8)
                            .background(.thinMaterial)
                            .clipShape(Capsule())
                    }

                    Text(report.location)
                        .font(.subheadline)

                    Text(report.description)
                        .font(.footnote)
                        .foregroundStyle(.secondary)

                    if let latitude = report.latitude,
                       let longitude = report.longitude {
                        Label(
                            String(
                                format: "%.5f, %.5f",
                                latitude,
                                longitude
                            ),
                            systemImage: "mappin.and.ellipse"
                        )
                        .font(.caption)
                    }

                    if report.urgentRequested {
                        Label(
                            report.urgentApproved
                                ? "Urgent alert approved"
                                : "Urgent alert awaiting review",
                            systemImage: "bell.badge"
                        )
                        .font(.caption.bold())
                        .foregroundStyle(
                            report.urgentApproved ? .green : .orange
                        )

                        if !report.urgentApproved {
                            HStack {
                                Button("Approve Alert") {
                                    updateReport(
                                        report,
                                        fields: ["urgentApproved": true]
                                    )
                                }
                                .buttonStyle(.borderedProminent)

                                Button("Reject Alert") {
                                    updateReport(
                                        report,
                                        fields: [
                                            "urgentRequested": false,
                                            "urgentApproved": false
                                        ]
                                    )
                                }
                                .buttonStyle(.bordered)
                            }
                        }
                    }

                    Menu("Update Report Status") {
                        Button("Pending") {
                            updateReport(
                                report,
                                fields: ["status": "Pending"]
                            )
                        }

                        Button("Approved") {
                            updateReport(
                                report,
                                fields: ["status": "Approved"]
                            )
                        }

                        Button("Rejected") {
                            updateReport(
                                report,
                                fields: ["status": "Rejected"]
                            )
                        }

                        Button("Returned") {
                            updateReport(
                                report,
                                fields: ["status": "Returned"]
                            )
                        }
                    }
                    .font(.subheadline.bold())
                }
                .padding(.vertical, 8)
            }
        }
        .navigationTitle("Manage Reports")
        .task {
            await loadReports()
        }
        .refreshable {
            await loadReports()
        }
    }

    @MainActor
    private func loadReports() async {
        guard Auth.auth().currentUser != nil else {
            errorMessage = "Please sign in again."
            isLoading = false
            return
        }

        isLoading = true

        do {
            let snapshot = try await db
                .collection("reports")
                .getDocuments()

            reports = snapshot.documents.map { document in
                let data = document.data()

                return AdminReportRow(
                    id: document.documentID,
                    itemName: data["itemName"] as? String ?? "Unnamed item",
                    category: data["category"] as? String ?? "Other",
                    description: data["description"] as? String ?? "",
                    location: data["location"] as? String ?? "",
                    reportType: data["reportType"] as? String ?? "Lost",
                    status: data["status"] as? String ?? "Pending",
                    latitude: data["latitude"] as? Double,
                    longitude: data["longitude"] as? Double,
                    urgentRequested: data["urgentRequested"] as? Bool ?? false,
                    urgentApproved: data["urgentApproved"] as? Bool ?? false
                )
            }

            errorMessage = nil
        } catch {
            errorMessage = "Could not load reports: \(error.localizedDescription)"
        }

        isLoading = false
    }

    private func updateReport(
        _ report: AdminReportRow,
        fields: [String: Any]
    ) {
        Task {
            do {
                try await db.collection("reports")
                    .document(report.id)
                    .updateData(fields)

                await loadReports()
            } catch {
                errorMessage = "Update failed: \(error.localizedDescription)"
            }
        }
    }
}

private struct AdminReportRow: Identifiable {
    let id: String
    let itemName: String
    let category: String
    let description: String
    let location: String
    let reportType: String
    let status: String
    let latitude: Double?
    let longitude: Double?
    let urgentRequested: Bool
    let urgentApproved: Bool
}
