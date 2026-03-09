import SwiftUI

struct QuizSlideView: View {
    let question: SlideQuestion
    let costsHeart: Bool
    let onAnswer: (Bool) -> Void
    let onContinue: () -> Void

    @State private var selectedOption: Int?
    @State private var textAnswer = ""
    @State private var answerState: AnswerState = .unanswered

    enum AnswerState {
        case unanswered, correct, incorrect
    }

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

            if answerState != .unanswered {
                feedbackSection
            }
        }
    }

    // MARK: - Multiple Choice

    private var multipleChoiceOptions: some View {
        VStack(spacing: 10) {
            ForEach(Array((question.options ?? []).enumerated()), id: \.offset) { index, option in
                Button {
                    guard answerState == .unanswered else { return }
                    selectedOption = index
                    checkMultipleChoice(selected: index)
                } label: {
                    HStack {
                        Text(option)
                            .font(TarsierFonts.body())
                            .foregroundStyle(TarsierColors.textPrimary)
                            .multilineTextAlignment(.leading)
                        Spacer()
                        if answerState != .unanswered {
                            if index == question.correctAnswer {
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
        guard answerState != .unanswered else { return TarsierColors.cream }
        if index == question.correctAnswer { return TarsierColors.correctGreen.opacity(0.15) }
        if index == selectedOption && answerState == .incorrect { return TarsierColors.alertRed.opacity(0.15) }
        return TarsierColors.cream
    }

    private func optionBorder(for index: Int) -> Color {
        guard answerState != .unanswered else { return TarsierColors.cardBorder }
        if index == question.correctAnswer { return TarsierColors.correctGreen }
        if index == selectedOption && answerState == .incorrect { return TarsierColors.alertRed }
        return TarsierColors.cardBorder
    }

    // MARK: - Fill in Blank

    private var fillInBlankInput: some View {
        VStack(spacing: 12) {
            if let hint = question.hint, answerState == .unanswered {
                Text("Hint: \(hint)")
                    .font(TarsierFonts.caption())
                    .foregroundStyle(TarsierColors.textSecondary)
                    .italic()
            }

            TextField("Type your answer", text: $textAnswer)
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
                .disabled(answerState != .unanswered)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)

            if answerState == .unanswered {
                PrimaryButton("Check Answer") {
                    checkFillInBlank()
                }
                .disabled(textAnswer.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
    }

    // MARK: - Feedback

    private var feedbackSection: some View {
        VStack(spacing: 12) {
            // Correct / incorrect header
            HStack(spacing: 6) {
                if answerState == .correct {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(TarsierColors.correctGreen)
                    Text("Tama!")
                        .font(TarsierFonts.heading())
                        .foregroundStyle(TarsierColors.correctGreen)
                } else {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(TarsierColors.alertRed)
                    Text("Hindi pa")
                        .font(TarsierFonts.heading())
                        .foregroundStyle(TarsierColors.alertRed)
                }
            }

            // Show correct answer for fill-in-blank when wrong
            if answerState == .incorrect, let answers = question.correctAnswers, let first = answers.first {
                Text("Answer: \(first)")
                    .font(TarsierFonts.body())
                    .foregroundStyle(TarsierColors.textSecondary)
            }

            // Explanation
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

            PrimaryButton("Continue") {
                onContinue()
            }
        }
        .padding(.top, 8)
    }

    // MARK: - Answer Checking

    private func checkMultipleChoice(selected: Int) {
        let isCorrect = selected == question.correctAnswer
        answerState = isCorrect ? .correct : .incorrect
        onAnswer(isCorrect)
    }

    private func checkFillInBlank() {
        let trimmed = textAnswer.trimmingCharacters(in: .whitespaces).lowercased()
        let accepted = (question.correctAnswers ?? []).map { $0.lowercased() }
        let isCorrect = accepted.contains(trimmed)
        answerState = isCorrect ? .correct : .incorrect
        onAnswer(isCorrect)
    }
}
