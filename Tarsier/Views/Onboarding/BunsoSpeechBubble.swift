import SwiftUI

/// Reusable Bunso mascot + speech bubble layout (Duolingo-style) with a tail pointing at Bunso
struct BunsoSpeechBubble: View {
    let pose: BunsoPose
    let text: String
    var bunsoSize: CGFloat = 70

    private let tailSize: CGFloat = 10
    private let bubbleRadius: CGFloat = 14

    var body: some View {
        HStack(alignment: .top, spacing: 4) {
            BunsoView(pose: pose, size: bunsoSize)

            // Speech bubble with left-pointing tail
            HStack(spacing: 0) {
                // Tail triangle
                BubbleTail(size: tailSize)
                    .fill(Color.white)
                    .overlay(
                        BubbleTail(size: tailSize)
                            .stroke(TarsierColors.cardBorder, lineWidth: 1)
                    )
                    .frame(width: tailSize, height: tailSize * 2)
                    .offset(x: 1) // overlap 1pt to hide the seam
                    .padding(.top, 14)

                Text(text)
                    .font(TarsierFonts.heading(17))
                    .foregroundStyle(TarsierColors.textPrimary)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: bubbleRadius)
                            .fill(Color.white)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: bubbleRadius)
                            .stroke(TarsierColors.cardBorder, lineWidth: 1)
                    )
            }
        }
        .padding(.horizontal, TarsierSpacing.screenPadding)
    }
}

// MARK: - Tail Shape

/// A small triangle pointing left, used as the speech bubble tail
private struct BubbleTail: Shape {
    let size: CGFloat

    func path(in rect: CGRect) -> Path {
        var path = Path()
        // Point on the left (tip), then top-right, then bottom-right
        path.move(to: CGPoint(x: 0, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}
