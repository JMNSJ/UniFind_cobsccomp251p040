
import Foundation
import SwiftUI
import Combine
import FirebaseAuth
import FirebaseFirestore

@MainActor
final class ReportStore: ObservableObject {

    static let shared = ReportStore()

    @Published private(set) var allReports: [LostFoundItem] = []
    @Published private(set) var isLoading = false
    @Published var errorMessage: String?

    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?
    private var listeningUserID: String?

    private init() {
        if let user = Auth.auth().currentUser {
            startListening(for: user.uid)
        }
    }

    // Reports belonging to the current signed-in user.
    var reports: [LostFoundItem] {
        guard let uid = Auth.auth().currentUser?.uid else {
            return []
        }

        return allReports
            .filter { $0.userID == uid }
            .sorted { $0.dateReported > $1.dateReported }
    }

    // MARK: - Start listening

    func startListening(for userID: String) {
        guard !userID.isEmpty else { return }

        if listeningUserID == userID, listener != nil {
            return
        }

        stopListening()

        listeningUserID = userID
        isLoading = true
        errorMessage = nil

        listener = db.collection("reports")
            .addSnapshotListener { [weak self] snapshot, error in

                Task { @MainActor in
                    guard let self else { return }

                    self.isLoading = false

                    if let error {
                        self.errorMessage =
                            "Unable to load reports: \(error.localizedDescription)"
                        return
                    }

                    guard let documents = snapshot?.documents else {
                        self.allReports = []
                        return
                    }

                    self.allReports = documents
                        .compactMap {
                            LostFoundItem(document: $0)
                        }
                        .sorted {
                            $0.dateReported > $1.dateReported
                        }
                }
            }
    }

    // MARK: - Stop listening

    func stopListening() {
        listener?.remove()
        listener = nil
        listeningUserID = nil
        allReports = []
        isLoading = false
    }

    // MARK: - Add report

    func addReport(
        _ report: LostFoundItem,
        completion: ((Result<Void, Error>) -> Void)? = nil
    ) {
        guard let user = Auth.auth().currentUser else {
            let error = NSError(
                domain: "UniFind",
                code: 401,
                userInfo: [
                    NSLocalizedDescriptionKey:
                        "Please sign in before submitting a report."
                ]
            )

            errorMessage = error.localizedDescription
            completion?(.failure(error))
            return
        }

        var newReport = report
        newReport.userID = user.uid
        newReport.dateReported = Date()
        newReport.status = "Pending"

        db.collection("reports")
            .document(newReport.id)
            .setData(newReport.firestoreData) { [weak self] error in

                Task { @MainActor in
                    if let error {
                        self?.errorMessage =
                            "Unable to submit report: \(error.localizedDescription)"
                        completion?(.failure(error))
                    } else {
                        self?.errorMessage = nil
                        completion?(.success(()))
                    }
                }
            }
    }

    func clearError() {
        errorMessage = nil
    }
}

