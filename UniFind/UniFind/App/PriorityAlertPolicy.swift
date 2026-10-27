
import Foundation

enum PriorityAlertPolicy {

    static func isValidRequest(
        itemName: String,
        description: String,
        location: String
    ) -> Bool {
        !itemName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !location.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    static func canCreateRequest(
        isSignedIn: Bool,
        itemName: String,
        description: String,
        location: String
    ) -> Bool {
        isSignedIn &&
        isValidRequest(
            itemName: itemName,
            description: description,
            location: location
        )
    }

    static func canReviewRequest(
        isAdmin: Bool,
        status: String
    ) -> Bool {
        isAdmin && status == "pending"
    }

    static func canBroadcastAlert(status: String) -> Bool {
        status == "approved"
    }
}
