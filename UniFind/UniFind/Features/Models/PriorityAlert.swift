import Foundation
import FirebaseFirestore

struct PriorityAlert: Identifiable {
    let id: String
    let itemName: String
    let message: String
    let location: String
    let approvedBy: String
    let isActive: Bool
    let createdAt: Date?

    init?(id: String, data: [String: Any]) {
        guard
            let itemName = data["itemName"] as? String,
            let message = data["message"] as? String,
            let location = data["location"] as? String,
            let approvedBy = data["approvedBy"] as? String,
            let isActive = data["isActive"] as? Bool
        else {
            return nil
        }

        self.id = id
        self.itemName = itemName
        self.message = message
        self.location = location
        self.approvedBy = approvedBy
        self.isActive = isActive
        self.createdAt = (data["createdAt"] as? Timestamp)?.dateValue()
    }
}
