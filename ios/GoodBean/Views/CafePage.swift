import SwiftUI

// MARK: - Mock Data
private struct MockShot: Identifiable {
    let id = UUID()
    let beanName: String
    let roaster: String
    let dose: Double
    let yield: Double
    let time: Int
    let rating: Int
}

private let mockShots: [MockShot] = [
    MockShot(beanName: "Geisha Reserve", roaster: "Onyx Coffee Lab", dose: 18.0, yield: 36.0, time: 28, rating: 8),
    MockShot(beanName: "Geisha Reserve", roaster: "Onyx Coffee Lab", dose: 18.2, yield: 37.0, time: 30, rating: 9),
    MockShot(beanName: "Nightcap Blend", roaster: "Counter Culture",  dose: 19.0, yield: 38.0, time: 32, rating: 7),
]

// MARK: - Subviews
private struct ShotRowView: View {
    let shot: MockShot

    var body: some View {
        HStack(spacing: Theme.Spacing.md) {
            // Bean info
            VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                Text(shot.beanName)
                    .font(Theme.Font.headline)
                    .foregroundStyle(Color.gbTextPrimary)
                Text(shot.roaster)
                    .font(Theme.Font.caption)
                    .foregroundStyle(Color.gbTextSecondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            // Data cells
            HStack(spacing: Theme.Spacing.md) {
                dataCell(value: String(format: "%.1fg", shot.dose), label: "DOSE")
                dataCell(value: String(format: "%.1fg", shot.yield), label: "YIELD")
                dataCell(value: "\(shot.time)s", label: "TIME")
            }

            // Rating bar (10 pips)
            HStack(spacing: 2) {
                ForEach(1...10, id: \.self) { pip in
                    RoundedRectangle(cornerRadius: 1.5)
                        .fill(pip <= shot.rating ? Color.gbAccent : Color.gbSeparator)
                        .frame(width: 3, height: 14)
                }
            }
        }
        .padding(Theme.Spacing.md)
        .gbCardStyle()
    }

    private func dataCell(value: String, label: String) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(Theme.Font.data)
                .foregroundStyle(Color.gbTextPrimary)
            Text(label)
                .font(Theme.Font.caption)
                .foregroundStyle(Color.gbTextTertiary)
        }
    }
}

// MARK: - CafePage
struct CafePage: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Theme.Spacing.lg) {
                    // Hero CTA card
                    VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                        VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                            Text("Ready to pull?")
                                .font(Theme.Font.title)
                                .foregroundStyle(Color.gbTextPrimary)
                            Text("Log your next shot")
                                .font(Theme.Font.body)
                                .foregroundStyle(Color.gbTextSecondary)
                        }
                        Button("+ Pull") {}
                            .buttonStyle(GBPrimaryButtonStyle())
                    }
                    .padding(Theme.Spacing.lg)
                    .gbCardStyle()

                    // Active bean card
                    VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                        Text("ACTIVE BEAN")
                            .font(Theme.Font.caption)
                            .foregroundStyle(Color.gbTextTertiary)
                            .kerning(1)

                        HStack(alignment: .top) {
                            VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                                Text("Geisha Reserve")
                                    .font(Theme.Font.headline)
                                    .foregroundStyle(Color.gbTextPrimary)
                                Text("Onyx Coffee Lab · Light")
                                    .font(Theme.Font.body)
                                    .foregroundStyle(Color.gbTextSecondary)
                                Text("Roasted 9 days ago")
                                    .font(Theme.Font.caption)
                                    .foregroundStyle(Color.gbTextTertiary)
                            }
                            Spacer()
                            Text("LIGHT")
                                .font(Theme.Font.caption.weight(.medium))
                                .foregroundStyle(Color.gbAccent)
                                .padding(.horizontal, Theme.Spacing.sm)
                                .padding(.vertical, Theme.Spacing.xs)
                                .background(Color.gbAccent.opacity(0.12))
                                .clipShape(Capsule())
                        }
                    }
                    .padding(Theme.Spacing.lg)
                    .gbCardStyle()

                    // Recent shots
                    VStack(spacing: Theme.Spacing.sm) {
                        HStack {
                            Text("RECENT SHOTS")
                                .font(Theme.Font.caption)
                                .foregroundStyle(Color.gbTextTertiary)
                                .kerning(1)
                            Spacer()
                            Button("See All") {}
                                .font(Theme.Font.caption.weight(.medium))
                                .foregroundStyle(Color.gbAccent)
                        }

                        ForEach(mockShots) { shot in
                            ShotRowView(shot: shot)
                        }
                    }
                }
                .padding(Theme.Spacing.md)
            }
            .background(Color.gbBackground)
            .navigationTitle("Cafe")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

#Preview {
    CafePage()
}
