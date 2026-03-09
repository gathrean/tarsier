import SwiftUI
import SwiftData

struct SettingsView: View {
    @Query private var profiles: [UserProfile]
    @Environment(\.modelContext) private var modelContext
    @State private var showResetConfirmation = false
    @State private var showSkillLevelChange = false
    @State private var newSkillLevel: SkillLevel?

    private var profile: UserProfile? { profiles.first }

    var body: some View {
        List {
            Section("Learning") {
                if let profile {
                    HStack {
                        Text("Skill Level")
                        Spacer()
                        Text(profile.skillLevel.displayName)
                            .foregroundStyle(TarsierColors.textSecondary)
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        showSkillLevelChange = true
                    }
                }
            }

            Section("Subscription") {
                Button("Manage Subscription") {
                    // TODO: Open RevenueCat management
                }
            }

            Section("Data") {
                Button("Reset Progress", role: .destructive) {
                    showResetConfirmation = true
                }
            }

            Section("About") {
                HStack {
                    Text("Version")
                    Spacer()
                    Text("0.1.0")
                        .foregroundStyle(TarsierColors.textSecondary)
                }

                Link("Privacy Policy", destination: URL(string: "https://tarsierapp.com/privacy")!)

                Link("Feedback", destination: URL(string: "mailto:hello@tarsierapp.com")!)
            }
        }
        .navigationTitle("Settings")
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
                    newSkillLevel = level
                    changeSkillLevel(to: level)
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Changing your skill level will reset your lesson progress.")
        }
    }

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
