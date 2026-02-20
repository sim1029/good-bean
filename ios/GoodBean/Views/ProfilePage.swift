import SwiftUI

// MARK: - ProfilePage
struct ProfilePage: View {
    @Environment(AuthenticationManager.self) private var authManager

    @State private var profile: Profile?
    @State private var activeBean: Bean?
    @State private var activeMachine: Machine?
    @State private var shots: [ShotPull] = []
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        VStack(spacing: Theme.Spacing.lg) {
                            profileHeroCard
                            if activeBean != nil || activeMachine != nil {
                                setupCard
                            }
                            if !shots.isEmpty {
                                recentShotsCard
                            }
                            settingsCard
                            signOutButton
                        }
                        .padding(Theme.Spacing.md)
                    }
                    .refreshable { await load() }
                }
            }
            .background(Color.gbBackground)
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
        }
        .task { await load() }
    }

    private func load() async {
        guard let userId = authManager.currentUserId else { return }
        isLoading = true
        errorMessage = nil
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
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Profile Hero Card

    private var profileHeroCard: some View {
        VStack(spacing: Theme.Spacing.md) {
            Circle()
                .fill(Color.gbAccent.opacity(0.15))
                .frame(width: 72, height: 72)
                .overlay(
                    Text(profile?.initials ?? "?")
                        .font(Theme.Font.title)
                        .foregroundStyle(Color.gbAccent)
                )

            VStack(spacing: Theme.Spacing.xs) {
                Text(profile?.username ?? "—")
                    .font(Theme.Font.headline)
                    .foregroundStyle(Color.gbTextPrimary)
                Text(profile?.memberSince ?? "")
                    .font(Theme.Font.caption)
                    .foregroundStyle(Color.gbTextTertiary)
            }

            HStack(spacing: 0) {
                statItem(value: "\(shots.count)", label: "Shots")
                Rectangle()
                    .fill(Color.gbSeparator)
                    .frame(width: 1, height: 28)
                statItem(value: "\(shots.filter(\.isPublic).count)", label: "Public")
            }
        }
        .padding(Theme.Spacing.lg)
        .gbCardStyle()
    }

    private func statItem(value: String, label: String) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(Theme.Font.dataLarge)
                .foregroundStyle(Color.gbTextPrimary)
            Text(label)
                .font(Theme.Font.caption)
                .foregroundStyle(Color.gbTextTertiary)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Setup Card

    private var setupCard: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            Text("SETUP")
                .font(Theme.Font.caption)
                .foregroundStyle(Color.gbTextTertiary)
                .kerning(1)
                .padding(.horizontal, Theme.Spacing.md)
                .padding(.top, Theme.Spacing.md)

            VStack(spacing: 0) {
                if let machine = activeMachine {
                    setupRow(icon: "cup.and.saucer", label: "Machine", value: machine.displayName)
                }
                if activeMachine != nil && activeBean != nil {
                    Divider()
                        .background(Color.gbSeparator)
                        .padding(.leading, Theme.Spacing.md + 28)
                }
                if let bean = activeBean {
                    setupRow(icon: "leaf", label: "Active Bean", value: "\(bean.name) · \(bean.roaster)")
                }
            }

            Spacer().frame(height: Theme.Spacing.xs)
        }
        .gbCardStyle()
    }

    private func setupRow(icon: String, label: String, value: String) -> some View {
        HStack(spacing: Theme.Spacing.md) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundStyle(Color.gbAccent)
                .frame(width: 20)
            VStack(alignment: .leading, spacing: 1) {
                Text(label)
                    .font(Theme.Font.caption)
                    .foregroundStyle(Color.gbTextTertiary)
                Text(value)
                    .font(Theme.Font.body.weight(.medium))
                    .foregroundStyle(Color.gbTextPrimary)
            }
            Spacer()
        }
        .padding(Theme.Spacing.md)
    }

    // MARK: - Recent Shots Card

    private var recentShotsCard: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            Text("RECENT SHOTS")
                .font(Theme.Font.caption)
                .foregroundStyle(Color.gbTextTertiary)
                .kerning(1)
                .padding(.horizontal, Theme.Spacing.md)
                .padding(.top, Theme.Spacing.md)

            VStack(spacing: 0) {
                ForEach(Array(shots.prefix(3).enumerated()), id: \.element.id) { index, shot in
                    if index > 0 {
                        Divider()
                            .background(Color.gbSeparator)
                            .padding(.horizontal, Theme.Spacing.md)
                    }
                    shotRow(shot)
                }
            }

            Spacer().frame(height: Theme.Spacing.xs)
        }
        .gbCardStyle()
    }

    private func shotRow(_ shot: ShotPull) -> some View {
        HStack(spacing: Theme.Spacing.sm) {
            VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                HStack(spacing: Theme.Spacing.xs) {
                    Text(String(format: "%.1fg → %.1fg", shot.doseGrams, shot.yieldGrams))
                        .font(Theme.Font.data)
                        .foregroundStyle(Color.gbTextPrimary)
                    Text("·")
                        .foregroundStyle(Color.gbTextTertiary)
                    Text("\(shot.timeSeconds)s")
                        .font(Theme.Font.data)
                        .foregroundStyle(Color.gbTextSecondary)
                }
                if let rating = shot.rating {
                    RatingPips(rating: rating)
                }
            }
            Spacer()
            if let date = shot.createdDate {
                Text(date, style: .relative)
                    .font(Theme.Font.caption)
                    .foregroundStyle(Color.gbTextTertiary)
            }
        }
        .padding(Theme.Spacing.md)
    }

    // MARK: - Settings Card

    private var settingsCard: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            Text("SETTINGS")
                .font(Theme.Font.caption)
                .foregroundStyle(Color.gbTextTertiary)
                .kerning(1)
                .padding(.horizontal, Theme.Spacing.md)
                .padding(.top, Theme.Spacing.md)

            VStack(spacing: 0) {
                settingsRow(icon: "bell", label: "Notifications")
                Divider()
                    .background(Color.gbSeparator)
                    .padding(.leading, Theme.Spacing.md + 28)
                settingsRow(icon: "lock.shield", label: "Privacy")
                Divider()
                    .background(Color.gbSeparator)
                    .padding(.leading, Theme.Spacing.md + 28)
                settingsRow(icon: "questionmark.circle", label: "Help & Feedback")
            }

            Spacer().frame(height: Theme.Spacing.xs)
        }
        .gbCardStyle()
    }

    private func settingsRow(icon: String, label: String) -> some View {
        HStack(spacing: Theme.Spacing.md) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundStyle(Color.gbTextSecondary)
                .frame(width: 20)
            Text(label)
                .font(Theme.Font.body)
                .foregroundStyle(Color.gbTextPrimary)
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(Color.gbTextTertiary)
        }
        .padding(Theme.Spacing.md)
    }

    // MARK: - Sign Out

    private var signOutButton: some View {
        Button("Sign Out") {
            Task { await authManager.signOut() }
        }
        .font(Theme.Font.body.weight(.medium))
        .foregroundStyle(Color.red)
        .frame(maxWidth: .infinity)
        .padding(.vertical, Theme.Spacing.md)
        .background(Color.red.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.md))
        .overlay(
            RoundedRectangle(cornerRadius: Theme.Radius.md)
                .strokeBorder(Color.red.opacity(0.5), lineWidth: 1)
        )
    }
}

// MARK: - Rating Pips

struct RatingPips: View {
    let rating: Int
    var body: some View {
        HStack(spacing: 2) {
            ForEach(1...10, id: \.self) { pip in
                RoundedRectangle(cornerRadius: 1)
                    .fill(pip <= rating ? Color.gbAccent : Color.gbSeparator)
                    .frame(width: 3, height: 8)
            }
        }
    }
}

#Preview {
    ProfilePage()
        .environment(AuthenticationManager())
}
