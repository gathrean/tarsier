import SwiftUI

struct TaglishCallout: View {
    let text: String

    var body: some View {
        HStack(spacing: 0) {
            Rectangle()
                .fill(TarsierColors.functionalPurple)
                .frame(width: 3)

            VStack(alignment: .leading, spacing: 4) {
                Text("Taglish Reality")
                    .font(TarsierFonts.caption())
                    .foregroundStyle(TarsierColors.functionalPurple)

                Text(text)
                    .font(TarsierFonts.body(15))
                    .foregroundStyle(TarsierColors.textSecondary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
        }
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(TarsierColors.primaryLight)
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
