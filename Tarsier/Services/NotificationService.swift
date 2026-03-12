import UserNotifications

enum NotificationService {
    private static let notificationIDs = ["tarsier-daily-1", "tarsier-daily-2", "tarsier-daily-3"]

    @MainActor
    static func requestAndSchedule(at time: Date, userName: String?) async {
        let center = UNUserNotificationCenter.current()
        let granted = (try? await center.requestAuthorization(options: [.alert, .badge, .sound])) ?? false
        guard granted else { return }
        scheduleDailyNotifications(at: time, userName: userName)
    }

    static func scheduleDailyNotifications(at time: Date, userName: String?) {
        let center = UNUserNotificationCenter.current()
        // Remove any existing scheduled notifications
        center.removePendingNotificationRequests(withIdentifiers: notificationIDs)

        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: time)
        let minute = calendar.component(.minute, from: time)

        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)

        let messages = notificationMessages(userName: userName)

        for (index, id) in notificationIDs.enumerated() {
            let content = UNMutableNotificationContent()
            content.title = "Tarsier"
            content.body = messages[index]
            content.sound = .default

            let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
            center.add(request)
        }
    }

    static func cancelAll() {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: notificationIDs)
    }

    private static func notificationMessages(userName: String?) -> [String] {
        if let name = userName {
            return [
                "Time to practice, \(name)! Keep your streak going.",
                "Kumusta, \(name)? Tarsier misses you.",
                "5 minutes is all it takes. Tara!"
            ]
        } else {
            return [
                "Time to practice! Keep your streak going.",
                "Kumusta? Tarsier misses you.",
                "5 minutes is all it takes. Tara!"
            ]
        }
    }
}
