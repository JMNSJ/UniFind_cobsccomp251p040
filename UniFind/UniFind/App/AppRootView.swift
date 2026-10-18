
import SwiftUI

struct AppRootView: View {
    @AppStorage("hasCompletedOnboarding")
    private var hasCompletedOnboarding = false

    @State private var isLoggedIn = false
    @State private var showingRegistration = false

    var body: some View {
        Group {
            if !hasCompletedOnboarding {
                OnboardingView {
                    hasCompletedOnboarding = true
                }
            } else if isLoggedIn {
                UserTabView(
                    onLogout: {
                        isLoggedIn = false
                    }
                )
            } else if showingRegistration {
                RegisterView(
                    onRegistered: {
                        showingRegistration = false
                        isLoggedIn = true
                    },
                    onBackToLogin: {
                        showingRegistration = false
                    }
                )
            } else {
                LoginView(
                    onLogin: {
                        isLoggedIn = true
                    },
                    onRegister: {
                        showingRegistration = true
                    }
                )
            }
        }
    }
}

#Preview {
    AppRootView()
}
