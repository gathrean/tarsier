import SwiftUI

// MARK: - Path Node Data

enum PathNodeKind {
    case lesson(id: Int)
    case practice(chapterId: String)
}

enum PathNodeState {
    case active       // Next incomplete lesson — large, pulsing
    case inProgress   // Has some sessions done but not fully complete
    case completed    // All sessions done
    case locked       // Not yet unlocked
}

struct PathNode: Identifiable {
    let id: String
    let kind: PathNodeKind
    let state: PathNodeState
    var position: CGPoint
    let indexInChapter: Int       // 1-based display number
    let title: String
    let emoji: String
    let completedSessions: Int
    let totalSessions: Int
    let isPracticeUnlocked: Bool  // Only used for practice nodes

    /// Emoji mapping by lesson ID. 💬 is the default.
    static func emoji(for lessonID: Int) -> String {
        let map: [Int: String] = [
            1: "🙏", 2: "👋", 3: "🤝", 4: "👤",
            5: "🔀", 6: "✨", 7: "🍽️", 8: "🍳",
            9: "🥤", 10: "👍", 11: "👨‍👩‍👧", 12: "👴",
            13: "❤️", 14: "🏠", 15: "🔢", 16: "💰",
            17: "🌅", 18: "💼", 19: "🧹", 20: "😴",
            21: "😊", 22: "💅", 23: "🌡️", 24: "😩",
            25: "📍", 26: "🚶", 27: "🛒", 28: "🚌",
            29: "📅", 30: "📝", 31: "🔓", 32: "🧩",
        ]
        return map[lessonID] ?? "💬"
    }
}

// MARK: - Path Node View

struct PathNodeView: View {
    let node: PathNode

    private var isActive: Bool { node.state == .active }
    private var nodeSize: CGFloat { isActive ? 84 : 60 }
    private var shouldDim: Bool {
        if node.state == .locked { return true }
        if case .practice = node.kind, !node.isPracticeUnlocked { return true }
        return false
    }

    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                switch node.kind {
                case .lesson:
                    lessonNodeContent
                case .practice:
                    practiceNodeContent
                }
            }

            Text(node.title)
                .font(TarsierFonts.caption(12))
                .foregroundStyle(node.state == .locked ? TarsierColors.textSecondary : TarsierColors.textPrimary)
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .frame(width: nodeSize + 24)
        }
        .opacity(shouldDim ? 0.9 : 1)
    }

    // MARK: - Lesson Node

    @ViewBuilder
    private var lessonNodeContent: some View {
        switch node.state {
        case .active:
            activeNode
        case .completed:
            completedNode
        case .inProgress:
            inProgressNode
        case .locked:
            lockedNode
        }
    }

    // MARK: - Active (84×84, pulsing glow, 3D shadow)

    private var activeNode: some View {
        Circle()
            .fill(TarsierColors.functionalPurple)
            .frame(width: nodeSize, height: nodeSize)
            .shadow(color: TarsierColors.nodeShadow, radius: 0, x: 0, y: 4)
            .shadow(color: TarsierColors.functionalPurple.opacity(0.25), radius: 12)
            .background(PulsingGlowRing(size: nodeSize))
            .overlay {
                Text(node.emoji)
                    .font(.system(size: 32))
            }
    }

    // MARK: - Completed (60×60, purple, checkmark)

    private var completedNode: some View {
        ZStack {
            Circle()
                .fill(TarsierColors.functionalPurple)
                .frame(width: nodeSize, height: nodeSize)

            Text(node.emoji)
                .font(.system(size: 24))
        }
    }

    // MARK: - In-Progress (60×60, cream, progress ring)

    private var inProgressNode: some View {
        ZStack {
            ProgressRingView(
                completed: node.completedSessions,
                total: node.totalSessions,
                size: nodeSize + 8,
                lineWidth: 3.5
            )

            Circle()
                .fill(TarsierColors.cream)
                .frame(width: nodeSize, height: nodeSize)
                .overlay(
                    Circle()
                        .stroke(TarsierColors.functionalPurple.opacity(0.3), lineWidth: 2)
                )

            Text(node.emoji)
                .font(.system(size: 24))
        }
    }

    // MARK: - Locked (60×60, grey, greyed-out emoji)

    private var lockedNode: some View {
        ZStack {
            Circle()
                .fill(TarsierColors.lockedFill)
                .frame(width: nodeSize, height: nodeSize)
                .overlay(
                    Circle()
                        .stroke(TarsierColors.cardBorder, lineWidth: 3)
                )

            Text(node.emoji)
                .font(.system(size: 24))
                .grayscale(1.0)
                .opacity(0.4)
        }
    }

    // MARK: - Practice Node

    private var practiceNodeContent: some View {
        ZStack {
            Circle()
                .fill(node.isPracticeUnlocked ? TarsierColors.gold.opacity(0.15) : .clear)
                .frame(width: nodeSize, height: nodeSize)
                .overlay(
                    Circle()
                        .stroke(
                            node.isPracticeUnlocked ? TarsierColors.gold : TarsierColors.cardBorder,
                            style: StrokeStyle(lineWidth: 2, dash: [5, 3])
                        )
                )

            Image(systemName: "book.fill")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(node.isPracticeUnlocked ? TarsierColors.gold : TarsierColors.textSecondary)
        }
    }
}

// MARK: - Pulsing Glow Ring

private struct PulsingGlowRing: View {
    let size: CGFloat
    @State private var isAnimating = false

    var body: some View {
        Circle()
            .fill(TarsierColors.functionalPurple.opacity(0.15))
            .frame(width: size + 20, height: size + 20)
            .scaleEffect(isAnimating ? 1.15 : 0.95)
            .opacity(isAnimating ? 0 : 0.6)
            .onAppear {
                withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                    isAnimating = true
                }
            }
    }
}

// MARK: - Press-Down Button Style

struct NodePressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.92 : 1.0)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}
