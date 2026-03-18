import SwiftUI

/// Floating greeting card that slides down from below the pinned header bar.
/// Shows once per calendar day on first Learn screen appear.
struct DailyToastView: View {
    let greeting: String
    let onDismiss: () -> Void

    @State private var isVisible = false
    @State private var dismissing = false

    var body: some View {
        if isVisible {
            HStack(spacing: 12) {
                bunsoAvatar
                    .frame(width: 56, height: 56)

                // Speech bubble text
                Text(greeting)
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundStyle(TarsierColors.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)

                Spacer(minLength: 0)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.white)
                    .shadow(color: .black.opacity(0.08), radius: 12, y: 4)
            )
            .padding(.horizontal, TarsierSpacing.screenPadding)
            .transition(.move(edge: .top).combined(with: .opacity))
            .onTapGesture {
                dismiss()
            }
            .allowsHitTesting(!dismissing)
            .onAppear {
                // Auto-dismiss after 2.5 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                    dismiss()
                }
            }
        }
    }

    private func dismiss() {
        guard !dismissing else { return }
        dismissing = true
        withAnimation(.easeInOut(duration: 0.3)) {
            isVisible = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            onDismiss()
        }
    }

    func show() -> DailyToastView {
        var view = self
        view._isVisible = State(initialValue: true)
        return view
    }

    @ViewBuilder
    private var bunsoAvatar: some View {
        if let _ = UIImage(named: "character_bunso") {
            Image("character_bunso")
                .resizable()
                .scaledToFit()
        } else if let _ = UIImage(named: "Tarsier-Waving") {
            Image("Tarsier-Waving")
                .resizable()
                .scaledToFit()
        } else {
            Circle()
                .fill(TarsierColors.brandPurple.opacity(0.15))
                .overlay(
                    Text("🐵")
                        .font(.system(size: 28))
                )
        }
    }
}
