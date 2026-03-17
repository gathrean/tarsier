import SwiftUI

struct TeachCardView: View {
    let card: SessionCard
    var showCharacterMeaning: Bool = true

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Character header (when character is present on teach card)
            if let character = card.character {
                HStack(spacing: 10) {
                    characterHead(character)
                        .frame(width: 36, height: 36)
                    VStack(alignment: .leading, spacing: 1) {
                        Text(character.displayName)
                            .font(TarsierFonts.caption(13))
                            .fontWeight(.semibold)
                            .foregroundStyle(TarsierColors.textPrimary)
                        if showCharacterMeaning {
                            Text(character.meaning)
                                .font(TarsierFonts.caption(11))
                                .foregroundStyle(TarsierColors.textSecondary)
                        }
                    }
                }
            }

            // Lesson image — render ONLY if file exists in bundle. No placeholder.
            if let uiImage = loadCardImage() {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(3 / 2, contentMode: .fill)
                    .frame(maxWidth: .infinity)
                    .clipShape(RoundedRectangle(cornerRadius: TarsierSpacing.cardCornerRadius))
                    .overlay(
                        RoundedRectangle(cornerRadius: TarsierSpacing.cardCornerRadius)
                            .stroke(TarsierColors.cardBorder, lineWidth: 1)
                    )
                    .accessibilityLabel(card.image?.alt ?? "Lesson image")
            }

            // Highlight (bold heading — the focal point) + speaker icon
            if let highlight = card.highlight {
                HStack(spacing: 10) {
                    HighlightedPoText(text: highlight, font: TarsierFonts.tagalogWord(28), baseColor: TarsierColors.functionalPurple)

                    if let audioPath = card.audio, AudioPlayerService.shared.hasAudio(relativePath: audioPath) {
                        Button {
                            AudioPlayerService.shared.play(relativePath: audioPath)
                        } label: {
                            Image(systemName: "speaker.wave.2.fill")
                                .font(.system(size: 20))
                                .foregroundStyle(TarsierColors.functionalPurple)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            // Body text
            if let body = card.body {
                HighlightedPoText(text: body, font: TarsierFonts.body(17), baseColor: TarsierColors.textPrimary)
            }

            // Example — styled as a distinct card
            if let example = card.example {
                exampleCard(example)
            }

            // Alam Mo Ba? inline callout
            if let alamMoBa = card.alamMoBaInline {
                alamMoBaCallout(alamMoBa)
            }
        }
        .onAppear {
            // Auto-play pronunciation audio when teach card appears
            if let audioPath = card.audio {
                AudioPlayerService.shared.play(relativePath: audioPath)
            }
        }
    }

    // MARK: - Image Loading

    /// Returns UIImage only if the file actually exists. Returns nil otherwise — no placeholder.
    private func loadCardImage() -> UIImage? {
        guard let filename = card.image?.filename, !filename.isEmpty else { return nil }
        if let img = UIImage(named: filename) { return img }
        let nameWithoutExt = (filename as NSString).deletingPathExtension
        if let img = UIImage(named: nameWithoutExt) { return img }
        return nil
    }

    // MARK: - Example Card

    @ViewBuilder
    private func exampleCard(_ example: CardExample) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            // Context label (e.g. "Speaking to your lola")
            if let context = example.context {
                Text(context)
                    .font(TarsierFonts.caption())
                    .foregroundStyle(TarsierColors.textSecondary)
                    .italic()
            }

            if let casual = example.casual, let withPo = example.withPo {
                // Format 1: casual → with_po transformation
                HStack(spacing: 8) {
                    HighlightedPoText(text: casual, font: TarsierFonts.body(), baseColor: TarsierColors.textSecondary)
                    Image(systemName: "arrow.right")
                        .font(TarsierFonts.caption())
                        .foregroundStyle(TarsierColors.textSecondary)
                    HighlightedPoText(text: withPo, font: TarsierFonts.body().bold(), baseColor: TarsierColors.functionalPurple)
                }
            } else if let sentence = example.sentence {
                // Format 2: sentence + translation
                HighlightedPoText(text: sentence, font: TarsierFonts.tagalogWord(18), baseColor: TarsierColors.functionalPurple)

                if let translation = example.translation {
                    HighlightedPoText(text: translation, font: TarsierFonts.body(15), baseColor: TarsierColors.textSecondary)
                }

                if let poPosition = example.poPosition {
                    Text(poPosition)
                        .font(TarsierFonts.caption())
                        .foregroundStyle(TarsierColors.functionalPurple)
                        .italic()
                }
            }

            // Note
            if let note = example.note {
                Text(note)
                    .font(TarsierFonts.caption())
                    .foregroundStyle(TarsierColors.textSecondary)
                    .italic()
            }

            // Taglish variant callout
            if let taglish = example.taglish {
                HStack(spacing: 0) {
                    Rectangle()
                        .fill(TarsierColors.functionalPurple)
                        .frame(width: 3)
                    Text(taglish)
                        .font(TarsierFonts.caption())
                        .foregroundStyle(TarsierColors.textSecondary)
                        .padding(.leading, 10)
                        .padding(.vertical, 4)
                }
            }
        }
        .padding(TarsierSpacing.cardPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(TarsierColors.functionalPurple.opacity(0.06))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(TarsierColors.functionalPurple.opacity(0.15), lineWidth: 1)
        )
    }

    // MARK: - Character Head

    @ViewBuilder
    private func characterHead(_ character: TarsierCharacter) -> some View {
        if let imageName = character.imageName {
            Image(imageName)
                .resizable()
                .scaledToFill()
                .clipShape(Circle())
        } else {
            Circle()
                .fill(Color(.systemGray5))
                .overlay(
                    Text(character.emoji)
                        .font(.system(size: 20))
                )
        }
    }

    // MARK: - Alam Mo Ba? Callout

    @ViewBuilder
    private func alamMoBaCallout(_ alamMoBa: AlamMoBaInline) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Text(alamMoBa.emoji ?? "💡")
                .font(.system(size: 18))

            VStack(alignment: .leading, spacing: 4) {
                Text("Alam Mo Ba?")
                    .font(TarsierFonts.caption())
                    .foregroundStyle(TarsierColors.gold)
                    .fontWeight(.semibold)
                Text(alamMoBa.fact)
                    .font(TarsierFonts.caption())
                    .foregroundStyle(TarsierColors.textPrimary)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(TarsierColors.gold.opacity(0.10))
        )
    }
}
