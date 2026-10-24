
import SwiftUI
import Combine

struct AppRootView: View {

    @StateObject private var authViewModel =
        AuthenticationViewModel()

    @State private var hasCompletedOnboarding = false

    var body: some View {
        Group {
            if authViewModel.isLoggedIn {

                // Existing signed-in user area.
                UserTabView(
                    onLogout: {
                        authViewModel.logout()
                    }
                )

            } else if hasCompletedOnboarding {

                // Show login after onboarding.
                LoginView(
                    authViewModel: authViewModel
                )

            } else {

                // Show onboarding when the app first opens.
                OnboardingView(
                    onGetStarted: {
                        hasCompletedOnboarding = true
                    }
                )
            }
        }
    }
}

#Preview {
    AppRootView()
}
