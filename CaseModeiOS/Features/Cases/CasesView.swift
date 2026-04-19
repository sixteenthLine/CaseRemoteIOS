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
                    Text("There are no cases available for opening")
                        .foregroundStyle(.secondary)
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
                            Text("Quantity: \(item.quantity)")
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
        .navigationTitle("Cases")
        .task {
            await loadCases()
        }
    }

    private func loadCases() async {
        guard let token = sessionStore.token else { return }
        await viewModel.loadCases(token: token)
    }
}
