import Foundation

#if canImport(WatchConnectivity)
import Combine
import WatchConnectivity

struct WatchRoastPrompt: Identifiable, Codable {
    var id = UUID()
    var title: String
    var prompt: String
}

final class WatchCompanionPlaceholder: NSObject, ObservableObject {
    @Published var isReachable = false
    @Published var latestPrompt = WatchRoastPrompt(
        title: "Daily Roast",
        prompt: "Send a safe daily roast prompt to Apple Watch."
    )

    func configureFutureSession() {
        guard WCSession.isSupported() else { return }
        isReachable = WCSession.default.isReachable
    }
}
#endif
