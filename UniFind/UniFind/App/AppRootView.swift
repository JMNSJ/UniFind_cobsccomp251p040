
import SwiftUI

struct AppRootView: View {

    @StateObject private var authViewModel = AuthenticationViewModel()

    @State private var hasCompletedOnboarding = false
    @State private var isCheckingRole = false
    @State private var isAdmin = false
    @State private var roleCheckError: String?

    var body: some View {
        Group {
            if !authViewModel.isLoggedIn {

                if hasCompletedOnboarding {
                    LoginView(authViewModel: authViewModel)
                } else {
                    OnboardingView {
                        hasCompletedOnboarding = true
                    }
                }

            } else if isCheckingRole {

                ProgressView("Checking account...")

            } else if let roleCheckError {

                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.shield")
                        .font(.largeTitle)

                    Text("Unable to verify your account")
                        .font(.headline)

                    Text(roleCheckError)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.secondary)

                    Button("Try Again") {
                        Task {
                            await checkUserRole()
                        }
                    }

                    Button("Sign Out") {
                        authViewModel.logout()
                    }
                }
                .padding()

            } else if isAdmin {

                AdminRootView {
                    authViewModel.logout()
                }

            } else {

                UserTabView {
                    authViewModel.logout()
                }
            }
        }
        .task(id: authViewModel.userID) {
            await checkUserRole()
        }
    }

    @MainActor
    private func checkUserRole() async {

        guard authViewModel.isLoggedIn,
              authViewModel.userID != nil else {
            isAdmin = false
            roleCheckError = nil
            isCheckingRole = false
            return
        }

        isCheckingRole = true
        isAdmin = false
        roleCheckError = nil

        do {
            isAdmin = try await AdminAccessService.shared
                .isCurrentUserAdmin()
        } catch {
            isAdmin = false
            roleCheckError =
                "We could not verify your account role. Check your internet connection and Firestore security rules, then try again."
        }

        isCheckingRole = false
    }
}

#Preview {
    AppRootView()
}
