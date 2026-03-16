import SwiftUI

/// Screen 7: Name + Ate/Kuya title collection
struct NameTitleScreen: View {
    @Binding var userName: String
    @Binding var preferredTitle: String?
    let onContinue: () -> Void

    @FocusState private var nameFieldFocused: Bool

    private let titles = ["Ate", "Kuya"]

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            BunsoSpeechBubble(pose: .waving, text: "What should I call you?")

            TextField("Your name", text: $userName)
                .font(TarsierFonts.body(18))
                .multilineTextAlignment(.center)
                .padding(TarsierSpacing.cardPadding)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(TarsierColors.cream)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(TarsierColors.cardBorder, lineWidth: 1.5)
                )
                .padding(.horizontal, 32)
                .textInputAutocapitalization(.words)
                .autocorrectionDisabled()
                .focused($nameFieldFocused)

            // Ate / Kuya picker
            VStack(spacing: 8) {
                HStack(spacing: 12) {
                    ForEach(titles, id: \.self) { title in
                        Button {
                            if preferredTitle == title {
                                preferredTitle = nil
                            } else {
                                preferredTitle = title
                            }
                        } label: {
                            Text(title)
                                .font(TarsierFonts.heading(16))
                                .foregroundStyle(preferredTitle == title ? .white : TarsierColors.textPrimary)
                                .padding(.horizontal, 24)
                                .padding(.vertical, 10)
                                .background(
                                    Capsule()
                                        .fill(preferredTitle == title ? TarsierColors.functionalPurple : .white)
                                )
                                .overlay(
                                    Capsule()
                                        .stroke(
                                            preferredTitle == title ? TarsierColors.functionalPurple : TarsierColors.cardBorder,
                                            lineWidth: 1.5
                                        )
                                )
                        }
                        .buttonStyle(.plain)
                    }

                    Button {
                        preferredTitle = nil
                    } label: {
                        Text("Neither")
                            .font(TarsierFonts.heading(16))
                            .foregroundStyle(preferredTitle == nil ? .white : TarsierColors.textSecondary)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 10)
                            .background(
                                Capsule()
                                    .fill(preferredTitle == nil ? TarsierColors.functionalPurple : .white)
                            )
                            .overlay(
                                Capsule()
                                    .stroke(
                                        preferredTitle == nil ? TarsierColors.functionalPurple : TarsierColors.cardBorder,
                                        lineWidth: 1.5
                                    )
                            )
                    }
                    .buttonStyle(.plain)
                }

                Text("In Filipino culture, Ate and Kuya are terms of respect and closeness — like older sister and older brother.")
                    .font(TarsierFonts.caption())
                    .foregroundStyle(TarsierColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
            }

            Spacer()
        }
        .onDisappear { nameFieldFocused = false }
    }
}
