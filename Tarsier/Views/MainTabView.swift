import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            NavigationStack {
                HomeView()
            }
            .tabItem {
                Label("Learn", systemImage: "book.fill")
            }

            NavigationStack {
                WordsView()
            }
            .tabItem {
                Label("Words", systemImage: "character.book.closed.fill")
            }

            NavigationStack {
                ProfileView()
            }
            .tabItem {
                Label("Profile", systemImage: "person.fill")
            }
        }
        .tint(TarsierColors.functionalPurple)
    }
}
