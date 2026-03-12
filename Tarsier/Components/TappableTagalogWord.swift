import SwiftUI
import SwiftData

struct TappableTagalogWord: View {
    let word: String
    let translation: String
    var font: Font = TarsierFonts.heading()
    var color: Color = TarsierColors.textPrimary

    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [UserProfile]

    @State private var showChip = false
    @State private var hasAutoShown = false
    @State private var dismissTask: Task<Void, Never>?

    private var profile: UserProfile? { profiles.first }

    var body: some View {
        VStack(spacing: 0) {
            Text(word)
                .font(font)
                .foregroundStyle(color)

            // Dashed underline
            Rectangle()
                .stroke(style: StrokeStyle(lineWidth: 1, dash: [3, 2]))
                .foregroundStyle(TarsierColors.functionalPurple.opacity(0.4))
                .frame(height: 1)
        }
        .fixedSize()
        .overlay(alignment: .top) {
            if showChip {
                chipView
                    .fixedSize()
                    .offset(y: -36)
                    .transition(.scale(scale: 0.8).combined(with: .opacity))
                    .zIndex(100)
            }
        }
        .onTapGesture {
            toggleChip()
        }
        .onAppear {
            autoShowIfNeeded()
        }
    }

    // MARK: - Chip

    private var chipView: some View {
        VStack(spacing: 0) {
            Text(translation)
                .font(TarsierFonts.caption(13).bold())
                .foregroundStyle(.white)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(TarsierColors.functionalPurple)
                )

            // Downward caret
            Image(systemName: "arrowtriangle.down.fill")
                .font(.system(size: 8))
                .foregroundStyle(TarsierColors.functionalPurple)
                .offset(y: -2)
        }
    }

    // MARK: - Actions

    private func toggleChip() {
        dismissTask?.cancel()
        if showChip {
            withAnimation(.easeOut(duration: 0.15)) {
                showChip = false
            }
        } else {
            withAnimation(.easeOut(duration: 0.15)) {
                showChip = true
            }
            scheduleDismiss(after: 3.0)
        }
    }

    private func autoShowIfNeeded() {
        guard !hasAutoShown else { return }
        guard let profile else { return }
        guard !profile.seenUIWords.contains(word) else { return }

        hasAutoShown = true

        // Brief delay so the view is settled
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            withAnimation(.easeOut(duration: 0.15)) {
                showChip = true
            }
            // Mark as seen
            profile.seenUIWords.append(word)
            // Auto-dismiss after 1.5s
            scheduleDismiss(after: 1.5)
        }
    }

    private func scheduleDismiss(after seconds: Double) {
        dismissTask?.cancel()
        dismissTask = Task { @MainActor in
            try? await Task.sleep(for: .seconds(seconds))
            guard !Task.isCancelled else { return }
            withAnimation(.easeOut(duration: 0.15)) {
                showChip = false
            }
        }
    }
}
