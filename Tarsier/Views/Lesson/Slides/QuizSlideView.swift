import SwiftUI
import Observation

// MARK: - Quiz State (shared between QuizSlideView and LessonContainerView)

@Observable
class QuizState {
    var selectedOption: Int?
    var textAnswer: String = ""
    var answerState: AnswerState = .unanswered

    // Word-order state
    var placedIndices: [Int] = []
    var totalWordPieces: Int = 0
    var wordOrderFeedbackSuffix: String? = nil

    enum AnswerState {
        case unanswered, correct, incorrect
    }

    var hasSelection: Bool {
        if totalWordPieces > 0 { return placedIndices.count == totalWordPieces }
        return selectedOption != nil || !textAnswer.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var isChecked: Bool { answerState != .unanswered }

    func reset() {
        selectedOption = nil
        textAnswer = ""
        answerState = .unanswered
        placedIndices = []
        totalWordPieces = 0
        wordOrderFeedbackSuffix = nil
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

    /// Check word order. Returns true if placed words match any correct order.
    /// Sets wordOrderFeedbackSuffix when correct but not best order.
    func checkWordOrder(placedWords: [String], correctOrders: [[String]], bestOrder: [String]) -> Bool {
        let isCorrect = correctOrders.contains(placedWords)
        if isCorrect {
            if placedWords != bestOrder {
                wordOrderFeedbackSuffix = bestOrder.joined(separator: " ")
            }
            answerState = .correct
        } else {
            answerState = .incorrect
        }
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
    /// Shuffled word pieces for word_order quiz. Provided by parent.
    let shuffledWordPieces: [String]
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
            case .wordOrder:
                WordOrderQuizView(pieces: shuffledWordPieces, state: state)
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
            return .white
        }
        if index == state.selectedOption { return TarsierColors.primaryLight }
        return .white
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
            // Feedback banner
            HStack(spacing: 8) {
                if state.answerState == .correct {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.white)
                    TappableTagalogWord(
                        word: "Tama!",
                        translation: "Correct!",
                        font: TarsierFonts.heading(),
                        color: .white
                    )
                } else {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.white)
                    TappableTagalogWord(
                        word: "Mali",
                        translation: "Wrong",
                        font: TarsierFonts.heading(),
                        color: .white
                    )
                }
            }
            .padding(.horizontal, TarsierSpacing.cardPadding)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(state.answerState == .correct ? TarsierColors.correctGreen : TarsierColors.alertRed)
            )

            // "More natural" note for word-order
            if state.answerState == .correct, let suffix = state.wordOrderFeedbackSuffix {
                Text("Though \"\(suffix)\" is more natural.")
                    .font(TarsierFonts.caption())
                    .foregroundStyle(TarsierColors.textSecondary)
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

// MARK: - Word Order Quiz View

struct WordOrderQuizView: View {
    let pieces: [String]
    @Bindable var state: QuizState

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Builder row — placed pills (left to right)
            VStack(alignment: .leading, spacing: 8) {
                Text("Your sentence:")
                    .font(TarsierFonts.caption())
                    .foregroundStyle(TarsierColors.textSecondary)

                FlowLayout(spacing: 8) {
                    ForEach(0..<pieces.count, id: \.self) { slot in
                        if slot < state.placedIndices.count {
                            let pieceIndex = state.placedIndices[slot]
                            Button {
                                guard !state.isChecked else { return }
                                state.placedIndices.remove(at: slot)
                            } label: {
                                Text(pieces[pieceIndex])
                                    .font(TarsierFonts.body())
                                    .foregroundStyle(TarsierColors.functionalPurple)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 8)
                                    .background(
                                        Capsule()
                                            .fill(TarsierColors.primaryLight)
                                    )
                                    .overlay(
                                        Capsule()
                                            .stroke(TarsierColors.functionalPurple, lineWidth: 1.5)
                                    )
                            }
                            .buttonStyle(.plain)
                            .disabled(state.isChecked)
                        } else {
                            Capsule()
                                .strokeBorder(
                                    TarsierColors.cardBorder,
                                    style: StrokeStyle(lineWidth: 1.5, dash: [5, 3])
                                )
                                .frame(width: 60, height: 36)
                        }
                    }
                }
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: TarsierSpacing.cardCornerRadius)
                        .fill(TarsierColors.cream)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: TarsierSpacing.cardCornerRadius)
                        .stroke(TarsierColors.cardBorder, lineWidth: 1)
                )
            }

            // Available pills pool
            VStack(alignment: .leading, spacing: 8) {
                Text("Word bank:")
                    .font(TarsierFonts.caption())
                    .foregroundStyle(TarsierColors.textSecondary)

                FlowLayout(spacing: 8) {
                    ForEach(Array(pieces.enumerated()), id: \.offset) { index, piece in
                        let isPlaced = state.placedIndices.contains(index)
                        Button {
                            guard !state.isChecked, !isPlaced else { return }
                            state.placedIndices.append(index)
                        } label: {
                            Text(piece)
                                .font(TarsierFonts.body())
                                .foregroundStyle(isPlaced ? .clear : TarsierColors.textPrimary)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(
                                    Capsule()
                                        .fill(isPlaced ? TarsierColors.cardBorder.opacity(0.4) : .white)
                                )
                                .overlay(
                                    Capsule()
                                        .stroke(isPlaced ? .clear : TarsierColors.cardBorder, lineWidth: 1.5)
                                )
                        }
                        .buttonStyle(.plain)
                        .disabled(state.isChecked || isPlaced)
                    }
                }
            }
        }
    }
}

