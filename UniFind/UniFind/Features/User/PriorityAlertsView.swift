
import SwiftUI
import FirebaseFirestore

struct PriorityAlertsView: View {
    @State private var alerts: [PriorityAlert] = []
    @State private var listener: ListenerRegistration?

    var body: some View {
        NavigationStack {
            Group {
                if alerts.isEmpty {
                    ContentUnavailableView(
                        "No Active Priority Alerts",
                        systemImage: "bell",
                        description: Text(
                            "Important lost-item alerts will appear here."
                        )
                    )
                } else {
                    List(alerts) { alert in
                        VStack(alignment: .leading, spacing: 8) {
                            Label(
                                alert.itemName,
                                systemImage: "exclamationmark.triangle.fill"
                            )
                            .font(.headline)
                            .foregroundStyle(.red)

                            Text(alert.message)

                            Label(
                                alert.location,
                                systemImage: "mappin.and.ellipse"
                            )
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                            if let date = alert.createdAt {
                                Text(date.formatted(
                                    date: .abbreviated,
                                    time: .shortened
                                ))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            }
                        }
                        .padding(.vertical, 6)
                    }
                }
            }
            .navigationTitle("Priority Alerts")
            .onAppear(perform: startListening)
            .onDisappear {
                listener?.remove()
                listener = nil
            }
        }
    }

    private func startListening() {
        guard listener == nil else { return }

        listener = Firestore.firestore()
            .collection("priorityAlerts")
            .whereField("isActive", isEqualTo: true)
            .addSnapshotListener { snapshot, error in
                guard error == nil else { return }

                let updatedAlerts = snapshot?.documents.compactMap {
                    PriorityAlert(
                        id: $0.documentID,
                        data: $0.data()
                    )
                }
                .sorted {
                    ($0.createdAt ?? .distantPast) >
                    ($1.createdAt ?? .distantPast)
                } ?? []

                DispatchQueue.main.async {
                    alerts = updatedAlerts
                }
            }
    }
}
