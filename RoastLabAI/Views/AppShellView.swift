import SwiftUI

enum AppRoute: Hashable {
    case photoRoast
    case bioRoast
    case voiceRoast
    case roastBattle
    case clapback
    case workplaceSafe
    case meme
    case creatorStudio
    case personas
    case shareCards
    case paywall
}

enum AppTab: String, CaseIterable, Identifiable {
    case dashboard
    case create
    case settings

    var id: String { rawValue }

    var title: String {
        switch self {
        case .dashboard: "Home"
        case .create: "Create"
        case .settings: "Settings"
        }
    }

    var icon: String {
        switch self {
        case .dashboard: "flame.fill"
        case .create: "wand.and.stars"
        case .settings: "gearshape.fill"
        }
    }
}

struct AppShellView: View {
    var body: some View {
        MainTabShell()
    }
}

private struct MainTabShell: View {
    @State private var selectedTab: AppTab = .dashboard
    @State private var dashboardPath: [AppRoute] = []
    @State private var createPath: [AppRoute] = []
    @State private var settingsPath: [AppRoute] = []

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack(path: $dashboardPath) {
                DashboardView()
                    .navigationDestination(for: AppRoute.self) { RouteDestinationView(route: $0) }
            }
            .tabItem { Label(AppTab.dashboard.title, systemImage: AppTab.dashboard.icon) }
            .tag(AppTab.dashboard)

            NavigationStack(path: $createPath) {
                CreateHubView()
                    .navigationDestination(for: AppRoute.self) { RouteDestinationView(route: $0) }
            }
            .tabItem { Label(AppTab.create.title, systemImage: AppTab.create.icon) }
            .tag(AppTab.create)

            NavigationStack(path: $settingsPath) {
                SettingsView()
                    .navigationDestination(for: AppRoute.self) { RouteDestinationView(route: $0) }
            }
            .tabItem { Label(AppTab.settings.title, systemImage: AppTab.settings.icon) }
            .tag(AppTab.settings)
        }
        .tint(RoastLabTheme.hotPink)
    }
}

private struct RouteDestinationView: View {
    var route: AppRoute

    var body: some View {
        switch route {
        case .photoRoast:
            PhotoRoastGeneratorView()
        case .bioRoast:
            BioRoastGeneratorView()
        case .voiceRoast:
            VoiceRoastFeatureView()
        case .roastBattle:
            RoastBattleModeView()
        case .clapback:
            ClapbackGeneratorView()
        case .workplaceSafe:
            WorkplaceSafeModeView()
        case .meme:
            MemeGeneratorView()
        case .creatorStudio:
            CreatorStudioView()
        case .personas:
            PersonalityProfilesView()
        case .shareCards:
            ShareCardsView()
        case .paywall:
            PaywallView()
        }
    }
}
