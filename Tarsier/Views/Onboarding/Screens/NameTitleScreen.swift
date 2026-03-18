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
                .transaction { $0.animation = nil }

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
                        preferredTitle = ""
                    } label: {
                        let isSelected = preferredTitle == ""
                        Text("Neither")
                            .font(TarsierFonts.heading(16))
                            .foregroundStyle(isSelected ? .white : TarsierColors.textSecondary)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 10)
                            .background(
                                Capsule()
                                    .fill(isSelected ? TarsierColors.functionalPurple : .white)
                            )
                            .overlay(
                                Capsule()
                                    .stroke(
                                        isSelected ? TarsierColors.functionalPurple : TarsierColors.cardBorder,
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
        .onAppear {
            // Delay focus until the slide transition animation completes.
            // Without this, the TextField can become non-interactive when
            // created inside an .id()-based transition (SwiftUI bug).
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
                nameFieldFocused = true
            }
        }
        .onDisappear { nameFieldFocused = false }
    }
}
