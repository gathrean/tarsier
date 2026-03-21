import SwiftUI

struct ZigzagChapterView: View {
    let chapter: Chapter
    let chapterNumber: Int
    let chapterIndex: Int
    let isChapterUnlocked: Bool

    // Closures that call back into HomeView's existing logic
    let isLessonUnlocked: (String) -> Bool
    let completedIDs: [String]
    let completedSessionCount: (String) -> Int
    let totalSessions: (String) -> Int
    let nextSessionNumber: (String) -> Int
    let lessonTitle: (String) -> String
    let isPremium: Bool

    @Binding var selectedLessonID: String?
    @Binding var showPremiumGate: Bool

    // MARK: - Layout Constants

    private let verticalSpacing: CGFloat = 100
    private let activeNodeSize: CGFloat = 84
    private let normalNodeSize: CGFloat = 60
    private let topPadding: CGFloat = 80
    private let bottomPadding: CGFloat = 20

    // MARK: - Body

    var body: some View {
        VStack(spacing: 16) {
            ChapterBannerView(
                chapterNumber: chapterNumber,
                title: chapter.title,
                subtitle: chapter.subtitle,
                isUnlocked: isChapterUnlocked
            )
            .padding(.horizontal, TarsierSpacing.screenPadding)

            GeometryReader { geo in
                let nodes = buildNodes(containerWidth: geo.size.width)

                ZStack {
                    // Canvas path lines (bottom layer)
                    pathCanvas(nodes: nodes)

                    // Nodes
                    ForEach(nodes) { node in
                        nodeContent(for: node)
                            .position(node.position)
                    }

                    // "Start!" bubble above active node
                    if let activeNode = nodes.first(where: { $0.state == .active }) {
                        StartBubbleView()
                            .position(
                                x: activeNode.position.x,
                                y: activeNode.position.y - (activeNodeSize / 2) - 24
                            )
                    }

                    // Popover card
                    if let selectedID = selectedLessonID,
                       let node = nodes.first(where: {
                           if case .lesson(let id) = $0.kind { return id == selectedID }
                           return false
                       }) {
                        // Transparent dismiss backdrop
                        Color.clear
                            .contentShape(Rectangle())
                            .onTapGesture { selectedLessonID = nil }

                        popoverCard(for: node, containerWidth: geo.size.width)
                            .position(
                                x: clampX(node.position.x, containerWidth: geo.size.width),
                                y: node.position.y + (node.state == .active ? activeNodeSize / 2 : normalNodeSize / 2) + 70
                            )
                            .transition(.asymmetric(
                                insertion: .scale(scale: 0.8, anchor: .top).combined(with: .opacity),
                                removal: .scale(scale: 0.8, anchor: .top).combined(with: .opacity)
                            ))
                            .zIndex(10)
                    }
                }
            }
            .frame(height: computeChapterHeight())
        }
    }

    // MARK: - Build Nodes

    private func buildNodes(containerWidth: CGFloat) -> [PathNode] {
        let lessonIDs = chapter.lessonIDs
        let leftX = containerWidth * 0.35
        let rightX = containerWidth * 0.65

        var nodes: [PathNode] = []

        // Find the first active (next incomplete) lesson across the whole app
        let firstActiveID = lessonIDs.first { id in
            isLessonUnlocked(id) && !completedIDs.contains(id)
        }

        for (index, lessonID) in lessonIDs.enumerated() {
            let x = (index % 2 == 0) ? leftX : rightX
            let y = topPadding + CGFloat(index) * verticalSpacing

            let isCompleted = completedIDs.contains(lessonID)
            let unlocked = isLessonUnlocked(lessonID)
            let completed = completedSessionCount(lessonID)
            let total = totalSessions(lessonID)
            let hasProgress = completed > 0 && !isCompleted

            let state: PathNodeState
            if isCompleted {
                state = .completed
            } else if lessonID == firstActiveID {
                state = .active
            } else if hasProgress && unlocked {
                state = .inProgress
            } else {
                state = .locked
            }

            nodes.append(PathNode(
                id: "lesson_\(lessonID)",
                kind: .lesson(id: lessonID),
                state: state,
                position: CGPoint(x: x, y: y),
                indexInChapter: (chapter.lessonIDs.firstIndex(of: lessonID) ?? 0) + 1,
                title: lessonTitle(lessonID),
                emoji: PathNode.emoji(for: lessonID),
                completedSessions: completed,
                totalSessions: total,
                isPracticeUnlocked: false
            ))
        }

        // Practice node at end, on the left
        let practiceY = topPadding + CGFloat(lessonIDs.count) * verticalSpacing
        let allCompleted = chapter.lessonIDs.allSatisfy { completedIDs.contains($0) }

        nodes.append(PathNode(
            id: "practice_\(chapter.chapterId)",
            kind: .practice(chapterId: chapter.chapterId),
            state: allCompleted ? .completed : .locked,
            position: CGPoint(x: leftX, y: practiceY),
            indexInChapter: 0,
            title: "Practice",
            emoji: "📖",
            completedSessions: 0,
            totalSessions: 0,
            isPracticeUnlocked: allCompleted
        ))

        return nodes
    }

    // MARK: - Node Content (wraps PathNodeView with interaction)

    @ViewBuilder
    private func nodeContent(for node: PathNode) -> some View {
        switch node.kind {
        case .lesson(let id):
            if node.state == .active {
                Button {
                    withAnimation(.spring(response: 0.3)) {
                        selectedLessonID = (selectedLessonID == id) ? nil : id
                    }
                } label: {
                    PathNodeView(node: node)
                }
                .buttonStyle(NodePressStyle())
            } else {
                // Completed, in-progress, or locked — tap to show popover
                Button {
                    withAnimation(.spring(response: 0.3)) {
                        selectedLessonID = (selectedLessonID == id) ? nil : id
                    }
                } label: {
                    PathNodeView(node: node)
                }
                .buttonStyle(.plain)
            }

        case .practice:
            if node.isPracticeUnlocked {
                if isPremium {
                    NavigationLink(value: "practice") {
                        PathNodeView(node: node)
                    }
                    .buttonStyle(.plain)
                } else {
                    Button { showPremiumGate = true } label: {
                        PathNodeView(node: node)
                    }
                    .buttonStyle(.plain)
                }
            } else {
                PathNodeView(node: node)
            }
        }
    }

    // MARK: - Popover Card

    @ViewBuilder
    private func popoverCard(for node: PathNode, containerWidth: CGFloat) -> some View {
        if case .lesson(let id) = node.kind {
            let isCompleted = completedIDs.contains(id)
            let total = totalSessions(id)
            let completed = completedSessionCount(id)
            let isAllDone = completed >= total && isCompleted
            let unlocked = node.state != .locked

            LessonPopoverCard(
                lessonID: id,
                title: node.title,
                chapterNumber: chapterNumber,
                unitNumber: node.indexInChapter,
                completedSessions: completed,
                totalSessions: total,
                isLocked: !unlocked,
                isReplay: isAllDone,
                sessionNumber: nextSessionNumber(id),
                onDismiss: { selectedLessonID = nil }
            )
        }
    }

    // MARK: - Path Canvas

    private func pathCanvas(nodes: [PathNode]) -> some View {
        ZStack {
            Canvas { context, _ in
                for i in 0..<(nodes.count - 1) {
                    let from = nodes[i].position
                    let to = nodes[i + 1].position

                    let fromCompleted = nodes[i].state == .completed
                    let toActive = nodes[i + 1].state == .active || nodes[i + 1].state == .inProgress || nodes[i + 1].state == .completed
                    let isActiveSegment = fromCompleted && toActive

                    var path = Path()
                    path.move(to: from)
                    let controlY = (from.y + to.y) / 2
                    path.addCurve(
                        to: to,
                        control1: CGPoint(x: from.x, y: controlY),
                        control2: CGPoint(x: to.x, y: controlY)
                    )

                    // Thick road base
                    let roadColor: Color = isActiveSegment
                        ? TarsierColors.pathActive.opacity(0.25)
                        : TarsierColors.pathLocked.opacity(0.15)
                    context.stroke(
                        path,
                        with: .color(roadColor),
                        style: StrokeStyle(lineWidth: 12, lineCap: .round)
                    )

                    // Dashed centre line
                    let dashColor: Color = isActiveSegment
                        ? TarsierColors.pathActive.opacity(0.5)
                        : TarsierColors.pathLocked.opacity(0.25)
                    context.stroke(
                        path,
                        with: .color(dashColor),
                        style: StrokeStyle(lineWidth: 2, lineCap: .round, dash: [6, 8])
                    )
                }
            }

            // Decorations between nodes
            ChapterDecorations(
                chapterIndex: chapterIndex,
                nodePositions: nodes.map(\.position)
            )
        }
    }

    // MARK: - Helpers

    private func computeChapterHeight() -> CGFloat {
        let lessonCount = chapter.lessonIDs.count
        let totalNodes = lessonCount + 1 // +1 for practice node
        return topPadding + CGFloat(totalNodes - 1) * verticalSpacing + bottomPadding + activeNodeSize
    }

    private func clampX(_ x: CGFloat, containerWidth: CGFloat) -> CGFloat {
        let halfCard: CGFloat = 100
        let padding: CGFloat = 20
        return max(halfCard + padding, min(containerWidth - halfCard - padding, x))
    }
}
