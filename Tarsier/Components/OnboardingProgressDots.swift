import SwiftUI

struct OnboardingProgressDots: View {
    let currentPage: Int
    let totalPages: Int = 6

    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<totalPages, id: \.self) { index in
                Circle()
                    .fill(index <= currentPage ? TarsierColors.functionalPurple : Color.clear)
                    .overlay(
                        Circle()
                            .stroke(
                                index <= currentPage ? TarsierColors.functionalPurple : TarsierColors.cardBorder,
                                lineWidth: 1
                            )
                    )
                    .frame(width: 6, height: 6)
            }
        }
        .animation(.easeInOut(duration: 0.25), value: currentPage)
    }
}
