
import Foundation
import FirebaseAuth
import FirebaseFirestore

final class PriorityAlertService {
    static let shared = PriorityAlertService()

    private let db = Firestore.firestore()

    private init() {}

    // MARK: - Submit a request

    func submitRequest(
        itemName: String,
        description: String,
        location: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion(.failure(ServiceError.notAuthenticated))
            return
        }

        let data: [String: Any] = [
            "itemName": itemName,
            "description": description,
            "location": location,
            "requestedBy": uid,
            "status": "pending",
            "createdAt": FieldValue.serverTimestamp()
        ]

        db.collection("priorityAlertRequests").addDocument(
            data: data
        ) { error in
            if let error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }

    // MARK: - Listen for pending requests

    func listenForPendingRequests(
        onChange: @escaping ([PriorityAlertRequest]) -> Void,
        onError: @escaping (Error) -> Void
    ) -> ListenerRegistration {
        return db.collection("priorityAlertRequests")
            .whereField("status", isEqualTo: "pending")
            .addSnapshotListener { snapshot, error in
                if let error {
                    onError(error)
                    return
                }

                let requests = snapshot?.documents.compactMap {
                    PriorityAlertRequest(
                        id: $0.documentID,
                        data: $0.data()
                    )
                } ?? []

                onChange(requests)
            }
    }

    // MARK: - Approve and publish an alert

    func approveRequest(
        _ request: PriorityAlertRequest,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        guard let adminUID = Auth.auth().currentUser?.uid else {
            completion(.failure(ServiceError.notAuthenticated))
            return
        }

        let requestRef = db.collection("priorityAlertRequests")
            .document(request.id)

        let alertRef = db.collection("priorityAlerts").document()

        let alertData: [String: Any] = [
            "itemName": request.itemName,
            "message": "Urgent: \(request.itemName) reported lost.",
            "location": request.location,
            "approvedBy": adminUID,
            "isActive": true,
            "createdAt": FieldValue.serverTimestamp()
        ]

        db.runTransaction({ transaction, errorPointer -> Any? in
            do {
                let requestSnapshot = try transaction.getDocument(requestRef)

                guard
                    requestSnapshot.exists,
                    requestSnapshot.data()?["status"] as? String == "pending"
                else {
                    errorPointer?.pointee = NSError(
                        domain: "UniFind",
                        code: 409,
                        userInfo: [
                            NSLocalizedDescriptionKey:
                                "This request has already been processed."
                        ]
                    )
                    return nil
                }

                transaction.setData(alertData, forDocument: alertRef)

                transaction.updateData([
                    "status": "approved",
                    "reviewedBy": adminUID,
                    "reviewedAt": FieldValue.serverTimestamp(),
                    "alertId": alertRef.documentID
                ], forDocument: requestRef)

                return nil
            } catch {
                errorPointer?.pointee = error as NSError
                return nil
            }
        }) { _, error in
            if let error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }

    // MARK: - Reject a request

    func rejectRequest(
        _ request: PriorityAlertRequest,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        guard let adminUID = Auth.auth().currentUser?.uid else {
            completion(.failure(ServiceError.notAuthenticated))
            return
        }

        db.collection("priorityAlertRequests")
            .document(request.id)
            .updateData([
                "status": "rejected",
                "reviewedBy": adminUID,
                "reviewedAt": FieldValue.serverTimestamp()
            ]) { error in
                if let error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
    }

    enum ServiceError: LocalizedError {
        case notAuthenticated

        var errorDescription: String? {
            switch self {
            case .notAuthenticated:
                return "Please sign in before continuing."
            }
        }
    }
}
