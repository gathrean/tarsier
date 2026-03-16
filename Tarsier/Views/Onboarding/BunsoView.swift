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
}

/// Bunso mascot placeholder — colored circle with golden eyes and pose indicator.
/// Replace with actual illustration assets when Ean provides them.
struct BunsoView: View {
    let pose: BunsoPose
    var size: CGFloat = 120

    private let bodyColor = Color(hex: "#C47A2B")
    private let bellyColor = Color(hex: "#E8A84C")
    private let eyeColor = Color(hex: "#D4A017")

    var body: some View {
        ZStack {
            // Body
            Circle()
                .fill(bodyColor)
                .frame(width: size, height: size)

            // Belly
            Ellipse()
                .fill(bellyColor)
                .frame(width: size * 0.55, height: size * 0.45)
                .offset(y: size * 0.08)

            // Eyes
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

            // Rosy cheeks
            HStack(spacing: size * 0.35) {
                Circle()
                    .fill(Color.pink.opacity(0.3))
                    .frame(width: size * 0.12, height: size * 0.12)
                Circle()
                    .fill(Color.pink.opacity(0.3))
                    .frame(width: size * 0.12, height: size * 0.12)
            }
            .offset(y: -size * 0.02)

            // Pose emoji indicator
            Text(pose.label)
                .font(.system(size: size * 0.22))
                .offset(x: size * 0.38, y: -size * 0.38)
        }
    }
}
