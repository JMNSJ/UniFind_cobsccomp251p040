
import SwiftUI

struct LoginView: View {

    @ObservedObject var authViewModel: AuthenticationViewModel

    var body: some View {
        NavigationStack {
            VStack(spacing: 22) {

                Image(systemName: "magnifyingglass.circle.fill")
                    .font(.system(size: 70))
                    .foregroundStyle(.blue)

                Text("Welcome to UniFind")
                    .font(.largeTitle.bold())

                Text("Sign in to find or report lost items.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)

                VStack(spacing: 16) {

                    TextField("Email address", text: $authViewModel.email)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .textContentType(.emailAddress)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 12))

                    SecureField("Password", text: $authViewModel.password)
                        .textContentType(.password)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }

                if let error = authViewModel.errorMessage {
                    Text(error)
                        .font(.footnote)
                        .foregroundStyle(.red)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                Button {
                    authViewModel.login()
                } label: {
                    HStack {
                        if authViewModel.isLoading {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text("Log In")
                                .fontWeight(.semibold)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .foregroundStyle(.white)
                    .background(Color.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .disabled(authViewModel.isLoading)

                Spacer()
            }
            .padding(24)
        }
    }
}
