import SwiftUI

// MARK: - ProfilePage
struct ProfilePage: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Theme.Spacing.lg) {
                    profileHeroCard
                    equipmentCard
                    settingsCard
                    signOutButton
                }
                .padding(Theme.Spacing.md)
            }
            .background(Color.gbBackground)
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    // MARK: - Profile Hero Card
    private var profileHeroCard: some View {
        VStack(spacing: Theme.Spacing.md) {
            // Avatar
            Circle()
                .fill(Color.gbAccent.opacity(0.15))
                .frame(width: 72, height: 72)
                .overlay(
                    Text("TN")
                        .font(Theme.Font.title)
                        .foregroundStyle(Color.gbAccent)
                )

            VStack(spacing: Theme.Spacing.xs) {
                Text("test_nerd")
                    .font(Theme.Font.headline)
                    .foregroundStyle(Color.gbTextPrimary)
                Text("Member since Feb 2026")
                    .font(Theme.Font.caption)
                    .foregroundStyle(Color.gbTextTertiary)
            }

            // Stats row
            HStack(spacing: 0) {
                statItem(value: "3", label: "Shots")
                Rectangle()
                    .fill(Color.gbSeparator)
                    .frame(width: 1, height: 28)
                statItem(value: "2", label: "Beans")
                Rectangle()
                    .fill(Color.gbSeparator)
                    .frame(width: 1, height: 28)
                statItem(value: "0", label: "Public")
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

    // MARK: - Equipment Card
    private var equipmentCard: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            Text("EQUIPMENT")
                .font(Theme.Font.caption)
                .foregroundStyle(Color.gbTextTertiary)
                .kerning(1)
                .padding(.horizontal, Theme.Spacing.md)
                .padding(.top, Theme.Spacing.md)

            VStack(spacing: 0) {
                equipRow(icon: "dial.medium", label: "Grinder", value: "Niche Zero")
                Divider()
                    .background(Color.gbSeparator)
                    .padding(.leading, Theme.Spacing.md + 28)
                equipRow(icon: "cup.and.saucer", label: "Machine", value: "Decent DE1")
                Divider()
                    .background(Color.gbSeparator)
                    .padding(.leading, Theme.Spacing.md + 28)
                equipRow(icon: "circle.grid.3x3", label: "Tamper", value: "Normcore V4")
            }

            Spacer().frame(height: Theme.Spacing.xs)
        }
        .gbCardStyle()
    }

    private func equipRow(icon: String, label: String, value: String) -> some View {
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
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(Color.gbTextTertiary)
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
        Button("Sign Out") {}
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

#Preview {
    ProfilePage()
}
