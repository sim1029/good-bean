import SwiftUI

// MARK: - CafePage
struct CafePage: View {
    @Environment(AuthenticationManager.self) private var authManager

    @State private var profile: Profile?
    @State private var activeBean: Bean?
    @State private var activeMachine: Machine?
    @State private var shots: [ShotPull] = []
    @State private var shotBeans: [UUID: BeanEmbed] = [:]
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            Group {
                if isLoading && shots.isEmpty {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        VStack(spacing: Theme.Spacing.lg) {
                            heroCTACard
                            if let bean = activeBean {
                                activeBeanCard(bean)
                            }
                            if !shots.isEmpty {
                                recentShotsSection
                            }
                        }
                        .padding(Theme.Spacing.md)
                    }
                    .refreshable { await load() }
                }
            }
            .background(Color.gbBackground)
            .navigationTitle("Cafe")
            .navigationBarTitleDisplayMode(.large)
        }
        .task { await load() }
    }

    private func load() async {
        guard let userId = authManager.currentUserId else { return }
        isLoading = true
        defer { isLoading = false }
        do {
            async let profileTask = SupabaseService.shared.getProfile(id: userId)
            async let shotsTask = SupabaseService.shared.getShotPulls(for: userId)
            let (loadedProfile, loadedShots) = try await (profileTask, shotsTask)
            profile = loadedProfile
            shots = loadedShots

            if let beanId = loadedProfile.activeBeanId {
                activeBean = try? await SupabaseService.shared.getBean(id: beanId)
            }
            if let machineId = loadedProfile.activeMachineId {
                activeMachine = try? await SupabaseService.shared.getMachine(id: machineId)
            }

            let uniqueBeanIds = Set(loadedShots.compactMap(\.beanId))
            var beans: [UUID: BeanEmbed] = [:]
            for beanId in uniqueBeanIds {
                if let bean = try? await SupabaseService.shared.getBean(id: beanId) {
                    beans[beanId] = BeanEmbed(name: bean.name, roaster: bean.roaster)
                }
            }
            shotBeans = beans
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Hero CTA Card

    private var heroCTACard: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                Text("Ready to pull?")
                    .font(Theme.Font.title)
                    .foregroundStyle(Color.gbTextPrimary)
                if let machine = activeMachine {
                    Text("on \(machine.displayName)")
                        .font(Theme.Font.body)
                        .foregroundStyle(Color.gbTextSecondary)
                } else {
                    Text("Log your next shot")
                        .font(Theme.Font.body)
                        .foregroundStyle(Color.gbTextSecondary)
                }
            }
            Button("+ Pull") {}
                .buttonStyle(GBPrimaryButtonStyle())
        }
        .padding(Theme.Spacing.lg)
        .gbCardStyle()
    }

    // MARK: - Active Bean Card

    private func activeBeanCard(_ bean: Bean) -> some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            Text("ACTIVE BEAN")
                .font(Theme.Font.caption)
                .foregroundStyle(Color.gbTextTertiary)
                .kerning(1)

            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                    Text(bean.name)
                        .font(Theme.Font.headline)
                        .foregroundStyle(Color.gbTextPrimary)
                    Text("\(bean.roaster)")
                        .font(Theme.Font.body)
                        .foregroundStyle(Color.gbTextSecondary)
                    if let roastDate = bean.roastDate {
                        Text(daysAgoText(from: roastDate))
                            .font(Theme.Font.caption)
                            .foregroundStyle(Color.gbTextTertiary)
                    }
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
        }
        .padding(Theme.Spacing.lg)
        .gbCardStyle()
    }

    private func daysAgoText(from dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        guard let date = formatter.date(from: dateString) else { return "" }
        let days = Calendar.current.dateComponents([.day], from: date, to: Date()).day ?? 0
        return "Roasted \(days) day\(days == 1 ? "" : "s") ago"
    }

    // MARK: - Recent Shots Section

    private var recentShotsSection: some View {
        VStack(spacing: Theme.Spacing.sm) {
            HStack {
                Text("RECENT SHOTS")
                    .font(Theme.Font.caption)
                    .foregroundStyle(Color.gbTextTertiary)
                    .kerning(1)
                Spacer()
            }

            ForEach(shots) { shot in
                ShotRowView(shot: shot, beanEmbed: shot.beanId.flatMap { shotBeans[$0] })
            }
        }
    }
}

// MARK: - Shot Row View

private struct ShotRowView: View {
    let shot: ShotPull
    let beanEmbed: BeanEmbed?

    var body: some View {
        HStack(spacing: Theme.Spacing.md) {
            VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                Text(beanEmbed?.name ?? "Unknown Bean")
                    .font(Theme.Font.headline)
                    .foregroundStyle(Color.gbTextPrimary)
                Text(beanEmbed?.roaster ?? "")
                    .font(Theme.Font.caption)
                    .foregroundStyle(Color.gbTextSecondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: Theme.Spacing.md) {
                dataCell(value: String(format: "%.1fg", shot.doseGrams), label: "DOSE")
                dataCell(value: String(format: "%.1fg", shot.yieldGrams), label: "YIELD")
                dataCell(value: "\(shot.timeSeconds)s", label: "TIME")
            }

            if let rating = shot.rating {
                RatingPips(rating: rating)
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

#Preview {
    CafePage()
        .environment(AuthenticationManager())
}
