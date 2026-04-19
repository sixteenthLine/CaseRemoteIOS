import SwiftUI

struct AuthView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text("Case Remote")
                    .font(.largeTitle)

                NavigationLink("Login") {
                    LoginView()
                }

                NavigationLink("Register") {
                    RegisterView()
                }
            }
            .padding()
        }
    }
}
