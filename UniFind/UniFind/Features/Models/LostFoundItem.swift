
import SwiftUI
import Combine

struct LostFoundItem: Identifiable {
    let id: UUID
    var itemName: String
    var category: String
    var description: String
    var location: String
    var reportType: String
    var dateReported: Date
    var image: UIImage?

    init(
        id: UUID = UUID(),
        itemName: String,
        category: String,
        description: String,
        location: String,
        reportType: String,
        dateReported: Date = Date(),
        image: UIImage? = nil
    ) {
        self.id = id
        self.itemName = itemName
        self.category = category
        self.description = description
        self.location = location
        self.reportType = reportType
        self.dateReported = dateReported
        self.image = image
    }
}

final class ReportStore: ObservableObject {
    static let shared = ReportStore()

    @Published var reports: [LostFoundItem] = []

    private init() {}

    func addReport(_ report: LostFoundItem) {
        reports.insert(report, at: 0)
    }
}
