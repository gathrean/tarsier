import SwiftUI

/// Special card shown the first time a character appears in the user's progression.
/// Large character illustration (or emoji), name, meaning, intro text, and fun fact.
struct CharacterIntroView: View {
    let character: TarsierCharacter
    let introText: String
    var funFact: String? = nil

    var body: some View {
        VStack(spacing: 20) {
            Spacer(minLength: 20)

            // Large character illustration or emoji
            characterAvatar
                .frame(width: 100, height: 100)

            // Name + meaning
            VStack(spacing: 4) {
                Text(character.displayName)
                    .font(TarsierFonts.title(32))
                    .foregroundStyle(TarsierColors.textPrimary)

                Text(character.meaning)
                    .font(TarsierFonts.body(16))
                    .foregroundStyle(TarsierColors.textSecondary)
            }

            // Intro text
            Text(introText)
                .font(TarsierFonts.body())
                .foregroundStyle(TarsierColors.textPrimary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 8)

            // Fun fact styled as Alam Mo Ba? callout
            if let funFact {
                HStack(alignment: .top, spacing: 10) {
                    Text("💡")
                        .font(.system(size: 18))

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Alam Mo Ba?")
                            .font(TarsierFonts.caption())
                            .foregroundStyle(TarsierColors.gold)
                            .fontWeight(.semibold)
                        Text(funFact)
                            .font(TarsierFonts.caption())
                            .foregroundStyle(TarsierColors.textPrimary)
                    }
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(TarsierColors.gold.opacity(0.10))
                )
            }

            Spacer(minLength: 20)
        }
    }

    @ViewBuilder
    private var characterAvatar: some View {
        if let imageName = character.imageName {
            Image(imageName)
                .resizable()
                .scaledToFill()
                .clipShape(Circle())
        } else {
            Circle()
                .fill(TarsierColors.primaryLight)
                .overlay(
                    Text(character.emoji)
                        .font(.system(size: 56))
                )
        }
    }
}
