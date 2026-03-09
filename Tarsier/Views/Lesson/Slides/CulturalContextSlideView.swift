import SwiftUI

struct CulturalContextSlideView: View {
    let slide: LessonSlide

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Image placeholder
            if slide.image != nil {
                RoundedRectangle(cornerRadius: TarsierSpacing.cardCornerRadius)
                    .fill(TarsierColors.cream)
                    .frame(height: 200)
                    .overlay(
                        VStack(spacing: 8) {
                            Image(systemName: "photo.fill")
                                .font(.system(size: 36))
                                .foregroundStyle(TarsierColors.textSecondary.opacity(0.3))
                            Text("Photo coming soon")
                                .font(TarsierFonts.caption())
                                .foregroundStyle(TarsierColors.textSecondary.opacity(0.4))
                        }
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: TarsierSpacing.cardCornerRadius)
                            .stroke(TarsierColors.cardBorder, lineWidth: 1)
                    )
            }

            if let title = slide.title {
                Text(title)
                    .font(TarsierFonts.heading())
                    .foregroundStyle(TarsierColors.functionalPurple)
            }

            if let body = slide.body {
                Text(body)
                    .font(TarsierFonts.body())
                    .foregroundStyle(TarsierColors.textPrimary)
                    .lineSpacing(4)
            }

            if let note = slide.taglishNote {
                TaglishCallout(text: note)
            }
        }
    }
}
