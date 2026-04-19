import SwiftUI

struct RootView: View {
    @Environment(SessionStore.self) private var sessionStore

    var body: some View {
        Group {
            if sessionStore.isLoading {
                ProgressView("Loading...")
            } else if sessionStore.isAuthenticated {
                DevicesView()
            } else {
                AuthView()
            }
        }
    }
}
