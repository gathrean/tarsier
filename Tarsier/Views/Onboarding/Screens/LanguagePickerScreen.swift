import SwiftUI

struct LanguageOption: Identifiable {
    let id: String
    let name: String
    let isAvailable: Bool
}

/// Screen 3: Language picker
struct LanguagePickerScreen: View {
    @Binding var selectedLanguage: String
    let onContinue: () -> Void

    private let languages = [
        LanguageOption(id: "tagalog", name: "Tagalog", isAvailable: true),
        LanguageOption(id: "cebuano", name: "Cebuano", isAvailable: false),
        LanguageOption(id: "ilocano", name: "Ilocano", isAvailable: false),
        LanguageOption(id: "hiligaynon", name: "Hiligaynon", isAvailable: false),
    ]

    var body: some View {
        VStack(spacing: 24) {
            VStack(alignment: .leading, spacing: 12) {
                Text("For English Speakers")
                    .font(TarsierFonts.caption())
                    .foregroundStyle(TarsierColors.textSecondary)
                ForEach(languages) { lang in
                    Button {
                        if lang.isAvailable {
                            selectedLanguage = lang.id
                        }
                    } label: {
                        HStack(spacing: 16) {
                            Image("philippine-flag")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 32, height: 32)
                                .clipShape(Circle())
                            Text(lang.name)
                                .font(TarsierFonts.heading(18))
                                .foregroundStyle(lang.isAvailable ? TarsierColors.textPrimary : TarsierColors.textSecondary)
                            Spacer()
                            if !lang.isAvailable {
                                Text("Coming soon")
                                    .font(TarsierFonts.caption())
                                    .foregroundStyle(TarsierColors.textSecondary)
                            } else if selectedLanguage == lang.id {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(TarsierColors.functionalPurple)
                            }
                        }
                        .padding(TarsierSpacing.cardPadding)
                        .background(
                            RoundedRectangle(cornerRadius: TarsierSpacing.cardCornerRadius)
                                .fill(selectedLanguage == lang.id ? TarsierColors.primaryLight : .white)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: TarsierSpacing.cardCornerRadius)
                                .stroke(
                                    selectedLanguage == lang.id ? TarsierColors.functionalPurple : TarsierColors.cardBorder,
                                    lineWidth: selectedLanguage == lang.id ? 2 : 1
                                )
                        )
                        .opacity(lang.isAvailable ? 1 : 0.6)
                    }
                    .buttonStyle(.plain)
                    .disabled(!lang.isAvailable)
                }
            }
            .padding(.horizontal, TarsierSpacing.screenPadding)

            Spacer()
        }
    }
}
