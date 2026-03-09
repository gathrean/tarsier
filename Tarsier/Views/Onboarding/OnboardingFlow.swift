import SwiftUI
import SwiftData

struct OnboardingFlow: View {
    @Environment(\.modelContext) private var modelContext
    @State private var currentPage = 0
    @State private var selectedSkillLevel: SkillLevel?
    @State private var selectedMotivations: Set<String> = []

    private let motivations = [
        "Reconnect with family",
        "Travel to the Philippines",
        "Partner is Filipino",
        "General interest",
        "Other"
    ]

    var body: some View {
        TabView(selection: $currentPage) {
            welcomePage.tag(0)
            skillLevelPage.tag(1)
            motivationPage.tag(2)
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .animation(.easeInOut, value: currentPage)
        .background(TarsierColors.warmWhite.ignoresSafeArea())
    }

    // MARK: - Welcome Page

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
            .padding(.horizontal, 32)
            .padding(.bottom, 48)
        }
    }

    // MARK: - Skill Level Page

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
                            RoundedRectangle(cornerRadius: TarsierSpacing.cardCornerRadius)
                                .fill(selectedSkillLevel == level ? TarsierColors.cream : TarsierColors.warmWhite)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: TarsierSpacing.cardCornerRadius)
                                .stroke(selectedSkillLevel == level ? TarsierColors.functionalPurple : TarsierColors.cardBorder, lineWidth: selectedSkillLevel == level ? 2 : 1)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 24)

            Spacer()

            PrimaryButton("Continue") {
                withAnimation { currentPage = 2 }
            }
            .disabled(selectedSkillLevel == nil)
            .padding(.horizontal, 32)
            .padding(.bottom, 48)
        }
    }

    // MARK: - Motivation Page

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
                            RoundedRectangle(cornerRadius: TarsierSpacing.cardCornerRadius)
                                .fill(selectedMotivations.contains(motivation) ? TarsierColors.cream : TarsierColors.warmWhite)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: TarsierSpacing.cardCornerRadius)
                                .stroke(selectedMotivations.contains(motivation) ? TarsierColors.functionalPurple : TarsierColors.cardBorder, lineWidth: selectedMotivations.contains(motivation) ? 2 : 1)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 24)

            Spacer()

            PrimaryButton("Let's Go!") {
                completeOnboarding()
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 48)
        }
    }

    private func completeOnboarding() {
        let profile = UserProfile(
            skillLevel: selectedSkillLevel ?? .beginner,
            motivations: Array(selectedMotivations)
        )
        modelContext.insert(profile)
        try? modelContext.save()
    }
}
