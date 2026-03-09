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
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(Color(.systemGray5))
                Rectangle()
                    .fill(TarsierTheme.blue)
                    .frame(width: geo.size.width * CGFloat(currentIndex) / CGFloat(questions.count))
                    .animation(.easeInOut, value: currentIndex)
            }
        }
        .frame(height: 6)
    }

    // MARK: - Question View

    @ViewBuilder
    private func questionView(_ question: QuizQuestion) -> some View {
        ScrollView {
            VStack(spacing: 24) {
                Text("Question \(currentIndex + 1) of \(questions.count)")
                    .font(TarsierTheme.caption)
                    .foregroundStyle(.secondary)
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
                            .foregroundStyle(.primary)
                        Spacer()
                        if answerState != .unanswered {
                            if index == question.correctIndex {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(.green)
                            } else if index == selectedOption && answerState == .incorrect {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundStyle(TarsierTheme.red)
                            }
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(optionBackground(for: index, question: question))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(optionBorder(for: index, question: question), lineWidth: 2)
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func optionBackground(for index: Int, question: QuizQuestion) -> Color {
        guard answerState != .unanswered else { return Color(.systemGray6) }
        if index == question.correctIndex { return .green.opacity(0.1) }
        if index == selectedOption && answerState == .incorrect { return TarsierTheme.red.opacity(0.1) }
        return Color(.systemGray6)
    }

    private func optionBorder(for index: Int, question: QuizQuestion) -> Color {
        guard answerState != .unanswered else { return .clear }
        if index == question.correctIndex { return .green }
        if index == selectedOption && answerState == .incorrect { return TarsierTheme.red }
        return .clear
    }

    // MARK: - Text Input

    private func textInputView(_ question: QuizQuestion) -> some View {
        VStack(spacing: 12) {
            if let hint = question.hint, answerState == .unanswered {
                Text("Hint: \(hint)")
                    .font(TarsierTheme.caption)
                    .foregroundStyle(.secondary)
                    .italic()
            }

            TextField("Type your answer", text: $textAnswer)
                .textFieldStyle(.roundedBorder)
                .font(TarsierTheme.body)
                .disabled(answerState != .unanswered)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)

            if answerState == .unanswered {
                Button("Check Answer") {
                    checkTextAnswer(question)
                }
                .buttonStyle(.borderedProminent)
                .tint(TarsierTheme.blue)
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
                        .font(TarsierTheme.headline)
                        .foregroundStyle(.green)
                } else {
                    Label("Not quite", systemImage: "arrow.uturn.backward")
                        .font(TarsierTheme.headline)
                        .foregroundStyle(TarsierTheme.red)

                    if let answer = question.answer {
                        Text("Answer: \(answer)")
                            .font(TarsierTheme.body)
                            .foregroundStyle(.secondary)
                    }
                }

                if let explanation = question.explanation {
                    Text(explanation)
                        .font(TarsierTheme.callout)
                        .foregroundStyle(.secondary)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(TarsierTheme.cream)
                        )
                }

                Button {
                    nextQuestion()
                } label: {
                    Text(currentIndex < questions.count - 1 ? "Next" : "See Results")
                        .font(TarsierTheme.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                }
                .buttonStyle(.borderedProminent)
                .tint(TarsierTheme.blue)
            }
        }
    }

    // MARK: - Quiz Complete

    private var quizComplete: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: score == questions.count ? "star.fill" : "checkmark.circle.fill")
                .font(.system(size: 60))
                .foregroundStyle(score == questions.count ? TarsierTheme.yellow : TarsierTheme.blue)

            Text("Quiz Complete!")
                .font(TarsierTheme.largeTitle)

            Text("\(score)/\(questions.count) correct")
                .font(TarsierTheme.title2)
                .foregroundStyle(.secondary)

            if let profile {
                HStack(spacing: 6) {
                    Image(systemName: "flame.fill")
                        .foregroundStyle(TarsierTheme.yellow)
                    Text("\(profile.currentStreak) day streak")
                        .font(TarsierTheme.headline)
                }
            }

            Spacer()

            Button {
                dismiss()
            } label: {
                Text("Continue")
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
