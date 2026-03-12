import SwiftUI

// MARK: - Tab Definition

enum AppTab: CaseIterable {
    case learn, words, profile

    var label: String {
        switch self {
        case .learn: "Learn"
        case .words: "Vocab"
        case .profile: "Me"
        }
    }

    var activeIcon: String {
        switch self {
        case .learn: "graduationcap.fill"
        case .words: "character.book.closed.fill"
        case .profile: "person.crop.circle.fill"
        }
    }

    var inactiveIcon: String {
        switch self {
        case .learn: "graduationcap"
        case .words: "character.book.closed"
        case .profile: "person.crop.circle"
        }
    }
}

// MARK: - Main Tab View

struct MainTabView: View {
    @State private var selectedTab: AppTab = .learn
    @State private var learnPath = NavigationPath()
    @State private var wordsPath = NavigationPath()

    private var showTabBar: Bool {
        learnPath.isEmpty && wordsPath.isEmpty
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            // Content area
            Group {
                switch selectedTab {
                case .learn:
                    NavigationStack(path: $learnPath) { HomeView() }
                case .words:
                    NavigationStack(path: $wordsPath) { WordsView() }
                case .profile:
                    NavigationStack { ProfileView() }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .safeAreaPadding(.bottom, showTabBar ? 56 : 0)

            // Custom tab bar
            if showTabBar {
                TarsierTabBar(selectedTab: $selectedTab)
                    .padding(.horizontal, 56)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.25), value: showTabBar)
        .ignoresSafeArea(.keyboard)
    }
}

// MARK: - Custom Tab Bar

private struct TarsierTabBar: View {
    @Binding var selectedTab: AppTab

    private let accentColor = TarsierColors.functionalPurple
    private let inactiveColor = TarsierColors.textSecondary
    var body: some View {
        HStack(spacing: 0) {
            ForEach(AppTab.allCases, id: \.self) { tab in
                tabButton(for: tab)
            }
        }
        .padding(.top, 10)
        .padding(.bottom, 8)
        .padding(.horizontal, 4)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(.white)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .strokeBorder(Color.black.opacity(0.04), lineWidth: 0.5)
        )
        // Gaussian glow surrounding all edges
        .shadow(color: .black.opacity(0.08), radius: 16, y: 0)
        .shadow(color: .black.opacity(0.05), radius: 6, y: 2)
    }

    private func tabButton(for tab: AppTab) -> some View {
        Button {
            selectedTab = tab
        } label: {
            VStack(spacing: 3) {
                let isActive = selectedTab == tab

                Image(systemName: isActive ? tab.activeIcon : tab.inactiveIcon)
                    .font(.system(size: 22, weight: .medium, design: .rounded))
                    .symbolRenderingMode(.monochrome)
                    .foregroundStyle(isActive ? AnyShapeStyle(accentColor) : AnyShapeStyle(inactiveColor))
                    .frame(height: 24)

                Text(tab.label)
                    .font(.system(size: 10, weight: .medium, design: .rounded))
                    .foregroundStyle(isActive ? AnyShapeStyle(accentColor) : AnyShapeStyle(inactiveColor))
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }
}
