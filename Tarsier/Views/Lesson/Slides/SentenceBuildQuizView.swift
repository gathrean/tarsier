import SwiftUI

/// Sentence construction quiz. User taps word blocks in order to build a translation.
struct SentenceBuildQuizView: View {
    let sourceText: String
    let allWords: [String]          // correctOrder + distractors, shuffled
    let correctOrder: [String]
    @Bindable var state: QuizState
    var audioBasePath: String? = nil
    var hideSourceText: Bool = false // Hide when character bubble already shows it

    var body: some View {
        VStack(spacing: 20) {
            // Source text card (English sentence to translate)
            // Hidden when a character bubble already displays it
            if !hideSourceText {
                HStack {
                    Text(sourceText)
                        .font(TarsierFonts.body())
                        .foregroundStyle(TarsierColors.textPrimary)
                        .multilineTextAlignment(.leading)
                    Spacer()
                }
                .padding(TarsierSpacing.cardPadding)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(TarsierColors.cream)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(TarsierColors.cardBorder, lineWidth: 1)
                )
            }

            // Answer area - placed words
            VStack(alignment: .leading, spacing: 8) {
                Text("You say:")
                    .font(TarsierFonts.caption())
                    .foregroundStyle(TarsierColors.textSecondary)

                FlowLayout(spacing: 8) {
                    if state.placedIndices.isEmpty && !state.isChecked {
                        // Empty placeholder
                        Text("Tap words below to build your sentence")
                            .font(TarsierFonts.caption(13))
                            .foregroundStyle(TarsierColors.textSecondary)
                            .italic()
                            .padding(.vertical, 8)
                    }

                    ForEach(Array(state.placedIndices.enumerated()), id: \.offset) { slot, wordIndex in
                        Button {
                            guard !state.isChecked else { return }
                            state.placedIndices.remove(at: slot)
                        } label: {
                            Text(allWords[wordIndex])
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
                    }
                }
                .padding(12)
                .frame(maxWidth: .infinity, minHeight: 60, alignment: .topLeading)
                .background(
                    RoundedRectangle(cornerRadius: TarsierSpacing.cardCornerRadius)
                        .fill(TarsierColors.cream)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: TarsierSpacing.cardCornerRadius)
                        .stroke(TarsierColors.cardBorder, lineWidth: 1)
                )
            }

            // Word bank
            VStack(alignment: .leading, spacing: 8) {
                Text("Word bank:")
                    .font(TarsierFonts.caption())
                    .foregroundStyle(TarsierColors.textSecondary)

                FlowLayout(spacing: 8) {
                    ForEach(Array(allWords.enumerated()), id: \.offset) { index, word in
                        let isPlaced = state.placedIndices.contains(index)
                        Button {
                            guard !state.isChecked, !isPlaced else { return }
                            state.placedIndices.append(index)
                            SoundManager.shared.play("tap")
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            // Play individual word pronunciation if available
                            if let basePath = audioBasePath {
                                let wordFile = word.lowercased()
                                    .replacingOccurrences(of: " ", with: "_")
                                let path = basePath + wordFile + ".mp3"
                                if AudioPlayerService.shared.hasAudio(relativePath: path) {
                                    AudioPlayerService.shared.play(relativePath: path)
                                }
                            }
                        } label: {
                            Text(word)
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
