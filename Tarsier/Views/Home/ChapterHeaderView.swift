import SwiftUI

struct ChapterHeaderView: View {
    let chapter: Chapter
    let chapterIndex: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Spacer()

            HStack(alignment: .bottom) {
                VStack(alignment: .leading, spacing: 6) {
                    // Chapter number label
                    Text("CHAPTER \(chapterIndex)")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .tracking(1.2)
                        .foregroundStyle(.white.opacity(0.7))

                    // Chapter title
                    Text(chapter.title)
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)

                    // Chapter subtitle (Tagalog name)
                    Text(chapter.subtitle)
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.8))
                }

                Spacer()

                // Chapter icon
                if let iconStr = chapter.icon {
                    if iconStr.unicodeScalars.first?.properties.isEmoji == true && iconStr.count <= 2 {
                        Text(iconStr)
                            .font(.system(size: 50))
                            .opacity(0.8)
                    } else {
                        Image(systemName: iconStr)
                            .font(.system(size: 40, weight: .medium))
                            .foregroundStyle(.white.opacity(0.6))
                    }
                }
            }
        }
        .padding(.horizontal, TarsierSpacing.screenPadding)
        .padding(.bottom, 24)
        .padding(.top, 60)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 200)
        .background(
            LinearGradient(
                colors: [
                    chapter.accentSwiftUIColor,
                    chapter.accentSwiftUIColor.opacity(0.7)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .padding(.top, -200) // extend up behind safe area
        )
    }
}
