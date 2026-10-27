
import SwiftUI
import FirebaseAuth

struct ProfileView: View {
    let onLogout: () -> Void

    @AppStorage("unifindNotificationsEnabled")
    private var notificationsEnabled = true

    @State private var showPersonalInfo = false
    @State private var showStations = false
    @State private var showHelp = false
    @State private var showLogoutConfirmation = false

    private var currentEmail: String {
        Auth.auth().currentUser?.email ?? "Email unavailable"
    }

    private var displayName: String {
        Auth.auth().currentUser?.displayName ?? "Student User"
    }

    var body: some View {
        NavigationStack {
            ZStack {
                UniFindBackground()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 22) {
                        VStack(spacing: 13) {
                            ZStack {
                                Circle()
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
                                    .frame(width: 88, height: 88)

                                Image(systemName: "person.fill")
                                    .font(.system(size: 37))
                                    .foregroundStyle(.white)
                            }
                            .shadow(
                                color: UniFindStyle.indigo.opacity(0.2),
                                radius: 15,
                                y: 7
                            )

                            Text(displayName)
                                .font(.system(size: 23, weight: .bold, design: .rounded))
                                .foregroundStyle(UniFindStyle.ink)

                            Text(currentEmail)
                                .font(.subheadline)
                                .foregroundStyle(UniFindStyle.muted)
                                .multilineTextAlignment(.center)
                                .textSelection(.enabled)

                            Text("UNIFIND ACCOUNT")
                                .font(.system(size: 10, weight: .bold))
                                .tracking(1.5)
                                .foregroundStyle(UniFindStyle.indigo)
                                .padding(.horizontal, 13)
                                .padding(.vertical, 7)
                                .background(UniFindStyle.paleIndigo)
                                .clipShape(Capsule())
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 28)
                        .padding(.horizontal, 18)
                        .uniGlassCard(cornerRadius: 28)

                        settingsSection(title: "ACCOUNT") {
                            settingsRow(
                                icon: "person.crop.circle",
                                title: "Personal Information",
                                subtitle: "View your account details",
                                color: UniFindStyle.indigo
                            ) {
                                showPersonalInfo = true
                            }

                            Divider().padding(.leading, 48)

                            settingsRow(
                                icon: "mappin.and.ellipse",
                                title: "Lost & Found Stations",
                                subtitle: "University station information",
                                color: UniFindStyle.teal
                            ) {
                                showStations = true
                            }
                        }

                        settingsSection(title: "PREFERENCES") {
                            HStack(spacing: 12) {
                                iconTile("bell.badge", color: UniFindStyle.indigo)

                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Notifications")
                                        .font(.subheadline.weight(.semibold))
                                        .foregroundStyle(UniFindStyle.ink)

                                    Text("Save your notification preference")
                                        .font(.caption)
                                        .foregroundStyle(UniFindStyle.muted)
                                }

                                Spacer()

                                Toggle(
                                    "Notifications",
                                    isOn: $notificationsEnabled
                                )
                                .labelsHidden()
                                .tint(UniFindStyle.teal)
                            }
                            .padding(.vertical, 13)
                        }

                        settingsSection(title: "SUPPORT") {
                            settingsRow(
                                icon: "questionmark.circle",
                                title: "Help & Support",
                                subtitle: "Get help using UniFind",
                                color: UniFindStyle.teal
                            ) {
                                showHelp = true
                            }
                        }

                        Button {
                            showLogoutConfirmation = true
                        } label: {
                            Label("Sign Out", systemImage: "rectangle.portrait.and.arrow.right")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(.red)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 17)
                                .background(Color.white.opacity(0.8))
                                .clipShape(RoundedRectangle(cornerRadius: 18))
                                .overlay {
                                    RoundedRectangle(cornerRadius: 18)
                                        .stroke(Color.red.opacity(0.10), lineWidth: 1)
                                }
                        }
                        .buttonStyle(.plain)

                        Text("UniFind · Find what matters")
                            .font(.caption)
                            .foregroundStyle(UniFindStyle.muted)
                            .padding(.bottom, 16)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 14)
                }
            }
            .navigationTitle("My Profile")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
            .sheet(isPresented: $showPersonalInfo) {
                personalInformationSheet
            }
            .sheet(isPresented: $showStations) {
                informationSheet(
                    title: "Lost & Found Stations",
                    icon: "mappin.and.ellipse",
                    message: "Visit your university's designated Lost & Found location or contact university administration to confirm station details."
                )
            }
            .sheet(isPresented: $showHelp) {
                informationSheet(
                    title: "Help & Support",
                    icon: "questionmark.circle",
                    message: "For help with reports, found items, or account access, contact your university's support team."
                )
            }
            .confirmationDialog(
                "Are you sure you want to sign out?",
                isPresented: $showLogoutConfirmation,
                titleVisibility: .visible
            ) {
                Button("Sign Out", role: .destructive) {
                    onLogout()
                }

                Button("Cancel", role: .cancel) {}
            }
        }
        .preferredColorScheme(.light)
    }

    private func settingsSection<Content: View>(
        title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.caption.weight(.bold))
                .tracking(1.5)
                .foregroundStyle(UniFindStyle.muted)
                .padding(.leading, 4)

            VStack(spacing: 0) {
                content()
            }
            .padding(.horizontal, 15)
            .padding(.vertical, 6)
            .uniGlassCard(cornerRadius: 22)
        }
    }

    private func settingsRow(
        icon: String,
        title: String,
        subtitle: String,
        color: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                iconTile(icon, color: color)

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(UniFindStyle.ink)

                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(UniFindStyle.muted)
                }

                Spacer(minLength: 8)

                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(UniFindStyle.muted.opacity(0.7))
            }
            .padding(.vertical, 12)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private func iconTile(_ icon: String, color: Color) -> some View {
        Image(systemName: icon)
            .font(.system(size: 18, weight: .semibold))
            .foregroundStyle(color)
            .frame(width: 39, height: 39)
            .background(color.opacity(0.10))
            .clipShape(RoundedRectangle(cornerRadius: 13))
    }

    private var personalInformationSheet: some View {
        NavigationStack {
            ZStack {
                UniFindBackground()

                VStack(spacing: 18) {
                    Image(systemName: "person.crop.circle.fill")
                        .font(.system(size: 54))
                        .foregroundStyle(UniFindStyle.indigo)

                    VStack(spacing: 6) {
                        Text(displayName)
                            .font(.title3.bold())
                            .foregroundStyle(UniFindStyle.ink)

                        Text("Account details")
                            .font(.subheadline)
                            .foregroundStyle(UniFindStyle.muted)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("EMAIL ADDRESS")
                            .font(.caption.bold())
                            .tracking(1)
                            .foregroundStyle(UniFindStyle.muted)

                        Label(currentEmail, systemImage: "envelope")
                            .font(.subheadline)
                            .foregroundStyle(UniFindStyle.ink)
                            .textSelection(.enabled)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(18)
                    .uniGlassCard()

                    Text("Your email is retrieved from the Firebase account currently signed in to UniFind.")
                        .font(.footnote)
                        .foregroundStyle(UniFindStyle.muted)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Spacer()
                }
                .padding(22)
                .padding(.top, 20)
            }
            .navigationTitle("Personal Information")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        showPersonalInfo = false
                    }
                    .tint(UniFindStyle.indigo)
                }
            }
        }
        .preferredColorScheme(.light)
    }

    private func informationSheet(
        title: String,
        icon: String,
        message: String
    ) -> some View {
        NavigationStack {
            ZStack {
                UniFindBackground()

                VStack(spacing: 20) {
                    Image(systemName: icon)
                        .font(.system(size: 50))
                        .foregroundStyle(UniFindStyle.indigo)
                        .padding(.top, 36)

                    Text(message)
                        .font(.body)
                        .foregroundStyle(UniFindStyle.muted)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .padding(22)
                        .uniGlassCard()

                    Spacer()
                }
                .padding(22)
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        if title == "Help & Support" {
                            showHelp = false
                        } else {
                            showStations = false
                        }
                    }
                    .tint(UniFindStyle.indigo)
                }
            }
        }
        .preferredColorScheme(.light)
    }
}

#Preview {
    ProfileView(onLogout: {})
}
