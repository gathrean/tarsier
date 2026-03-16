import SwiftUI

/// Reusable Bunso mascot + speech bubble layout (Duolingo-style) with a tail pointing at Bunso.
/// The bubble and tail are drawn as a single unified shape — no seams.
struct BunsoSpeechBubble: View {
    let pose: BunsoPose
    let text: String
    var bunsoSize: CGFloat = 70

    private let tailWidth: CGFloat = 10
    private let tailHeight: CGFloat = 16
    private let bubbleRadius: CGFloat = 14

    var body: some View {
        HStack(alignment: .top, spacing: 4) {
            BunsoView(pose: pose, size: bunsoSize)

            // Single unified speech bubble (tail + rounded rect as one shape)
            Text(text)
                .font(TarsierFonts.heading(17))
                .foregroundStyle(TarsierColors.textPrimary)
                .padding(.leading, 14 + tailWidth) // extra left padding for the tail area
                .padding(.trailing, 14)
                .padding(.vertical, 10)
                .background(
                    SpeechBubbleShape(
                        cornerRadius: bubbleRadius,
                        tailWidth: tailWidth,
                        tailHeight: tailHeight,
                        tailTopOffset: 12
                    )
                    .fill(Color.white)
                )
                .overlay(
                    SpeechBubbleShape(
                        cornerRadius: bubbleRadius,
                        tailWidth: tailWidth,
                        tailHeight: tailHeight,
                        tailTopOffset: 12
                    )
                    .stroke(TarsierColors.cardBorder, lineWidth: 1)
                )
        }
        .padding(.horizontal, TarsierSpacing.screenPadding)
    }
}

// MARK: - Unified Speech Bubble Shape

/// A rounded rectangle with an integrated left-pointing tail — one continuous path.
private struct SpeechBubbleShape: Shape {
    let cornerRadius: CGFloat
    let tailWidth: CGFloat
    let tailHeight: CGFloat
    let tailTopOffset: CGFloat // distance from top of bubble to top of tail

    func path(in rect: CGRect) -> Path {
        // The bubble body starts after the tail width
        let bubbleLeft = tailWidth
        let bubbleRect = CGRect(
            x: bubbleLeft, y: rect.minY,
            width: rect.width - tailWidth, height: rect.height
        )
        let r = min(cornerRadius, bubbleRect.width / 2, bubbleRect.height / 2)

        // Tail attachment points on the left edge of the bubble
        let tailTop = tailTopOffset
        let tailTip = CGPoint(x: 0, y: tailTop + tailHeight / 2)
        let tailBottom = tailTop + tailHeight

        var path = Path()

        // Start at top-left corner (after the corner radius)
        path.move(to: CGPoint(x: bubbleLeft + r, y: rect.minY))

        // Top edge → top-right corner
        path.addLine(to: CGPoint(x: bubbleRect.maxX - r, y: rect.minY))
        path.addArc(
            center: CGPoint(x: bubbleRect.maxX - r, y: r),
            radius: r, startAngle: .degrees(-90), endAngle: .degrees(0), clockwise: false
        )

        // Right edge → bottom-right corner
        path.addLine(to: CGPoint(x: bubbleRect.maxX, y: rect.maxY - r))
        path.addArc(
            center: CGPoint(x: bubbleRect.maxX - r, y: rect.maxY - r),
            radius: r, startAngle: .degrees(0), endAngle: .degrees(90), clockwise: false
        )

        // Bottom edge → bottom-left corner
        path.addLine(to: CGPoint(x: bubbleLeft + r, y: rect.maxY))
        path.addArc(
            center: CGPoint(x: bubbleLeft + r, y: rect.maxY - r),
            radius: r, startAngle: .degrees(90), endAngle: .degrees(180), clockwise: false
        )

        // Left edge going up — with tail notch
        path.addLine(to: CGPoint(x: bubbleLeft, y: tailBottom))
        path.addLine(to: tailTip)
        path.addLine(to: CGPoint(x: bubbleLeft, y: tailTop))

        // Continue up left edge → top-left corner
        path.addLine(to: CGPoint(x: bubbleLeft, y: r))
        path.addArc(
            center: CGPoint(x: bubbleLeft + r, y: r),
            radius: r, startAngle: .degrees(180), endAngle: .degrees(270), clockwise: false
        )

        path.closeSubpath()
        return path
    }
}
