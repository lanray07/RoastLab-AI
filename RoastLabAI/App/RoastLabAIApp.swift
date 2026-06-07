import SwiftData
import SwiftUI

@main
struct RoastLabAIApp: App {
    @StateObject private var services = AppServices.makeMock()
    private let modelContainer: ModelContainer

    init() {
        do {
            let schema = Schema([
                UserProfile.self,
                RoastRequest.self,
                VoiceTranscript.self,
                RoastBattle.self,
                Clapback.self,
                ComedyPersona.self,
                SubscriptionState.self
            ])
            let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
            modelContainer = try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("Unable to create RoastLab AI SwiftData container: \(error.localizedDescription)")
        }
    }

    var body: some Scene {
        WindowGroup {
            AppShellView()
                .environmentObject(services)
                .preferredColorScheme(.dark)
        }
        .modelContainer(modelContainer)
    }
}
