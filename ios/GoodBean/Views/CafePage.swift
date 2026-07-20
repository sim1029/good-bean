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
    @State private var showAddBean = false
    @State private var showAddMachine = false

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
                            cafeSetupCard
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
        .sheet(isPresented: $showAddBean) {
            if let id = authManager.currentUserId {
                AddItemView(itemType: .bean, profileId: id) { await load() }
            }
        }
        .sheet(isPresented: $showAddMachine) {
            if let id = authManager.currentUserId {
                AddItemView(itemType: .machine, profileId: id) { await load() }
            }
        }
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

    // MARK: - Cafe Setup Card

    private var cafeSetupCard: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            Text("CAFE SETUP")
                .font(Theme.Font.caption)
                .foregroundStyle(Color.gbTextTertiary)
                .kerning(1)
                .padding(.horizontal, Theme.Spacing.md)
                .padding(.top, Theme.Spacing.md)

            VStack(spacing: 0) {
                Button {
                    showAddMachine = true
                } label: {
                    setupRow(
                        icon: "cup.and.saucer",
                        label: "MACHINE",
                        value: activeMachine?.displayName ?? "Add a machine",
                        isEmpty: activeMachine == nil
                    )
                }
                .buttonStyle(.plain)

                Divider()
                    .background(Color.gbSeparator)
                    .padding(.leading, Theme.Spacing.md + 28)

                Button {
                    showAddBean = true
                } label: {
                    setupRow(
                        icon: "leaf",
                        label: "ACTIVE BEAN",
                        value: activeBean.map { "\($0.name) · \($0.roaster)" } ?? "Add a bean",
                        isEmpty: activeBean == nil
                    )
                }
                .buttonStyle(.plain)
            }

            Spacer().frame(height: Theme.Spacing.xs)
        }
        .gbCardStyle()
    }

    private func setupRow(icon: String, label: String, value: String, isEmpty: Bool) -> some View {
        HStack(spacing: Theme.Spacing.md) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundStyle(Color.gbAccent)
                .frame(width: 20)
            VStack(alignment: .leading, spacing: 1) {
                Text(label)
                    .font(Theme.Font.caption)
                    .foregroundStyle(Color.gbTextTertiary)
                    .kerning(1)
                Text(value)
                    .font(Theme.Font.body.weight(.medium))
                    .foregroundStyle(isEmpty ? Color.gbAccent : Color.gbTextPrimary)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(Color.gbTextTertiary)
        }
        .padding(Theme.Spacing.md)
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
