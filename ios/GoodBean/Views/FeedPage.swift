import SwiftUI

// MARK: - FeedPage
struct FeedPage: View {
    @Environment(AuthenticationManager.self) private var authManager

    @State private var allItems: [FeedItem] = []
    @State private var selectedFilter = "All"
    @State private var isLoading = false
    @State private var errorMessage: String?

    private let filters = ["All", "Shots", "Beans", "Machines"]

    private var filteredItems: [FeedItem] {
        switch selectedFilter {
        case "Shots":    return allItems.filter { guard case .shot    = $0 else { return false }; return true }
        case "Beans":    return allItems.filter { guard case .bean    = $0 else { return false }; return true }
        case "Machines": return allItems.filter { guard case .machine = $0 else { return false }; return true }
        default:         return allItems
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Theme.Spacing.md) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: Theme.Spacing.sm) {
                            ForEach(filters, id: \.self) { filter in
                                FilterPill(
                                    label: filter,
                                    isSelected: selectedFilter == filter,
                                    action: { selectedFilter = filter }
                                )
                            }
                        }
                        .padding(.horizontal, Theme.Spacing.md)
                    }

                    if isLoading && allItems.isEmpty {
                        ProgressView()
                            .padding(.top, Theme.Spacing.xl)
                    } else if let error = errorMessage {
                        Text(error)
                            .font(Theme.Font.caption)
                            .foregroundStyle(Color.gbTextTertiary)
                            .padding()
                    } else {
                        LazyVStack(spacing: Theme.Spacing.sm) {
                            ForEach(filteredItems) { item in
                                feedCard(for: item)
                            }
                        }
                        .padding(.horizontal, Theme.Spacing.md)
                    }
                }
                .padding(.vertical, Theme.Spacing.md)
            }
            .background(Color.gbBackground)
            .navigationTitle("Feed")
            .navigationBarTitleDisplayMode(.large)
            .refreshable { await load() }
        }
        .task { await load() }
    }

    private func load() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            async let shotsTask = SupabaseService.shared.getFeedShots()
            async let beansTask = SupabaseService.shared.getFeedBeans()
            async let machinesTask = SupabaseService.shared.getFeedMachines()
            let (shots, beans, machines) = try await (shotsTask, beansTask, machinesTask)

            var items: [FeedItem] = []
            items += shots.map { .shot($0) }
            items += beans.map { .bean($0) }
            items += machines.map { .machine($0) }
            allItems = items.sorted { $0.sortDate > $1.sortDate }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    @ViewBuilder
    private func feedCard(for item: FeedItem) -> some View {
        switch item {
        case .shot(let shot):
            FeedShotCardView(shot: shot, currentUserId: authManager.currentUserId)
        case .bean(let bean):
            FeedBeanCardView(bean: bean, currentUserId: authManager.currentUserId)
        case .machine(let machine):
            FeedMachineCardView(machine: machine, currentUserId: authManager.currentUserId)
        }
    }
}

// MARK: - Feed Shot Card

private struct FeedShotCardView: View {
    let shot: FeedShotPull
    let currentUserId: UUID?

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            FeedCardHeader(profile: shot.profile, createdAt: shot.createdAt, typePill: "SHOT", pillColor: .gbAccent)

            Rectangle().fill(Color.gbSeparator).frame(height: 1)

            VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                if let bean = shot.bean {
                    Text(bean.name)
                        .font(Theme.Font.headline)
                        .foregroundStyle(Color.gbTextPrimary)
                    Text(bean.roaster)
                        .font(Theme.Font.caption)
                        .foregroundStyle(Color.gbTextSecondary)
                }

                HStack(spacing: Theme.Spacing.lg) {
                    dataChip(value: String(format: "%.1fg", shot.doseGrams), label: "DOSE")
                    dataChip(value: String(format: "%.1fg", shot.yieldGrams), label: "YIELD")
                    dataChip(value: "\(shot.timeSeconds)s", label: "TIME")
                    if let temp = shot.tempC {
                        dataChip(value: "\(temp)°C", label: "TEMP")
                    }
                }
                .padding(.top, Theme.Spacing.xs)

                if let rating = shot.rating {
                    RatingPips(rating: rating)
                        .padding(.top, Theme.Spacing.xs)
                }
            }
            .padding(Theme.Spacing.md)

            Rectangle().fill(Color.gbSeparator).frame(height: 1)

            FeedCardFooter(likeCount: shot.likeCount, commentCount: shot.commentCount, hasLiked: shot.hasLiked(userId: currentUserId))
        }
        .gbCardStyle()
    }

    private func dataChip(value: String, label: String) -> some View {
        VStack(spacing: 1) {
            Text(value)
                .font(Theme.Font.data)
                .foregroundStyle(Color.gbTextPrimary)
            Text(label)
                .font(Theme.Font.caption)
                .foregroundStyle(Color.gbTextTertiary)
        }
    }
}

// MARK: - Feed Bean Card

private struct FeedBeanCardView: View {
    let bean: FeedBean
    let currentUserId: UUID?

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            FeedCardHeader(profile: bean.profile, createdAt: bean.createdAt, typePill: "BEAN", pillColor: .gbTextSecondary)

            Rectangle().fill(Color.gbSeparator).frame(height: 1)

            VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                        Text(bean.name)
                            .font(Theme.Font.headline)
                            .foregroundStyle(Color.gbTextPrimary)
                        Text(bean.roaster)
                            .font(Theme.Font.caption)
                            .foregroundStyle(Color.gbTextSecondary)
                    }
                    Spacer()
                    if let level = bean.roastLevel {
                        Text(level.uppercased())
                            .font(Theme.Font.caption.weight(.medium))
                            .foregroundStyle(Color.gbAccent)
                            .padding(.horizontal, Theme.Spacing.sm)
                            .padding(.vertical, Theme.Spacing.xs)
                            .background(Color.gbAccent.opacity(0.12))
                            .clipShape(Capsule())
                    }
                }
                if let notes = bean.notes {
                    Text(notes)
                        .font(Theme.Font.body)
                        .foregroundStyle(Color.gbTextSecondary)
                        .lineLimit(3)
                }
            }
            .padding(Theme.Spacing.md)

            Rectangle().fill(Color.gbSeparator).frame(height: 1)

            FeedCardFooter(likeCount: bean.likeCount, commentCount: bean.commentCount, hasLiked: bean.hasLiked(userId: currentUserId))
        }
        .gbCardStyle()
    }
}

// MARK: - Feed Machine Card

private struct FeedMachineCardView: View {
    let machine: FeedMachine
    let currentUserId: UUID?

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            FeedCardHeader(profile: machine.profile, createdAt: machine.createdAt, typePill: "MACHINE", pillColor: .gbTextSecondary)

            Rectangle().fill(Color.gbSeparator).frame(height: 1)

            VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                Text(machine.displayName)
                    .font(Theme.Font.headline)
                    .foregroundStyle(Color.gbTextPrimary)
                if let notes = machine.notes {
                    Text(notes)
                        .font(Theme.Font.body)
                        .foregroundStyle(Color.gbTextSecondary)
                        .lineLimit(3)
                }
            }
            .padding(Theme.Spacing.md)

            Rectangle().fill(Color.gbSeparator).frame(height: 1)

            FeedCardFooter(likeCount: machine.likeCount, commentCount: machine.commentCount, hasLiked: machine.hasLiked(userId: currentUserId))
        }
        .gbCardStyle()
    }
}

// MARK: - Shared Feed Subviews

private struct FeedCardHeader: View {
    let profile: ProfileEmbed?
    let createdAt: String?
    let typePill: String
    let pillColor: Color

    var body: some View {
        HStack(spacing: Theme.Spacing.sm) {
            Circle()
                .fill(Color.gbAccent.opacity(0.15))
                .frame(width: 32, height: 32)
                .overlay(
                    Text(profile?.initials ?? "?")
                        .font(Theme.Font.caption.weight(.semibold))
                        .foregroundStyle(Color.gbAccent)
                )

            VStack(alignment: .leading, spacing: 1) {
                Text(profile?.username ?? "unknown")
                    .font(Theme.Font.body.weight(.medium))
                    .foregroundStyle(Color.gbTextPrimary)
                if let date = parsedDate(createdAt) {
                    Text(date, style: .relative)
                        .font(Theme.Font.caption)
                        .foregroundStyle(Color.gbTextTertiary)
                }
            }

            Spacer()

            Text(typePill)
                .font(Theme.Font.caption.weight(.semibold))
                .foregroundStyle(pillColor)
                .padding(.horizontal, Theme.Spacing.sm)
                .padding(.vertical, Theme.Spacing.xs)
                .background(pillColor.opacity(0.1))
                .clipShape(Capsule())
        }
        .padding(Theme.Spacing.md)
    }

    private func parsedDate(_ iso8601: String?) -> Date? {
        guard let iso8601 else { return nil }
        let fmt = ISO8601DateFormatter()
        fmt.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let d = fmt.date(from: iso8601) { return d }
        fmt.formatOptions = [.withInternetDateTime]
        return fmt.date(from: iso8601)
    }
}

private struct FeedCardFooter: View {
    let likeCount: Int
    let commentCount: Int
    let hasLiked: Bool

    var body: some View {
        HStack(spacing: Theme.Spacing.lg) {
            Label("\(likeCount)", systemImage: hasLiked ? "heart.fill" : "heart")
                .font(Theme.Font.caption)
                .foregroundStyle(hasLiked ? Color.gbAccent : Color.gbTextSecondary)
            Label("\(commentCount)", systemImage: "bubble.left")
                .font(Theme.Font.caption)
                .foregroundStyle(Color.gbTextSecondary)
            Spacer()
        }
        .padding(Theme.Spacing.md)
    }
}

// MARK: - Filter Pill

private struct FilterPill: View {
    let label: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(Theme.Font.body.weight(.medium))
                .foregroundStyle(isSelected ? Color.white : Color.gbTextSecondary)
                .padding(.horizontal, Theme.Spacing.md)
                .padding(.vertical, Theme.Spacing.sm)
                .background(isSelected ? Color.gbAccent : Color.gbSurface)
                .clipShape(Capsule())
                .overlay(Capsule().strokeBorder(isSelected ? Color.gbAccent : Color.gbSeparator, lineWidth: 1))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    FeedPage()
        .environment(AuthenticationManager())
}
