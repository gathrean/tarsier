import SwiftUI

struct GreetingSheetView: View {
    let profile: UserProfile?
    let currentStreak: Int
    let inProgressLessonTitle: String?
    let onDismiss: () -> Void

    @State private var autoDismissTask: Task<Void, Never>?

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                // Time-of-day Tagalog greeting
                Text(tagalogGreeting)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundStyle(TarsierColors.textPrimary)

                // Contextual line
                Text(contextualLine)
                    .font(.system(size: 15, weight: .regular, design: .rounded))
                    .foregroundStyle(TarsierColors.textSecondary)
            }

            Spacer()

            // Bunso illustration (~60pt) if asset exists
            bunsoAvatar
                .frame(width: 60, height: 60)
        }
        .padding(.horizontal, 24)
        .padding(.top, 20)
        .padding(.bottom, 16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.white)
                .shadow(color: .black.opacity(0.12), radius: 16, y: 4)
        )
        .onTapGesture { onDismiss() }
        .onAppear {
            // Auto-dismiss after 5 seconds
            autoDismissTask = Task {
                try? await Task.sleep(for: .seconds(5))
                guard !Task.isCancelled else { return }
                onDismiss()
            }
        }
        .onDisappear {
            autoDismissTask?.cancel()
        }
    }

    // MARK: - Tagalog Greeting

    private var tagalogGreeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        let name = profile?.userName ?? ""
        let displayName = name.isEmpty ? "" : ", \(name)"

        switch hour {
        case 5..<12:
            return "Magandang Umaga\(displayName)!"
        case 12..<18:
            return "Magandang Hapon\(displayName)!"
        default:
            return "Magandang Gabi\(displayName)!"
        }
    }

    // MARK: - Contextual Line

    private var contextualLine: String {
        if currentStreak > 0 {
            return "🔥 \(currentStreak) day streak! Keep it up."
        }
        if let title = inProgressLessonTitle {
            return "Ready to continue \(title)?"
        }
        return "What would you like to learn today?"
    }

    // MARK: - Bunso Avatar

    @ViewBuilder
    private var bunsoAvatar: some View {
        if UIImage(named: "character_bunso") != nil {
            Image("character_bunso")
                .resizable()
                .scaledToFit()
        } else if UIImage(named: "Tarsier-Waving") != nil {
            Image("Tarsier-Waving")
                .resizable()
                .scaledToFit()
        } else {
            // No placeholder — greeting works fine without it
            EmptyView()
        }
    }
}
