import AVKit
import SwiftUI

struct GroupedOpeningSessionView: View {
    let device: Device
    let groupedItem: GroupedInventoryCase
    let category: InventoryImageCategory

    @Environment(SessionStore.self) private var sessionStore
    @State private var viewModel = OpeningSessionViewModel()

    var body: some View {
        ZStack {
            AppTheme.background
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 16) {
                InventoryCardView(
                    title: groupedItem.displayName,
                    subtitle: groupedItem.marketHashName,
                    quantity: groupedItem.quantity,
                    category: category
                )

                if let session = viewModel.session {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 10) {
                            if viewModel.isPolling && !OpeningSessionViewModel.isTerminalStatus(session.status) {
                                ProgressView()
                                    .tint(AppTheme.accent)
                            }

                            Text(humanReadableStatus(session.status))
                                .font(.headline)
                                .foregroundStyle(statusColor(session.status))
                        }

                        Text("Session ID: \(session.id)")
                            .font(.footnote)
                            .foregroundStyle(AppTheme.textSecondary)

                        if let commandId = session.commandId {
                            Text("Command ID: \(commandId)")
                                .font(.footnote)
                                .foregroundStyle(AppTheme.textSecondary)
                        }

                        Text("Video: \(humanReadableVideoStatus(session.videoStatus))")
                            .font(.footnote)
                            .foregroundStyle(AppTheme.textSecondary)
                    }
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(AppTheme.card)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(AppTheme.cardBorder, lineWidth: 1)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16))

                    if let errorMessage = session.errorMessage, !errorMessage.isEmpty {
                        Text("Error: \(errorMessage)")
                            .foregroundStyle(AppTheme.danger)
                    }

                    resultSection(for: session)
                } else {
                    Text("This will use one real inventory item from the selected \(itemName) group.")
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.textSecondary)
                }

                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundStyle(AppTheme.danger)
                }

                Button {
                    Task {
                        guard let token = sessionStore.token else { return }
                        await viewModel.createSession(
                            deviceId: device.id,
                            selectedInventoryItemId: groupedItem.representativeInventoryItemId,
                            token: token
                        )
                    }
                } label: {
                    Text(viewModel.isLoading ? "Starting..." : "Open \(itemName)")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                }
                .buttonStyle(.borderedProminent)
                .tint(AppTheme.accent)
                .disabled(viewModel.isLoading || viewModel.session != nil)

                Spacer()
            }
            .padding()
        }
        .navigationTitle(groupedItem.displayName)
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear {
            viewModel.stopPolling()
        }
    }

    @ViewBuilder
    private func resultSection(for session: OpeningSession) -> some View {
        if let historyItem = viewModel.historyItem {
            VStack(alignment: .leading, spacing: 10) {
                Text("Result")
                    .font(.headline)
                    .foregroundStyle(AppTheme.textPrimary)

                HStack(alignment: .top, spacing: 12) {
                    if let imageURL = ApiClient.absoluteURL(from: historyItem.resultIconURL) {
                        AsyncImage(url: imageURL) { image in
                            image
                                .resizable()
                                .scaledToFit()
                        } placeholder: {
                            ProgressView()
                                .tint(AppTheme.accent)
                        }
                        .frame(width: 64, height: 64)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text(historyItem.resultName ?? historyItem.resultMarketHashName ?? "Detected item")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(AppTheme.textPrimary)

                        if let resultRarity = historyItem.resultRarity {
                            Text(resultRarity)
                                .font(.footnote)
                                .foregroundStyle(AppTheme.textSecondary)
                        }

                        if let resultExterior = historyItem.resultExterior {
                            Text(resultExterior)
                                .font(.footnote)
                                .foregroundStyle(AppTheme.textSecondary)
                        }

                        if let resultFloat = historyItem.resultFloat {
                            Text("Float: \(resultFloat)")
                                .font(.footnote)
                                .foregroundStyle(AppTheme.textSecondary)
                        }
                    }
                }

                if let recordingURL = ApiClient.absoluteURL(from: historyItem.recordingURL) {
                    VideoPlayer(player: AVPlayer(url: recordingURL))
                        .frame(height: 220)
                        .clipShape(RoundedRectangle(cornerRadius: 12))

                    Link("Open recording", destination: recordingURL)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(AppTheme.accent)
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(AppTheme.card)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(AppTheme.cardBorder, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
        } else if let resultPayload = session.resultPayload, !resultPayload.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                Text("Result payload")
                    .font(.headline)
                    .foregroundStyle(AppTheme.textPrimary)

                Text(resultPayload)
                    .font(.footnote)
                    .foregroundStyle(AppTheme.textSecondary)
                    .textSelection(.enabled)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(AppTheme.card)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(AppTheme.cardBorder, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }

    private var itemName: String {
        switch category {
        case .cases:
            return "case"
        case .terminals:
            return "terminal"
        }
    }

    private func humanReadableStatus(_ status: String) -> String {
        switch status {
        case "created":
            return "Session created"
        case "launching_environment":
            return "Launching Steam and CS2"
        case "syncing_inventory_before_opening":
            return "Syncing inventory before opening"
        case "waiting_for_game_ready":
            return "Preparing game"
        case "ready":
            return "Environment ready"
        case "opening_in_progress":
            return "Opening \(itemName)"
        case "recording_opening":
            return "Recording opening"
        case "syncing_inventory_after_opening":
            return "Syncing inventory after opening"
        case "awaiting_inventory_result":
            return "Waiting for inventory result"
        case "completed":
            return "Completed"
        case "result_detection_failed":
            return "Opened, result was not detected"
        case "failed":
            return "Failed"
        default:
            return status
        }
    }

    private func humanReadableVideoStatus(_ status: String) -> String {
        switch status {
        case "not_started":
            return "Not started"
        case "starting":
            return "Starting"
        case "saved_locally":
            return "Saved locally"
        case "streamed_and_saved_locally":
            return "Streamed and saved locally"
        case "uploaded":
            return "Uploaded"
        case "saved_locally_upload_failed":
            return "Saved locally, upload failed"
        case "recording_unavailable":
            return "Recording unavailable"
        default:
            return status
        }
    }

    private func statusColor(_ status: String) -> Color {
        switch status {
        case "completed":
            return AppTheme.accent
        case "result_detection_failed":
            return AppTheme.warning
        case "failed":
            return AppTheme.danger
        default:
            return AppTheme.textPrimary
        }
    }
}
