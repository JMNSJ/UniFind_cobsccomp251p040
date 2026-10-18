
import SwiftUI

struct LoginView: View {
    let onLogin: () -> Void
    let onRegister: () -> Void

    @State private var email = ""
    @State private var password = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Image(systemName: "person.crop.circle.fill")
                    .font(.system(size: 65))
                    .foregroundStyle(.blue)

                Text("Welcome Back")
                    .font(.largeTitle.bold())

                Text("Sign in to your UniFind account")
                    .foregroundStyle(.secondary)

                VStack(spacing: 14) {
                    TextField("University email", text: $email)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .padding()
                        .background(.gray.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 12))

                    SecureField("Password", text: $password)
                        .padding()
                        .background(.gray.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }

                Button(action: onLogin) {
                    Text("Log In")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .foregroundStyle(.white)
                        .background(.blue)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }

                Button(action: onRegister) {
                    Text("Don't have an account? Register")
                        .font(.subheadline)
                }

                Spacer()
            }
            .padding(24)
        }
    }
}

#Preview {
    LoginView(onLogin: {}, onRegister: {})
}
