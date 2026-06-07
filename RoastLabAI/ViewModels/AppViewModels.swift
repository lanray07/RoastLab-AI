import Combine
import Foundation

@MainActor
final class GenerationViewModel: ObservableObject {
    @Published var output = ""
    @Published var observations: [String] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var response: RoastAIResponse?

    func run(_ operation: () async throws -> RoastAIResponse) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let response = try await operation()
            self.response = response
            output = response.primaryText
            observations = response.funnyObservations
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func reset() {
        output = ""
        observations = []
        errorMessage = nil
        response = nil
    }
}

@MainActor
final class OnboardingViewModel: ObservableObject {
    @Published var selectedStyle: HumorStyle = .playful
    @Published var selectedIntensity: RoastIntensity = .medium
    @Published var sampleRoast = ""
    @Published var isGenerating = false
    @Published var errorMessage: String?

    func generateSample(with service: RoastGenerationService) async {
        isGenerating = true
        errorMessage = nil
        defer { isGenerating = false }

        do {
            let response = try await service.generate(
                type: .bio,
                prompt: "A new creator wants a safe sample roast that feels clever and viral.",
                humorStyle: selectedStyle,
                roastIntensity: selectedIntensity
            )
            sampleRoast = response.primaryText
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

struct DashboardViewModel {
    func roastScore(roasts: Int, clapbacks: Int, battles: Int, voices: Int) -> Int {
        min(9_999, roasts * 12 + clapbacks * 10 + battles * 22 + voices * 18)
    }

    func streak(from dates: [Date]) -> Int {
        let calendar = Calendar.current
        let days = Set(dates.map { calendar.startOfDay(for: $0) })
        var streak = 0
        var cursor = calendar.startOfDay(for: Date())

        while days.contains(cursor) {
            streak += 1
            guard let previous = calendar.date(byAdding: .day, value: -1, to: cursor) else { break }
            cursor = previous
        }

        return streak
    }
}
