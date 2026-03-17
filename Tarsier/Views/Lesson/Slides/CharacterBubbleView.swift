import SwiftUI

/// Shows a character head + speech bubble. Used in quiz and teach cards
/// when a `character` field is present in the JSON.
struct CharacterBubbleView: View {
    let character: TarsierCharacter
    let text: String
    var translation: String? = nil
    var audio: String? = nil
    var showMeaning: Bool = true

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Character head + name
            VStack(spacing: 4) {
                characterHead
                    .frame(width: 48, height: 48)

                Text(character.displayName)
                    .font(TarsierFonts.caption(11))
                    .foregroundStyle(TarsierColors.textSecondary)

                if showMeaning {
                    Text("(\(character.meaning))")
                        .font(TarsierFonts.caption(10))
                        .foregroundStyle(TarsierColors.textSecondary)
                        .opacity(0.7)
                }
            }

            // Speech bubble
            HStack(alignment: .top, spacing: 8) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(text)
                        .font(TarsierFonts.body().bold())
                        .foregroundStyle(TarsierColors.textPrimary)

                    if let translation {
                        Text(translation)
                            .font(TarsierFonts.body(14))
                            .foregroundStyle(TarsierColors.textSecondary)
                    }
                }

                Spacer(minLength: 0)

                if let audioPath = audio, AudioPlayerService.shared.hasAudio(relativePath: audioPath) {
                    Button {
                        AudioPlayerService.shared.play(relativePath: audioPath)
                    } label: {
                        Image(systemName: "speaker.wave.2.fill")
                            .font(.system(size: 16))
                            .foregroundStyle(TarsierColors.functionalPurple)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(12)
            .background(
                BubbleShape(tailOnLeft: true)
                    .fill(Color(hex: "#F5F5F5"))
            )
            .background(
                BubbleShape(tailOnLeft: true)
                    .stroke(TarsierColors.cardBorder, lineWidth: 1)
            )
        }
    }

    @ViewBuilder
    private var characterHead: some View {
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
                        .font(.system(size: 28))
                )
        }
    }
}

/// Rounded rectangle with a small triangle tail on one side.
private struct BubbleShape: Shape {
    var tailOnLeft: Bool = true
    var cornerRadius: CGFloat = 12
    var tailSize: CGFloat = 8

    func path(in rect: CGRect) -> Path {
        var path = Path()

        let r = cornerRadius
        let tailY = min(rect.height * 0.3, 24.0)

        // Main rounded rect
        path.addRoundedRect(in: rect, cornerSize: CGSize(width: r, height: r))

        // Tail triangle
        if tailOnLeft {
            var tail = Path()
            let x = rect.minX
            tail.move(to: CGPoint(x: x, y: tailY))
            tail.addLine(to: CGPoint(x: x - tailSize, y: tailY + tailSize))
            tail.addLine(to: CGPoint(x: x, y: tailY + tailSize * 2))
            tail.closeSubpath()
            path.addPath(tail)
        }

        return path
    }
}
