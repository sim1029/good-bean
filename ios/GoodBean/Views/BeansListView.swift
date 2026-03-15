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
            if let idx = beans.firstIndex(where: { $0.id == bean.id }) {
                // Refresh just that row
                let updated = try await SupabaseService.shared.getBean(id: bean.id)
                beans[idx] = updated
            }
        } catch {
            // Silently fail — not ideal but keeps the list responsive
        }
    }
}

// MARK: - Bean Row View

private struct BeanRowView: View {
    let bean: Bean
    let onStatusChange: (BeanStatus) async -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                Text(bean.name)
                    .font(.headline)

                HStack(spacing: 14) {
                    Label(bean.roaster, systemImage: "flame")
                    if let roastLevel = bean.roastLevel {
                        Label(roastLevel.capitalized, systemImage: "dial.medium")
                    }
                }
                .font(.caption)
                .foregroundStyle(.secondary)

                if let remaining = bean.remainingGrams {
                    Text(String(format: "%.0fg remaining", remaining))
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }

                if let notes = bean.notes {
                    Text(notes)
                        .font(.caption)
                        .foregroundStyle(.tertiary)
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
                            Label(status.displayName, systemImage: statusIcon(status))
                        }
                    }
                }
        }
    }

    private func statusIcon(_ status: BeanStatus) -> String {
        switch status {
        case .active:   return "checkmark.circle"
        case .frozen:   return "snowflake"
        case .pantry:   return "archivebox"
        case .depleted: return "battery.0"
        }
    }
}

// MARK: - Bean Status Badge

struct BeanStatusBadge: View {
    let status: BeanStatus

    var body: some View {
        Text("\(status.emoji) \(status.displayName)")
            .font(.caption.weight(.medium))
            .foregroundStyle(foregroundColor)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(backgroundColor)
            .clipShape(Capsule())
    }

    private var foregroundColor: Color {
        switch status {
        case .active:   return .green
        case .frozen:   return .cyan
        case .pantry:   return .orange
        case .depleted: return .secondary
        }
    }

    private var backgroundColor: Color {
        foregroundColor.opacity(0.12)
    }
}

#Preview {
    BeansListView()
}
