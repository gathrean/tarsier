import SwiftUI

struct TeachCardView: View {
    let card: SessionCard
    var showCharacterMeaning: Bool = true

    /// Tracks how many content blocks are visible (progressive reveal).
    @Binding var visibleBlockCount: Int
    /// Total number of blocks for this card.
    @Binding var totalBlockCount: Int

    private var isIntroLayout: Bool { card.introLayout == true }

    var body: some View {
        if isIntroLayout {
            introBody
        } else {
            standardBody
        }
    }

    // MARK: - Intro Layout (HelloChinese-style centered, visual-heavy)

    // MARK: - Intro Block Model

    private enum IntroBlock {
        case emojiAndHighlight(emoji: String, text: String)
        case highlight(String)
        case callout(String)
        case body(String)
        case bulletPoint(String)
    }

    private func buildIntroBlocks() -> [IntroBlock] {
        var blocks: [IntroBlock] = []
        let hasCallout = card.callout != nil

        // Cards with callout: callout first, then highlight below it (no emoji)
        // Cards without callout: emoji + highlight together as first block
        if hasCallout {
            if let callout = card.callout {
                blocks.append(.callout(callout))
            }
            if let highlight = card.highlight {
                blocks.append(.highlight(highlight))
            }
        } else {
            if let highlight = card.highlight {
                if let emoji = card.emoji {
                    blocks.append(.emojiAndHighlight(emoji: emoji, text: highlight))
                } else {
                    blocks.append(.highlight(highlight))
                }
            }
        }

        // Body text: split on bullet points for individual reveal
        if let body = card.body {
            let parts = splitBodyIntoParts(body)
            for part in parts {
                if part.hasPrefix("\u{2022}") {
                    blocks.append(.bulletPoint(part))
                } else {
                    blocks.append(.body(part))
                }
            }
        }

        return blocks
    }

    /// Splits body text into separate parts: paragraphs and individual bullet points.
    /// Each bullet point becomes its own reveal block.
    private func splitBodyIntoParts(_ text: String) -> [String] {
        // Split on double newlines to get paragraphs
        let paragraphs = text.components(separatedBy: "\n\n")
        var parts: [String] = []

        for paragraph in paragraphs {
            let trimmed = paragraph.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else { continue }

            if trimmed.hasPrefix("\u{2022}") {
                // This paragraph contains bullet points - split each line
                let lines = trimmed.components(separatedBy: "\n")
                for line in lines {
                    let lineTrimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
                    if !lineTrimmed.isEmpty {
                        parts.append(lineTrimmed)
                    }
                }
            } else {
                parts.append(trimmed)
            }
        }

        return parts
    }

    private var introBody: some View {
        let blocks = buildIntroBlocks()

        return VStack(alignment: .leading, spacing: 0) {
            Spacer(minLength: 20)

            ForEach(Array(blocks.prefix(visibleBlockCount).enumerated()), id: \.offset) { _, block in
                introBlockView(for: block)
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                    .animation(.easeOut(duration: 0.3), value: visibleBlockCount)
            }

            Spacer(minLength: 20)
        }
        .padding(.horizontal, 4)
        .onAppear {
            let blocks = buildIntroBlocks()
            totalBlockCount = blocks.count
            visibleBlockCount = min(1, blocks.count)

            if let audioPath = card.audio {
                AudioPlayerService.shared.play(relativePath: audioPath)
            }
        }
    }

    @ViewBuilder
    private func introBlockView(for block: IntroBlock) -> some View {
        switch block {
        case .emojiAndHighlight(let emoji, let text):
            VStack(spacing: 12) {
                if emoji == "bunso" {
                    BunsoView(pose: .celebrating, size: 120)
                } else {
                    Text(emoji)
                        .font(.system(size: 80))
                }
                HighlightedPoText(
                    text: text,
                    font: .system(size: 28, weight: .bold, design: .rounded),
                    baseColor: TarsierColors.textPrimary
                )
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 8)
            .padding(.bottom, 20)

        case .highlight(let text):
            HighlightedPoText(
                text: text,
                font: .system(size: 28, weight: .bold, design: .rounded),
                baseColor: TarsierColors.textPrimary
            )
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 8)
            .padding(.bottom, 16)

        case .callout(let text):
            Text(text)
                .font(.system(size: 26, weight: .semibold, design: .rounded))
                .foregroundStyle(TarsierColors.textSecondary)
                .tracking(2)
                .lineSpacing(10)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .padding(.horizontal, 16)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(TarsierColors.cream)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(TarsierColors.cardBorder, lineWidth: 1)
                )
                .padding(.horizontal, 8)
                .padding(.bottom, 8)

        case .body(let text):
            HighlightedPoText(
                text: text,
                font: .system(size: 17, weight: .regular, design: .rounded),
                baseColor: TarsierColors.textSecondary
            )
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 8)
            .padding(.bottom, 8)

        case .bulletPoint(let text):
            HighlightedPoText(
                text: text,
                font: .system(size: 17, weight: .regular, design: .rounded),
                baseColor: TarsierColors.textSecondary
            )
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 8)
            .padding(.bottom, 4)
        }
    }

    // MARK: - Standard Layout (progressive reveal)

    private var standardBody: some View {
        let blocks = buildBlocks()

        return VStack(alignment: .leading, spacing: 16) {
            ForEach(Array(blocks.prefix(visibleBlockCount).enumerated()), id: \.offset) { index, block in
                blockView(for: block)
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                    .animation(.easeOut(duration: 0.3), value: visibleBlockCount)
            }
        }
        .padding(.horizontal, 4)
        .onAppear {
            let blocks = buildBlocks()
            totalBlockCount = blocks.count
            visibleBlockCount = min(1, blocks.count)

            // Auto-play pronunciation audio when teach card appears
            if let audioPath = card.audio {
                AudioPlayerService.shared.play(relativePath: audioPath)
            }
        }
    }

    // MARK: - Block Model

    private enum TeachBlock {
        case character(TarsierCharacter)
        case image(UIImage, alt: String?)
        case highlight(String, audioPath: String?)
        case body(String)
        case callout(String)
        case example(CardExample)
    }

    // MARK: - Build Blocks from Card Data

    private func buildBlocks() -> [TeachBlock] {
        var blocks: [TeachBlock] = []

        if let character = card.character {
            blocks.append(.character(character))
        }

        if let uiImage = loadCardImage() {
            blocks.append(.image(uiImage, alt: card.image?.alt))
        }

        if let highlight = card.highlight {
            blocks.append(.highlight(highlight, audioPath: card.audio))
        }

        if let body = card.body {
            blocks.append(.body(body))
        }

        if let callout = card.callout {
            blocks.append(.callout(callout))
        }

        if let example = card.example {
            blocks.append(.example(example))
        }

        // Multiple examples (e.g. time-of-day greetings on one card)
        if let examples = card.examples {
            for ex in examples {
                blocks.append(.example(ex))
            }
        }

        return blocks
    }

    // MARK: - Block Rendering

    @ViewBuilder
    private func blockView(for block: TeachBlock) -> some View {
        switch block {
        case .character(let character):
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

        case .image(let uiImage, let alt):
            Image(uiImage: uiImage)
                .resizable()
                .aspectRatio(3 / 2, contentMode: .fill)
                .frame(maxWidth: .infinity)
                .frame(minHeight: 240)
                .clipShape(RoundedRectangle(cornerRadius: TarsierSpacing.cardCornerRadius))
                .overlay(
                    RoundedRectangle(cornerRadius: TarsierSpacing.cardCornerRadius)
                        .stroke(TarsierColors.cardBorder, lineWidth: 1)
                )
                .accessibilityLabel(alt ?? "Lesson image")

        case .highlight(let text, let audioPath):
            HStack(spacing: 10) {
                HighlightedPoText(text: text, font: .system(size: 32, weight: .bold, design: .rounded), baseColor: TarsierColors.functionalPurple)

                if let audioPath, AudioPlayerService.shared.hasAudio(relativePath: audioPath) {
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
            .frame(maxWidth: .infinity, alignment: .center)

        case .body(let text):
            HighlightedPoText(text: text, font: .system(size: 18, weight: .regular, design: .rounded), baseColor: TarsierColors.textPrimary)

        case .callout(let text):
            Text(text)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(TarsierColors.functionalPurple)
                .tracking(2)
                .lineSpacing(12)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .padding(.horizontal, 16)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(TarsierColors.functionalPurple.opacity(0.06))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(TarsierColors.functionalPurple.opacity(0.15), lineWidth: 1)
                )

        case .example(let example):
            exampleCard(example)
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

}
