import SwiftUI

struct LoginView: View {
    @Environment(SessionStore.self) private var sessionStore

    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage = ""
    @State private var isLoading = false

    var body: some View {
        VStack(spacing: 16) {
            TextField("Email", text: $email)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .textFieldStyle(.roundedBorder)

            SecureField("Password", text: $password)
                .textFieldStyle(.roundedBorder)

            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundStyle(.red)
            }

            Button(isLoading ? "Loading..." : "Login") {
                Task {
                    await login()
                }
            }
            .disabled(isLoading)
        }
        .padding()
        .navigationTitle("Login")
    }

    private func login() async {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Fill in all fields"
            return
        }

        isLoading = true
        errorMessage = ""

        do {
            let response = try await ApiClient.shared.login(email: email, password: password)
            sessionStore.saveToken(response.accessToken)
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}
