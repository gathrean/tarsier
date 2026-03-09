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
    }

    // MARK: - Welcome Page

    private var welcomePage: some View {
        VStack(spacing: 32) {
            Spacer()

            Image(systemName: "eyes")
                .font(.system(size: 80))
                .foregroundStyle(TarsierTheme.brown)

            VStack(spacing: 8) {
                Text("Tarsier")
                    .font(TarsierTheme.largeTitle)
                    .foregroundStyle(TarsierTheme.blue)

                Text("learn Tagalog")
                    .font(TarsierTheme.title3)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Button {
                withAnimation { currentPage = 1 }
            } label: {
                Text("Get Started")
                    .font(TarsierTheme.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
            }
            .buttonStyle(.borderedProminent)
            .tint(TarsierTheme.blue)
            .padding(.horizontal, 32)
            .padding(.bottom, 48)
        }
    }

    // MARK: - Skill Level Page

    private var skillLevelPage: some View {
        VStack(spacing: 24) {
            Spacer()

            Text("What's your level?")
                .font(TarsierTheme.title)

            VStack(spacing: 12) {
                ForEach(SkillLevel.allCases, id: \.self) { level in
                    Button {
                        selectedSkillLevel = level
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(level.displayName)
                                    .font(TarsierTheme.headline)
                                Text(level.description)
                                    .font(TarsierTheme.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            if selectedSkillLevel == level {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(TarsierTheme.blue)
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(selectedSkillLevel == level ? TarsierTheme.cream : Color(.systemGray6))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(selectedSkillLevel == level ? TarsierTheme.blue : .clear, lineWidth: 2)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 24)

            Spacer()

            Button {
                withAnimation { currentPage = 2 }
            } label: {
                Text("Continue")
                    .font(TarsierTheme.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
            }
            .buttonStyle(.borderedProminent)
            .tint(TarsierTheme.blue)
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
                .font(TarsierTheme.title)
                .multilineTextAlignment(.center)

            Text("Pick all that apply (optional)")
                .font(TarsierTheme.subheadline)
                .foregroundStyle(.secondary)

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
                                .font(TarsierTheme.body)
                            Spacer()
                            if selectedMotivations.contains(motivation) {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(TarsierTheme.blue)
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(selectedMotivations.contains(motivation) ? TarsierTheme.cream : Color(.systemGray6))
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 24)

            Spacer()

            Button {
                completeOnboarding()
            } label: {
                Text("Let's Go!")
                    .font(TarsierTheme.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
            }
            .buttonStyle(.borderedProminent)
            .tint(TarsierTheme.blue)
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
    }
}
