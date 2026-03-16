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
    @FocusState private var isTextFieldFocused: Bool

    var body: some View {
        VStack(spacing: 20) {
            if let prompt = card.prompt {
                HStack(spacing: 10) {
                    Text(prompt)
                        .font(TarsierFonts.heading(20))
                        .foregroundStyle(TarsierColors.textPrimary)
                        .multilineTextAlignment(.center)

                    // Speaker icon for Tagalog prompts (no auto-play on quiz cards)
                    if let audioPath = card.audio, AudioPlayerService.shared.hasAudio(relativePath: audioPath) {
                        Button {
                            AudioPlayerService.shared.play(relativePath: audioPath)
                        } label: {
                            Image(systemName: "speaker.wave.2.fill")
                                .font(.system(size: 18))
                                .foregroundStyle(TarsierColors.functionalPurple)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            switch card.quizType {
            case .multipleChoice:
                multipleChoiceOptions
            case .fillInBlank:
                fillInBlankInput
            case .wordOrder:
                WordOrderQuizView(
                    pieces: shuffledWordPieces,
                    state: state,
                    audioBasePath: card.audio.flatMap { ($0 as NSString).deletingLastPathComponent + "/" }
                )
            case .none:
                EmptyView()
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
                .focused($isTextFieldFocused)
                .disabled(state.isChecked)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        isTextFieldFocused = true
                    }
                }

            if let hint = card.hint, !state.isChecked {
                Text("Hint: \(hint)")
                    .font(TarsierFonts.caption())
                    .foregroundStyle(TarsierColors.textSecondary)
                    .italic()
            }
        }
    }

}

// MARK: - Word Order Quiz View

struct WordOrderQuizView: View {
    let pieces: [String]
    @Bindable var state: QuizState
    /// Base audio path for the lesson (e.g., "audio/lesson_001/") used to look up individual word pronunciation
    var audioBasePath: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Builder row — fixed slots, each sized to its word
            VStack(alignment: .leading, spacing: 8) {
                Text("Your sentence:")
                    .font(TarsierFonts.caption())
                    .foregroundStyle(TarsierColors.textSecondary)

                FlowLayout(spacing: 8) {
                    // Always render all slots using the original piece order for sizing
                    ForEach(0..<pieces.count, id: \.self) { slot in
                        wordSlot(at: slot)
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
                            SoundManager.shared.play("tap")
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            // Play individual word pronunciation if available
                            if let basePath = audioBasePath {
                                let wordFile = piece.lowercased()
                                    .replacingOccurrences(of: " ", with: "_")
                                let path = basePath + wordFile + ".mp3"
                                if AudioPlayerService.shared.hasAudio(relativePath: path) {
                                    AudioPlayerService.shared.play(relativePath: path)
                                }
                            }
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

    /// Each slot is sized to the longest word so slots never shift.
    /// Filled slots show the placed word; empty slots show a dashed outline.
    @ViewBuilder
    private func wordSlot(at slot: Int) -> some View {
        let isFilled = slot < state.placedIndices.count
        let longestPiece = pieces.max(by: { $0.count < $1.count }) ?? ""

        // Hidden text sets a fixed minimum width per slot
        Text(longestPiece)
            .font(TarsierFonts.body())
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .hidden()
            .overlay {
                if isFilled {
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
                            .frame(maxWidth: .infinity)
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
                }
            }
    }
}

