import SwiftUI
import SwiftData

struct OnboardingFlow: View {
    @Environment(\.modelContext) private var modelContext
    @FocusState private var nameFieldFocused: Bool

    @State private var currentPage = 0
    @State private var selectedSkillLevel: SkillLevel?
    @State private var selectedMotivations: Set<String> = []
    @State private var userName: String = ""
    @State private var dailyGoalMinutes: Int = 10
    @State private var showHookButton = false

    private let motivations = [
        "Connect with family",
        "Cultural pride",
        "Travel to the Philippines",
        "Partner/relationship",
        "Just curious"
    ]

    var body: some View {
        VStack(spacing: 0) {
            // Progress dots (hidden on welcome page)
            if currentPage > 0 {
                OnboardingProgressDots(currentPage: currentPage)
                    .padding(.top, 8)
                    .transition(.opacity)
            }

            TabView(selection: $currentPage) {
                welcomePage.tag(0)
                namePage.tag(1)
                skillLevelPage.tag(2)
                motivationPage.tag(3)
                emotionalHookPage.tag(4)
                dailyGoalPage.tag(5)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.easeInOut, value: currentPage)
        }
        .background(TarsierColors.warmWhite.ignoresSafeArea())
    }

    // MARK: - Welcome Page (0)

    private var welcomePage: some View {
        VStack(spacing: 32) {
            Spacer()

            Image(systemName: "eyes")
                .font(.system(size: 80))
                .foregroundStyle(TarsierColors.tarsierDark)

            VStack(spacing: 8) {
                Text("Tarsier")
                    .font(TarsierFonts.title(36))
                    .foregroundStyle(TarsierColors.functionalPurple)

                Text("Learn Tagalog")
                    .font(TarsierFonts.heading(18))
                    .foregroundStyle(TarsierColors.textSecondary)
            }

            Spacer()

            PrimaryButton("Get Started") {
                withAnimation { currentPage = 1 }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 48)
        }
    }

    // MARK: - Name Page (1)

    private var namePage: some View {
        VStack(spacing: 24) {
            Spacer()

            Text("What should we call you?")
                .font(TarsierFonts.title())
                .multilineTextAlignment(.center)

            TextField("Your first name", text: $userName)
                .font(TarsierFonts.body(18))
                .multilineTextAlignment(.center)
                .padding(TarsierSpacing.cardPadding)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(TarsierColors.cream)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(TarsierColors.cardBorder, lineWidth: 1.5)
                )
                .padding(.horizontal, 32)
                .textInputAutocapitalization(.words)
                .autocorrectionDisabled()
                .focused($nameFieldFocused)

            Spacer()

            VStack(spacing: 12) {
                PrimaryButton("Continue") {
                    nameFieldFocused = false
                    withAnimation { currentPage = 2 }
                }
                .disabled(userName.trimmingCharacters(in: .whitespaces).isEmpty)

                Button {
                    userName = ""
                    nameFieldFocused = false
                    withAnimation { currentPage = 2 }
                } label: {
                    Text("Skip")
                        .font(TarsierFonts.caption())
                        .foregroundStyle(TarsierColors.textSecondary)
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 48)
        }
    }

    // MARK: - Skill Level Page (2)

    private var skillLevelPage: some View {
        VStack(spacing: 24) {
            Spacer()

            Text("What's your level?")
                .font(TarsierFonts.title())

            VStack(spacing: 12) {
                ForEach(SkillLevel.allCases, id: \.self) { level in
                    Button {
                        selectedSkillLevel = level
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(level.displayName)
                                    .font(TarsierFonts.heading(17))
                                Text(level.description)
                                    .font(TarsierFonts.caption())
                                    .foregroundStyle(TarsierColors.textSecondary)
                            }
                            Spacer()
                            if selectedSkillLevel == level {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(TarsierColors.functionalPurple)
                            }
                        }
                        .padding(TarsierSpacing.cardPadding)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(selectedSkillLevel == level ? TarsierColors.primaryLight : .white)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(selectedSkillLevel == level ? TarsierColors.functionalPurple : TarsierColors.cardBorder, lineWidth: selectedSkillLevel == level ? 2 : 1.5)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 24)

            Spacer()

            PrimaryButton("Continue") {
                withAnimation { currentPage = 3 }
            }
            .disabled(selectedSkillLevel == nil)
            .padding(.horizontal, 24)
            .padding(.bottom, 48)
        }
    }

    // MARK: - Motivation Page (3)

    private var motivationPage: some View {
        VStack(spacing: 24) {
            Spacer()

            Text("Why are you learning Tagalog?")
                .font(TarsierFonts.title())
                .multilineTextAlignment(.center)

            Text("Pick all that apply (optional)")
                .font(TarsierFonts.body(15))
                .foregroundStyle(TarsierColors.textSecondary)

            VStack(spacing: 10) {
                ForEach(motivations, id: \.self) { motivation in
                    Button {
                        if selectedMotivations.contains(motivation) {
                            selectedMotivations.remove(motivation)
                        } else {
                            selectedMotivations.insert(motivation)
                        }
                    } label: {
                        HStack {
                            Text(motivation)
                                .font(TarsierFonts.body())
                            Spacer()
                            if selectedMotivations.contains(motivation) {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(TarsierColors.functionalPurple)
                            }
                        }
                        .padding(TarsierSpacing.cardPadding)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(selectedMotivations.contains(motivation) ? TarsierColors.primaryLight : .white)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(selectedMotivations.contains(motivation) ? TarsierColors.functionalPurple : TarsierColors.cardBorder, lineWidth: selectedMotivations.contains(motivation) ? 2 : 1.5)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 24)

            Spacer()

            PrimaryButton("Continue") {
                showHookButton = false
                withAnimation { currentPage = 4 }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 48)
        }
    }

    // MARK: - Emotional Hook Page (4)

    private var emotionalHookPage: some View {
        let hook = resolveHook()

        return VStack(spacing: 24) {
            Spacer()

            VStack(spacing: 16) {
                Text(hook.stat)
                    .font(TarsierFonts.heading(18))
                    .foregroundStyle(TarsierColors.textPrimary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)

                Text(hook.message)
                    .font(TarsierFonts.body())
                    .foregroundStyle(TarsierColors.textSecondary)
                    .multilineTextAlignment(.center)
            }

            Spacer()

            Image(systemName: "eyes")
                .font(.system(size: 48))
                .foregroundStyle(TarsierColors.tarsierDark)
                .padding(.bottom, 16)

            if showHookButton {
                VStack(spacing: 8) {
                    TappableTagalogWord(
                        word: "Tara!",
                        translation: "Let's go!",
                        font: TarsierFonts.title(28),
                        color: TarsierColors.functionalPurple
                    )

                    PrimaryButton("Continue") {
                        withAnimation { currentPage = 5 }
                    }
                    .padding(.horizontal, TarsierSpacing.screenPadding)
                }
                .transition(.opacity.combined(with: .move(edge: .bottom)))
            }

            // Invisible spacer to maintain layout when button is hidden
            if !showHookButton {
                Color.clear.frame(height: 52)
            }

            Spacer()
                .frame(height: 48)
        }
        .onAppear {
            showHookButton = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                withAnimation(.easeOut(duration: 0.3)) {
                    showHookButton = true
                }
            }
        }
    }

    // MARK: - Daily Goal Page (5)

    private var dailyGoalPage: some View {
        let goals: [(minutes: Int, title: String, subtitle: String)] = [
            (5, "Casual", "A few minutes a day"),
            (10, "Regular", "Steady progress"),
            (15, "Serious", "Real commitment")
        ]

        return VStack(spacing: 24) {
            Spacer()

            Text("How much time per day?")
                .font(TarsierFonts.title())
                .multilineTextAlignment(.center)

            VStack(spacing: 12) {
                ForEach(goals, id: \.minutes) { goal in
                    Button {
                        dailyGoalMinutes = goal.minutes
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("\(goal.minutes) min — \(goal.title)")
                                    .font(TarsierFonts.heading(17))
                                Text(goal.subtitle)
                                    .font(TarsierFonts.caption())
                                    .foregroundStyle(TarsierColors.textSecondary)
                            }
                            Spacer()
                            if dailyGoalMinutes == goal.minutes {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(TarsierColors.functionalPurple)
                            }
                        }
                        .padding(TarsierSpacing.cardPadding)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(dailyGoalMinutes == goal.minutes ? TarsierColors.primaryLight : .white)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(dailyGoalMinutes == goal.minutes ? TarsierColors.functionalPurple : TarsierColors.cardBorder, lineWidth: dailyGoalMinutes == goal.minutes ? 2 : 1.5)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 24)

            Spacer()

            PrimaryButton("Continue") {
                completeOnboarding()
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 48)
        }
    }

    // MARK: - Emotional Hook Data

    private struct HookContent {
        let stat: String
        let message: String
    }

    private func resolveHook() -> HookContent {
        // Priority: family > pride > partner > travel > curious
        let priorityOrder: [(key: String, hook: HookContent)] = [
            ("Connect with family", HookContent(
                stat: "33% of Filipino-Americans understand Tagalog but can't speak it.",
                message: "You're about to change that."
            )),
            ("Cultural pride", HookContent(
                stat: "80 million people speak Tagalog. Duolingo won't teach it.",
                message: "Tarsier will."
            )),
            ("Partner/relationship", HookContent(
                stat: "Your partner's family will love you for trying.",
                message: "Start with respect."
            )),
            ("Travel to the Philippines", HookContent(
                stat: "Filipinos notice when you try. Even just 'po' changes everything.",
                message: "Let's start there."
            )),
            ("Just curious", HookContent(
                stat: "Tagalog turns any word into a verb. Even names.",
                message: "You'll see what we mean."
            ))
        ]

        for item in priorityOrder {
            if selectedMotivations.contains(item.key) {
                return item.hook
            }
        }

        // Default if nothing selected
        return priorityOrder.last!.hook
    }

    // MARK: - Complete Onboarding

    private func completeOnboarding() {
        let profile = UserProfile(
            skillLevel: selectedSkillLevel ?? .beginner,
            motivations: Array(selectedMotivations)
        )
        let trimmedName = userName.trimmingCharacters(in: .whitespaces)
        profile.userName = trimmedName.isEmpty ? nil : trimmedName
        profile.dailyGoalMinutes = dailyGoalMinutes
        modelContext.insert(profile)
        try? modelContext.save()
    }
}
