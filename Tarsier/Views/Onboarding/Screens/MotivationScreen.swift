import SwiftUI

/// Screens 8–9: Motivation picker + Bunso reaction
struct MotivationScreen: View {
    let screenIndex: Int // 0 = picker, 1 = response
    @Binding var selectedMotivations: Set<String>
    let onContinue: () -> Void
    var onShowContinue: (() -> Void)? = nil

    private let motivations = [
        "Connect with my family better",
        "Just for fun",
        "Impress my partner",
        "Prepare for travel",
        "Connect with people who speak Tagalog",
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
            FlowLayout(spacing: 8) {
                ForEach(motivations, id: \.self) { motivation in
                    let isSelected = selectedMotivations.contains(motivation)
                    Button {
                        if isSelected {
                            selectedMotivations.remove(motivation)
                        } else {
                            selectedMotivations.insert(motivation)
                        }
                    } label: {
                        Text(motivation)
                            .font(TarsierFonts.body(15))
                            .foregroundStyle(isSelected ? .white : TarsierColors.textPrimary)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(
                                Capsule()
                                    .fill(isSelected ? TarsierColors.functionalPurple : .white)
                            )
                            .overlay(
                                Capsule()
                                    .stroke(
                                        isSelected ? TarsierColors.functionalPurple : TarsierColors.cardBorder,
                                        lineWidth: isSelected ? 2 : 1
                                    )
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, TarsierSpacing.screenPadding)

            Spacer()
        }
    }

    private var responseView: some View {
        VStack(spacing: 32) {
            Spacer()
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                onShowContinue?()
            }
        }
    }
}
