import SwiftUI
import SwiftData

/// 17-screen Bunso onboarding flow (v0.3.3).
/// Manages screen progression with manual index — no NavigationStack, no back-swipe.
/// Bunso + speech bubble are rendered persistently (not re-created per screen).
struct OnboardingFlow: View {
    @Environment(\.modelContext) private var modelContext

    // Screen index (0–16, mapping to 17 screens)
    @State private var currentScreen = 0

    // Collected data
    @State private var userName: String = ""
    @State private var preferredTitle: String? = nil
    @State private var selectedLanguage: String = ""
    @State private var attributionSources: Set<String> = []
    @State private var proficiencyLevel: Int = -1       // -1 = no selection
    @State private var selectedMotivations: Set<String> = []
    @State private var dailyGoalMinutes: Int = 0        // 0 = no selection

    // Guards against double-advance on auto-advance screens
    @State private var autoAdvanceFired = false

    // Transition direction
    @State private var isGoingForward = true

    // Screen 9: motivation response → routine transition (shows continue after delay)
    @State private var motivationResponseReady = false
    @State private var createdProfile: UserProfile?

    private let totalScreens = 16 // last index

    /// Screens where the back button should be hidden
    private var hideBackButton: Bool {
        // Splash (0,1), loading (16)
        [0, 1, 16].contains(currentScreen)
    }

    /// Screens where the progress bar should be hidden
    private var hideProgressBar: Bool {
        [0, 1, 16].contains(currentScreen)
    }

    /// Screens where the floating Continue button should be hidden
    private var hideFloatingButton: Bool {
        // Auto-advance responses (5, 7), screen 9 until ready, subscription gate (15), loading (16)
        if currentScreen == 9 && !motivationResponseReady { return true }
        return [5, 7, 15, 16].contains(currentScreen)
    }

    /// Whether the Continue button should be disabled
    private var isButtonDisabled: Bool {
        switch currentScreen {
        case 2: selectedLanguage.isEmpty
        case 3: attributionSources.isEmpty
        case 4: proficiencyLevel < 0
        case 6: userName.trimmingCharacters(in: .whitespaces).isEmpty
        case 8: selectedMotivations.isEmpty
        case 10: dailyGoalMinutes == 0
        default: false
        }
    }

    /// Label for the floating Continue button
    private var buttonLabel: String {
        switch currentScreen {
        case 0: "Get Started"
        case 14: "Okay! You can add my widget any time."
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

    // MARK: - Bubble Config

    /// Returns (pose, text, bunsoSize) for the current screen, or nil if no bubble.
    private var bubbleConfig: (pose: BunsoPose, text: String, size: CGFloat)? {
        switch currentScreen {
        case 0: return nil // Splash — centered BunsoView, no bubble
        case 1: return (.curious, "Just a few quick questions before we start your first lesson!", 100)
        case 2: return (.excited, "What would you like to learn?", 70)
        case 3: return (.curious, "How did you learn about Tarsier?", 70)
        case 4: return (.curious, "How much Tagalog do you know?", 70)
        case 5: // Proficiency response (dynamic)
            let (pose, text) = proficiencyResponse
            return (pose, text, 100)
        case 6: return (.waving, "What should I call you?", 70)
        case 7: return (.celebrating, nameGreeting, 100)
        case 8: // Motivation picker — bubble reacts live to selection
            if selectedMotivations.isEmpty {
                return (.heartEyes, "Why are you learning Tagalog?", 70)
            }
            let (pose, text) = motivationLiveReaction
            return (pose, text, 70)
        case 9: // Motivation response → routine transition
            if motivationResponseReady {
                return (.tappingWrist, "Let's set up a learning routine!", 100)
            }
            return (.celebrating, motivationEncouragement, 100)
        case 10: return (.tappingWrist, "What's your daily learning goal?", 70)
        case 11: // Goal confirmation (dynamic)
            let resolvedGoal = dailyGoalMinutes > 0 ? dailyGoalMinutes : 10
            let words = [5: 15, 10: 30, 15: 50, 20: 70][resolvedGoal] ?? 30
            return (.celebrating, "\(resolvedGoal) minutes a day? That's about \(words) new words in your first week!", 100)
        case 12: return (.flexing, "Here's what you can achieve in 3 months", 70)
        case 13: return (.tappingWrist, "A quick daily reminder keeps your streak alive!", 100)
        case 14: return (.celebrating, "I'll cheer you on from your home screen!", 100)
        default: return nil // Subscription (15), Loading (16)
        }
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
                    .padding(.bottom, 24)
                } else {
                    // Match the progress bar area height so content doesn't hug the top
                    Spacer().frame(height: 56)
                }

                // Persistent Bunso + speech bubble (NOT animated with screen transitions)
                if let config = bubbleConfig {
                    BunsoSpeechBubble(pose: config.pose, text: config.text, bunsoSize: config.size)
                        .animation(.easeInOut(duration: 0.3), value: currentScreen)
                        .animation(.easeInOut(duration: 0.3), value: motivationResponseReady)
                        .animation(.easeInOut(duration: 0.3), value: selectedMotivations)
                        .padding(.bottom, 16)
                }

                // Animated screen content (below bubble)
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
        case 1: // Quick questions intro (auto-advance)
            SplashIntroScreen(screenIndex: 1) { advance() }
        case 2: // Language picker
            LanguagePickerScreen(selectedLanguage: $selectedLanguage) { advance() }
        case 3: // Attribution
            AttributionScreen(attributionSources: $attributionSources) { advance() }
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
        case 9: // Motivation response → routine transition
            MotivationScreen(screenIndex: 1, selectedMotivations: $selectedMotivations, onContinue: { advance() }, onShowContinue: {
                withAnimation {
                    motivationResponseReady = true
                }
            })
        case 10: // Daily goal picker
            DailyGoalScreen(screenIndex: 1, dailyGoalMinutes: $dailyGoalMinutes) { advance() }
        case 11: // Goal confirmation
            DailyGoalScreen(screenIndex: 2, dailyGoalMinutes: $dailyGoalMinutes) { advance() }
        case 12: // Three-month vision
            VisionScreen { advance() }
        case 13: // Notification pitch
            OnboardingNotificationScreen { advance() }
        case 14: // Widget pitch
            WidgetScreen { advance() }
        case 15: // Subscription gate
            SubscriptionGateScreen { advance() }
        case 16: // Loading
            if let profile = createdProfile {
                LoadingScreen(profile: profile) {
                    modelContext.insert(profile)
                    try? modelContext.save()
                }
            }
        default:
            EmptyView()
        }
    }

    // MARK: - Name Greeting Screen

    private var nameGreetingView: some View {
        VStack(spacing: 32) {
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

    // MARK: - Dynamic Response Helpers

    private var proficiencyResponse: (BunsoPose, String) {
        switch proficiencyLevel {
        case 0: (.thumbsUp, "No worries, we'll start from the very beginning!")
        case 1, 2: (.excited, "Okay, we'll build on what you know!")
        default: (.flexing, "Nice! Let's sharpen those skills.")
        }
    }

    /// Live reaction on screen 8 as user taps motivations
    private var motivationLiveReaction: (BunsoPose, String) {
        if selectedMotivations.contains("Connect with my family better") {
            return (.heartEyes, "Family is everything. I love that!")
        }
        if selectedMotivations.contains("Impress my partner") {
            return (.blushing, "Kilig! They'll love this.")
        }
        if selectedMotivations.contains("Just for fun") {
            return (.excited, "The best way to learn!")
        }
        if selectedMotivations.contains("Prepare for travel") {
            return (.excited, "The Philippines is beautiful!")
        }
        if selectedMotivations.contains("Connect with people who speak Tagalog") {
            return (.waving, "Filipinos are the friendliest!")
        }
        if selectedMotivations.contains("Understand Filipino media/music") {
            return (.celebrating, "OPM hits different when you understand the lyrics!")
        }
        if selectedMotivations.contains("For my career") {
            return (.flexing, "That's a smart move!")
        }
        if selectedMotivations.contains("Other") {
            return (.curious, "I like the mystery!")
        }
        return (.thumbsUp, "Great choice!")
    }

    /// Encouragement shown on screen 9 (response slide)
    private var motivationEncouragement: String {
        if selectedMotivations == ["Other"] {
            return "I like the mystery! Let's get you speaking Tagalog."
        }
        if selectedMotivations.count == 1 {
            return "That's a great reason! Let's make it happen."
        }
        return "Those are great reasons! Let's make it happen."
    }

    // MARK: - Navigation

    private func advance(playSound: Bool = true) {
        autoAdvanceFired = false
        motivationResponseReady = false
        isGoingForward = true
        if playSound {
            UIImpactFeedbackGenerator(style: .soft).impactOccurred()
        }
        // Pre-create profile before entering loading screen to avoid
        // modifying @State during body evaluation.
        if currentScreen + 1 == 16, createdProfile == nil {
            createdProfile = createProfile()
        }
        withAnimation {
            currentScreen += 1
        }
    }

    private func goBack() {
        guard currentScreen > 0 else { return }
        motivationResponseReady = false
        isGoingForward = false
        withAnimation {
            currentScreen -= 1
        }
    }

    /// For auto-advance screens — prevents double-fire from both timer and tap.
    /// No sound on auto-advance (screens 5, 7).
    private func advanceOnce() {
        guard !autoAdvanceFired else { return }
        autoAdvanceFired = true
        advance(playSound: false)
    }

    /// Creates UserProfile from collected onboarding data (does NOT insert yet).
    /// Insertion happens when the loading screen completes, so @Query in ContentView
    /// doesn't prematurely route away from OnboardingFlow.
    private func createProfile() -> UserProfile {
        let resolvedGoal = dailyGoalMinutes > 0 ? dailyGoalMinutes : 10
        let profile = UserProfile(
            skillLevel: proficiencyToSkillLevel(),
            motivations: Array(selectedMotivations),
            dailyGoalMinutes: resolvedGoal
        )
        let trimmedName = userName.trimmingCharacters(in: .whitespaces)
        profile.userName = trimmedName.isEmpty ? nil : trimmedName
        profile.preferredTitle = (preferredTitle?.isEmpty == false) ? preferredTitle : nil
        profile.selectedLanguage = selectedLanguage
        profile.attributionSource = attributionSources.joined(separator: ", ")
        profile.proficiencyLevel = max(proficiencyLevel, 0)

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
