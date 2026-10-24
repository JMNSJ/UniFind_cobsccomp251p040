
import Foundation
import FirebaseAuth
import FirebaseFirestore

final class AdminAccessService {
    static let shared = AdminAccessService()

    private let db = Firestore.firestore()

    private init() {}

    func isCurrentUserAdmin() async throws -> Bool {
        guard let uid = Auth.auth().currentUser?.uid else {
            return false
        }

        let document = try await db
            .collection("users")
            .document(uid)
            .getDocument()

        return document.data()?["role"] as? String == "admin"
    }
}
