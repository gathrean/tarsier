import SwiftUI
import SwiftData

struct StreakCalendarView: View {
    @Query private var activities: [DailyActivity]

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 7)
    private let dayHeaders = ["M", "T", "W", "T", "F", "S", "S"]

    private var calendarData: (monthLabel: String, days: [DayInfo]) {
        let calendar = Calendar.current
        let today = Date.now
        let components = calendar.dateComponents([.year, .month], from: today)
        guard let firstOfMonth = calendar.date(from: components) else {
            return ("", [])
        }

        let monthFormatter = DateFormatter()
        monthFormatter.dateFormat = "MMMM yyyy"
        let monthLabel = monthFormatter.string(from: today)

        let range = calendar.range(of: .day, in: .month, for: firstOfMonth)!
        let weekday = calendar.component(.weekday, from: firstOfMonth)
        let leadingBlanks = (weekday + 5) % 7 // Monday = 0

        var days: [DayInfo] = []

        // Leading blanks
        for _ in 0..<leadingBlanks {
            days.append(DayInfo(day: 0, hasActivity: false, isToday: false))
        }

        // Days of month
        for day in range {
            let date = calendar.date(byAdding: .day, value: day - 1, to: firstOfMonth)!
            let hasActivity = activities.contains { calendar.isDate($0.date, inSameDayAs: date) && $0.minutesPracticed > 0 }
            let isToday = calendar.isDateInToday(date)
            days.append(DayInfo(day: day, hasActivity: hasActivity, isToday: isToday))
        }

        return (monthLabel, days)
    }

    var body: some View {
        let data = calendarData

        VStack(alignment: .leading, spacing: 10) {
            Text(data.monthLabel)
                .font(TarsierFonts.caption())
                .foregroundStyle(TarsierColors.textSecondary)
                .textCase(.uppercase)

            // Day headers
            LazyVGrid(columns: columns, spacing: 4) {
                ForEach(dayHeaders, id: \.self) { header in
                    Text(header)
                        .font(TarsierFonts.caption(9))
                        .foregroundStyle(TarsierColors.textSecondary)
                        .frame(maxWidth: .infinity)
                }
            }

            // Day dots
            LazyVGrid(columns: columns, spacing: 6) {
                ForEach(Array(data.days.enumerated()), id: \.offset) { _, day in
                    if day.day == 0 {
                        Color.clear.frame(width: 24, height: 24)
                    } else {
                        ZStack {
                            if day.hasActivity {
                                Circle()
                                    .fill(TarsierColors.functionalPurple)
                                    .frame(width: 24, height: 24)
                            } else {
                                Circle()
                                    .stroke(TarsierColors.cardBorder, lineWidth: 1)
                                    .frame(width: 24, height: 24)
                            }

                            if day.isToday {
                                Circle()
                                    .stroke(TarsierColors.functionalPurple, lineWidth: 2)
                                    .frame(width: 28, height: 28)
                            }

                            Text("\(day.day)")
                                .font(TarsierFonts.caption(9))
                                .foregroundStyle(day.hasActivity ? .white : TarsierColors.textSecondary)
                        }
                        .frame(width: 30, height: 30)
                    }
                }
            }
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

private struct DayInfo {
    let day: Int
    let hasActivity: Bool
    let isToday: Bool
}
