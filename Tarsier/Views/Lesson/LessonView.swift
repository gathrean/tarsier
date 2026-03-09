import SwiftUI
import SwiftData

struct LessonContainerView: View {
    let lesson: SlideLesson
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [UserProfile]

    @State private var currentPageIndex = 0
    @State private var pages: [LessonPage] = []
    @State private var showCloseConfirmation = false
    @State private var quizScore = 0
    @State private var quizTotal = 0

    private var profile: UserProfile? { profiles.first }
    private var currentPage: LessonPage? {
        guard currentPageIndex < pages.count else { return nil }
        return pages[currentPageIndex]
    }

    var body: some View {
        VStack(spacing: 0) {
            // Top bar: close button + progress
            HStack(spacing: 12) {
                Button {
                    showCloseConfirmation = true
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(TarsierColors.textSecondary)
                        .frame(width: 32, height: 32)
                        .background(Circle().fill(TarsierColors.cream))
                        .overlay(Circle().stroke(TarsierColors.cardBorder, lineWidth: 1))
                }

                ProgressBarView(current: currentPageIndex, total: pages.count)
            }
            .padding(.horizontal, TarsierSpacing.screenPadding)
            .padding(.top, 8)
            .padding(.bottom, 4)

            // Slide content
            if let page = currentPage {
                ScrollView {
                    slideContent(for: page)
                        .padding(.horizontal, TarsierSpacing.screenPadding)
                        .padding(.top, 16)
                        .padding(.bottom, page.showsContinueButton ? 80 : 16)
                }
            }

            Spacer(minLength: 0)

            // Continue button (hidden for quiz & summary — they have their own)
            if let page = currentPage, page.showsContinueButton {
                PrimaryButton("Continue") {
                    advancePage()
                }
                .padding(.horizontal, TarsierSpacing.screenPadding)
                .padding(.bottom, 16)
            }
        }
        .background(TarsierColors.warmWhite.ignoresSafeArea())
        .navigationBarBackButtonHidden()
        .toolbar(.hidden, for: .tabBar)
        .toolbar(.hidden, for: .navigationBar)
        .alert("Leave lesson?", isPresented: $showCloseConfirmation) {
            Button("Stay", role: .cancel) {}
            Button("Leave", role: .destructive) { dismiss() }
        } message: {
            Text("Your progress in this lesson won't be saved.")
        }
        .onAppear {
            pages = lesson.expandToPages()
        }
    }

    // MARK: - Slide Router

    @ViewBuilder
    private func slideContent(for page: LessonPage) -> some View {
        switch page {
        case .culturalContext(let slide):
            CulturalContextSlideView(slide: slide)
        case .teaching(let slide):
            TeachingSlideView(slide: slide)
        case .vocabulary(let word):
            VocabularySlideView(word: word)
        case .alamMoBa(let slide):
            AlamMoBaSlideView(slide: slide)
        case .quiz(let question, let costsHeart):
            QuizSlideView(
                question: question,
                costsHeart: costsHeart,
                onAnswer: { isCorrect in
                    quizTotal += 1
                    if isCorrect {
                        quizScore += 1
                    } else if costsHeart {
                        profile?.loseHeart()
                    }
                },
                onContinue: { advancePage() }
            )
        case .summary(let slide):
            SummarySlideView(
                slide: slide,
                xpReward: lesson.gamification.xpReward,
                quizScore: quizScore,
                quizTotal: quizTotal,
                onContinue: { completeLesson() }
            )
        }
    }

    // MARK: - Navigation

    private func advancePage() {
        withAnimation(.easeInOut(duration: 0.25)) {
            if currentPageIndex < pages.count - 1 {
                currentPageIndex += 1
            }
        }
    }

    // MARK: - Lesson Completion

    private func completeLesson() {
        if let profile {
            profile.addXP(lesson.gamification.xpReward)

            if !profile.completedLessonIDs.contains(lesson.id) {
                profile.completedLessonIDs.append(lesson.id)
            }

            if lesson.id >= profile.currentLessonIndex {
                profile.currentLessonIndex = lesson.id + 1
            }

            StreakService.updateStreak(for: profile)
        }

        let result = LessonResult(
            lessonID: lesson.id,
            chapterId: lesson.chapterId,
            score: quizScore,
            totalQuestions: quizTotal,
            xpEarned: lesson.gamification.xpReward
        )
        modelContext.insert(result)

        // Add words to word bank
        for slide in lesson.slides where slide.type == .vocabulary {
            for word in slide.words ?? [] {
                let entry = WordBankEntry(
                    word: word.word,
                    root: word.word,
                    meaning: word.meaning,
                    lessonId: lesson.id,
                    chapterId: lesson.chapterId
                )
                modelContext.insert(entry)
            }
        }

        dismiss()
    }
}
