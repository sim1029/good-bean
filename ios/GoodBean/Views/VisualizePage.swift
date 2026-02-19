import SwiftUI
import Charts

// MARK: - Mock Data
private struct RatioDataPoint: Identifiable {
    let id = UUID()
    let date: Date
    let ratio: Double
}

private struct ShotDuration: Identifiable {
    let id = UUID()
    let index: Int
    let seconds: Int
}

private let ratioData: [RatioDataPoint] = {
    let cal = Calendar.current
    let today = Date()
    let ratios: [Double] = [2.05, 1.95, 2.10, 1.88, 2.15, 2.00, 1.92, 2.18, 2.22, 2.01]
    return ratios.enumerated().map { i, r in
        RatioDataPoint(date: cal.date(byAdding: .day, value: -(9 - i), to: today)!, ratio: r)
    }
}()

private let durationData: [ShotDuration] = [
    ShotDuration(index: 1, seconds: 24),
    ShotDuration(index: 2, seconds: 28),
    ShotDuration(index: 3, seconds: 30),
    ShotDuration(index: 4, seconds: 27),
    ShotDuration(index: 5, seconds: 33),
    ShotDuration(index: 6, seconds: 22),
    ShotDuration(index: 7, seconds: 29),
]

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
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Theme.Spacing.lg) {
                    // Stat tiles row
                    HStack(spacing: Theme.Spacing.sm) {
                        StatTile(value: "7", label: "SHOTS\nTHIS WEEK")
                        StatTile(value: "2.01", label: "AVG\nRATIO")
                        StatTile(value: "29s", label: "AVG\nTIME")
                        StatTile(value: "7.4", label: "AVG\nRATING")
                    }

                    // Extraction ratio chart
                    VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                        Text("EXTRACTION RATIO")
                            .font(Theme.Font.caption)
                            .foregroundStyle(Color.gbTextTertiary)
                            .kerning(1)

                        Chart {
                            ForEach(ratioData) { point in
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

                    // Shot duration bar chart
                    VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                        Text("SHOT DURATION")
                            .font(Theme.Font.caption)
                            .foregroundStyle(Color.gbTextTertiary)
                            .kerning(1)

                        Chart {
                            ForEach(durationData) { shot in
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
                .padding(Theme.Spacing.md)
            }
            .background(Color.gbBackground)
            .navigationTitle("Visualize")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

#Preview {
    VisualizePage()
}
