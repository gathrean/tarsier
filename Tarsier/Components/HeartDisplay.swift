import SwiftUI

struct HeartDisplay: View {
    let current: Int
    let max: Int
    let isPremium: Bool

    init(current: Int, max: Int = 5, isPremium: Bool = false) {
        self.current = current
        self.max = max
        self.isPremium = isPremium
    }

    var body: some View {
        HStack(spacing: 2) {
            if isPremium {
                Image(systemName: "heart.fill")
                    .foregroundStyle(TarsierColors.heartRed)
                Text("\u{221E}")
                    .font(TarsierFonts.heading())
                    .foregroundStyle(TarsierColors.heartRed)
            } else {
                ForEach(0..<max, id: \.self) { index in
                    Image(systemName: index < current ? "heart.fill" : "heart")
                        .foregroundStyle(index < current ? TarsierColors.heartRed : .white.opacity(0.35))
                        .font(.system(size: 14, weight: .semibold))
                        .scaleEffect(index < current ? 1.0 : 0.9)
                        .animation(.easeOut(duration: 0.3), value: current)
                }
            }
        }
    }
}
