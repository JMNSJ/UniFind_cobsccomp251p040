
import Foundation
import FirebaseAuth
import FirebaseFirestore
import WidgetKit

private let appGroupID = "group.com.example.UniFind"

final class PriorityAlertService {

    static let shared = PriorityAlertService()

    private let db = Firestore.firestore()

    private init() {}

    // MARK: - Submit Request

    func submitRequest(
        itemName: String,
        description: String,
        location: String,
        reportId: String? = nil,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion(.failure(ServiceError.notAuthenticated))
            return
        }

        var data: [String: Any] = [
            "itemName": itemName,
            "description": description,
            "location": location,
            "requestedBy": uid,
            "status": "pending",
            "createdAt": FieldValue.serverTimestamp()
        ]

        if let reportId = reportId {
            data["reportId"] = reportId
        }

        db.collection("priorityAlertRequests")
            .addDocument(data: data) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
    }

    // MARK: - Listen for Pending Requests

    func listenForPendingRequests(
        onChange: @escaping ([PriorityAlertRequest]) -> Void,
        onError: @escaping (Error) -> Void
    ) -> ListenerRegistration {

        return db.collection("priorityAlertRequests")
            .whereField("status", isEqualTo: "pending")
            .addSnapshotListener { snapshot, error in

                if let error = error {
                    onError(error)
                    return
                }

                let requests = snapshot?.documents.compactMap {
                    PriorityAlertRequest(
                        id: $0.documentID,
                        data: $0.data()
                    )
                } ?? []

                UserDefaults(suiteName: appGroupID)?
                    .set(
                        requests.count,
                        forKey: "adminPendingRequestCount"
                    )

                WidgetCenter.shared.reloadAllTimelines()

                onChange(requests)
            }
    }

    // MARK: - Listen for Active Alerts

    func listenForActiveAlerts(
        onChange: @escaping ([PriorityAlert]) -> Void,
        onError: @escaping (Error) -> Void
    ) -> ListenerRegistration {

        return db.collection("priorityAlerts")
            .whereField("isActive", isEqualTo: true)
            .addSnapshotListener { snapshot, error in

                if let error = error {
                    onError(error)
                    return
                }

                let documents = snapshot?.documents ?? []

                let sortedDocuments = documents.sorted {
                    let firstDate =
                        ($0.data()["createdAt"] as? Timestamp)?
                        .dateValue() ?? .distantPast

                    let secondDate =
                        ($1.data()["createdAt"] as? Timestamp)?
                        .dateValue() ?? .distantPast

                    return firstDate > secondDate
                }

                // Convert Firestore documents into PriorityAlert models.
                let alerts: [PriorityAlert] =
                    sortedDocuments.compactMap { document in
                        PriorityAlert(
                            id: document.documentID,
                            data: document.data()
                        )
                    }

                // Cache the latest alert for the widget.
                if let latest = sortedDocuments.first {
                    let data = latest.data()

                    let cachedAlert: [String: String] = [
                        "itemName": data["itemName"] as? String ?? "",
                        "message": data["message"] as? String ?? "",
                        "location": data["location"] as? String ?? ""
                    ]

                    UserDefaults(suiteName: appGroupID)?
                        .set(
                            cachedAlert,
                            forKey: "latestPriorityAlert"
                        )
                } else {
                    UserDefaults(suiteName: appGroupID)?
                        .set(
                            [
                                "itemName": "No active alerts",
                                "message": "Important alerts will appear here.",
                                "location": ""
                            ],
                            forKey: "latestPriorityAlert"
                        )
                }

                WidgetCenter.shared.reloadAllTimelines()

                onChange(alerts)
            }
    }

    // MARK: - Approve and Publish Alert

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
                let requestSnapshot =
                    try transaction.getDocument(requestRef)

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

                transaction.setData(
                    alertData,
                    forDocument: alertRef
                )

                transaction.updateData(
                    [
                        "status": "approved",
                        "reviewedBy": adminUID,
                        "reviewedAt": FieldValue.serverTimestamp(),
                        "alertId": alertRef.documentID
                    ],
                    forDocument: requestRef
                )

                return nil

            } catch {
                errorPointer?.pointee = error as NSError
                return nil
            }
        }) { _, error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }

    // MARK: - Reject Request

    func rejectRequest(
        _ request: PriorityAlertRequest,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        guard let adminUID = Auth.auth().currentUser?.uid else {
            completion(.failure(ServiceError.notAuthenticated))
            return
        }

        let requestRef = db.collection("priorityAlertRequests")
            .document(request.id)

        db.runTransaction({ transaction, errorPointer -> Any? in
            do {
                let snapshot = try transaction.getDocument(requestRef)

                guard
                    snapshot.exists,
                    snapshot.data()?["status"] as? String == "pending"
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

                transaction.updateData(
                    [
                        "status": "rejected",
                        "reviewedBy": adminUID,
                        "reviewedAt": FieldValue.serverTimestamp()
                    ],
                    forDocument: requestRef
                )

                return nil

            } catch {
                errorPointer?.pointee = error as NSError
                return nil
            }
        }) { _, error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }

    // MARK: - Deactivate Published Alert

    func deactivateAlert(
        id alertID: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        guard Auth.auth().currentUser != nil else {
            completion(.failure(ServiceError.notAuthenticated))
            return
        }

        db.collection("priorityAlerts")
            .document(alertID)
            .updateData(["isActive": false]) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
    }

    // MARK: - Errors

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
