import SwiftUI

struct RegisterView: View {
    @Environment(SessionStore.self) private var sessionStore

    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
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

            SecureField("Confirm password", text: $confirmPassword)
                .textFieldStyle(.roundedBorder)

            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundStyle(.red)
            }

            Button(isLoading ? "Loading..." : "Register") {
                Task {
                    await register()
                }
            }
            .disabled(isLoading)
        }
        .padding()
        .navigationTitle("Register")
    }

    private func register() async {
        guard !email.isEmpty, !password.isEmpty, !confirmPassword.isEmpty else {
            errorMessage = "Fill in all fields"
            return
        }

        guard password == confirmPassword else {
            errorMessage = "Passwords do not match"
            return
        }

        isLoading = true
        errorMessage = ""

        do {
            let response = try await ApiClient.shared.register(email: email, password: password)
            sessionStore.saveToken(response.accessToken)
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}
