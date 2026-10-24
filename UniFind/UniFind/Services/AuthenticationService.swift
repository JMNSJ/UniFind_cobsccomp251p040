
import Foundation
import FirebaseAuth

final class AuthenticationService {

    static let shared = AuthenticationService()

    private init() {}

    func signIn(
        email: String,
        password: String,
        completion: @escaping (Result<User, Error>) -> Void
    ) {
        Auth.auth().signIn(
            withEmail: email,
            password: password
        ) { result, error in

            if let error = error {
                completion(.failure(error))
                return
            }

            guard let user = result?.user else {
                let error = NSError(
                    domain: "UniFind",
                    code: -1,
                    userInfo: [
                        NSLocalizedDescriptionKey:
                            "Unable to sign in. Please try again."
                    ]
                )

                completion(.failure(error))
                return
            }

            completion(.success(user))
        }
    }

    func signOut() throws {
        try Auth.auth().signOut()
    }

    var currentUser: User? {
        Auth.auth().currentUser
    }
}
