
import SwiftUI
import FirebaseFirestore

struct AdminAlertsView: View {
    @State private var alerts: [PriorityAlert] = []
    @State private var listener: ListenerRegistration?

    var body: some View {
        List(alerts) { alert in
            VStack(alignment: .leading, spacing: 6) {
                Label(
                    alert.itemName,
                    systemImage: "bell.badge.fill"
                )
                .font(.headline)

                Text(alert.message)
                    .font(.subheadline)

                Text(alert.location)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text(alert.isActive ? "Active" : "Inactive")
                    .font(.caption)
                    .foregroundStyle(
                        alert.isActive ? .green : .secondary
                    )
            }
            .padding(.vertical, 5)
        }
        .navigationTitle("Published Alerts")
        .onAppear(perform: startListening)
        .onDisappear {
            listener?.remove()
            listener = nil
        }
    }

    private func startListening() {
        guard listener == nil else { return }

        listener = Firestore.firestore()
            .collection("priorityAlerts")
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { snapshot, error in
                guard error == nil else { return }

                let updatedAlerts = snapshot?.documents.compactMap {
                    PriorityAlert(
                        id: $0.documentID,
                        data: $0.data()
                    )
                } ?? []

                DispatchQueue.main.async {
                    alerts = updatedAlerts
                }
            }
    }
}
