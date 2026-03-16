import SwiftUI
import SwiftData

/// Screen 17: Loading screen — persists onboarding data and transitions to first lesson
struct LoadingScreen: View {
    let profile: UserProfile
    let onComplete: () -> Void

    @Environment(\.modelContext) private var modelContext
    @State private var loadingText = "Building your course..."
    @State private var progress: CGFloat = 0
    @State private var isComplete = false

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            BunsoView(pose: .reading, size: 140)

            VStack(spacing: 12) {
                Text(loadingText)
                    .font(TarsierFonts.heading(20))
                    .foregroundStyle(TarsierColors.textPrimary)
                    .animation(.easeInOut, value: loadingText)

                // Progress bar
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(TarsierColors.cardBorder)
                            .frame(height: 8)

                        Capsule()
                            .fill(TarsierColors.functionalPurple)
                            .frame(width: geo.size.width * progress, height: 8)
                            .animation(.easeInOut(duration: 0.3), value: progress)
                    }
                }
                .frame(height: 8)
                .padding(.horizontal, 60)
            }

            Spacer()
        }
        .onAppear {
            startLoading()
        }
    }

    private func startLoading() {
        // Animate progress
        withAnimation(.easeInOut(duration: 0.8)) { progress = 0.3 }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            loadingText = "Get ready to learn Tagalog!"
            withAnimation(.easeInOut(duration: 0.8)) { progress = 0.7 }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            // Persist the onboarding data
            try? modelContext.save()
            withAnimation(.easeInOut(duration: 0.5)) { progress = 1.0 }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            onComplete()
        }
    }
}
