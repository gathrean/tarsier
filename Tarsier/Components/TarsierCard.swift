import SwiftUI

struct TarsierCard<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(TarsierSpacing.cardPadding)
            .background(
                RoundedRectangle(cornerRadius: TarsierSpacing.cardCornerRadius)
                    .fill(TarsierColors.cream)
                    .shadow(color: .black.opacity(0.04), radius: 8, y: 2)
            )
            .overlay(
                RoundedRectangle(cornerRadius: TarsierSpacing.cardCornerRadius)
                    .stroke(TarsierColors.cardBorder, lineWidth: 1)
            )
    }
}
