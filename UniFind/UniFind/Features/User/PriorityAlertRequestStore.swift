
import Foundation
import FirebaseAuth
import FirebaseFirestore

final class PriorityAlertRequestStore {

    static let shared = PriorityAlertRequestStore()

    private let db = Firestore.firestore()

    private init() {}

    func createRequest(
        itemName: String,
        description: String,
        location: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        guard let user = Auth.auth().currentUser else {
            let error = NSError(
                domain: "UniFind.PriorityAlert",
                code: 401,
                userInfo: [
                    NSLocalizedDescriptionKey:
                        "Please sign in before requesting a high-priority alert."
                ]
            )

            completion(.failure(error))
            return
        }

        let requestData: [String: Any] = [
            "itemName": itemName,
            "description": description,
            "location": location,
            "requestedBy": user.uid,
            "status": "pending",
            "createdAt": Timestamp(date: Date())
        ]

        db.collection("priorityAlertRequests")
            .addDocument(data: requestData) { error in

                if let error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
    }
}
