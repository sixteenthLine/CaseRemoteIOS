import SwiftUI

struct CasesView: View {
    let device: Device

    @Environment(SessionStore.self) private var sessionStore
    @State private var viewModel = CasesViewModel()

    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView("Loading cases...")
            } else if let errorMessage = viewModel.errorMessage {
                VStack(spacing: 12) {
                    Text("Error")
                        .font(.headline)
                    Text(errorMessage)
                        .multilineTextAlignment(.center)
                    Button("Retry") {
                        Task { await loadCases() }
                    }
                }
                .padding()
            } else if viewModel.cases.isEmpty {
                VStack(spacing: 12) {
                    Text("No cases available")
                        .font(.headline)
                    Text("Refresh inventory to load your cases")
                        .foregroundStyle(.secondary)

                    Button(viewModel.isSyncing ? "Syncing..." : "Refresh inventory") {
                        Task { await syncAndReload() }
                    }
                    .disabled(viewModel.isSyncing)
                }
                .padding()
            } else {
                List(viewModel.cases) { item in
                    NavigationLink {
                        OpeningSessionView(device: device, selectedCase: item)
                    } label: {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(item.name)
                                .font(.headline)

                            if let marketHashName = item.marketHashName {
                                Text(marketHashName)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }

                            Text("Quantity: \(item.quantity)")
                                .font(.subheadline)
                        }
                    }
                }
            }
        }
        .navigationTitle("Cases")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(viewModel.isSyncing ? "Syncing..." : "Refresh") {
                    Task { await syncAndReload() }
                }
                .disabled(viewModel.isSyncing)
            }
        }
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: 4) {
                if let syncMessage = viewModel.syncMessage {
                    Text(syncMessage)
                        .font(.footnote)
                }

                if let lastSyncedAt = viewModel.lastSyncedAt {
                    Text("Last synced: \(lastSyncedAt)")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity)
            .background(.thinMaterial)
        }
        .task {
            await loadCases()
        }
    }

    private func loadCases() async {
        guard let token = sessionStore.token else { return }
        await viewModel.loadCases(token: token)
    }

    private func syncAndReload() async {
        guard let token = sessionStore.token else { return }
        await viewModel.syncAndReload(token: token)
    }
}
