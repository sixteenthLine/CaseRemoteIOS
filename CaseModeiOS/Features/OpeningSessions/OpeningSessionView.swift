import SwiftUI

struct OpeningSessionView: View {
    let device: Device
    let selectedCase: InventoryCase

    @Environment(SessionStore.self) private var sessionStore
    @State private var viewModel = OpeningSessionViewModel()

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(selectedCase.name)
                .font(.title2)
                .fontWeight(.semibold)

            Text("Device: \(device.name)")
            Text("Quantity: \(selectedCase.quantity)")

            if let session = viewModel.session {
                Text("Status: \(humanReadableStatus(session.status))")
                    .font(.headline)

                if let errorMessage = session.errorMessage, !errorMessage.isEmpty {
                    Text("Error: \(errorMessage)")
                        .foregroundStyle(.red)
                }

                if let resultPayload = session.resultPayload, !resultPayload.isEmpty {
                    Text("Result payload:")
                        .font(.subheadline)
                        .fontWeight(.medium)

                    Text(resultPayload)
                        .font(.footnote)
                        .textSelection(.enabled)
                }
            } else {
                Text("Session not started yet")
                    .foregroundStyle(.secondary)
            }

            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundStyle(.red)
            }

            Button {
                Task {
                    guard let token = sessionStore.token else { return }
                    await viewModel.createSession(
                        deviceId: device.id,
                        selectedInventoryItemId: selectedCase.inventoryItemId,
                        token: token
                    )
                }
            } label: {
                Text(viewModel.isLoading ? "Starting..." : "Open case")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .disabled(viewModel.isLoading || viewModel.session != nil)

            Spacer()
        }
        .padding()
        .navigationTitle("Opening Session")
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
