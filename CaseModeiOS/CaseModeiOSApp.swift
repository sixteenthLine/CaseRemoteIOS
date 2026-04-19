import SwiftUI

@main
struct CaseModeiOSApp: App {
    @State private var sessionStore = SessionStore()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(sessionStore)
        }
    }
}
