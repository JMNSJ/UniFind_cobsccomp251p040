
import SwiftUI

struct LoginView: View {
    @ObservedObject var authViewModel: AuthenticationViewModel
    @FocusState private var emailFocused: Bool
    @FocusState private var passwordFocused: Bool
    @State private var showPassword = false

    var body: some View {
        NavigationStack {
            ZStack {
                UniFindBackground()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 28) {
                        VStack(spacing: 14) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 24)
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
                                    .frame(width: 82, height: 82)

                                Image(systemName: "magnifyingglass")
                                    .font(.system(size: 36, weight: .bold))
                                    .foregroundStyle(.white)
                            }
                            .shadow(
                                color: UniFindStyle.indigo.opacity(0.2),
                                radius: 16,
                                y: 8
                            )

                            Text("Welcome to UniFind")
                                .font(.system(size: 30, weight: .bold, design: .rounded))
                                .foregroundStyle(UniFindStyle.ink)
                                .multilineTextAlignment(.center)

                            Text("Sign in to reconnect people with their belongings.")
                                .font(.subheadline)
                                .foregroundStyle(UniFindStyle.muted)
                                .multilineTextAlignment(.center)
                                .lineSpacing(4)
                        }
                        .padding(.top, 36)

                        VStack(alignment: .leading, spacing: 20) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Email address")
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(UniFindStyle.ink)

                                HStack(spacing: 12) {
                                    Image(systemName: "envelope")
                                        .foregroundStyle(UniFindStyle.indigo)

                                    TextField("you@example.com", text: $authViewModel.email)
                                        .keyboardType(.emailAddress)
                                        .textInputAutocapitalization(.never)
                                        .autocorrectionDisabled()
                                        .textContentType(.emailAddress)
                                        .keyboardType(.emailAddress)
                                        .focused($emailFocused)
                                }
                                .padding(16)
                                .background(Color.white.opacity(0.78))
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                .overlay {
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.black.opacity(0.05), lineWidth: 1)
                                }
                            }

                            VStack(alignment: .leading, spacing: 8) {
                                Text("Password")
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(UniFindStyle.ink)

                                HStack(spacing: 12) {
                                    Image(systemName: "lock")
                                        .foregroundStyle(UniFindStyle.indigo)

                                    Group {
                                        if showPassword {
                                            TextField("Enter your password", text: $authViewModel.password)
                                        } else {
                                            SecureField("Enter your password", text: $authViewModel.password)
                                        }
                                    }
                                    .textContentType(.password)
                                    .focused($passwordFocused)

                                    Button {
                                        showPassword.toggle()
                                    } label: {
                                        Image(systemName: showPassword ? "eye.slash" : "eye")
                                            .foregroundStyle(UniFindStyle.muted)
                                    }
                                    .buttonStyle(.plain)
                                    .accessibilityLabel(showPassword ? "Hide password" : "Show password")
                                }
                                .padding(16)
                                .background(Color.white.opacity(0.78))
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                .overlay {
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.black.opacity(0.05), lineWidth: 1)
                                }
                            }

                            if let error = authViewModel.errorMessage {
                                Label(error, systemImage: "exclamationmark.circle.fill")
                                    .font(.footnote)
                                    .foregroundStyle(.red)
                                    .fixedSize(horizontal: false, vertical: true)
                            }

                            Button {
                                emailFocused = false
                                passwordFocused = false
                                authViewModel.login()
                            } label: {
                                HStack(spacing: 10) {
                                    if authViewModel.isLoading {
                                        ProgressView()
                                            .tint(.white)
                                    } else {
                                        Text("Sign In")
                                        Image(systemName: "arrow.right")
                                    }
                                }
                                .font(.system(size: 16, weight: .bold))
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(
                                    LinearGradient(
                                        colors: [
                                            UniFindStyle.indigo,
                                            Color(red: 0.38, green: 0.43, blue: 0.91)
                                        ],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 17))
                                .shadow(
                                    color: UniFindStyle.indigo.opacity(0.23),
                                    radius: 12,
                                    y: 6
                                )
                            }
                            .buttonStyle(.plain)
                            .disabled(authViewModel.isLoading)
                            .opacity(authViewModel.isLoading ? 0.75 : 1)
                        }
                        .padding(22)
                        .uniGlassCard(cornerRadius: 26)

                        HStack(spacing: 6) {
                            Image(systemName: "building.2")
                            Text("Your campus community, connected.")
                        }
                        .font(.caption)
                        .foregroundStyle(UniFindStyle.muted)
                        .padding(.bottom, 24)
                    }
                    .padding(.horizontal, 22)
                    .frame(maxWidth: 520)
                    .frame(maxWidth: .infinity)
                }
            }
            .toolbar(.hidden, for: .navigationBar)
        }
        .preferredColorScheme(.light)
    }
}
