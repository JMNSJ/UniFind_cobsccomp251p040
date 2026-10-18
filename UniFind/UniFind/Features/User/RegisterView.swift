
import SwiftUI

struct RegisterView: View {
    let onRegistered: () -> Void
    let onBackToLogin: () -> Void

    @State private var fullName = ""
    @State private var email = ""
    @State private var password = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Personal Information") {
                    TextField("Full name", text: $fullName)

                    TextField("University email", text: $email)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                }

                Section("Account Security") {
                    SecureField("Password", text: $password)
                }

                Section {
                    Button("Create Account", action: onRegistered)
                        .frame(maxWidth: .infinity)
                }

                Section {
                    Button("Back to Login", action: onBackToLogin)
                        .frame(maxWidth: .infinity)
                }
            }
            .navigationTitle("Create Account")
        }
    }
}

#Preview {
    RegisterView(
        onRegistered: {},
        onBackToLogin: {}
    )
}
