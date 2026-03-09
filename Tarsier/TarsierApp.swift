import SwiftUI
import SwiftData

@main
struct TarsierApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [UserProfile.self, LessonResult.self, ChatMessage.self])
    }
}
