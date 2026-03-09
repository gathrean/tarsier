import SwiftUI
import SwiftData

struct QuizView: View {
    let lesson: Lesson
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var profiles: [UserProfile]

    @State private var currentIndex = 0
    @State private var score = 0
    @State private var selectedOption: Int?
    @State private var textAnswer = ""
    @State private var answerState: AnswerState = .unanswered
    @State private var isFinished = false

    private var profile: UserProfile? { profiles.first }
    private var questions: [QuizQuestion] { lesson.quiz }
    private var currentQuestion: QuizQuestion? {
        guard currentIndex < questions.count else { return nil }
        return questions[currentIndex]
    }

    enum AnswerState {
        case unanswered, correct, incorrect
    }

    var body: some View {
        VStack(spacing: 0) {
            if isFinished {
                quizComplete
            } else if let question = currentQuestion {
                progressBar
                questionView(question)
            }
        }
        .navigationTitle("Quiz")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
    }

    // MARK: - Progress Bar

    private var progressBar: some View {
        ProgressBarView(current: currentIndex, total: questions.count)
    }

    // MARK: - Question View

    @ViewBuilder
    private func questionView(_ question: QuizQuestion) -> some View {
        ScrollView {
            VStack(spacing: 24) {
                Text("Question \(currentIndex + 1) of \(questions.count)")
                    .font(TarsierTheme.caption)
                    .foregroundStyle(TarsierColors.textSecondary)
                    .padding(.top, 16)

                Text(question.question)
                    .font(TarsierTheme.title3)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                switch question.type {
                case .multipleChoice, .rootPattern:
                    multipleChoiceOptions(question)
                case .fillInBlank:
                    textInputView(question)
                case .translate:
                    textInputView(question)
                }

                feedbackView(question)
            }
            .padding()
        }
    }

    // MARK: - Multiple Choice

    private func multipleChoiceOptions(_ question: QuizQuestion) -> some View {
        VStack(spacing: 10) {
            ForEach(Array((question.options ?? []).enumerated()), id: \.offset) { index, option in
                Button {
                    guard answerState == .unanswered else { return }
                    selectedOption = index
                    checkMultipleChoiceAnswer(question, selected: index)
                } label: {
                    HStack {
                        Text(option)
                            .font(TarsierTheme.body)
                            .foregroundStyle(TarsierColors.textPrimary)
                        Spacer()
                        if answerState != .unanswered {
                            if index == question.correctIndex {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(TarsierColors.correctGreen)
                            } else if index == selectedOption && answerState == .incorrect {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundStyle(TarsierColors.alertRed)
                            }
                        }
                    }
                    .padding(TarsierSpacing.cardPadding)
                    .background(
                        RoundedRectangle(cornerRadius: TarsierSpacing.cardCornerRadius)
                            .fill(optionBackground(for: index, question: question))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: TarsierSpacing.cardCornerRadius)
                            .stroke(optionBorder(for: index, question: question), lineWidth: 2)
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func optionBackground(for index: Int, question: QuizQuestion) -> Color {
        guard answerState != .unanswered else { return TarsierColors.cream }
        if index == question.correctIndex { return TarsierColors.correctGreen.opacity(0.15) }
        if index == selectedOption && answerState == .incorrect { return TarsierColors.alertRed.opacity(0.15) }
        return TarsierColors.cream
    }

    private func optionBorder(for index: Int, question: QuizQuestion) -> Color {
        guard answerState != .unanswered else { return TarsierColors.cardBorder }
        if index == question.correctIndex { return TarsierColors.correctGreen }
        if index == selectedOption && answerState == .incorrect { return TarsierColors.alertRed }
        return TarsierColors.cardBorder
    }

    // MARK: - Text Input

    private func textInputView(_ question: QuizQuestion) -> some View {
        VStack(spacing: 12) {
            if let hint = question.hint, answerState == .unanswered {
                Text("Hint: \(hint)")
                    .font(TarsierTheme.caption)
                    .foregroundStyle(TarsierColors.textSecondary)
                    .italic()
            }

            TextField("Type your answer", text: $textAnswer)
                .textFieldStyle(.roundedBorder)
                .font(TarsierTheme.body)
                .disabled(answerState != .unanswered)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)

            if answerState == .unanswered {
                PrimaryButton("Check Answer") {
                    checkTextAnswer(question)
                }
                .disabled(textAnswer.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
    }

    // MARK: - Feedback

    @ViewBuilder
    private func feedbackView(_ question: QuizQuestion) -> some View {
        if answerState != .unanswered {
            VStack(spacing: 12) {
                if answerState == .correct {
                    Label("Correct!", systemImage: "star.fill")
                        .font(TarsierFonts.button())
                        .foregroundStyle(TarsierColors.correctGreen)
                } else {
                    Label("Not quite", systemImage: "arrow.uturn.backward")
                        .font(TarsierTheme.headline)
                        .foregroundStyle(TarsierTheme.red)

                    if let answer = question.answer {
                        Text("Answer: \(answer)")
                            .font(TarsierTheme.body)
                            .foregroundStyle(TarsierColors.textSecondary)
                    }
                }

                if let explanation = question.explanation {
                    Text(explanation)
                        .font(TarsierFonts.body(15))
                        .foregroundStyle(TarsierColors.textSecondary)
                        .padding(TarsierSpacing.cardPadding)
                        .background(
                            RoundedRectangle(cornerRadius: TarsierSpacing.cardCornerRadius)
                                .fill(TarsierColors.cream)
                        )
                }

                PrimaryButton(currentIndex < questions.count - 1 ? "Next" : "See Results") {
                    nextQuestion()
                }
            }
        }
    }

    // MARK: - Quiz Complete

    private var quizComplete: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: score == questions.count ? "star.fill" : "checkmark.circle.fill")
                .font(.system(size: 60, weight: .bold, design: .rounded))
                .foregroundStyle(score == questions.count ? TarsierColors.gold : TarsierColors.functionalPurple)

            Text("Quiz Complete!")
                .font(TarsierFonts.title(34))
                .foregroundStyle(TarsierColors.textPrimary)

            Text("\(score)/\(questions.count) correct")
                .font(TarsierFonts.heading(22))
                .foregroundStyle(TarsierColors.textSecondary)

            if let profile {
                HStack(spacing: 6) {
                    Image(systemName: "flame.fill")
                        .foregroundStyle(TarsierColors.gold)
                    Text("\(profile.currentStreak) day streak")
                        .font(TarsierFonts.button())
                        .foregroundStyle(TarsierColors.textPrimary)
                }
            }

            Spacer()

            PrimaryButton("Continue") {
                dismiss()
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 48)
        }
        .background(TarsierColors.warmWhite.ignoresSafeArea())
    }

    // MARK: - Logic

    private func checkMultipleChoiceAnswer(_ question: QuizQuestion, selected: Int) {
        if selected == question.correctIndex {
            answerState = .correct
            score += 1
        } else {
            answerState = .incorrect
        }
    }

    private func checkTextAnswer(_ question: QuizQuestion) {
        let trimmed = textAnswer.trimmingCharacters(in: .whitespaces).lowercased()
        let correct = question.answer?.lowercased() ?? ""
        let alternatives = (question.acceptAlso ?? []).map { $0.lowercased() }

        if trimmed == correct || alternatives.contains(trimmed) {
            answerState = .correct
            score += 1
        } else {
            answerState = .incorrect
        }
    }

    private func nextQuestion() {
        if currentIndex < questions.count - 1 {
            currentIndex += 1
            answerState = .unanswered
            selectedOption = nil
            textAnswer = ""
        } else {
            completeQuiz()
        }
    }

    private func completeQuiz() {
        let result = LessonResult(
            lessonID: lesson.id,
            score: score,
            totalQuestions: questions.count
        )
        modelContext.insert(result)

        if let profile {
            if !profile.completedLessonIDs.contains(lesson.id) {
                profile.completedLessonIDs.append(lesson.id)
            }
            if lesson.id >= profile.currentLessonIndex {
                profile.currentLessonIndex = lesson.id + 1
            }
            StreakService.updateStreak(for: profile)
        }

        isFinished = true
    }
}
