import Foundation
import SwiftData

@Model
final class DailyActivity {
    var date: Date
    var minutesPracticed: Int

    init(date: Date = .now, minutesPracticed: Int = 0) {
        self.date = Calendar.current.startOfDay(for: date)
        self.minutesPracticed = minutesPracticed
    }
}
