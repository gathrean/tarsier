import SwiftUI

/// Small decorative elements placed along the roadmap path.
/// Purely visual — not interactive.
enum RoadmapDecoration {
    case stone
    case bush

    /// Returns a small decorative view.
    @ViewBuilder
    func view() -> some View {
        switch self {
        case .stone:
            StoneDecoration()
        case .bush:
            BushDecoration()
        }
    }
}

/// Small grey circle — "stone" decoration.
private struct StoneDecoration: View {
    var body: some View {
        Ellipse()
            .fill(Color(.systemGray4).opacity(0.5))
            .frame(width: 10, height: 8)
    }
}

/// Small green rounded rectangle — "bush" decoration.
private struct BushDecoration: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 4)
            .fill(Color.green.opacity(0.2))
            .frame(width: 16, height: 10)
    }
}

/// Places 2-3 decorations per chapter at fixed offsets from the path.
/// Uses a seeded random to keep positions stable across re-renders.
struct ChapterDecorations: View {
    let chapterIndex: Int
    let nodePositions: [CGPoint]

    var body: some View {
        ForEach(decorationPlacements, id: \.offset) { placement in
            placement.decoration.view()
                .position(placement.position)
        }
    }

    private struct Placement: Identifiable {
        let offset: Int
        let decoration: RoadmapDecoration
        let position: CGPoint
        var id: Int { offset }
    }

    private var decorationPlacements: [Placement] {
        guard nodePositions.count >= 2 else { return [] }
        var placements: [Placement] = []

        // Place 2-3 decorations between nodes
        let count = min(3, nodePositions.count - 1)
        for i in 0..<count {
            let nodeA = nodePositions[i]
            let nodeB = nodePositions[min(i + 1, nodePositions.count - 1)]
            let midY = (nodeA.y + nodeB.y) / 2

            // Deterministic offset based on chapter + index
            let seed = chapterIndex * 100 + i
            let xOffset: CGFloat = (seed % 2 == 0) ? -50 : 50
            let decoration: RoadmapDecoration = (seed % 3 == 0) ? .bush : .stone

            placements.append(Placement(
                offset: seed,
                decoration: decoration,
                position: CGPoint(
                    x: (nodeA.x + nodeB.x) / 2 + xOffset,
                    y: midY + CGFloat(seed % 20) - 10
                )
            ))
        }

        return placements
    }
}
