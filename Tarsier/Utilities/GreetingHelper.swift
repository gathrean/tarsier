import Foundation

enum GreetingHelper {
    /// Returns a personalised, time-of-day greeting using the user's name and optional Ate/Kuya title.
    static func greeting(for profile: UserProfile) -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        let timeGreeting: String
        switch hour {
        case 5..<12: timeGreeting = "Good morning"
        case 12..<17: timeGreeting = "Good afternoon"
        case 17..<21: timeGreeting = "Good evening"
        default: timeGreeting = "Hey"
        }

        guard let name = profile.userName, !name.isEmpty else {
            return "\(timeGreeting)!"
        }

        if let title = profile.preferredTitle, !title.isEmpty {
            return "\(timeGreeting), \(title) \(name)!"
        }
        return "\(timeGreeting), \(name)!"
    }
}
