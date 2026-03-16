import SwiftUI
import SwiftData

struct WeeklyActivityChart: View {
    @Query private var activities: [DailyActivity]

    private let dayLabels = ["M", "T", "W", "T", "F", "S", "S"]

    private var weekData: [(label: String, minutes: Int, isToday: Bool)] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)

        // Find Monday of this week
        let weekday = calendar.component(.weekday, from: today)
        let daysFromMonday = (weekday + 5) % 7 // Monday = 0
        guard let monday = calendar.date(byAdding: .day, value: -daysFromMonday, to: today) else {
            return []
        }

        return (0..<7).map { offset in
            let date = calendar.date(byAdding: .day, value: offset, to: monday)!
            let dayStart = calendar.startOfDay(for: date)
            let minutes = activities.first { calendar.isDate($0.date, inSameDayAs: dayStart) }?.minutesPracticed ?? 0
            let isToday = calendar.isDateInToday(date)
            return (dayLabels[offset], minutes, isToday)
        }
    }

    private var maxMinutes: Int {
        max(weekData.map(\.minutes).max() ?? 0, 1)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("This Week")
                .font(TarsierFonts.caption())
                .foregroundStyle(TarsierColors.textSecondary)
                .textCase(.uppercase)

            HStack(alignment: .bottom, spacing: 8) {
                ForEach(Array(weekData.enumerated()), id: \.offset) { _, day in
                    VStack(spacing: 6) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(day.isToday ? TarsierColors.functionalPurple : TarsierColors.brandPurple.opacity(0.6))
                            .frame(height: max(4, CGFloat(day.minutes) / CGFloat(maxMinutes) * 80))

                        Text(day.label)
                            .font(TarsierFonts.caption(10))
                            .foregroundStyle(day.isToday ? TarsierColors.functionalPurple : TarsierColors.textSecondary)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .frame(height: 100)
        }
        .padding(TarsierSpacing.cardPadding)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(.white)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(TarsierColors.cardBorder, lineWidth: 1)
        )
    }
}
