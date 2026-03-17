import SwiftUI

/// 2x2 image grid quiz. User taps the image that matches the prompt.
struct ImageMatchQuizView: View {
    let options: [ImageMatchOption]
    let shuffledIndices: [Int]
    @Bindable var state: QuizState
    /// Index of the correct option within shuffledIndices
    let correctIndex: Int

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
    ]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            ForEach(Array(shuffledIndices.enumerated()), id: \.offset) { displayIndex, originalIndex in
                let option = options[originalIndex]
                Button {
                    guard !state.isChecked else { return }
                    state.selectedOption = displayIndex
                    SoundManager.shared.play("tap")
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                } label: {
                    VStack(spacing: 8) {
                        imageContent(for: option)
                            .frame(height: 120)
                            .frame(maxWidth: .infinity)
                            .clipShape(RoundedRectangle(cornerRadius: 12))

                        Text(option.label)
                            .font(TarsierFonts.body(14))
                            .foregroundStyle(TarsierColors.textPrimary)
                    }
                    .padding(10)
                    .background(
                        RoundedRectangle(cornerRadius: TarsierSpacing.cardCornerRadius)
                            .fill(cardBackground(for: displayIndex))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: TarsierSpacing.cardCornerRadius)
                            .stroke(cardBorder(for: displayIndex), lineWidth: 2)
                    )
                }
                .buttonStyle(.plain)
                .disabled(state.isChecked)
            }
        }
    }

    // MARK: - Image Content

    @ViewBuilder
    private func imageContent(for option: ImageMatchOption) -> some View {
        let filename = option.image
        let nameWithoutExt = (filename as NSString).deletingPathExtension

        if UIImage(named: filename) != nil {
            Image(filename)
                .resizable()
                .scaledToFill()
        } else if UIImage(named: nameWithoutExt) != nil {
            Image(nameWithoutExt)
                .resizable()
                .scaledToFill()
        } else {
            // Grey placeholder
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(.systemGray5))
                .overlay(
                    Text(nameWithoutExt)
                        .font(TarsierFonts.caption(13))
                        .foregroundStyle(.secondary)
                )
        }
    }

    // MARK: - Styling

    private func cardBackground(for index: Int) -> Color {
        if state.isChecked {
            if index == correctIndex { return TarsierColors.correctGreen.opacity(0.15) }
            if index == state.selectedOption && state.answerState == .incorrect { return TarsierColors.alertRed.opacity(0.15) }
            return .white
        }
        if index == state.selectedOption { return TarsierColors.primaryLight }
        return .white
    }

    private func cardBorder(for index: Int) -> Color {
        if state.isChecked {
            if index == correctIndex { return TarsierColors.correctGreen }
            if index == state.selectedOption && state.answerState == .incorrect { return TarsierColors.alertRed }
            return TarsierColors.cardBorder
        }
        if index == state.selectedOption { return TarsierColors.functionalPurple }
        return TarsierColors.cardBorder
    }
}
