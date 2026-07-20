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
                        BeanRowView(bean: bean) { newStatus in
                            await updateStatus(for: bean, status: newStatus)
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

    private func updateStatus(for bean: Bean, status: BeanStatus) async {
        do {
            try await SupabaseService.shared.updateBeanStatus(
                id: bean.id,
                status: status,
                remainingGrams: bean.remainingGrams
            )
            // Refresh just the affected row.
            if let idx = beans.firstIndex(where: { $0.id == bean.id }) {
                beans[idx] = try await SupabaseService.shared.getBean(id: bean.id)
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

// MARK: - Bean Row

private struct BeanRowView: View {
    let bean: Bean
    let onStatusChange: (BeanStatus) async -> Void

    var body: some View {
        HStack(alignment: .top, spacing: Theme.Spacing.md) {
            VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                Text(bean.name)
                    .font(Theme.Font.headline)
                    .foregroundStyle(Color.gbTextPrimary)

                HStack(spacing: Theme.Spacing.md) {
                    Label(bean.roaster, systemImage: "flame")
                    if let roastLevel = bean.roastLevel {
                        Label(roastLevel.capitalized, systemImage: "dial.medium")
                    }
                }
                .font(Theme.Font.caption)
                .foregroundStyle(Color.gbTextSecondary)

                if let remaining = bean.remainingGrams {
                    Text(String(format: "%.0fg remaining", remaining))
                        .font(Theme.Font.data)
                        .foregroundStyle(Color.gbTextTertiary)
                }

                if let notes = bean.notes {
                    Text(notes)
                        .font(Theme.Font.caption)
                        .foregroundStyle(Color.gbTextTertiary)
                        .lineLimit(2)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            BeanStatusBadge(status: bean.status)
                .contextMenu {
                    ForEach(BeanStatus.allCases, id: \.self) { status in
                        Button {
                            Task { await onStatusChange(status) }
                        } label: {
                            Label(status.displayName, systemImage: status.iconName)
                        }
                    }
                }
        }
    }
}

// MARK: - Bean Status Badge

struct BeanStatusBadge: View {
    let status: BeanStatus

    var body: some View {
        Text("\(status.emoji) \(status.displayName)")
            .font(Theme.Font.caption.weight(.medium))
            .foregroundStyle(status.color)
            .padding(.horizontal, Theme.Spacing.sm)
            .padding(.vertical, Theme.Spacing.xs)
            .background(status.color.opacity(0.12))
            .clipShape(Capsule())
    }
}

#Preview {
    BeansListView()
}
