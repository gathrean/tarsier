import SwiftUI

struct StartBubbleView: View {
    var body: some View {
        VStack(spacing: 0) {
            Text("Start!")
                .font(TarsierFonts.button(15))
                .foregroundStyle(TarsierColors.functionalPurple)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(TarsierColors.cardBorder, lineWidth: 1.5)
                        )
                )

            // Downward caret
            BubbleCaret()
                .fill(.white)
                .frame(width: 14, height: 8)
                .overlay(
                    BubbleCaret()
                        .stroke(TarsierColors.cardBorder, lineWidth: 1.5)
                )
                .offset(y: -1) // overlap to hide top border seam
        }
    }
}

// MARK: - Triangle Shape for Caret

private struct BubbleCaret: Shape {
    func path(in rect: CGRect) -> Path {
        Path { p in
            p.move(to: CGPoint(x: rect.midX, y: rect.maxY))
            p.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
            p.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
            p.closeSubpath()
        }
    }
}
