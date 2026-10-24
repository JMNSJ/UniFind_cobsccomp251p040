
import Foundation

struct UserProfile: Identifiable, Codable {
    var id: String
    var fullName: String
    var email: String
    var role: String
    var createdAt: Date?

    // New registrations must use the "user" role.
    static let defaultRole = "user"
}
