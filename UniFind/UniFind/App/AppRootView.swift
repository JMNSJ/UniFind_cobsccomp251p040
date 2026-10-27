
import SwiftUI

struct AppRootView: View {
    @StateObject private var authViewModel = AuthenticationViewModel()

    @AppStorage("unifindHasCompletedOnboarding")
    private var hasCompletedOnboarding = false

    @State private var showSplash = true
    @State private var isCheckingRole = false
    @State private var hasCheckedRole = false
    @State private var isAdmin = false
    @State private var roleCheckError: String?

    var body: some View {
        Group {
            if showSplash {
                SplashScreenView()
            } else if !hasCompletedOnboarding {
                OnboardingView {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        hasCompletedOnboarding = true
                    }
                }
            } else if !authViewModel.isLoggedIn {
                LoginView(authViewModel: authViewModel)
            } else if isCheckingRole || !hasCheckedRole {
                VStack(spacing: 16) {
                    ProgressView()
                        .tint(UniFindStyle.indigo)
                    Text("Checking your account...")
                        .foregroundStyle(UniFindStyle.muted)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(UniFindStyle.background)
            } else if let roleCheckError {
                VStack(spacing: 18) {
                    Image(systemName: "exclamationmark.shield.fill")
                        .font(.system(size: 48))
                        .foregroundStyle(.orange)

                    Text("Unable to verify your account")
                        .font(.title2.bold())
                        .foregroundStyle(UniFindStyle.ink)

                    Text(roleCheckError)
                        .font(.subheadline)
                        .foregroundStyle(UniFindStyle.muted)
                        .multilineTextAlignment(.center)

                    Button("Try Again") {
                        Task { await checkUserRole() }
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(UniFindStyle.indigo)

                    Button("Sign Out", role: .destructive) {
                        authViewModel.logout()
                    }
                }
                .padding(28)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(UniFindStyle.background)
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
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(UniFindStyle.background)
        .preferredColorScheme(.light)
        .task {
            try? await Task.sleep(nanoseconds: 1_500_000_000)
            guard !Task.isCancelled else { return }

            withAnimation(.easeInOut(duration: 0.3)) {
                showSplash = false
            }
        }
        .task(
            id: "\(authViewModel.userID ?? "signed-out")-\(hasCompletedOnboarding)-\(showSplash)"
        ) {
            await checkUserRole()
        }
    }

    @MainActor
    private func checkUserRole() async {
        guard !showSplash, hasCompletedOnboarding else {
            isCheckingRole = false
            hasCheckedRole = false
            isAdmin = false
            roleCheckError = nil
            return
        }

        guard authViewModel.isLoggedIn,
              authViewModel.userID != nil else {
            isCheckingRole = false
            hasCheckedRole = false
            isAdmin = false
            roleCheckError = nil
            return
        }

        isCheckingRole = true
        hasCheckedRole = false
        roleCheckError = nil

        do {
            isAdmin = try await AdminAccessService.shared
                .isCurrentUserAdmin()
            hasCheckedRole = true
        } catch {
            roleCheckError =
                "We couldn't verify your account role. Check your connection and Firestore rules, then try again."
            hasCheckedRole = true
        }

        isCheckingRole = false
    }
}

private struct SplashScreenView: View {
    @State private var animateLogo = false

    var body: some View {
        ZStack {
            UniFindBackground()

            VStack(spacing: 22) {
                ZStack {
                    RoundedRectangle(cornerRadius: 28)
                        .fill(
                            LinearGradient(
                                colors: [
                                    UniFindStyle.indigo,
                                    UniFindStyle.teal
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 96, height: 96)
                        .shadow(
                            color: UniFindStyle.indigo.opacity(0.25),
                            radius: 20,
                            y: 10
                        )

                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 43, weight: .bold))
                        .foregroundStyle(.white)
                }
                .scaleEffect(animateLogo ? 1 : 0.88)
                .opacity(animateLogo ? 1 : 0.65)

                VStack(spacing: 7) {
                    Text("UniFind")
                        .font(.system(size: 38, weight: .bold, design: .rounded))
                        .tracking(-1.2)
                        .foregroundStyle(UniFindStyle.ink)

                    Text("FIND WHAT MATTERS")
                        .font(.system(size: 11, weight: .bold))
                        .tracking(3)
                        .foregroundStyle(UniFindStyle.indigo)
                }

                ProgressView()
                    .tint(UniFindStyle.teal)
                    .padding(.top, 10)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true)) {
                animateLogo = true
            }
        }
    }
}

#Preview {
    AppRootView()
}
