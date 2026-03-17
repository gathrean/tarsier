import SwiftUI
import SwiftData

/// Bunso waving + speech bubble greeting at the top of the roadmap.
/// Scrolls with content (not pinned).
struct BunsoGreetingHeader: View {
    let greeting: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Bunso illustration or emoji placeholder
            bunsoAvatar
                .frame(width: 80, height: 80)

            // Speech bubble
            VStack(alignment: .leading, spacing: 2) {
                Text(greeting)
                    .font(TarsierFonts.body(15))
                    .foregroundStyle(TarsierColors.textPrimary)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(
                SpeechBubble()
                    .fill(.white)
            )
            .background(
                SpeechBubble()
                    .stroke(TarsierColors.cardBorder, lineWidth: 1)
            )

            Spacer(minLength: 0)
        }
        .padding(.horizontal, TarsierSpacing.screenPadding)
        .padding(.vertical, 8)
    }

    @ViewBuilder
    private var bunsoAvatar: some View {
        if let _ = UIImage(named: "character_bunso") {
            Image("character_bunso")
                .resizable()
                .scaledToFit()
        } else if let _ = UIImage(named: "Tarsier-Waving") {
            Image("Tarsier-Waving")
                .resizable()
                .scaledToFit()
        } else {
            Circle()
                .fill(TarsierColors.primaryLight)
                .overlay(
                    Text("🐵")
                        .font(.system(size: 40))
                )
        }
    }
}

/// Rounded rectangle with a left-pointing tail for the speech bubble.
private struct SpeechBubble: Shape {
    var cornerRadius: CGFloat = 12
    var tailSize: CGFloat = 8

    func path(in rect: CGRect) -> Path {
        var path = Path()

        // Main rounded rect
        path.addRoundedRect(in: rect, cornerSize: CGSize(width: cornerRadius, height: cornerRadius))

        // Left-pointing tail
        let tailY: CGFloat = min(rect.height * 0.35, 20)
        var tail = Path()
        tail.move(to: CGPoint(x: rect.minX, y: tailY))
        tail.addLine(to: CGPoint(x: rect.minX - tailSize, y: tailY + tailSize))
        tail.addLine(to: CGPoint(x: rect.minX, y: tailY + tailSize * 2))
        tail.closeSubpath()
        path.addPath(tail)

        return path
    }
}
