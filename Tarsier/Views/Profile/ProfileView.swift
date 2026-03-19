import SwiftUI
import SwiftData

struct ProfileView: View {
    @Query private var profiles: [UserProfile]
    @Query(sort: \WordBankEntry.word) private var words: [WordBankEntry]
    @Environment(\.modelContext) private var modelContext
    @State private var showResetConfirmation = false
    @State private var showSkillLevelChange = false
    @State private var showNameEdit = false
    @State private var editingName: String = ""
    @AppStorage("notificationsEnabled") private var notificationsEnabled = true
    @AppStorage("soundEnabled") private var soundEnabled = true

    private var profile: UserProfile? { profiles.first }

    var body: some View {
        ZStack(alignment: .top) {
            ScrollView {
                VStack(spacing: TarsierSpacing.sectionSpacing) {
                    // Spacer for gradient header
                    Color.clear.frame(height: 24)

                    // Header: Bunso + greeting
                    headerSection

                    // Stats cards
                    statsCards

                    // Activity & Streak
                    activitySection

                    // Settings sections
                    settingsSection
                }
                .padding(.horizontal, TarsierSpacing.screenPadding)
                .padding(.bottom, 100) // Extra bottom clearance for tab bar
            }

            // Purple gradient header
            VStack(spacing: 0) {
                Text("Profile")
                    .font(TarsierFonts.heading(22))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, 12)
            }
            .allowsHitTesting(false)
            .background(
                LinearGradient(
                    colors: [Color(hex: "#5B48E0"), Color(hex: "#5B48E0").opacity(0)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .padding(.top, -200)
                .padding(.bottom, -40)
            )
        }
        .background(TarsierColors.warmWhite)
        .toolbar(.hidden, for: .navigationBar)
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
        .alert("Edit Name", isPresented: $showNameEdit) {
            TextField("Your name", text: $editingName)
            Button("Save") {
                profile?.userName = editingName.trimmingCharacters(in: .whitespaces).isEmpty ? nil : editingName.trimmingCharacters(in: .whitespaces)
            }
            Button("Cancel", role: .cancel) {}
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        HStack(spacing: 14) {
            BunsoView(pose: .waving, size: 60)

            VStack(alignment: .leading, spacing: 4) {
                if let profile {
                    Text(GreetingHelper.greeting(for: profile))
                        .font(TarsierFonts.heading(18))
                        .foregroundStyle(TarsierColors.textPrimary)
                }

                HStack(spacing: 6) {
                    Image("philippine-flag")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 16, height: 16)
                        .clipShape(Circle())
                    Text("Learning Tagalog")
                        .font(TarsierFonts.caption())
                        .foregroundStyle(TarsierColors.textSecondary)
                }
            }

            Spacer()
        }
        .padding(.top, 8)
    }

    // MARK: - Stats Cards

    private var statsCards: some View {
        HStack(spacing: 12) {
            statCard(
                icon: "flame.fill",
                value: "\(profile?.currentStreak ?? 0)",
                label: "Streak",
                color: TarsierColors.gold
            )
            statCard(
                icon: "hexagon.fill",
                value: "\(profile?.totalXP ?? 0)",
                label: "XP",
                color: Color(hex: "#38BDF8")
            )
            statCard(
                icon: "textformat.abc",
                value: "\(words.count)",
                label: "Words",
                color: TarsierColors.correctGreen
            )
        }
    }

    private func statCard(icon: String, value: String, label: String, color: Color) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(color)
            Text(value)
                .font(TarsierFonts.heading(22))
                .foregroundStyle(TarsierColors.textPrimary)
            Text(label)
                .font(TarsierFonts.caption(11))
                .foregroundStyle(TarsierColors.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(.white)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(TarsierColors.cardBorder, lineWidth: 1)
        )
    }

    // MARK: - Activity

    private var activitySection: some View {
        VStack(spacing: 12) {
            WeeklyActivityChart()
            StreakCalendarView()
        }
    }

    // MARK: - Settings

    private var settingsSection: some View {
        VStack(spacing: 16) {
            // Profile settings
            settingsGroup(title: "Profile") {
                settingsRow(label: "Name", value: profile?.userName ?? "Add name", highlight: profile?.userName == nil) {
                    editingName = profile?.userName ?? ""
                    showNameEdit = true
                }
                Divider()
                settingsRow(label: "Skill Level", value: profile?.skillLevel.displayName ?? "—") {
                    showSkillLevelChange = true
                }
            }

            // Preferences
            settingsGroup(title: "Preferences") {
                Toggle(isOn: $notificationsEnabled) {
                    Text("Notifications")
                        .font(TarsierFonts.body())
                }
                .tint(TarsierColors.functionalPurple)
                Divider()
                Toggle(isOn: $soundEnabled) {
                    Text("Sound Effects")
                        .font(TarsierFonts.body())
                }
                .tint(TarsierColors.functionalPurple)
            }

            // About
            settingsGroup(title: "About") {
                HStack {
                    Text("Version")
                        .font(TarsierFonts.body())
                    Spacer()
                    Text("0.1.1")
                        .font(TarsierFonts.body())
                        .foregroundStyle(TarsierColors.textSecondary)
                }
                Divider()
                Link(destination: URL(string: "https://tarsierapp.com/privacy")!) {
                    HStack {
                        Text("Privacy Policy")
                            .font(TarsierFonts.body())
                            .foregroundStyle(TarsierColors.textPrimary)
                        Spacer()
                        Image(systemName: "arrow.up.right")
                            .font(.system(size: 12))
                            .foregroundStyle(TarsierColors.textSecondary)
                    }
                }
                Divider()
                Link(destination: URL(string: "mailto:hello@tarsierapp.com")!) {
                    HStack {
                        Text("Feedback")
                            .font(TarsierFonts.body())
                            .foregroundStyle(TarsierColors.textPrimary)
                        Spacer()
                        Image(systemName: "arrow.up.right")
                            .font(.system(size: 12))
                            .foregroundStyle(TarsierColors.textSecondary)
                    }
                }
                Divider()
                NavigationLink {
                    PhotoCreditsView()
                } label: {
                    HStack {
                        Text("Photo Credits")
                            .font(TarsierFonts.body())
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(TarsierColors.textSecondary)
                    }
                }
            }

            // Data
            settingsGroup(title: "Data") {
                Button(role: .destructive) {
                    showResetConfirmation = true
                } label: {
                    Text("Reset Progress")
                        .font(TarsierFonts.body())
                        .foregroundStyle(TarsierColors.alertRed)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
    }

    // MARK: - Settings Helpers

    private func settingsGroup(title: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .font(TarsierFonts.caption())
                .foregroundStyle(TarsierColors.textSecondary)
                .textCase(.uppercase)
                .padding(.bottom, 8)
                .padding(.leading, 4)

            VStack(spacing: 0) {
                content()
            }
            .padding(TarsierSpacing.cardPadding)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(.white)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(TarsierColors.cardBorder, lineWidth: 1)
            )
        }
    }

    private func settingsRow(label: String, value: String, highlight: Bool = false, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Text(label)
                    .font(TarsierFonts.body())
                    .foregroundStyle(TarsierColors.textPrimary)
                Spacer()
                Text(value)
                    .font(TarsierFonts.body())
                    .foregroundStyle(highlight ? TarsierColors.functionalPurple : TarsierColors.textSecondary)
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(TarsierColors.textSecondary)
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Actions

    private func resetProgress() {
        if let profile {
            profile.completedLessonIDs = []
            profile.currentLessonIndex = 1
            profile.currentStreak = 0
            profile.lastCompletedDate = nil
            profile.hasCompletedOnboarding = false
            profile.hasSeenCoachMarks = false
            profile.seenUIWords = []
        }
    }

    private func changeSkillLevel(to level: SkillLevel) {
        if let profile {
            profile.skillLevel = level
            resetProgress()
        }
    }
}
