import SwiftUI
import Charts

// MARK: - Chart Data Types

private struct RatioPoint: Identifiable {
    let id: UUID
    let date: Date
    let ratio: Double
}

private struct DurationPoint: Identifiable {
    let id: UUID
    let index: Int
    let seconds: Int
}

// MARK: - Stat Tile
private struct StatTile: View {
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: Theme.Spacing.xs) {
            Text(value)
                .font(Theme.Font.dataLarge)
                .foregroundStyle(Color.gbTextPrimary)
            Text(label)
                .font(Theme.Font.caption)
                .foregroundStyle(Color.gbTextTertiary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Theme.Spacing.md)
        .gbCardStyle()
    }
}

// MARK: - VisualizePage
struct VisualizePage: View {
    @Environment(AuthenticationManager.self) private var authManager

    @State private var shots: [ShotPull] = []
    @State private var isLoading = false

    private var last20: [ShotPull] { Array(shots.prefix(20)) }

    private var shotsThisWeek: Int {
        let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        return shots.filter { ($0.createdDate ?? .distantPast) >= weekAgo }.count
    }

    private var avgRatio: String {
        guard !shots.isEmpty else { return "—" }
        let avg = shots.map(\.ratio).reduce(0, +) / Double(shots.count)
        return String(format: "%.2f", avg)
    }

    private var avgTime: String {
        guard !shots.isEmpty else { return "—" }
        let avg = shots.map { Double($0.timeSeconds) }.reduce(0, +) / Double(shots.count)
        return String(format: "%.0fs", avg)
    }

    private var avgRating: String {
        let rated = shots.compactMap(\.rating)
        guard !rated.isEmpty else { return "—" }
        let avg = rated.map(Double.init).reduce(0, +) / Double(rated.count)
        return String(format: "%.1f", avg)
    }

    private var ratioPoints: [RatioPoint] {
        last20.compactMap { shot in
            guard let date = shot.createdDate else { return nil }
            return RatioPoint(id: shot.id, date: date, ratio: shot.ratio)
        }.reversed()
    }

    private var durationPoints: [DurationPoint] {
        Array(last20.enumerated().map { index, shot in
            DurationPoint(id: shot.id, index: index + 1, seconds: shot.timeSeconds)
        }.reversed())
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Theme.Spacing.lg) {
                    HStack(spacing: Theme.Spacing.sm) {
                        StatTile(value: "\(shotsThisWeek)", label: "SHOTS\nTHIS WEEK")
                        StatTile(value: avgRatio, label: "AVG\nRATIO")
                        StatTile(value: avgTime, label: "AVG\nTIME")
                        StatTile(value: avgRating, label: "AVG\nRATING")
                    }

                    if shots.isEmpty && !isLoading {
                        emptyState
                    } else {
                        ratioChart
                        durationChart
                    }
                }
                .padding(Theme.Spacing.md)
            }
            .background(Color.gbBackground)
            .navigationTitle("Visualize")
            .navigationBarTitleDisplayMode(.large)
            .refreshable { await load() }
        }
        .task { await load() }
    }

    private func load() async {
        guard let userId = authManager.currentUserId else { return }
        isLoading = true
        defer { isLoading = false }
        shots = (try? await SupabaseService.shared.getShotPulls(for: userId)) ?? []
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: Theme.Spacing.md) {
            Image(systemName: "chart.bar")
                .font(.system(size: 40))
                .foregroundStyle(Color.gbTextTertiary)
            Text("No shots logged yet")
                .font(Theme.Font.headline)
                .foregroundStyle(Color.gbTextSecondary)
            Text("Pull your first shot to see charts here.")
                .font(Theme.Font.body)
                .foregroundStyle(Color.gbTextTertiary)
                .multilineTextAlignment(.center)
        }
        .padding(Theme.Spacing.xl)
    }

    // MARK: - Ratio Chart

    private var ratioChart: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            Text("EXTRACTION RATIO")
                .font(Theme.Font.caption)
                .foregroundStyle(Color.gbTextTertiary)
                .kerning(1)

            Chart {
                ForEach(ratioPoints) { point in
                    LineMark(
                        x: .value("Date", point.date),
                        y: .value("Ratio", point.ratio)
                    )
                    .foregroundStyle(Color.gbAccent)
                    .interpolationMethod(.catmullRom)

                    PointMark(
                        x: .value("Date", point.date),
                        y: .value("Ratio", point.ratio)
                    )
                    .foregroundStyle(Color.gbAccent)
                    .symbolSize(30)
                }

                RuleMark(y: .value("Golden Ratio", 2.0))
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [4, 4]))
                    .foregroundStyle(Color.gbTextTertiary)
                    .annotation(position: .trailing, alignment: .trailing) {
                        Text("2.0")
                            .font(Theme.Font.caption)
                            .foregroundStyle(Color.gbTextTertiary)
                    }
            }
            .chartYScale(domain: 1.5...2.5)
            .chartXAxis {
                AxisMarks(values: .automatic(desiredCount: 4)) { _ in
                    AxisValueLabel(format: .dateTime.month(.abbreviated).day())
                        .foregroundStyle(Color.gbTextTertiary)
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading, values: .automatic(desiredCount: 4)) { _ in
                    AxisValueLabel()
                        .foregroundStyle(Color.gbTextTertiary)
                    AxisGridLine()
                        .foregroundStyle(Color.gbSeparator)
                }
            }
            .frame(height: 180)
        }
        .padding(Theme.Spacing.md)
        .gbCardStyle()
    }

    // MARK: - Duration Chart

    private var durationChart: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            Text("SHOT DURATION")
                .font(Theme.Font.caption)
                .foregroundStyle(Color.gbTextTertiary)
                .kerning(1)

            Chart {
                ForEach(durationPoints) { shot in
                    BarMark(
                        x: .value("Shot", shot.index),
                        y: .value("Seconds", shot.seconds)
                    )
                    .foregroundStyle(
                        (25...35).contains(shot.seconds) ? Color.gbAccent : Color.gbTextTertiary
                    )
                    .cornerRadius(4)
                }

                RuleMark(y: .value("Sweet Spot Min", 25))
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [4, 4]))
                    .foregroundStyle(Color.gbTextTertiary)

                RuleMark(y: .value("Sweet Spot Max", 35))
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [4, 4]))
                    .foregroundStyle(Color.gbTextTertiary)
            }
            .chartXAxis(.hidden)
            .chartYAxis {
                AxisMarks(position: .leading, values: [20, 25, 30, 35, 40]) { value in
                    AxisValueLabel {
                        if let s = value.as(Int.self) {
                            Text("\(s)s")
                                .font(Theme.Font.caption)
                                .foregroundStyle(Color.gbTextTertiary)
                        }
                    }
                    AxisGridLine()
                        .foregroundStyle(Color.gbSeparator)
                }
            }
            .frame(height: 160)
        }
        .padding(Theme.Spacing.md)
        .gbCardStyle()
    }
}

#Preview {
    VisualizePage()
        .environment(AuthenticationManager())
}
