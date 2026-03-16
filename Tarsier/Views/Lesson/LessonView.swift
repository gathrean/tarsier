import SwiftUI
import SwiftData
import StoreKit

struct LessonContainerView: View {
    let lesson: SlideLesson
    let sessionNumber: Int
    let isReplay: Bool
    var hideCloseButton: Bool = false
    var onSessionComplete: (() -> Void)? = nil

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [UserProfile]

    // Card queue — wrong quiz answers get moved to back
    @State private var cardQueue: [SessionCard] = []
    @State private var initialCardCount = 0
    @State private var completedCardIds: Set<String> = []

    // Shuffle state for current quiz card
    @State private var shuffledOptions: [String] = []
    @State private var shuffledCorrectIndex: Int = 0

    // Word-order state
    @State private var shuffledWordPieces: [String] = []
    @State private var wordOrderShakeCount: Int = 0

    // Quiz state
    @State private var quizState = QuizState()
    @State private var showCloseConfirmation = false
    @State private var showHeartsEmpty = false

    // Session completion
    @State private var sessionComplete = false
    @State private var isLessonComplete = false
    @State private var completedCountBeforeThis = 0

    // Wrong answer tracking
    @State private var wrongCounts: [String: Int] = [:]
    @State private var heartShakeCount: Int = 0

    // Coach marks
    @State private var showQuizCoachMark = false
    @State private var quizOptionsRect: CGRect = .zero
    @State private var coachMarkDismissedQuiz = false

    private var profile: UserProfile? { profiles.first }
    private var currentCard: SessionCard? { cardQueue.first }

    private var session: LessonSession? {
        lesson.sessions.first { $0.sessionNumber == sessionNumber }
    }

    var body: some View {
        VStack(spacing: 0) {
            if sessionComplete {
                SessionCompleteView(
                    lesson: lesson,
                    sessionNumber: sessionNumber,
                    isLessonComplete: isLessonComplete,
                    isReplay: isReplay,
                    completedSessionsBefore: completedCountBeforeThis,
                    onContinue: {
                        if let onSessionComplete {
                            onSessionComplete()
                        } else {
                            dismiss()
                        }
                    }
                )
            } else {
                sessionContent
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
            Text("Your progress in this session won't be saved.")
        }
        .sheet(isPresented: $showHeartsEmpty) {
            HeartsEmptySheet(
                onWatchAd: {
                    profile?.hearts = min(5, (profile?.hearts ?? 0) + 1)
                },
                onGetPremium: {
                    // TODO: Superwall paywall trigger
                },
                onLeaveLesson: {
                    dismiss()
                }
            )
        }
        .onAppear {
            loadSession()
        }
    }

    // MARK: - Session Content (cards)

    private var sessionContent: some View {
        VStack(spacing: 0) {
            // Top bar: close + progress
            HStack(spacing: 12) {
                if !hideCloseButton {
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
                }

                ProgressBarView(current: completedCardIds.count, total: initialCardCount)

                HStack(spacing: 4) {
                    Image(systemName: "heart.fill")
                        .foregroundStyle(TarsierColors.heartRed)
                    Text("\(profile?.hearts ?? 5)")
                        .font(TarsierFonts.heading(16))
                        .foregroundStyle(TarsierColors.heartRed)
                }
                .modifier(ShakeModifier(animatableData: CGFloat(heartShakeCount)))
            }
            .padding(.horizontal, TarsierSpacing.screenPadding)
            .padding(.top, 8)
            .padding(.bottom, 4)

            // Session title
            if let session {
                Text(session.title)
                    .font(TarsierFonts.caption())
                    .foregroundStyle(TarsierColors.textSecondary)
                    .padding(.bottom, 8)
            }

            // Card content
            if let card = currentCard {
                ScrollView {
                    cardContent(for: card)
                        .padding(.horizontal, TarsierSpacing.screenPadding)
                        .padding(.top, 16)
                        .padding(.bottom, 80)
                }
                .scrollDismissesKeyboard(.interactively)
                .id(card.cardId + "_\(cardQueue.count)")
            }

            Spacer(minLength: 0)

            // Alam Mo Ba inline tooltip (hidden after quiz check)
            if let inline = currentCard?.alamMoBaInline, !quizState.isChecked {
                alamMoBaInlineView(inline)
                    .padding(.horizontal, TarsierSpacing.screenPadding)
                    .padding(.bottom, 8)
            }

            // Bottom button
            bottomButton
        }
        .coordinateSpace(name: "sessionContent")
        .overlay {
            if showQuizCoachMark, quizOptionsRect != .zero {
                CoachMarkOverlay(
                    targetRect: quizOptionsRect,
                    message: "Tap an answer, then Check",
                    arrowPointsDown: false
                )
                .onTapGesture {
                    withAnimation { showQuizCoachMark = false }
                    coachMarkDismissedQuiz = true
                    profile?.hasSeenCoachMarks = true
                }
            }
        }
        .onChange(of: quizState.hasSelection) { _, hasSelection in
            if hasSelection && showQuizCoachMark {
                withAnimation { showQuizCoachMark = false }
                coachMarkDismissedQuiz = true
                profile?.hasSeenCoachMarks = true
            }
        }
    }

    // MARK: - Alam Mo Ba Inline Tooltip

    private func alamMoBaInlineView(_ inline: AlamMoBaInline) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Text(inline.emoji ?? "💡")
                .font(.system(size: 14))

            VStack(alignment: .leading, spacing: 2) {
                Text(inline.term)
                    .font(TarsierFonts.caption(13))
                    .fontWeight(.bold)
                    .foregroundStyle(TarsierColors.functionalPurple)
                Text(inline.fact)
                    .font(TarsierFonts.caption(12))
                    .foregroundStyle(TarsierColors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(TarsierColors.primaryLight)
        )
        .fixedSize(horizontal: false, vertical: true)
    }

    // MARK: - Card Router

    @ViewBuilder
    private func cardContent(for card: SessionCard) -> some View {
        switch card.type {
        case .teach:
            TeachCardView(card: card)
        case .quiz:
            QuizSlideView(
                card: card,
                displayOptions: shuffledOptions,
                correctIndex: shuffledCorrectIndex,
                shuffledWordPieces: shuffledWordPieces,
                state: quizState
            )
        }
    }

    // MARK: - Bottom Button

    @ViewBuilder
    private var bottomButton: some View {
        if let card = currentCard {
            switch card.type {
            case .teach:
                PrimaryButton("Continue") {
                    advanceTeachCard()
                }
                .padding(.horizontal, TarsierSpacing.screenPadding)
                .padding(.bottom, 16)

            case .quiz:
                if quizState.isChecked {
                    quizFeedbackPanel(card: card)
                } else {
                    PrimaryButton("Check") {
                        checkQuizAnswer(card: card)
                    }
                    .disabled(!quizState.hasSelection)
                    .modifier(ShakeModifier(animatableData: CGFloat(wordOrderShakeCount)))
                    .padding(.horizontal, TarsierSpacing.screenPadding)
                    .padding(.bottom, 16)
                }
            }
        }
    }

    // MARK: - Quiz Feedback Banner (compact bottom strip)

    private func quizFeedbackPanel(card: SessionCard) -> some View {
        let isCorrect = quizState.answerState == .correct
        let accentColor = isCorrect ? TarsierColors.correctGreen : TarsierColors.alertRed
        let bannerBg = isCorrect ? TarsierColors.correctBannerBg : TarsierColors.wrongBannerBg

        // Build explanation text
        let explanation: String? = {
            if let exp = card.explanation { return exp }
            if isCorrect, let suffix = quizState.wordOrderFeedbackSuffix {
                return "Though \"\(suffix)\" is more natural."
            }
            if !isCorrect, card.quizType == .fillInBlank,
               let answers = card.correctAnswers, let first = answers.first {
                return "Correct answer: \(first)"
            }
            if !isCorrect, card.quizType == .wordOrder,
               let best = card.bestOrder, !best.isEmpty {
                return "Correct: \(best.joined(separator: " "))"
            }
            return nil
        }()

        return VStack(alignment: .leading, spacing: 8) {
            // Header: checkmark + "Tama!" / "Mali"
            HStack(spacing: 6) {
                Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(accentColor)
                Text(isCorrect ? "Tama!" : "Mali")
                    .font(TarsierFonts.heading(22))
                    .foregroundStyle(accentColor)
            }

            // Explanation (1-2 lines max)
            if let explanation {
                Text(explanation)
                    .font(TarsierFonts.body(14))
                    .foregroundStyle(TarsierColors.textPrimary)
                    .lineLimit(2)
            }

            // Continue button
            Button {
                advanceAfterQuizCheck()
            } label: {
                Text("CONTINUE")
                    .font(TarsierFonts.button())
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(
                        RoundedRectangle(cornerRadius: TarsierSpacing.buttonCornerRadius)
                            .fill(accentColor)
                    )
            }
            .buttonStyle(PrimaryButtonStyle())
        }
        .padding(.horizontal, TarsierSpacing.screenPadding)
        .padding(.top, 16)
        .padding(.bottom, 12)
        .background(bannerBg.ignoresSafeArea(edges: .bottom))
    }

    // MARK: - Load Session

    private func loadSession() {
        guard let session else { return }
        cardQueue = session.cards
        initialCardCount = session.cards.count

        // Count completed sessions before this one
        let lessonId = lesson.lessonId
        let descriptor = FetchDescriptor<SessionProgress>(
            predicate: #Predicate { $0.lessonId == lessonId && $0.isCompleted == true }
        )
        completedCountBeforeThis = (try? modelContext.fetchCount(descriptor)) ?? 0

        prepareCurrentCard()

        // Show quiz coach mark on first quiz card if user hasn't seen coach marks
    }

    // MARK: - Card Advancement

    private func advanceTeachCard() {
        guard let card = currentCard else { return }
        completedCardIds.insert(card.cardId)
        _ = withAnimation(.easeInOut(duration: 0.25)) {
            cardQueue.removeFirst()
        }
        if cardQueue.isEmpty {
            completeSession()
        } else {
            prepareCurrentCard()
        }
    }

    private func advanceAfterQuizCheck() {
        guard let card = currentCard else { return }

        // Stop any pronunciation audio still playing from correct-answer feedback
        AudioPlayerService.shared.stop()

        if quizState.answerState == .correct {
            completedCardIds.insert(card.cardId)
            cardQueue.removeFirst()
        } else {
            // Move wrong card to back of queue
            let wrongCard = cardQueue.removeFirst()
            cardQueue.append(wrongCard)
        }

        quizState.reset()

        if cardQueue.isEmpty {
            completeSession()
        } else {
            prepareCurrentCard()
        }
    }

    // MARK: - Quiz Answer Checking

    private func checkQuizAnswer(card: SessionCard) {
        let isCorrect: Bool

        switch card.quizType {
        case .multipleChoice:
            isCorrect = quizState.checkMultipleChoice(correctIndex: shuffledCorrectIndex)
        case .fillInBlank:
            isCorrect = quizState.checkFillInBlank(acceptedAnswers: card.correctAnswers ?? [])
        case .wordOrder:
            checkWordOrder(card: card)
            return
        case .none:
            return
        }

        if isCorrect {
            handleCorrectAnswer(card: card)
        } else {
            handleWrongAnswer(card: card)
        }
    }

    private func checkWordOrder(card: SessionCard) {
        let placedWords = quizState.placedIndices.map { shuffledWordPieces[$0] }
        let correctOrders = card.correctOrders ?? []
        let bestOrder = card.bestOrder ?? []

        let isCorrect = quizState.checkWordOrder(
            placedWords: placedWords,
            correctOrders: correctOrders,
            bestOrder: bestOrder
        )

        if isCorrect {
            handleCorrectAnswer(card: card)
        } else {
            handleWrongAnswer(card: card)
        }
    }

    // MARK: - Answer Feedback (sound + haptics)

    private func handleCorrectAnswer(card: SessionCard) {
        SoundManager.shared.play("correct")
        UINotificationFeedbackGenerator().notificationOccurred(.success)

        // Delayed pronunciation — plays while "Tama!" banner is showing
        if let audioPath = card.audio {
            Task {
                try? await Task.sleep(for: .seconds(0.3))
                AudioPlayerService.shared.play(relativePath: audioPath)
            }
        }
    }

    private func handleWrongAnswer(card: SessionCard) {
        SoundManager.shared.play("incorrect")
        UINotificationFeedbackGenerator().notificationOccurred(.error)
        wrongCounts[card.cardId, default: 0] += 1
        profile?.loseHeart()
        withAnimation(.spring(response: 0.3, dampingFraction: 0.3)) {
            heartShakeCount += 1
        }
        if profile?.hearts == 0 {
            showHeartsEmpty = true
        }
    }

    // MARK: - Prepare Current Card (shuffle if needed)

    private func prepareCurrentCard() {
        guard let card = currentCard else { return }
        if card.type == .quiz, card.quizType == .multipleChoice {
            prepareShuffledOptions(for: card)
            shuffledWordPieces = []
            quizState.totalWordPieces = 0
        } else if card.type == .quiz, card.quizType == .wordOrder {
            shuffledOptions = []
            shuffledCorrectIndex = 0
            let pieces = card.wordPieces ?? []
            shuffledWordPieces = pieces.shuffled()
            quizState.totalWordPieces = pieces.count
        } else {
            shuffledOptions = []
            shuffledCorrectIndex = 0
            shuffledWordPieces = []
            quizState.totalWordPieces = 0
        }

        // Show quiz coach mark on first quiz card
        if card.type == .quiz,
           !coachMarkDismissedQuiz,
           profile?.hasSeenCoachMarks == false {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation { showQuizCoachMark = true }
            }
        }
    }

    private func prepareShuffledOptions(for card: SessionCard) {
        guard let options = card.options else {
            shuffledOptions = []
            shuffledCorrectIndex = 0
            return
        }

        if card.shuffleOptions == true {
            var indices = Array(0..<options.count)
            indices.shuffle()
            shuffledOptions = indices.map { options[$0] }
            shuffledCorrectIndex = indices.firstIndex(of: card.correctAnswer ?? 0) ?? 0
        } else {
            shuffledOptions = options
            shuffledCorrectIndex = card.correctAnswer ?? 0
        }
    }

    // MARK: - Session Completion

    private func completeSession() {
        isLessonComplete = (completedCountBeforeThis + 1) >= lesson.totalSessions

        // Save session progress
        let progress = SessionProgress(lessonId: lesson.lessonId, sessionNumber: sessionNumber)
        progress.wrongCounts = wrongCounts
        progress.markCompleted()
        modelContext.insert(progress)

        // Add vocabulary to word bank on first session (not replay)
        if !isReplay && sessionNumber == 1 {
            addVocabularyToWordBank()
        }

        if isLessonComplete && !isReplay {
            completeLessonFull()
        }

        withAnimation(.easeInOut(duration: 0.3)) {
            sessionComplete = true
        }

        // Review prompt after first full lesson completion
        if isLessonComplete, let profile, !profile.hasPromptedReview {
            profile.hasPromptedReview = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                if let scene = UIApplication.shared.connectedScenes
                    .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
                    SKStoreReviewController.requestReview(in: scene)
                }
            }
        }
    }

    // MARK: - Shake Modifier (word_order wrong answer)

    struct ShakeModifier: GeometryEffect {
        var animatableData: CGFloat

        func effectValue(size: CGSize) -> ProjectionTransform {
            let offset = sin(animatableData * .pi * 6) * 8
            return ProjectionTransform(CGAffineTransform(translationX: offset, y: 0))
        }
    }

    private func completeLessonFull() {
        guard let profile else { return }

        let xp = lesson.completionReward.xp
        profile.addXP(xp)

        if !profile.completedLessonIDs.contains(lesson.id) {
            profile.completedLessonIDs.append(lesson.id)
        }

        if lesson.id >= profile.currentLessonIndex {
            profile.currentLessonIndex = lesson.id + 1
        }

        StreakService.updateStreak(for: profile)

        let result = LessonResult(
            lessonID: lesson.id,
            chapterId: lesson.chapterId,
            score: 0,
            totalQuestions: 0,
            xpEarned: xp
        )
        modelContext.insert(result)
    }

    private func addVocabularyToWordBank() {
        for vocab in lesson.vocabulary {
            let entry = WordBankEntry(
                word: vocab.word,
                root: vocab.word,
                meaning: vocab.meaning,
                lessonId: lesson.id,
                chapterId: lesson.chapterId,
                pronunciationGuide: vocab.pronunciation
            )
            modelContext.insert(entry)
        }
    }
}
