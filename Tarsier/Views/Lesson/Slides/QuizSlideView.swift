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

    /// Check multiple choice against a shuffled correct index
    func checkMultipleChoice(correctIndex: Int) -> Bool {
        guard let selected = selectedOption else { return false }
        let isCorrect = selected == correctIndex
        answerState = isCorrect ? .correct : .incorrect
        return isCorrect
    }

    /// Check fill-in-blank against accepted answers
    func checkFillInBlank(acceptedAnswers: [String]) -> Bool {
        let trimmed = textAnswer.trimmingCharacters(in: .whitespaces).lowercased()
        let accepted = acceptedAnswers.map { $0.lowercased() }
        let isCorrect = accepted.contains(trimmed)
        answerState = isCorrect ? .correct : .incorrect
        return isCorrect
    }
}

// MARK: - Quiz Slide View

struct QuizSlideView: View {
    let card: SessionCard
    /// Shuffled options (or original if no shuffle). Provided by parent.
    let displayOptions: [String]
    /// Correct answer index within displayOptions
    let correctIndex: Int
    @Bindable var state: QuizState

    var body: some View {
        VStack(spacing: 20) {
            if let prompt = card.prompt {
                Text(prompt)
                    .font(TarsierFonts.heading(20))
                    .foregroundStyle(TarsierColors.textPrimary)
                    .multilineTextAlignment(.center)
            }

            switch card.quizType {
            case .multipleChoice:
                multipleChoiceOptions
            case .fillInBlank:
                fillInBlankInput
            case .none:
                EmptyView()
            }

            if state.isChecked {
                feedbackSection
            }
        }
    }

    // MARK: - Multiple Choice

    private var multipleChoiceOptions: some View {
        VStack(spacing: 10) {
            ForEach(Array(displayOptions.enumerated()), id: \.offset) { index, option in
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
                            if index == correctIndex {
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
            if index == correctIndex { return TarsierColors.correctGreen.opacity(0.15) }
            if index == state.selectedOption && state.answerState == .incorrect { return TarsierColors.alertRed.opacity(0.15) }
            return TarsierColors.cream
        }
        if index == state.selectedOption { return TarsierColors.brandPurple.opacity(0.1) }
        return TarsierColors.cream
    }

    private func optionBorder(for index: Int) -> Color {
        if state.isChecked {
            if index == correctIndex { return TarsierColors.correctGreen }
            if index == state.selectedOption && state.answerState == .incorrect { return TarsierColors.alertRed }
            return TarsierColors.cardBorder
        }
        if index == state.selectedOption { return TarsierColors.functionalPurple }
        return TarsierColors.cardBorder
    }

    // MARK: - Fill in Blank

    private var fillInBlankInput: some View {
        VStack(spacing: 12) {
            if let hint = card.hint, !state.isChecked {
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

    // MARK: - Feedback

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

            // Show correct answer for fill-in-blank wrong answers
            if state.answerState == .incorrect,
               card.quizType == .fillInBlank,
               let answers = card.correctAnswers,
               let first = answers.first {
                Text("Answer: \(first)")
                    .font(TarsierFonts.body())
                    .foregroundStyle(TarsierColors.textSecondary)
            }

            if let explanation = card.explanation {
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
