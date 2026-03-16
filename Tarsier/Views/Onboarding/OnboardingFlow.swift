import SwiftUI
import SwiftData

/// 18-screen Bunso onboarding flow (v0.3).
/// Manages screen progression with manual index — no NavigationStack, no back-swipe.
struct OnboardingFlow: View {
    @Environment(\.modelContext) private var modelContext

    // Screen index (0–17, mapping to 18 screens)
    @State private var currentScreen = 0

    // Collected data
    @State private var userName: String = ""
    @State private var preferredTitle: String? = nil
    @State private var selectedLanguage: String = ""
    @State private var attributionSource: String = ""
    @State private var proficiencyLevel: Int = -1       // -1 = no selection
    @State private var selectedMotivations: Set<String> = []
    @State private var dailyGoalMinutes: Int = 0        // 0 = no selection

    // Guards against double-advance on auto-advance screens
    @State private var autoAdvanceFired = false

    // Transition direction
    @State private var isGoingForward = true

    private let totalScreens = 17 // last index

    /// Screens where the back button should be hidden
    private var hideBackButton: Bool {
        // Splash (0,1), auto-advance responses (5, 7, 9), loading (17)
        [0, 1, 5, 7, 9, 17].contains(currentScreen)
    }

    /// Screens where the progress bar should be hidden
    private var hideProgressBar: Bool {
        [0, 1, 17].contains(currentScreen)
    }

    /// Screens where the floating Continue button should be hidden
    private var hideFloatingButton: Bool {
        // Auto-advance responses (5, 7, 9), subscription gate (16, has own buttons), loading (17)
        [5, 7, 9, 16, 17].contains(currentScreen)
    }

    /// Whether the Continue button should be disabled
    private var isButtonDisabled: Bool {
        switch currentScreen {
        case 2: selectedLanguage.isEmpty
        case 3: attributionSource.isEmpty
        case 4: proficiencyLevel < 0
        case 6: userName.trimmingCharacters(in: .whitespaces).isEmpty
        case 8: selectedMotivations.isEmpty
        case 11: dailyGoalMinutes == 0
        default: false
        }
    }

    /// Label for the floating Continue button
    private var buttonLabel: String {
        switch currentScreen {
        case 0: "Get Started"
        case 15: "Okay! You can add my widget any time."
        default: "Continue"
        }
    }

    /// Personalised name greeting for screen 7
    private var nameGreeting: String {
        let name = userName.trimmingCharacters(in: .whitespaces)
        if let title = preferredTitle, !title.isEmpty {
            return "It's nice to get to know you, \(title) \(name)!"
        }
        return "It's nice to get to know you, \(name)!"
    }

    var body: some View {
        ZStack {
            TarsierColors.warmWhite.ignoresSafeArea()

            VStack(spacing: 0) {
                // Top bar: back button + progress bar
                if !hideProgressBar {
                    HStack(spacing: 12) {
                        if !hideBackButton {
                            Button {
                                goBack()
                            } label: {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundStyle(TarsierColors.textSecondary)
                            }
                        }

                        ProgressBarView(current: currentScreen, total: totalScreens)
                    }
                    .padding(.horizontal, TarsierSpacing.screenPadding)
                    .padding(.top, 8)
                    .padding(.bottom, 4)
                }

                // Animated screen content
                screenContent
                    .id(currentScreen)
                    .transition(.asymmetric(
                        insertion: .move(edge: isGoingForward ? .trailing : .leading).combined(with: .opacity),
                        removal: .move(edge: isGoingForward ? .leading : .trailing).combined(with: .opacity)
                    ))

                // Floating Continue button (not animated with screen transitions)
                if !hideFloatingButton {
                    PrimaryButton(buttonLabel) {
                        advance()
                    }
                    .disabled(isButtonDisabled)
                    .opacity(isButtonDisabled ? 0.5 : 1)
                    .padding(.horizontal, TarsierSpacing.screenPadding)
                    .padding(.bottom, 48)
                    .animation(.none, value: currentScreen)
                }
            }
        }
        .animation(.easeInOut(duration: 0.35), value: currentScreen)
    }

    @ViewBuilder
    private var screenContent: some View {
        switch currentScreen {
        case 0: // Splash
            SplashIntroScreen(screenIndex: 0) { advance() }
        case 1: // Quick questions intro
            SplashIntroScreen(screenIndex: 1) { advance() }
        case 2: // Language picker
            LanguagePickerScreen(selectedLanguage: $selectedLanguage) { advance() }
        case 3: // Attribution
            AttributionScreen(attributionSource: $attributionSource) { advance() }
        case 4: // Proficiency picker
            ProficiencyScreen(screenIndex: 0, proficiencyLevel: $proficiencyLevel) { advance() }
        case 5: // Proficiency response (auto-advance)
            ProficiencyScreen(screenIndex: 1, proficiencyLevel: $proficiencyLevel) { advanceOnce() }
        case 6: // Name + title
            NameTitleScreen(userName: $userName, preferredTitle: $preferredTitle) { advance() }
        case 7: // Name greeting (auto-advance)
            nameGreetingView
        case 8: // Motivation picker
            MotivationScreen(screenIndex: 0, selectedMotivations: $selectedMotivations) { advance() }
        case 9: // Motivation response (auto-advance)
            MotivationScreen(screenIndex: 1, selectedMotivations: $selectedMotivations) { advanceOnce() }
        case 10: // Daily goal intro
            DailyGoalScreen(screenIndex: 0, dailyGoalMinutes: $dailyGoalMinutes) { advance() }
        case 11: // Daily goal picker
            DailyGoalScreen(screenIndex: 1, dailyGoalMinutes: $dailyGoalMinutes) { advance() }
        case 12: // Goal confirmation
            DailyGoalScreen(screenIndex: 2, dailyGoalMinutes: $dailyGoalMinutes) { advance() }
        case 13: // Three-month vision
            VisionScreen { advance() }
        case 14: // Notification pitch
            OnboardingNotificationScreen { advance() }
        case 15: // Widget pitch
            WidgetScreen { advance() }
        case 16: // Subscription gate
            SubscriptionGateScreen { advance() }
        case 17: // Loading
            LoadingScreen(profile: createProfile()) {
                // Profile is saved by LoadingScreen; ContentView will re-route
            }
        default:
            EmptyView()
        }
    }

    // MARK: - Name Greeting Screen

    private var nameGreetingView: some View {
        VStack(spacing: 32) {
            Spacer()

            BunsoView(pose: .celebrating, size: 120)

            Text(nameGreeting)
                .font(TarsierFonts.heading(20))
                .foregroundStyle(TarsierColors.textPrimary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            Spacer()
        }
        .contentShape(Rectangle())
        .onTapGesture { advanceOnce() }
        .onAppear {
            autoAdvanceFired = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                advanceOnce()
            }
        }
    }

    // MARK: - Navigation

    private func advance() {
        autoAdvanceFired = false
        isGoingForward = true
        withAnimation {
            currentScreen += 1
        }
    }

    private func goBack() {
        guard currentScreen > 0 else { return }
        isGoingForward = false
        withAnimation {
            currentScreen -= 1
        }
    }

    /// For auto-advance screens — prevents double-fire from both timer and tap
    private func advanceOnce() {
        guard !autoAdvanceFired else { return }
        autoAdvanceFired = true
        advance()
    }

    /// Creates and inserts UserProfile from collected onboarding data.
    private func createProfile() -> UserProfile {
        let resolvedGoal = dailyGoalMinutes > 0 ? dailyGoalMinutes : 10
        let profile = UserProfile(
            skillLevel: proficiencyToSkillLevel(),
            motivations: Array(selectedMotivations),
            dailyGoalMinutes: resolvedGoal
        )
        let trimmedName = userName.trimmingCharacters(in: .whitespaces)
        profile.userName = trimmedName.isEmpty ? nil : trimmedName
        profile.preferredTitle = preferredTitle
        profile.selectedLanguage = selectedLanguage
        profile.attributionSource = attributionSource
        profile.proficiencyLevel = max(proficiencyLevel, 0)

        modelContext.insert(profile)
        return profile
    }

    /// Maps the 0–4 proficiency scale to existing SkillLevel enum
    private func proficiencyToSkillLevel() -> SkillLevel {
        switch proficiencyLevel {
        case 0: .beginner
        case 1, 2: .intermediate
        default: .heritage
        }
    }
}
