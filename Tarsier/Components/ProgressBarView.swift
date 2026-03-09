import SwiftUI

struct ProgressBarView: View {
    let current: Int
    let total: Int

    private var progress: CGFloat {
        guard total > 0 else { return 0 }
        return CGFloat(current) / CGFloat(total)
    }

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(TarsierColors.cardBorder)

                Capsule()
                    .fill(TarsierColors.functionalPurple)
                    .frame(width: geo.size.width * progress)
                    .animation(.easeInOut(duration: 0.3), value: current)
            }
        }
        .frame(height: 6)
    }
}
