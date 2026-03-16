import SwiftUI
import SwiftData

/// Screen 17: Loading screen — persists onboarding data and transitions to first lesson
struct LoadingScreen: View {
    let profile: UserProfile
    let onComplete: () -> Void

    @Environment(\.modelContext) private var modelContext
    @State private var loadingText = "Writing your first lesson..."
    @State private var progress: CGFloat = 0
    @State private var displayPercent: Int = 0

    private let ringSize: CGFloat = 140
    private let ringLineWidth: CGFloat = 10

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            // Circular progress ring with Bunso inside
            ZStack {
                // Track
                Circle()
                    .stroke(TarsierColors.cardBorder, lineWidth: ringLineWidth)
                    .frame(width: ringSize, height: ringSize)

                // Fill
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        TarsierColors.functionalPurple,
                        style: StrokeStyle(lineWidth: ringLineWidth, lineCap: .round)
                    )
                    .frame(width: ringSize, height: ringSize)
                    .rotationEffect(.degrees(-90))

                BunsoView(pose: .reading, size: 80)
            }

            VStack(spacing: 8) {
                Text(loadingText)
                    .font(TarsierFonts.heading(20))
                    .foregroundStyle(TarsierColors.textPrimary)
                    .multilineTextAlignment(.center)
                    .contentTransition(.numericText())

                Text("\(displayPercent)%")
                    .font(TarsierFonts.caption(15))
                    .foregroundStyle(TarsierColors.textSecondary)
                    .contentTransition(.numericText())
                    .monospacedDigit()
            }
            .padding(.horizontal, TarsierSpacing.screenPadding)

            Spacer()
        }
        .onAppear {
            startLoading()
        }
    }

    // MARK: - Staggered loading with haptics

    private func startLoading() {
        let haptic = UIImpactFeedbackGenerator(style: .light)
        haptic.prepare()

        // Phase 1: Quick burst to ~18% (0.0s – 0.4s)
        animateProgress(to: 0.18, percent: 18, duration: 0.4)
        haptic.impactOccurred()

        // Phase 2: Pause, then crawl to ~35% (0.7s – 1.4s)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            haptic.impactOccurred(intensity: 0.5)
            animateProgress(to: 0.35, percent: 35, duration: 0.7)
        }

        // Phase 3: Stall at ~42% (1.6s – 2.2s) — feels like it's "thinking"
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
            animateProgress(to: 0.42, percent: 42, duration: 0.6)
        }

        // Phase 4: Jump to ~68% with text change (2.4s – 3.0s)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.4) {
            haptic.impactOccurred(intensity: 0.7)
            withAnimation(.easeInOut(duration: 0.3)) {
                loadingText = "Personalizing your experience..."
            }
            animateProgress(to: 0.68, percent: 68, duration: 0.6)
        }

        // Phase 5: Slow crawl to ~85% (3.2s – 4.0s)
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.2) {
            animateProgress(to: 0.85, percent: 85, duration: 0.8)
        }

        // Phase 6: Final push to 100% + save (4.2s – 4.6s)
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.2) {
            try? modelContext.save()
            haptic.impactOccurred(intensity: 1.0)
            withAnimation(.easeInOut(duration: 0.3)) {
                loadingText = "Let's go!"
            }
            animateProgress(to: 1.0, percent: 100, duration: 0.4)
        }

        // Phase 7: Complete
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            let done = UINotificationFeedbackGenerator()
            done.notificationOccurred(.success)
            onComplete()
        }
    }

    private func animateProgress(to value: CGFloat, percent: Int, duration: Double) {
        withAnimation(.easeInOut(duration: duration)) {
            progress = value
        }
        withAnimation(.easeInOut(duration: duration)) {
            displayPercent = percent
        }
    }
}
