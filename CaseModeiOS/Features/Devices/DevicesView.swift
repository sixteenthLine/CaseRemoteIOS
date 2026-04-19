import SwiftUI

struct DevicesView: View {
    @Environment(SessionStore.self) private var sessionStore
    @State private var viewModel = DevicesViewModel()

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    ProgressView("Loading devices...")
                } else if let errorMessage = viewModel.errorMessage {
                    VStack(spacing: 12) {
                        Text("Error")
                            .font(.headline)
                        Text(errorMessage)
                            .multilineTextAlignment(.center)
                        Button("Retry") {
                            Task { await loadDevices() }
                        }
                    }
                    .padding()
                } else if viewModel.devices.isEmpty {
                    VStack(spacing: 12) {
                        Text("No devices paired yet")
                            .font(.headline)
                        Text("Open Windows agent and pair your PC")
                            .foregroundStyle(.secondary)
                    }
                    .padding()
                } else {
                    List(viewModel.devices) { device in
                        NavigationLink {
                            DeviceDetailView(device: device)
                        } label: {
                            DeviceRowView(device: device)
                        }
                    }
                }
            }
            .navigationTitle("My Devices")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Refresh") {
                        Task { await loadDevices() }
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button("Logout") {
                        sessionStore.logout()
                        viewModel.clear()
                    }
                }
            }
        }
        .task {
            await loadDevices()
        }
    }

    private func loadDevices() async {
        guard let token = sessionStore.token else { return }
        await viewModel.loadDevices(token: token)
    }
}
