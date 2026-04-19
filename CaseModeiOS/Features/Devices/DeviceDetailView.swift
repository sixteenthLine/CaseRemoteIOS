import SwiftUI

struct DeviceDetailView: View {
    let device: Device

    @Environment(SessionStore.self) private var sessionStore
    @State private var commandViewModel = CommandViewModel()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(device.name)
                    .font(.title2)
                    .fontWeight(.semibold)

                HStack(spacing: 8) {
                    Circle()
                        .fill(device.status == "online" ? .green : .gray)
                        .frame(width: 10, height: 10)

                    Text(device.status.capitalized)
                        .foregroundStyle(device.status == "online" ? .green : .secondary)
                }

                Text("Platform: \(device.platform)")
                Text("Agent version: \(device.agentVersion)")
                Text(lastSeenText)
                    .foregroundStyle(.secondary)

                Divider()

                Text("Actions")
                    .font(.headline)

                Button {
                    Task {
                        guard let token = sessionStore.token else { return }
                        await commandViewModel.sendCommand(
                            deviceId: device.id,
                            type: "launch_steam",
                            token: token
                        )
                    }
                } label: {
                    Text(commandViewModel.isSending ? "Sending..." : "Launch Steam")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .disabled(commandViewModel.isSending)

                Button {
                    Task {
                        guard let token = sessionStore.token else { return }
                        await commandViewModel.sendCommand(
                            deviceId: device.id,
                            type: "launch_cs2",
                            token: token
                        )
                    }
                } label: {
                    Text(commandViewModel.isSending ? "Sending..." : "Launch CS2")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .disabled(commandViewModel.isSending)
                
                NavigationLink {
                    CasesView(device: device)
                } label: {
                    Text("Open Case Flow")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)

                Divider()

                Text("Command status")
                    .font(.headline)

                Text(commandViewModel.statusText)
                    .multilineTextAlignment(.leading)

                if let command = commandViewModel.currentCommand {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Command ID: \(command.id)")
                        Text("Type: \(command.type)")
                        Text("Status: \(command.status)")

                        if let result = command.result, !result.isEmpty {
                            Text("Result:")
                                .font(.subheadline)
                                .fontWeight(.medium)

                            Text(result)
                                .font(.footnote)
                                .textSelection(.enabled)
                        }

                        if let errorMessage = command.errorMessage, !errorMessage.isEmpty {
                            Text("Error:")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundStyle(.red)

                            Text(errorMessage)
                                .font(.footnote)
                                .foregroundStyle(.red)
                                .textSelection(.enabled)
                        }
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }

                Spacer(minLength: 20)
            }
            .padding()
        }
        .navigationTitle(device.name)
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear {
            commandViewModel.stopPolling()
        }
    }

    private var lastSeenText: String {
        guard let lastSeenAt = device.lastSeenAt, !lastSeenAt.isEmpty else {
            return "Last seen: never"
        }

        return "Last seen: \(lastSeenAt)"
    }
}
