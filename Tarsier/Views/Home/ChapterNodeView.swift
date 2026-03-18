import SwiftUI

enum ChapterNodeState {
    case notStarted
    case inProgress
    case completed
    case locked
}

struct ChapterNodeView: View {
    let chapter: Chapter
    let chapterIndex: Int
    let state: ChapterNodeState
    let completedLessons: Int
    let totalLessons: Int

    private let nodeSize: CGFloat = 100

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                // Progress ring
                if state != .locked {
                    progressRing
                }

                // Circle background
                Circle()
                    .fill(circleFill)
                    .frame(width: nodeSize, height: nodeSize)

                // Icon content
                iconContent

                // Completed checkmark overlay
                if state == .completed {
                    Circle()
                        .fill(Color.black.opacity(0.15))
                        .frame(width: nodeSize, height: nodeSize)

                    Image(systemName: "checkmark")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(.white)
                }

                // Lock overlay
                if state == .locked {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 24, weight: .medium))
                        .foregroundStyle(Color(hex: "#9CA3AF"))
                }
            }
            .modifier(InProgressPulse(isActive: state == .inProgress))

            // Title
            Text(chapter.title)
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundStyle(state == .locked ? TarsierColors.textSecondary : TarsierColors.textPrimary)
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .frame(width: nodeSize + 20)
        }
    }

    // MARK: - Progress Ring

    private var progressRing: some View {
        let progress = totalLessons > 0 ? Double(completedLessons) / Double(totalLessons) : 0
        return ZStack {
            // Track
            Circle()
                .stroke(chapter.accentSwiftUIColor.opacity(0.15), lineWidth: 4)
                .frame(width: nodeSize + 12, height: nodeSize + 12)

            // Fill
            Circle()
                .trim(from: 0, to: progress)
                .stroke(chapter.accentSwiftUIColor, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                .frame(width: nodeSize + 12, height: nodeSize + 12)
                .rotationEffect(.degrees(-90))
        }
    }

    // MARK: - Circle Fill

    private var circleFill: Color {
        switch state {
        case .notStarted:
            return chapter.accentSwiftUIColor.opacity(0.2)
        case .inProgress, .completed:
            return chapter.accentSwiftUIColor
        case .locked:
            return Color(hex: "#E5E5E5")
        }
    }

    // MARK: - Icon Content

    @ViewBuilder
    private var iconContent: some View {
        if state == .locked {
            // Lock icon replaces content
            EmptyView()
        } else if let iconStr = chapter.icon {
            if iconStr.unicodeScalars.first?.properties.isEmoji == true && iconStr.count <= 2 {
                // Emoji icon
                Text(iconStr)
                    .font(.system(size: 38))
            } else {
                // SF Symbol
                Image(systemName: iconStr)
                    .font(.system(size: 30, weight: .medium))
                    .foregroundStyle(iconColor)
            }
        }
    }

    private var iconColor: Color {
        switch state {
        case .notStarted:
            return chapter.accentSwiftUIColor
        case .inProgress, .completed:
            return .white
        case .locked:
            return Color(hex: "#9CA3AF")
        }
    }
}

// MARK: - In-Progress Pulse

private struct InProgressPulse: ViewModifier {
    let isActive: Bool
    @State private var isPulsing = false

    func body(content: Content) -> some View {
        content
            .scaleEffect(isActive && isPulsing ? 1.02 : 1.0)
            .onAppear {
                guard isActive else { return }
                withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                    isPulsing = true
                }
            }
    }
}
