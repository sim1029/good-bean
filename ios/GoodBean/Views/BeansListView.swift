import SwiftUI

struct BeansListView: View {
    @State private var beans: [Bean] = []
    @State private var isLoading = true
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    ProgressView("Loading beans...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let errorMessage {
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 32))
                            .foregroundStyle(.orange)
                        Text("Error Loading Beans")
                            .font(.headline)
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                        Button("Retry") {
                            Task { await loadBeans() }
                        }
                    }
                    .padding(24)
                } else if beans.isEmpty {
                    ContentUnavailableView(
                        "No Beans Yet",
                        systemImage: "bag",
                        description: Text("Add coffee beans to get started")
                    )
                } else {
                    List(beans) { bean in
                        VStack(alignment: .leading, spacing: 8) {
                            Text(bean.name)
                                .font(.headline)
                            HStack(spacing: 16) {
                                Label(bean.roaster, systemImage: "flame")
                                if let roastLevel = bean.roastLevel {
                                    Label(roastLevel.capitalized, systemImage: "dial.medium")
                                }
                            }
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            if let notes = bean.notes {
                                Text(notes)
                                    .font(.caption)
                                    .foregroundStyle(.tertiary)
                                    .lineLimit(2)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Coffee Beans")
            .navigationBarTitleDisplayMode(.large)
            .refreshable {
                await loadBeans()
            }
        }
        .task {
            await loadBeans()
        }
    }

    private func loadBeans() async {
        isLoading = true
        errorMessage = nil
        do {
            beans = try await SupabaseService.shared.getBeans()
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}

#Preview {
    BeansListView()
}
