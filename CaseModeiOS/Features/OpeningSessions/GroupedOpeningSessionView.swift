import SwiftUI

struct GroupedOpeningSessionView: View {
    let device: Device
    let groupedCase: GroupedInventoryCase

    @Environment(SessionStore.self) private var sessionStore
    @State private var viewModel = OpeningSessionViewModel()

    var body: some View {
        ZStack {
            AppTheme.background
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 16) {
                InventoryCardView(
                    title: groupedCase.displayName,
                    subtitle: groupedCase.marketHashName,
                    quantity: groupedCase.quantity,
                    category: .cases
                )

                if let session = viewModel.session {
                    Text("Status: \(humanReadableStatus(session.status))")
                        .font(.headline)
                        .foregroundStyle(AppTheme.textPrimary)

                    if let errorMessage = session.errorMessage, !errorMessage.isEmpty {
                        Text("Error: \(errorMessage)")
                            .foregroundStyle(AppTheme.danger)
                    }

                    if let resultPayload = session.resultPayload, !resultPayload.isEmpty {
                        Text(resultPayload)
                            .font(.footnote)
                            .foregroundStyle(AppTheme.textSecondary)
                            .textSelection(.enabled)
                    }
                } else {
                    Text("This will use one real inventory item from the selected case group.")
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
                            selectedInventoryItemId: groupedCase.representativeInventoryItemId,
                            token: token
                        )
                    }
                } label: {
                    Text(viewModel.isLoading ? "Starting..." : "Open case")
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
        .navigationTitle(groupedCase.displayName)
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear {
            viewModel.stopPolling()
        }
    }

    private func humanReadableStatus(_ status: String) -> String {
        switch status {
        case "created":
            return "Session created"
        case "launching_environment":
            return "Launching Steam and CS2"
        case "waiting_for_game_ready":
            return "Preparing game"
        case "ready":
            return "Environment ready"
        case "opening_in_progress":
            return "Opening case"
        case "awaiting_inventory_result":
            return "Waiting for inventory result"
        case "completed":
            return "Completed"
        case "failed":
            return "Failed"
        default:
            return status
        }
    }
}
