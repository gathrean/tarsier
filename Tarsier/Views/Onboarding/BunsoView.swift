import SwiftUI

enum BunsoPose: String, CaseIterable {
    case waving
    case curious
    case blushing
    case flexing
    case celebrating
    case reading
    case tappingWrist
    case thumbsUp
    case heartEyes
    case excited

    var label: String {
        switch self {
        case .waving: "👋"
        case .curious: "🤔"
        case .blushing: "☺️"
        case .flexing: "💪"
        case .celebrating: "🎉"
        case .reading: "📖"
        case .tappingWrist: "⏰"
        case .thumbsUp: "👍"
        case .heartEyes: "😍"
        case .excited: "🤩"
        }
    }

    /// Asset catalog image name for this pose, nil if not yet provided.
    /// Add new cases here as Ean exports more poses from Affinity Designer.
    var assetName: String? {
        switch self {
        case .waving: "Tarsier-Waving"
        // Future poses:
        // case .curious: "Tarsier-Curious"
        // case .celebrating: "Tarsier-Celebrating"
        default: nil
        }
    }
}

/// Bunso mascot — renders the real illustration asset when available,
/// falls back to the default Waving asset (or placeholder circle if no assets exist).
struct BunsoView: View {
    let pose: BunsoPose
    var size: CGFloat = 120

    /// The asset to display: use pose-specific if available, otherwise fall back to Waving
    private var resolvedAsset: String? {
        pose.assetName ?? BunsoPose.waving.assetName
    }

    var body: some View {
        if let asset = resolvedAsset, UIImage(named: asset) != nil {
            Image(asset)
                .resizable()
                .scaledToFit()
                .frame(width: size, height: size)
        } else {
            placeholderView
        }
    }

    // MARK: - Placeholder (used only if no assets exist at all)

    private let bodyColor = Color(hex: "#C47A2B")
    private let bellyColor = Color(hex: "#E8A84C")
    private let eyeColor = Color(hex: "#D4A017")

    private var placeholderView: some View {
        ZStack {
            Circle()
                .fill(bodyColor)
                .frame(width: size, height: size)

            Ellipse()
                .fill(bellyColor)
                .frame(width: size * 0.55, height: size * 0.45)
                .offset(y: size * 0.08)

            HStack(spacing: size * 0.15) {
                Circle()
                    .fill(eyeColor)
                    .frame(width: size * 0.2, height: size * 0.2)
                    .overlay(
                        Circle()
                            .fill(.black)
                            .frame(width: size * 0.1, height: size * 0.1)
                    )
                Circle()
                    .fill(eyeColor)
                    .frame(width: size * 0.2, height: size * 0.2)
                    .overlay(
                        Circle()
                            .fill(.black)
                            .frame(width: size * 0.1, height: size * 0.1)
                    )
            }
            .offset(y: -size * 0.12)

            HStack(spacing: size * 0.35) {
                Circle()
                    .fill(Color.pink.opacity(0.3))
                    .frame(width: size * 0.12, height: size * 0.12)
                Circle()
                    .fill(Color.pink.opacity(0.3))
                    .frame(width: size * 0.12, height: size * 0.12)
            }
            .offset(y: -size * 0.02)

            Text(pose.label)
                .font(.system(size: size * 0.22))
                .offset(x: size * 0.38, y: -size * 0.38)
        }
    }
}
