import SwiftUI

/// Screens 8–9: Motivation picker + Bunso reaction
struct MotivationScreen: View {
    let screenIndex: Int // 0 = picker, 1 = response
    @Binding var selectedMotivations: Set<String>
    let onContinue: () -> Void

    private let motivations = [
        "Just for fun",
        "Prepare for travel",
        "Connect with people",
        "Impress my partner",
        "Impress other Filipinos",
        "Connect with my family better",
        "Understand Filipino media/music",
        "For my career",
        "Other"
    ]

    var body: some View {
        if screenIndex == 0 {
            pickerView
        } else {
            responseView
        }
    }

    private var pickerView: some View {
        VStack(spacing: 20) {
            Spacer()
                .frame(height: 24)

            Text("Why are you learning Tagalog?")
                .font(TarsierFonts.title(24))
                .multilineTextAlignment(.center)

            Text("Pick all that apply")
                .font(TarsierFonts.caption())
                .foregroundStyle(TarsierColors.textSecondary)

            ScrollView {
                LazyVStack(spacing: 10) {
                    ForEach(motivations, id: \.self) { motivation in
                        Button {
                            if selectedMotivations.contains(motivation) {
                                selectedMotivations.remove(motivation)
                            } else {
                                selectedMotivations.insert(motivation)
                            }
                        } label: {
                            HStack {
                                Text(motivation)
                                    .font(TarsierFonts.body())
                                    .foregroundStyle(TarsierColors.textPrimary)
                                Spacer()
                                if selectedMotivations.contains(motivation) {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(TarsierColors.functionalPurple)
                                }
                            }
                            .padding(TarsierSpacing.cardPadding)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(selectedMotivations.contains(motivation) ? TarsierColors.primaryLight : .white)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(
                                        selectedMotivations.contains(motivation) ? TarsierColors.functionalPurple : TarsierColors.cardBorder,
                                        lineWidth: selectedMotivations.contains(motivation) ? 2 : 1
                                    )
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, TarsierSpacing.screenPadding)
            }

        }
    }

    private var responseView: some View {
        let (pose, message) = motivationResponse

        return VStack(spacing: 32) {
            Spacer()

            BunsoView(pose: pose, size: 120)

            Text(message)
                .font(TarsierFonts.heading(20))
                .foregroundStyle(TarsierColors.textPrimary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            Spacer()
        }
        .contentShape(Rectangle())
        .onTapGesture { onContinue() }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                onContinue()
            }
        }
    }

    private var motivationResponse: (BunsoPose, String) {
        // Priority: family > partner > impress > fun > people > default
        if selectedMotivations.contains("Connect with my family better") {
            return (.heartEyes, "That's the best reason. Let's make it happen!")
        }
        if selectedMotivations.contains("Impress my partner") {
            return (.blushing, "Kilig! They're going to love this.")
        }
        if selectedMotivations.contains("Impress other Filipinos") {
            return (.flexing, "They won't know what hit them.")
        }
        if selectedMotivations.contains("Just for fun") {
            return (.excited, "The best way to learn! Let's go!")
        }
        if selectedMotivations.contains("Connect with people") {
            return (.waving, "Filipinos are the friendliest. You'll fit right in.")
        }
        return (.thumbsUp, "Great reasons. Let's get started!")
    }
}
