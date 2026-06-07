import Combine
import Foundation
import StoreKit
import SwiftData

let roastLabSystemPrompt = """
You are RoastLab AI, a comedy roast assistant. Generate playful, humorous, creative roasts and banter. Keep content funny and safe. Do not generate hate speech, harassment, threats, or abusive content. Focus on wit, absurdity, and clever observations.
"""

struct RoastAIRequest: Codable {
    var module: String
    var humorStyle: String
    var roastIntensity: String
    var prompt: String
    var voiceTranscript: String
    var photoAnalysis: String
}

struct RoastAIResponse: Codable {
    var roast: String?
    var clapback: String?
    var battle: String?
    var funnyObservations: [String]

    var primaryText: String {
        roast ?? clapback ?? battle ?? "RoastLab AI warmed up, adjusted the mic, and found nothing to roast yet."
    }
}

protocol RoastAIClient {
    func generate(_ request: RoastAIRequest) async throws -> RoastAIResponse
}

enum RoastLabError: LocalizedError {
    case unsafeInput
    case remoteServiceUnavailable
    case emptyPrompt

    var errorDescription: String? {
        switch self {
        case .unsafeInput:
            "That prompt is outside RoastLab AI safety rules. Try a playful, non-targeted setup."
        case .remoteServiceUnavailable:
            "The remote AI endpoint is not configured yet. Mock AI is still available."
        case .emptyPrompt:
            "Add a prompt, bio, transcript, or image first."
        }
    }
}

enum SafetyGuardrails {
    static let blockedTerms = [
        "kill yourself",
        "self harm",
        "terrorist recruitment",
        "sexual abuse",
        "minor sexual",
        "protected class"
    ]

    static func cleaned(_ text: String) throws -> String {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { throw RoastLabError.emptyPrompt }

        let lowered = trimmed.lowercased()
        guard !blockedTerms.contains(where: { lowered.contains($0) }) else {
            throw RoastLabError.unsafeInput
        }

        return String(trimmed.prefix(1_200))
    }

    static func playfulSafetyLine(for intensity: RoastIntensity) -> String {
        switch intensity {
        case .mild: "Keep it cozy, clever, and suitable for a group chat."
        case .medium: "Make it sharp, but still clearly friendly comedy."
        case .spicy: "Bring heat without hate, threats, or personal cruelty."
        case .nuclear: "Go big on absurdity and theatrical flair, not abuse."
        }
    }
}

@MainActor
final class AppServices: ObservableObject {
    let roastGeneration: RoastGenerationService
    let clapback: ClapbackService
    let roastBattle: RoastBattleService
    let voiceRoast: VoiceRoastService
    let comedyPersona: ComedyPersonaService
    let memeCaption: MemeCaptionService
    let imageAnalysis: PhotoAnalysisService
    let subscriptionStore: SubscriptionStore

    init(aiClient: RoastAIClient, imageAnalysis: PhotoAnalysisService = PhotoAnalysisService()) {
        self.roastGeneration = RoastGenerationService(aiClient: aiClient)
        self.clapback = ClapbackService(aiClient: aiClient)
        self.roastBattle = RoastBattleService(aiClient: aiClient)
        self.voiceRoast = VoiceRoastService(aiClient: aiClient)
        self.comedyPersona = ComedyPersonaService()
        self.memeCaption = MemeCaptionService(aiClient: aiClient)
        self.imageAnalysis = imageAnalysis
        self.subscriptionStore = SubscriptionStore()
    }

    static func makeMock() -> AppServices {
        AppServices(aiClient: MockAIService())
    }

    static func makeRemote(endpoint: URL = URL(string: "https://YOUR_BACKEND_URL.com/roastlab-ai")!) -> AppServices {
        AppServices(aiClient: RemoteAIService(endpoint: endpoint))
    }
}

final class RoastGenerationService {
    private let aiClient: RoastAIClient

    init(aiClient: RoastAIClient) {
        self.aiClient = aiClient
    }

    func generate(
        type: RoastRequestType,
        prompt: String,
        humorStyle: HumorStyle,
        roastIntensity: RoastIntensity,
        photoAnalysis: String = "",
        voiceTranscript: String = ""
    ) async throws -> RoastAIResponse {
        let prompt = try SafetyGuardrails.cleaned(prompt)
        return try await aiClient.generate(RoastAIRequest(
            module: type.rawValue,
            humorStyle: humorStyle.promptValue,
            roastIntensity: roastIntensity.rawValue,
            prompt: prompt,
            voiceTranscript: voiceTranscript,
            photoAnalysis: photoAnalysis
        ))
    }
}

final class ClapbackService {
    private let aiClient: RoastAIClient

    init(aiClient: RoastAIClient) {
        self.aiClient = aiClient
    }

    func generate(context: String, style: HumorStyle, intensity: RoastIntensity) async throws -> RoastAIResponse {
        let context = try SafetyGuardrails.cleaned(context)
        return try await aiClient.generate(RoastAIRequest(
            module: RoastRequestType.clapback.rawValue,
            humorStyle: style.promptValue,
            roastIntensity: intensity.rawValue,
            prompt: context,
            voiceTranscript: "",
            photoAnalysis: ""
        ))
    }
}

final class RoastBattleService {
    private let aiClient: RoastAIClient

    init(aiClient: RoastAIClient) {
        self.aiClient = aiClient
    }

    func generate(participantA: String, participantB: String, style: HumorStyle, intensity: RoastIntensity) async throws -> RoastAIResponse {
        let a = try SafetyGuardrails.cleaned(participantA)
        let b = try SafetyGuardrails.cleaned(participantB)
        return try await aiClient.generate(RoastAIRequest(
            module: RoastRequestType.battle.rawValue,
            humorStyle: style.promptValue,
            roastIntensity: intensity.rawValue,
            prompt: "\(a) vs \(b)",
            voiceTranscript: "",
            photoAnalysis: ""
        ))
    }
}

final class VoiceRoastService {
    private let aiClient: RoastAIClient

    init(aiClient: RoastAIClient) {
        self.aiClient = aiClient
    }

    func generate(transcript: String, style: HumorStyle, intensity: RoastIntensity) async throws -> RoastAIResponse {
        let transcript = try SafetyGuardrails.cleaned(transcript)
        return try await aiClient.generate(RoastAIRequest(
            module: RoastRequestType.voice.rawValue,
            humorStyle: style.promptValue,
            roastIntensity: intensity.rawValue,
            prompt: transcript,
            voiceTranscript: transcript,
            photoAnalysis: ""
        ))
    }
}

final class MemeCaptionService {
    private let aiClient: RoastAIClient

    init(aiClient: RoastAIClient) {
        self.aiClient = aiClient
    }

    func generate(prompt: String, style: HumorStyle, intensity: RoastIntensity) async throws -> RoastAIResponse {
        let prompt = try SafetyGuardrails.cleaned(prompt)
        return try await aiClient.generate(RoastAIRequest(
            module: RoastRequestType.meme.rawValue,
            humorStyle: style.promptValue,
            roastIntensity: intensity.rawValue,
            prompt: prompt,
            voiceTranscript: "",
            photoAnalysis: ""
        ))
    }
}

@MainActor
final class ComedyPersonaService {
    func seedDefaultPersonas(in context: ModelContext, existing: [ComedyPersona]) {
        guard existing.isEmpty else { return }
        ComedyPersona.starterPersonas.forEach { persona in
            context.insert(ComedyPersona(name: persona.name, tagline: persona.tagline, unlocked: persona.unlocked))
        }
        try? context.save()
    }

    func unlockEligiblePersonas(in personas: [ComedyPersona], roastCount: Int) {
        let unlockTargets = max(1, min(personas.count, roastCount / 5 + 1))
        personas.prefix(unlockTargets).forEach { $0.unlocked = true }
    }
}

struct MockAIService: RoastAIClient {
    func generate(_ request: RoastAIRequest) async throws -> RoastAIResponse {
        try await Task.sleep(nanoseconds: 350_000_000)

        let style = request.humorStyle
        let intensity = RoastIntensity(rawValue: request.roastIntensity) ?? .medium
        let subject = compactSubject(from: request)
        let observationSeed = [
            "The confidence is loading faster than the plan.",
            "There is premium chaos in the margins.",
            "The main-character energy has requested backup dancers."
        ]

        switch request.module {
        case RoastRequestType.clapback.rawValue:
            return RoastAIResponse(
                roast: nil,
                clapback: "Tiny trumpet for the drama: \(subject) arrived with the energy of a comment section wearing sunglasses. Reply: \"Bold take from someone whose Wi-Fi has commitment issues.\"",
                battle: nil,
                funnyObservations: observationSeed
            )
        case RoastRequestType.battle.rawValue:
            return RoastAIResponse(
                roast: nil,
                clapback: nil,
                battle: """
                Round 1
                A opens with confidence. B replies with the calm of someone who alphabetizes excuses.

                Round 2
                A says the vibes are premium. B says premium does not mean the free trial of self-awareness expired.

                Winner
                The audience, because both sides were roasted and nobody had to call HR.
                """,
                funnyObservations: ["A brought volume.", "B brought timing.", "The safest winner is the group chat."]
            )
        case RoastRequestType.voice.rawValue:
            return RoastAIResponse(
                roast: "Voice note reviewed. \(subject) has the pacing of a TED Talk and the plot structure of a drawer full of cables. \(SafetyGuardrails.playfulSafetyLine(for: intensity))",
                clapback: nil,
                battle: nil,
                funnyObservations: ["Great material for stand-up pacing.", "A tiny pause before the punchline would cook.", "The transcript has sitcom cold-open energy."]
            )
        case RoastRequestType.meme.rawValue:
            return RoastAIResponse(
                roast: """
                Meme captions:
                1. POV: you said \"quick update\" and opened a 47-slide deck.
                2. When the confidence is loud but the calendar invite is louder.
                3. \(subject): professionally unserious, spiritually caffeinated.
                """,
                clapback: nil,
                battle: nil,
                funnyObservations: ["Caption format is ready for image macros.", "Punchline works as a reaction post.", "Safe, shareable, and creator-friendly."]
            )
        case RoastRequestType.creator.rawValue:
            return RoastAIResponse(
                roast: """
                TikTok script
                Hook: Upload anything. Get roasted instantly.
                Beat 1: Show the prompt like it owes you rent.
                Beat 2: RoastLab AI delivers a clean uppercut of absurdity.
                Beat 3: Smash cut to the share card.
                CTA: Send it to the friend who can handle premium banter.
                """,
                clapback: nil,
                battle: nil,
                funnyObservations: ["Shorts-ready structure.", "Fast hook.", "Ends with a shareable moment."]
            )
        case RoastRequestType.workplace.rawValue:
            return RoastAIResponse(
                roast: "Office-safe roast: \(subject) has the energy of a meeting that could have been a calendar emoji. Polite, professional, and only mildly toasted.",
                clapback: nil,
                battle: nil,
                funnyObservations: ["No HR alarms detected.", "Works as meeting banter.", "Friendly enough for coworkers."]
            )
        default:
            return RoastAIResponse(
                roast: "\(style.capitalized) mode: \(subject) is giving \"I installed confidence from a beta build\". Funny, flashy, and somehow still waiting for the tutorial.",
                clapback: nil,
                battle: nil,
                funnyObservations: observationSeed
            )
        }
    }

    private func compactSubject(from request: RoastAIRequest) -> String {
        switch request.module {
        case RoastRequestType.photo.rawValue:
            "this creator photo"
        case RoastRequestType.bio.rawValue:
            "this profile bio"
        case RoastRequestType.voice.rawValue:
            "this voice note"
        case RoastRequestType.battle.rawValue:
            "this roast battle matchup"
        case RoastRequestType.clapback.rawValue:
            "that comment"
        case RoastRequestType.workplace.rawValue:
            "this office setup"
        case RoastRequestType.meme.rawValue:
            "this meme setup"
        case RoastRequestType.creator.rawValue:
            "this creator brief"
        default:
            "this mysterious input"
        }
    }
}

struct RemoteAIService: RoastAIClient {
    var endpoint: URL

    func generate(_ request: RoastAIRequest) async throws -> RoastAIResponse {
        var urlRequest = URLRequest(url: endpoint)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = try JSONEncoder().encode(request)

        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        guard let httpResponse = response as? HTTPURLResponse, (200..<300).contains(httpResponse.statusCode) else {
            throw RoastLabError.remoteServiceUnavailable
        }

        return try JSONDecoder().decode(RoastAIResponse.self, from: data)
    }
}

@MainActor
final class SubscriptionStore: ObservableObject {
    @Published var products: [Product] = []
    @Published var activePlan: SubscriptionPlan = .free
    @Published var isActive = false
    @Published var storeError: String?

    let productIdentifiers: Set<String> = [
        "roastlab.roastpro.monthly",
        "roastlab.roastpro.yearly",
        "roastlab.creatorpro.monthly"
    ]

    func refreshProducts() async {
        do {
            products = try await Product.products(for: productIdentifiers)
            await syncEntitlements()
        } catch {
            storeError = error.localizedDescription
        }
    }

    func purchase(_ product: Product) async throws {
        let result = try await product.purchase()
        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            apply(productID: transaction.productID)
            await transaction.finish()
        case .userCancelled, .pending:
            break
        @unknown default:
            break
        }
    }

    func syncEntitlements() async {
        for await result in Transaction.currentEntitlements {
            guard let transaction = try? checkVerified(result) else { continue }
            apply(productID: transaction.productID)
        }
    }

    func activateMock(plan: SubscriptionPlan) {
        activePlan = plan
        isActive = plan != .free
    }

    private func apply(productID: String) {
        switch productID {
        case "roastlab.roastpro.monthly":
            activePlan = .roastProMonthly
        case "roastlab.roastpro.yearly":
            activePlan = .roastProYearly
        case "roastlab.creatorpro.monthly":
            activePlan = .creatorProMonthly
        default:
            activePlan = .free
        }
        isActive = activePlan != .free
    }

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw RoastLabError.remoteServiceUnavailable
        case .verified(let safe):
            return safe
        }
    }
}
