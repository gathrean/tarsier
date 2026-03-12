import SwiftUI

struct CoachMarkOverlay: View {
    let targetRect: CGRect
    let message: String
    let arrowPointsDown: Bool

    @State private var pulseScale: CGFloat = 1.0

    var body: some View {
        ZStack {
            // Semi-transparent scrim (no spotlight cutout — simpler & more reliable)
            Color.black.opacity(0.35)
                .ignoresSafeArea()

            // Arrow + label positioned near the target
            VStack(spacing: 4) {
                if arrowPointsDown {
                    labelPill
                    arrowIcon(pointsDown: true)
                } else {
                    arrowIcon(pointsDown: false)
                    labelPill
                }
            }
            .position(
                x: targetRect.midX,
                y: arrowPointsDown ? targetRect.minY - 40 : targetRect.maxY + 40
            )
        }
    }

    private var labelPill: some View {
        Text(message)
            .font(.system(size: 14, weight: .semibold, design: .rounded))
            .foregroundStyle(.white)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(
                Capsule().fill(TarsierColors.functionalPurple)
            )
    }

    private func arrowIcon(pointsDown: Bool) -> some View {
        Image(systemName: pointsDown ? "arrow.down" : "arrow.up")
            .font(.system(size: 20, weight: .bold))
            .foregroundStyle(.white)
            .scaleEffect(pulseScale)
            .onAppear {
                withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                    pulseScale = 1.15
                }
            }
    }
}
