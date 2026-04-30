import AVKit
import SwiftUI

struct OpeningHistoryView: View {
    @Environment(SessionStore.self) private var sessionStore
    @State private var openings: [OpeningHistoryItem] = []
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
            } else if openings.isEmpty {
                VStack(spacing: 12) {
                    Text("No opening history yet")
                        .font(.headline)
                    Text("Your opening sessions will appear here")
                        .foregroundStyle(.secondary)
                }
                .padding()
            } else {
                List(openings) { opening in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(opening.resultName ?? opening.resultMarketHashName ?? opening.selectedCaseName ?? "Opening")
                            .font(.headline)

                        Text("Case: \(opening.selectedCaseName ?? opening.selectedMarketHashName ?? "Unknown")")
                            .foregroundStyle(.secondary)

                        Text("Status: \(opening.status)")

                        if let commandId = opening.commandId {
                            Text("Command ID: \(commandId)")
                        }

                        if let resultRarity = opening.resultRarity {
                            Text(resultRarity)
                        }

                        if let resultExterior = opening.resultExterior {
                            Text(resultExterior)
                        }

                        if let resultFloat = opening.resultFloat {
                            Text("Float: \(resultFloat)")
                        }

                        Text("Video: \(opening.videoStatus ?? "unknown")")
                            .foregroundStyle(.secondary)

                        if let recordingURL = ApiClient.absoluteURL(from: opening.recordingURL) {
                            VideoPlayer(player: AVPlayer(url: recordingURL))
                                .frame(height: 180)

                            Link("Open recording", destination: recordingURL)
                        }

                        if let openedAt = opening.openedAt {
                            Text(openedAt)
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 6)
                }
                .refreshable {
                    await loadHistory()
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
            let response = try await ApiClient.shared.getOpeningHistory(token: token)
            openings = response.openings
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}
