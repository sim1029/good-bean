import SwiftUI

struct BeansListView: View {
    @State private var beans: [Bean] = []
    @State private var isLoading = true
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                } else if let errorMessage = errorMessage {
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 32))
                            .foregroundStyle(.orange)
                        Text("Error Loading Beans")
                            .font(.headline)
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .textSelection(.enabled)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    .padding(24)
                } else if beans.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "bag")
                            .font(.system(size: 32))
                            .foregroundStyle(.secondary)
                        Text("No Beans Yet")
                            .font(.headline)
                        Text("Add your first coffee bean to get started")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                } else {
                    List {
                        ForEach(beans) { bean in
                            VStack(alignment: .leading, spacing: 8) {
                                Text(bean.name)
                                    .font(.headline)
                                HStack(spacing: 16) {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Roaster")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                        Text(bean.roaster)
                                            .font(.caption)
                                            .fontWeight(.medium)
                                    }
                                    Divider()
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Roast")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                        Text(bean.roastLevel)
                                            .font(.caption)
                                            .fontWeight(.medium)
                                    }
                                    Spacer()
                                    if let notes = bean.notes {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text("Notes")
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                            Text(notes)
                                                .font(.caption)
                                                .lineLimit(1)
                                        }
                                    }
                                }
                                .foregroundStyle(.secondary)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Coffee Beans")
            .navigationBarTitleDisplayMode(.inline)
        }
        .task {
            await loadBeans()
        }
    }

    private func loadBeans() async {
        isLoading = true
        errorMessage = nil

        do {
            beans = try await SupabaseClient.shared.getBeans()
        } catch {
            errorMessage = error.localizedDescription
            print("Error loading beans: \(error)")
        }

        isLoading = false
    }
}

#Preview {
    BeansListView()
}
