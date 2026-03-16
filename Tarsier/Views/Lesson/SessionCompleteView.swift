import SwiftUI
import SwiftData

struct SessionCompleteView: View {
    let lesson: SlideLesson
    let sessionNumber: Int
    let isLessonComplete: Bool
    let isReplay: Bool
    let completedSessionsBefore: Int
    let onContinue: () -> Void

    @Query private var profiles: [UserProfile]
    @State private var animatedCompleted: Int = 0
    @State private var showContent = false

    private var profile: UserProfile? { profiles.first }

    private var totalSessions: Int { lesson.totalSessions }
    private var xp: Int { isReplay ? 0 : lesson.completionReward.xp }
    private var randomAlamMoBa: String? {
        lesson.completionReward.alamMoBa.randomElement()
    }

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            if isLessonComplete {
                lessonCompleteContent
            } else {
                sessionCompleteContent
            }

            Spacer()

            PrimaryButton("Continue") {
                onContinue()
            }
            .padding(.horizontal, TarsierSpacing.screenPadding)
            .padding(.bottom, 16)
        }
        .onAppear {
            // Start with pre-completion count, then animate to new count
            animatedCompleted = completedSessionsBefore
            withAnimation(.easeInOut(duration: 0.6).delay(0.3)) {
                animatedCompleted = completedSessionsBefore + 1
                showContent = true
            }

            // Play sound when ring animation completes (~0.9s = 0.3s delay + 0.6s animation)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
                if isLessonComplete {
                    SoundManager.shared.play("lesson_complete")
                } else {
                    SoundManager.shared.play("progress")
                }
                UINotificationFeedbackGenerator().notificationOccurred(.success)
            }
        }
    }

    // MARK: - Session Complete (mid-lesson)

    private var sessionCompleteContent: some View {
        VStack(spacing: 20) {
            // Progress ring — animates from X/5 to (X+1)/5
            ZStack {
                ProgressRingView(
                    completed: animatedCompleted,
                    total: totalSessions,
                    size: 120,
                    lineWidth: 8
                )

                VStack(spacing: 2) {
                    Text("\(animatedCompleted)")
                        .font(TarsierFonts.title(32))
                        .foregroundStyle(TarsierColors.functionalPurple)
                        .contentTransition(.numericText())
                    Text("of \(totalSessions)")
                        .font(TarsierFonts.caption())
                        .foregroundStyle(TarsierColors.textSecondary)
                }
            }

            if let name = profile?.userName {
                HStack(spacing: 4) {
                    TappableTagalogWord(
                        word: "Magaling,",
                        translation: "Great job!",
                        font: TarsierFonts.title(24),
                        color: TarsierColors.textPrimary
                    )
                    Text("\(name)!")
                        .font(TarsierFonts.title(24))
                        .foregroundStyle(TarsierColors.textPrimary)
                }
                .opacity(showContent ? 1 : 0)
            } else {
                Text("Session Complete!")
                    .font(TarsierFonts.title(24))
                    .foregroundStyle(TarsierColors.textPrimary)
                    .opacity(showContent ? 1 : 0)
            }

            if let session = lesson.sessions.first(where: { $0.sessionNumber == sessionNumber }) {
                Text(session.title)
                    .font(TarsierFonts.body())
                    .foregroundStyle(TarsierColors.textSecondary)
                    .opacity(showContent ? 1 : 0)
            }
        }
    }

    // MARK: - Lesson Complete (final session)

    private var lessonCompleteContent: some View {
        VStack(spacing: 20) {
            // Full progress ring
            ZStack {
                ProgressRingView(
                    completed: animatedCompleted,
                    total: totalSessions,
                    size: 120,
                    lineWidth: 8
                )

                Image(systemName: "checkmark")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundStyle(TarsierColors.functionalPurple)
            }

            if let name = profile?.userName {
                HStack(spacing: 4) {
                    TappableTagalogWord(
                        word: "Ang galing mo,",
                        translation: "You're amazing!",
                        font: TarsierFonts.title(28),
                        color: TarsierColors.textPrimary
                    )
                    Text("\(name)!")
                        .font(TarsierFonts.title(28))
                        .foregroundStyle(TarsierColors.textPrimary)
                }
                .opacity(showContent ? 1 : 0)
            } else {
                Text("Lesson Complete!")
                    .font(TarsierFonts.title(28))
                    .foregroundStyle(TarsierColors.textPrimary)
                    .opacity(showContent ? 1 : 0)
            }

            Text(lesson.title)
                .font(TarsierFonts.body())
                .foregroundStyle(TarsierColors.textSecondary)
                .opacity(showContent ? 1 : 0)

            // XP badge
            if xp > 0 {
                HStack(spacing: 6) {
                    Image(systemName: "star.fill")
                        .foregroundStyle(TarsierColors.functionalPurple)
                    Text("+\(xp) XP")
                        .font(TarsierFonts.heading(18))
                        .foregroundStyle(TarsierColors.textPrimary)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(TarsierColors.cream)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(TarsierColors.cardBorder, lineWidth: 1)
                )
                .opacity(showContent ? 1 : 0)
            }

            if isReplay {
                Text("Replay — no XP earned")
                    .font(TarsierFonts.caption())
                    .foregroundStyle(TarsierColors.textSecondary)
                    .opacity(showContent ? 1 : 0)
            }

            // Vocabulary learned
            if !lesson.vocabulary.isEmpty {
                VStack(spacing: 10) {
                    Text("Words Learned")
                        .font(TarsierFonts.caption())
                        .foregroundStyle(TarsierColors.textSecondary)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(lesson.vocabulary) { vocab in
                                Text(vocab.word)
                                    .font(TarsierFonts.caption())
                                    .foregroundStyle(TarsierColors.textPrimary)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(
                                        Capsule().fill(TarsierColors.cream)
                                    )
                                    .overlay(
                                        Capsule().stroke(TarsierColors.cardBorder, lineWidth: 1)
                                    )
                            }
                        }
                    }
                }
                .padding(.horizontal, TarsierSpacing.screenPadding)
                .opacity(showContent ? 1 : 0)
            }

            // Random Alam Mo Ba fact
            if let fact = randomAlamMoBa {
                AlamMoBaView(text: fact)
                    .padding(.horizontal, TarsierSpacing.screenPadding)
                    .opacity(showContent ? 1 : 0)
            }
        }
    }
}
