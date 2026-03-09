import SwiftUI

struct ProgressRingView: View {
    let completed: Int
    let total: Int
    var size: CGFloat = 64
    var lineWidth: CGFloat = 4

    private var progress: CGFloat {
        guard total > 0 else { return 0 }
        return CGFloat(completed) / CGFloat(total)
    }

    var body: some View {
        ZStack {
            // Background track
            Circle()
                .stroke(TarsierColors.cardBorder, lineWidth: lineWidth)

            // Filled arc
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    TarsierColors.functionalPurple,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.5), value: completed)
        }
        .frame(width: size, height: size)
    }
}
