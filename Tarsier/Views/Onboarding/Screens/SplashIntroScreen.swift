import SwiftUI

/// Screens 1–2: Bunso introduction + quick questions intro
struct SplashIntroScreen: View {
    let screenIndex: Int // 0 = splash, 1 = quick questions
    let onContinue: () -> Void

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            if screenIndex == 0 {
                BunsoView(pose: .waving, size: 140)

                VStack(spacing: 8) {
                    Text("Hi there! I'm Bunso!")
                        .font(TarsierFonts.title(28))
                        .foregroundStyle(TarsierColors.textPrimary)

                    Text("Your Tagalog learning buddy")
                        .font(TarsierFonts.body())
                        .foregroundStyle(TarsierColors.textSecondary)
                }
            } else {
                BunsoSpeechBubble(pose: .curious, text: "Just a few quick questions before we start your first lesson!", bunsoSize: 100)
            }

            Spacer()
        }
    }
}
