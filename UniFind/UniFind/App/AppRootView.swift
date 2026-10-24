
import SwiftUI

struct AppRootView: View {
    @StateObject private var authViewModel = AuthenticationViewModel()

    @State private var hasCompletedOnboarding = false
    @State private var isCheckingRole = false
    @State private var isAdmin = false
    @State private var roleCheckError: String?

    var body: some View {
        Group {
            if authViewModel.isLoggedIn {
                if isCheckingRole {
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
            } else if hasCompletedOnboarding {
                LoginView(authViewModel: authViewModel)
            } else {
                OnboardingView {
                    hasCompletedOnboarding = true
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
        roleCheckError = nil

        do {
            isAdmin = try await AdminAccessService.shared
                .isCurrentUserAdmin()
        } catch {
            isAdmin = false
            roleCheckError =
                "We could not verify your role in Firebase. Check your connection and Firestore permissions, then try again."
        }

        isCheckingRole = false
    }
}

#Preview {
    AppRootView()
}
