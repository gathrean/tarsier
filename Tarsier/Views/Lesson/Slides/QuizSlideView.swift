import SwiftUI
import Observation

// MARK: - Quiz State (shared between QuizSlideView and LessonContainerView)

@Observable
class QuizState {
    var selectedOption: Int?
    var textAnswer: String = ""
    var answerState: AnswerState = .unanswered

    enum AnswerState {
        case unanswered, correct, incorrect
    }

    var hasSelection: Bool {
        selectedOption != nil || !textAnswer.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var isChecked: Bool { answerState != .unanswered }

    func reset() {
        selectedOption = nil
        textAnswer = ""
        answerState = .unanswered
    }

    func checkMultipleChoice(question: SlideQuestion) -> Bool {
        guard let selected = selectedOption else { return false }
        let isCorrect = selected == question.correctAnswer
        answerState = isCorrect ? .correct : .incorrect
        return isCorrect
    }

    func checkFillInBlank(question: SlideQuestion) -> Bool {
        let trimmed = textAnswer.trimmingCharacters(in: .whitespaces).lowercased()
        let accepted = (question.correctAnswers ?? []).map { $0.lowercased() }
        let isCorrect = accepted.contains(trimmed)
        answerState = isCorrect ? .correct : .incorrect
        return isCorrect
    }
}

// MARK: - Quiz Slide View (content only — no bottom button)

struct QuizSlideView: View {
    let question: SlideQuestion
    @Bindable var state: QuizState

    var body: some View {
        VStack(spacing: 20) {
            Text(question.prompt)
                .font(TarsierFonts.heading(20))
                .foregroundStyle(TarsierColors.textPrimary)
                .multilineTextAlignment(.center)

            switch question.type {
            case .multipleChoice:
                multipleChoiceOptions
            case .fillInBlank:
                fillInBlankInput
            }

            if state.isChecked {
                feedbackSection
            }
        }
    }

    // MARK: - Multiple Choice

    private var multipleChoiceOptions: some View {
        VStack(spacing: 10) {
            ForEach(Array((question.options ?? []).enumerated()), id: \.offset) { index, option in
                Button {
                    guard !state.isChecked else { return }
                    state.selectedOption = index
                } label: {
                    HStack {
                        Text(option)
                            .font(TarsierFonts.body())
                            .foregroundStyle(TarsierColors.textPrimary)
                            .multilineTextAlignment(.leading)
                        Spacer()
                        if state.isChecked {
                            if index == question.correctAnswer {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(TarsierColors.correctGreen)
                            } else if index == state.selectedOption && state.answerState == .incorrect {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundStyle(TarsierColors.alertRed)
                            }
                        }
                    }
                    .padding(TarsierSpacing.cardPadding)
                    .background(
                        RoundedRectangle(cornerRadius: TarsierSpacing.cardCornerRadius)
                            .fill(optionBackground(for: index))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: TarsierSpacing.cardCornerRadius)
                            .stroke(optionBorder(for: index), lineWidth: 2)
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func optionBackground(for index: Int) -> Color {
        if state.isChecked {
            if index == question.correctAnswer { return TarsierColors.correctGreen.opacity(0.15) }
            if index == state.selectedOption && state.answerState == .incorrect { return TarsierColors.alertRed.opacity(0.15) }
            return TarsierColors.cream
        }
        // Not checked yet — highlight selected option
        if index == state.selectedOption { return TarsierColors.brandPurple.opacity(0.1) }
        return TarsierColors.cream
    }

    private func optionBorder(for index: Int) -> Color {
        if state.isChecked {
            if index == question.correctAnswer { return TarsierColors.correctGreen }
            if index == state.selectedOption && state.answerState == .incorrect { return TarsierColors.alertRed }
            return TarsierColors.cardBorder
        }
        // Not checked yet — highlight selected option
        if index == state.selectedOption { return TarsierColors.functionalPurple }
        return TarsierColors.cardBorder
    }

    // MARK: - Fill in Blank

    private var fillInBlankInput: some View {
        VStack(spacing: 12) {
            if let hint = question.hint, !state.isChecked {
                Text("Hint: \(hint)")
                    .font(TarsierFonts.caption())
                    .foregroundStyle(TarsierColors.textSecondary)
                    .italic()
            }

            TextField("Type your answer", text: $state.textAnswer)
                .font(TarsierFonts.body())
                .padding(TarsierSpacing.cardPadding)
                .background(
                    RoundedRectangle(cornerRadius: TarsierSpacing.cardCornerRadius)
                        .fill(TarsierColors.cream)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: TarsierSpacing.cardCornerRadius)
                        .stroke(TarsierColors.cardBorder, lineWidth: 1)
                )
                .disabled(state.isChecked)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
        }
    }

    // MARK: - Feedback (shown after checking)

    private var feedbackSection: some View {
        VStack(spacing: 12) {
            HStack(spacing: 6) {
                if state.answerState == .correct {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(TarsierColors.correctGreen)
                    Text("Tama!")
                        .font(TarsierFonts.heading())
                        .foregroundStyle(TarsierColors.correctGreen)
                } else {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(TarsierColors.alertRed)
                    Text("Mali")
                        .font(TarsierFonts.heading())
                        .foregroundStyle(TarsierColors.alertRed)
                }
            }

            if state.answerState == .incorrect, let answers = question.correctAnswers, let first = answers.first {
                Text("Answer: \(first)")
                    .font(TarsierFonts.body())
                    .foregroundStyle(TarsierColors.textSecondary)
            }

            if let explanation = question.explanation {
                Text(explanation)
                    .font(TarsierFonts.body(15))
                    .foregroundStyle(TarsierColors.textSecondary)
                    .padding(TarsierSpacing.cardPadding)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: TarsierSpacing.cardCornerRadius)
                            .fill(TarsierColors.cream)
                    )
            }
        }
        .padding(.top, 8)
    }
}
