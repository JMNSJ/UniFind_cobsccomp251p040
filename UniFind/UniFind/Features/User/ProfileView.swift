
import SwiftUI

struct ProfileView: View {
    let onLogout: () -> Void

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack(spacing: 16) {
                        Image(systemName: "person.crop.circle.fill")
                            .font(.system(size: 58))
                            .foregroundStyle(.blue)

                        VStack(alignment: .leading, spacing: 6) {
                            Text("Student User")
                                .font(.headline)

                            Text("student@university.edu")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 8)
                }

                Section("Account") {
                    Label("Personal Information", systemImage: "person")
                    Label("Notifications", systemImage: "bell")
                    Label("Lost and Found Stations", systemImage: "mappin.and.ellipse")
                }

                Section {
                    Button(role: .destructive, action: onLogout) {
                        Label("Log Out", systemImage: "rectangle.portrait.and.arrow.right")
                    }
                }
            }
            .navigationTitle("My Profile")
        }
    }
}

#Preview {
    ProfileView(onLogout: {})
}
