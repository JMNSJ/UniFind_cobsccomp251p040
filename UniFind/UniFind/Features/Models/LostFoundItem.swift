
import Foundation
import UIKit
import FirebaseFirestore

struct LostFoundItem: Identifiable {
    var id: String
    var itemName: String
    var category: String
    var description: String
    var location: String
    var reportType: String
    var userID: String
    var dateReported: Date
    var status: String
    var imageURL: String?
    var image: UIImage?
    var latitude: Double?
    var longitude: Double?

    init(
        id: String = UUID().uuidString,
        itemName: String,
        category: String,
        description: String,
        location: String,
        reportType: String,
        image: UIImage? = nil,
        userID: String = "",
        dateReported: Date = Date(),
        status: String = "Open",
        imageURL: String? = nil,
        latitude: Double? = nil,
        longitude: Double? = nil
    ) {
        self.id = id
        self.itemName = itemName
        self.category = category
        self.description = description
        self.location = location
        self.reportType = reportType
        self.image = image
        self.userID = userID
        self.dateReported = dateReported
        self.status = status
        self.imageURL = imageURL
        self.latitude = latitude
        self.longitude = longitude
    }

    // Firestore field names must match the security rules.
    var firestoreData: [String: Any] {
        var data: [String: Any] = [
            "itemName": itemName,
            "category": category,
            "description": description,
            "location": location,
            "reportType": reportType,
            "userId": userID,
            "createdAt": Timestamp(date: dateReported),
            "status": status
        ]

        data["imageURL"] = imageURL ?? ""
        data["latitude"] = latitude.map { $0 as Any } ?? NSNull()
        data["longitude"] = longitude.map { $0 as Any } ?? NSNull()

        return data
    }

    init?(document: QueryDocumentSnapshot) {
        let data = document.data()

        guard
            let itemName = data["itemName"] as? String,
            let category = data["category"] as? String,
            let description = data["description"] as? String,
            let location = data["location"] as? String,
            let reportType = data["reportType"] as? String
        else {
            return nil
        }

        // Support both the new and old field names.
        guard let userID =
            (data["userId"] as? String) ??
            (data["userID"] as? String)
        else {
            return nil
        }

        self.id = document.documentID
        self.itemName = itemName
        self.category = category
        self.description = description
        self.location = location
        self.reportType = reportType
        self.userID = userID

        if let timestamp = data["createdAt"] as? Timestamp {
            self.dateReported = timestamp.dateValue()
        } else if let timestamp = data["dateReported"] as? Timestamp {
            self.dateReported = timestamp.dateValue()
        } else {
            self.dateReported = Date()
        }

        self.status = data["status"] as? String ?? "Open"
        self.imageURL = data["imageURL"] as? String
        self.latitude = data["latitude"] as? Double
        self.longitude = data["longitude"] as? Double
        self.image = nil
    }
}
