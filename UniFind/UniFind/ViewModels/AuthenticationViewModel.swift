
import Foundation
import Combine
import FirebaseAuth

@MainActor
final class AuthenticationViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isLoggedIn = false
    @Published var userID: String?
    @Published var userEmail: String?

    private let authService = AuthenticationService.shared

    init() {
        // Require sign-in again when the app is relaunched.
        if authService.currentUser != nil {
            try? authService.signOut()
        }

        ReportStore.shared.stopListening()
        isLoggedIn = false
        userID = nil
        userEmail = nil
    }

    func login() {
        guard !isLoading else { return }

        errorMessage = nil

        let trimmedEmail = email.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard !trimmedEmail.isEmpty, !password.isEmpty else {
            errorMessage = "Please enter your email and password."
            return
        }

        guard trimmedEmail.contains("@") else {
            errorMessage = "Please enter a valid email address."
            return
        }

        isLoading = true

        authService.signIn(
            email: trimmedEmail,
            password: password
        ) { [weak self] result in
            Task { @MainActor in
                guard let self else { return }

                self.isLoading = false

                switch result {
                case .success(let user):
                    self.userID = user.uid
                    self.userEmail = user.email
                    self.isLoggedIn = true
                    self.password = ""
                    self.errorMessage = nil

                    ReportStore.shared.startListening(for: user.uid)

                case .failure(let error):
                    self.errorMessage = self.friendlyErrorMessage(error)
                }
            }
        }
    }

    func logout() {
        do {
            try authService.signOut()
            ReportStore.shared.stopListening()

            userID = nil
            userEmail = nil
            email = ""
            password = ""
            errorMessage = nil
            isLoggedIn = false
        } catch {
            errorMessage = "Unable to log out. Please try again."
        }
    }

    private func friendlyErrorMessage(_ error: Error) -> String {
        let nsError = error as NSError

        guard let code = AuthErrorCode(rawValue: nsError.code) else {
            return "Login failed. Please try again."
        }

        switch code {
        case .wrongPassword, .invalidCredential:
            return "Incorrect email or password."
        case .userNotFound:
            return "No account found with this email."
        case .invalidEmail:
            return "Please enter a valid email address."
        case .networkError:
            return "Network error. Check your internet connection."
        case .tooManyRequests:
            return "Too many attempts. Please try again later."
        case .userDisabled:
            return "This account has been disabled."
        default:
            return "Login failed. Please try again."
        }
    }
}
