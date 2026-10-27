
import Foundation
import FirebaseAuth
import FirebaseFirestore

final class UserProfileService {
    static let shared = UserProfileService()

    private let db = Firestore.firestore()

    private init() {}

    func isAdmin() async throws -> Bool {
        try await AdminAccessService.shared.isCurrentUserAdmin()
    }

    func fetchCurrentUserRole() async throws -> String {
        guard let user = Auth.auth().currentUser else {
            return "guest"
        }

        let adminDocument = try await db
            .collection("admin")
            .document(user.uid)
            .getDocument()

        if adminDocument.exists,
           let role = adminDocument.data()?["role"] as? String,
           role.trimmingCharacters(in: .whitespacesAndNewlines)
                .lowercased() == "admin" {
            return "admin"
        }

        return "user"
    }

    func currentUserID() -> String? {
        Auth.auth().currentUser?.uid
    }
}
