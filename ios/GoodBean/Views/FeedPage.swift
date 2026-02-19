import SwiftUI

// MARK: - Mock Data
private struct MockFeedItem: Identifiable {
    let id = UUID()
    let initials: String
    let username: String
    let timeAgo: String
    let type: String   // "SHOT" or "BEAN"
    let beanName: String
    let roaster: String
    let dose: Double
    let yield: Double
    let time: Int
    let temp: Double
    let rating: Int
    let hearts: Int
    let comments: Int
}

private let mockFeedItems: [MockFeedItem] = [
    MockFeedItem(initials: "JR", username: "jrbarista", timeAgo: "12m ago", type: "SHOT",
                 beanName: "Ethiopia Yirgacheffe", roaster: "Stumptown Coffee",
                 dose: 18.5, yield: 37.0, time: 27, temp: 93.5, rating: 9, hearts: 14, comments: 3),
    MockFeedItem(initials: "AK", username: "arabica_kate", timeAgo: "1h ago", type: "SHOT",
                 beanName: "Colombia El Paraíso", roaster: "Intelligentsia",
                 dose: 17.8, yield: 35.6, time: 29, temp: 92.0, rating: 8, hearts: 7, comments: 1),
    MockFeedItem(initials: "MC", username: "mcrema", timeAgo: "3h ago", type: "BEAN",
                 beanName: "Kenya Kiambu AA", roaster: "Blue Bottle Coffee",
                 dose: 19.0, yield: 38.0, time: 31, temp: 94.0, rating: 10, hearts: 22, comments: 6),
    MockFeedItem(initials: "TN", username: "test_nerd", timeAgo: "9h ago", type: "SHOT",
                 beanName: "Geisha Reserve", roaster: "Onyx Coffee Lab",
                 dose: 18.0, yield: 36.0, time: 28, temp: 93.0, rating: 8, hearts: 5, comments: 0),
]

// MARK: - Feed Card
private struct FeedCardView: View {
    let item: MockFeedItem

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack(spacing: Theme.Spacing.sm) {
                Circle()
                    .fill(Color.gbAccent.opacity(0.15))
                    .frame(width: 32, height: 32)
                    .overlay(
                        Text(item.initials)
                            .font(Theme.Font.caption.weight(.semibold))
                            .foregroundStyle(Color.gbAccent)
                    )
                VStack(alignment: .leading, spacing: 1) {
                    Text(item.username)
                        .font(Theme.Font.body.weight(.medium))
                        .foregroundStyle(Color.gbTextPrimary)
                    Text(item.timeAgo)
                        .font(Theme.Font.caption)
                        .foregroundStyle(Color.gbTextTertiary)
                }
                Spacer()
                Text(item.type)
                    .font(Theme.Font.caption.weight(.semibold))
                    .foregroundStyle(item.type == "SHOT" ? Color.gbAccent : Color.gbTextSecondary)
                    .padding(.horizontal, Theme.Spacing.sm)
                    .padding(.vertical, Theme.Spacing.xs)
                    .background(
                        (item.type == "SHOT" ? Color.gbAccent : Color.gbTextSecondary).opacity(0.1)
                    )
                    .clipShape(Capsule())
            }
            .padding(Theme.Spacing.md)

            Rectangle()
                .fill(Color.gbSeparator)
                .frame(height: 1)

            // Body
            VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                Text(item.beanName)
                    .font(Theme.Font.headline)
                    .foregroundStyle(Color.gbTextPrimary)
                Text(item.roaster)
                    .font(Theme.Font.caption)
                    .foregroundStyle(Color.gbTextSecondary)

                HStack(spacing: Theme.Spacing.lg) {
                    dataChip(value: String(format: "%.1fg", item.dose), label: "DOSE")
                    dataChip(value: String(format: "%.1fg", item.yield), label: "YIELD")
                    dataChip(value: "\(item.time)s", label: "TIME")
                    dataChip(value: String(format: "%.0f°C", item.temp), label: "TEMP")
                    dataChip(value: "\(item.rating)/10", label: "RATING")
                }
                .padding(.top, Theme.Spacing.xs)
            }
            .padding(Theme.Spacing.md)

            Rectangle()
                .fill(Color.gbSeparator)
                .frame(height: 1)

            // Footer
            HStack(spacing: Theme.Spacing.lg) {
                Label("\(item.hearts)", systemImage: "heart")
                    .font(Theme.Font.caption)
                    .foregroundStyle(Color.gbTextSecondary)
                Label("\(item.comments)", systemImage: "bubble.left")
                    .font(Theme.Font.caption)
                    .foregroundStyle(Color.gbTextSecondary)
                Spacer()
            }
            .padding(Theme.Spacing.md)
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

// MARK: - FeedPage
struct FeedPage: View {
    @State private var selectedFilter = "All"
    private let filters = ["All", "Shots", "Beans", "Following"]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Theme.Spacing.md) {
                    // Filter pills
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

                    // Feed cards
                    LazyVStack(spacing: Theme.Spacing.sm) {
                        ForEach(mockFeedItems) { item in
                            FeedCardView(item: item)
                        }
                    }
                    .padding(.horizontal, Theme.Spacing.md)
                }
                .padding(.vertical, Theme.Spacing.md)
            }
            .background(Color.gbBackground)
            .navigationTitle("Feed")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

#Preview {
    FeedPage()
}
