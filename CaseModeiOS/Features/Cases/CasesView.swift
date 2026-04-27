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
            await loadCases()
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

                Button(viewModel.isSyncing ? "Syncing..." : "Refresh") {
                    Task { await syncAndReload() }
                }
                .buttonStyle(.borderedProminent)
                .tint(AppTheme.accent)
                .disabled(viewModel.isSyncing)
            }

            if let syncMessage = viewModel.syncMessage {
                Text(syncMessage)
                    .font(.footnote)
                    .foregroundStyle(AppTheme.accent)
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
                                    groupedCase: item
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
            if viewModel.terminals.isEmpty {
                emptyState(
                    title: "No terminals catalog",
                    subtitle: "Add terminal_catalog.json and images"
                )
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.terminals) { item in
                            VStack(spacing: 10) {
                                InventoryCardView(
                                    title: item.name,
                                    subtitle: nil,
                                    quantity: 1,
                                    category: .terminals
                                )

                                HStack {
                                    Spacer()

                                    Text("Opening soon")
                                        .font(.footnote.weight(.semibold))
                                        .foregroundStyle(AppTheme.warning)
                                }
                            }
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

    private func loadCases() async {
        guard let token = sessionStore.token else { return }
        await viewModel.loadCases(token: token)
    }

    private func syncAndReload() async {
        guard let token = sessionStore.token else { return }
        await viewModel.syncAndReload(token: token)
    }
}
