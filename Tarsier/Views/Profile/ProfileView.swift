import SwiftUI
import SwiftData

struct ProfileView: View {
    @Query private var profiles: [UserProfile]
    @Environment(\.modelContext) private var modelContext
    @State private var showResetConfirmation = false
    @State private var showSkillLevelChange = false

    private var profile: UserProfile? { profiles.first }

    var body: some View {
        List {
            // MARK: - Stats
            Section {
                statsGrid
            }
            .listRowBackground(TarsierColors.cream)

            // MARK: - Profile
            Section("Profile") {
                if let profile {
                    HStack {
                        Text("Skill Level")
                            .font(TarsierFonts.body())
                        Spacer()
                        Text(profile.skillLevel.displayName)
                            .font(TarsierFonts.body())
                            .foregroundStyle(TarsierColors.textSecondary)
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        showSkillLevelChange = true
                    }
                }
            }

            // MARK: - Preferences
            Section("Preferences") {
                // Placeholder for notifications/sound toggles
                Text("Notifications")
                    .font(TarsierFonts.body())
                    .foregroundStyle(TarsierColors.textSecondary)
                Text("Sound")
                    .font(TarsierFonts.body())
                    .foregroundStyle(TarsierColors.textSecondary)
            }

            // MARK: - Subscription
            Section("Subscription") {
                Button("Manage Subscription") {
                    // TODO: Open RevenueCat management
                }
                .font(TarsierFonts.body())
            }

            // MARK: - Data
            Section("Data") {
                Button("Reset Progress", role: .destructive) {
                    showResetConfirmation = true
                }
                .font(TarsierFonts.body())
            }

            // MARK: - About
            Section("About") {
                HStack {
                    Text("Version")
                        .font(TarsierFonts.body())
                    Spacer()
                    Text("0.1.1")
                        .font(TarsierFonts.body())
                        .foregroundStyle(TarsierColors.textSecondary)
                }

                Link("Privacy Policy", destination: URL(string: "https://tarsierapp.com/privacy")!)
                    .font(TarsierFonts.body())

                Link("Feedback", destination: URL(string: "mailto:hello@tarsierapp.com")!)
                    .font(TarsierFonts.body())
            }
        }
        .scrollContentBackground(.hidden)
        .background(TarsierColors.warmWhite)
        .navigationTitle("Profile")
        .alert("Reset Progress?", isPresented: $showResetConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Reset", role: .destructive) {
                resetProgress()
            }
        } message: {
            Text("This will clear all lesson progress and streak data. This cannot be undone.")
        }
        .confirmationDialog("Change Skill Level", isPresented: $showSkillLevelChange, titleVisibility: .visible) {
            ForEach(SkillLevel.allCases, id: \.self) { level in
                Button(level.displayName) {
                    changeSkillLevel(to: level)
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Changing your skill level will reset your lesson progress.")
        }
    }

    // MARK: - Stats Grid

    private var statsGrid: some View {
        HStack(spacing: 0) {
            statItem(
                icon: "flame.fill",
                value: "\(profile?.currentStreak ?? 0)",
                label: "Streak",
                color: TarsierColors.gold
            )
            statItem(
                icon: "star.fill",
                value: "\(profile?.totalXP ?? 0)",
                label: "XP",
                color: TarsierColors.functionalPurple
            )
            statItem(
                icon: "book.closed.fill",
                value: "\(profile?.completedLessonIDs.count ?? 0)",
                label: "Lessons",
                color: TarsierColors.correctGreen
            )
        }
    }

    private func statItem(icon: String, value: String, label: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(color)
            Text(value)
                .font(TarsierFonts.heading())
                .foregroundStyle(TarsierColors.textPrimary)
            Text(label)
                .font(TarsierFonts.caption())
                .foregroundStyle(TarsierColors.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Actions

    private func resetProgress() {
        if let profile {
            profile.completedLessonIDs = []
            profile.currentLessonIndex = 1
            profile.currentStreak = 0
            profile.lastCompletedDate = nil
        }
    }

    private func changeSkillLevel(to level: SkillLevel) {
        if let profile {
            profile.skillLevel = level
            resetProgress()
        }
    }
}
