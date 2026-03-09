import SwiftUI
import SwiftData

struct WordsView: View {
    @Query private var profiles: [UserProfile]

    private var profile: UserProfile? { profiles.first }
    private var wordCount: Int { profile?.completedLessonIDs.count ?? 0 }

    var body: some View {
        VStack(spacing: TarsierSpacing.sectionSpacing) {
            Spacer()

            Image(systemName: "character.book.closed.fill")
                .font(.system(size: 50, weight: .bold, design: .rounded))
                .foregroundStyle(TarsierColors.brandPurple)

            VStack(spacing: 8) {
                Text("Word Bank")
                    .font(TarsierFonts.title())
                    .foregroundStyle(TarsierColors.textPrimary)

                Text("Start your first lesson to build your word bank")
                    .font(TarsierFonts.body())
                    .foregroundStyle(TarsierColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(TarsierColors.warmWhite)
        .navigationTitle("Words")
    }
}
