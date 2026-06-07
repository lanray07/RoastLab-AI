import SwiftUI

enum AppRoute: Hashable {
    case photoRoast
    case bioRoast
    case voiceRoast
    case roastBattle
    case clapback
    case workplaceSafe
    case meme
    case personas
    case shareCards
    case paywall
    case widgets
    case watch
}

enum AppTab: String, CaseIterable, Identifiable {
    case dashboard
    case create
    case studio
    case analytics
    case settings

    var id: String { rawValue }

    var title: String {
        switch self {
        case .dashboard: "Dashboard"
        case .create: "Create"
        case .studio: "Studio"
        case .analytics: "Analytics"
        case .settings: "Settings"
        }
    }

    var icon: String {
        switch self {
        case .dashboard: "flame.fill"
        case .create: "wand.and.stars"
        case .studio: "movieclapper.fill"
        case .analytics: "chart.line.uptrend.xyaxis"
        case .settings: "gearshape.fill"
        }
    }
}

struct AppShellView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    var body: some View {
        if hasCompletedOnboarding {
            MainTabShell()
        } else {
            OnboardingView()
        }
    }
}

private struct MainTabShell: View {
    @State private var selectedTab: AppTab = .dashboard
    @State private var dashboardPath: [AppRoute] = []
    @State private var createPath: [AppRoute] = []
    @State private var studioPath: [AppRoute] = []
    @State private var analyticsPath: [AppRoute] = []
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

            NavigationStack(path: $studioPath) {
                CreatorStudioView()
                    .navigationDestination(for: AppRoute.self) { RouteDestinationView(route: $0) }
            }
            .tabItem { Label(AppTab.studio.title, systemImage: AppTab.studio.icon) }
            .tag(AppTab.studio)

            NavigationStack(path: $analyticsPath) {
                AnalyticsDashboardView()
                    .navigationDestination(for: AppRoute.self) { RouteDestinationView(route: $0) }
            }
            .tabItem { Label(AppTab.analytics.title, systemImage: AppTab.analytics.icon) }
            .tag(AppTab.analytics)

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
        case .personas:
            PersonalityProfilesView()
        case .shareCards:
            ShareCardsView()
        case .paywall:
            PaywallView()
        case .widgets:
            WidgetPlaceholderView()
        case .watch:
            WatchPlaceholderView()
        }
    }
}
