import SwiftUI

struct CasesView: View {
    let device: Device

    @Environment(SessionStore.self) private var sessionStore
    @State private var viewModel = CasesViewModel()
    @State private var selectedTab: InventoryDisplayTab = .cases

    var body: some View {
        ZStack {
            AppTheme.background
                .ignoresSafeArea()

            VStack(spacing: 16) {
                header

                picker

                content
            }
            .padding()
        }
        .navigationTitle("Inventory")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await loadInventory()
        }
        .onDisappear {
            viewModel.stopSyncPolling()
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Openings")
                        .font(.title2.weight(.bold))
                        .foregroundStyle(AppTheme.textPrimary)

                    Text("Choose what you want to open")
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.textSecondary)
                }

                Spacer()

                Button(viewModel.isStartingSync ? "Starting..." : "Sync Owner Inventory") {
                    Task { await syncOwnerInventory() }
                }
                .buttonStyle(.borderedProminent)
                .tint(AppTheme.accent)
                .disabled(viewModel.isStartingSync)
            }

            if let syncMessage = viewModel.syncMessage {
                Text(syncMessage)
                    .font(.footnote)
                    .foregroundStyle(AppTheme.accent)
            }

            if let syncCommandStatus = viewModel.syncCommandStatus {
                Text("Command status: \(syncCommandStatus)")
                    .font(.footnote)
                    .foregroundStyle(AppTheme.textSecondary)
            }

            if let lastSyncedAt = viewModel.lastSyncedAt {
                Text("Last synced: \(lastSyncedAt)")
                    .font(.footnote)
                    .foregroundStyle(AppTheme.textSecondary)
            }

            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .font(.footnote)
                    .foregroundStyle(AppTheme.danger)
            }
        }
        .padding(16)
        .background(AppTheme.card)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(AppTheme.cardBorder, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    private var picker: some View {
        HStack(spacing: 10) {
            ForEach(InventoryDisplayTab.allCases) { tab in
                Button {
                    selectedTab = tab
                } label: {
                    Text(tab.rawValue)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(selectedTab == tab ? Color.black : AppTheme.textSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(selectedTab == tab ? AppTheme.accent : AppTheme.card)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(AppTheme.cardBorder, lineWidth: selectedTab == tab ? 0 : 1)
                        )
                }
            }
        }
    }

    @ViewBuilder
    private var content: some View {
        switch selectedTab {
        case .cases:
            casesContent
        case .terminals:
            terminalsContent
        }
    }

    private var casesContent: some View {
        Group {
            if viewModel.isLoading {
                ProgressView("Loading cases...")
                    .tint(AppTheme.accent)
                    .foregroundStyle(AppTheme.textPrimary)
                    .frame(maxHeight: .infinity)
            } else if viewModel.groupedCases.isEmpty {
                emptyState(
                    title: "No cases available",
                    subtitle: "Refresh inventory to load your cases"
                )
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.groupedCases) { item in
                            NavigationLink {
                                GroupedOpeningSessionView(
                                    device: device,
                                    groupedItem: item,
                                    category: .cases
                                )
                            } label: {
                                InventoryCardView(
                                    title: item.displayName,
                                    subtitle: item.marketHashName,
                                    quantity: item.quantity,
                                    category: .cases
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.bottom, 24)
                }
            }
        }
    }

    private var terminalsContent: some View {
        Group {
            if viewModel.isLoading {
                ProgressView("Loading terminals...")
                    .tint(AppTheme.accent)
                    .foregroundStyle(AppTheme.textPrimary)
                    .frame(maxHeight: .infinity)
            } else if viewModel.groupedTerminals.isEmpty {
                emptyState(
                    title: "No terminals available",
                    subtitle: "Refresh inventory to load your terminals"
                )
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.groupedTerminals) { item in
                            NavigationLink {
                                GroupedOpeningSessionView(
                                    device: device,
                                    groupedItem: item,
                                    category: .terminals
                                )
                            } label: {
                                InventoryCardView(
                                    title: item.displayName,
                                    subtitle: item.marketHashName,
                                    quantity: item.quantity,
                                    category: .terminals
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.bottom, 24)
                }
            }
        }
    }

    private func emptyState(title: String, subtitle: String) -> some View {
        VStack(spacing: 10) {
            Spacer()

            Text(title)
                .font(.headline)
                .foregroundStyle(AppTheme.textPrimary)

            Text(subtitle)
                .font(.subheadline)
                .foregroundStyle(AppTheme.textSecondary)
                .multilineTextAlignment(.center)

            Spacer()
        }
    }

    private func loadInventory() async {
        guard let token = sessionStore.token else { return }
        await viewModel.loadInventory(token: token)
    }

    private func syncOwnerInventory() async {
        guard let token = sessionStore.token else { return }
        await viewModel.syncOwnerInventory(token: token)
    }
}
