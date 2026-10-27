
import Foundation
import FirebaseAuth
import FirebaseFirestore

final class AdminAccessService {

    static let shared = AdminAccessService()

    private let db = Firestore.firestore()

    private init() {}

    /// Returns true only when the signed-in user has
    /// an admin/{uid} document with role == "admin".
    func isCurrentUserAdmin() async throws -> Bool {
        guard let user = Auth.auth().currentUser else {
            return false
        }

        let document = try await db
            .collection("admin")
            .document(user.uid)
            .getDocument()

        guard
            document.exists,
            let role = document.data()?["role"] as? String
        else {
            return false
        }

        return role
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased() == "admin"
    }
}
