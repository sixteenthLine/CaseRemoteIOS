import SwiftUI

struct OpeningHistoryView: View {
    @Environment(SessionStore.self) private var sessionStore
    @State private var sessions: [OpeningSession] = []
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        Group {
            if isLoading {
                ProgressView("Loading history...")
            } else if let errorMessage {
                VStack(spacing: 12) {
                    Text("Error")
                        .font(.headline)
                    Text(errorMessage)
                        .multilineTextAlignment(.center)
                }
                .padding()
            } else if sessions.isEmpty {
                VStack(spacing: 12) {
                    Text("No opening history yet")
                        .font(.headline)
                    Text("Your opening sessions will appear here")
                        .foregroundStyle(.secondary)
                }
                .padding()
            } else {
                List(sessions) { session in
                    VStack(alignment: .leading, spacing: 6) {
                        Text(session.selectedCaseName)
                            .font(.headline)
                        Text("Status: \(session.status)")
                        if let resultItemId = session.resultItemId {
                            Text("Result item id: \(resultItemId)")
                        }
                        Text("Video: \(session.videoStatus)")
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .navigationTitle("Opening History")
        .task {
            await loadHistory()
        }
    }

    private func loadHistory() async {
        guard let token = sessionStore.token else { return }

        isLoading = true
        errorMessage = nil

        do {
            let response = try await ApiClient.shared.getOpeningSessions(token: token)
            sessions = response.sessions
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}
