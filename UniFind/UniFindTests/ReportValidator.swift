import Foundation

enum ReportValidator {
    static func validate(
        itemName: String,
        description: String,
        location: String
    ) -> Bool {
        !itemName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !location.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
