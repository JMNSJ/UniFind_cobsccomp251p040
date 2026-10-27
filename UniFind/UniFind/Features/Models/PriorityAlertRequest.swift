import Foundation
import FirebaseFirestore

struct PriorityAlertRequest: Identifiable {
    let id: String
    let itemName: String
    let description: String
    let location: String
    let requestedBy: String
    let status: String
    let createdAt: Date?

    init?(id: String, data: [String: Any]) {
        guard
            let itemName = data["itemName"] as? String,
            let description = data["description"] as? String,
            let location = data["location"] as? String,
            let requestedBy = data["requestedBy"] as? String,
            let status = data["status"] as? String
        else {
            return nil
        }

        self.id = id
        self.itemName = itemName
        self.description = description
        self.location = location
        self.requestedBy = requestedBy
        self.status = status
        self.createdAt = (data["createdAt"] as? Timestamp)?.dateValue()
    }
}
