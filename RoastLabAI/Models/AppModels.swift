import Foundation
import SwiftData

enum HumorStyle: String, CaseIterable, Identifiable, Codable {
    case playful
    case sarcastic
    case savage
    case absurd
    case britishBanter
    case witty
    case cleanComedy

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .playful: "Playful"
        case .sarcastic: "Sarcastic"
        case .savage: "Savage"
        case .absurd: "Absurd"
        case .britishBanter: "British Banter"
        case .witty: "Witty"
        case .cleanComedy: "Clean Comedy"
        }
    }

    var promptValue: String {
        switch self {
        case .britishBanter: "british banter"
        case .cleanComedy: "clean comedy"
        default: rawValue
        }
    }
}

enum RoastIntensity: String, CaseIterable, Identifiable, Codable {
    case mild
    case medium
    case spicy
    case nuclear

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .mild: "Mild"
        case .medium: "Medium"
        case .spicy: "Spicy"
        case .nuclear: "Nuclear"
        }
    }
}

enum RoastRequestType: String, CaseIterable, Identifiable, Codable {
    case photo
    case bio
    case voice
    case battle
    case clapback
    case workplace
    case meme
    case creator

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .photo: "Photo Roast"
        case .bio: "Bio Roast"
        case .voice: "Voice Roast"
        case .battle: "Roast Battle"
        case .clapback: "Clapback"
        case .workplace: "Workplace Safe"
        case .meme: "Meme Roast"
        case .creator: "Creator Studio"
        }
    }
}

enum SubscriptionPlan: String, CaseIterable, Identifiable, Codable {
    case free
    case roastProMonthly
    case roastProYearly
    case creatorProMonthly

    var id: String { rawValue }

    static let paidPlans: [SubscriptionPlan] = [
        .roastProMonthly,
        .roastProYearly,
        .creatorProMonthly
    ]

    var productIdentifier: String? {
        switch self {
        case .free:
            nil
        case .roastProMonthly:
            "roastlab.roastpro.monthly"
        case .roastProYearly:
            "roastlab.roastpro.yearly"
        case .creatorProMonthly:
            "roastlab.creatorpro.monthly"
        }
    }

    var displayName: String {
        switch self {
        case .free: "Free"
        case .roastProMonthly: "Roast Pro Monthly"
        case .roastProYearly: "Roast Pro Yearly"
        case .creatorProMonthly: "Creator Pro Monthly"
        }
    }

    var pricePlaceholder: String {
        switch self {
        case .free: "GBP 0"
        case .roastProMonthly: "GBP 4.99"
        case .roastProYearly: "GBP 29.99"
        case .creatorProMonthly: "GBP 9.99"
        }
    }

    var includedFeatures: [String] {
        switch self {
        case .free:
            ["10 roasts per day", "Basic styles", "Limited voice roasts"]
        case .roastProMonthly, .roastProYearly:
            ["Unlimited roasts", "Voice roasts", "Roast battles", "Clapback generator", "Premium styles"]
        case .creatorProMonthly:
            ["Creator studio", "Advanced personas", "Voice playback placeholder", "Premium exports", "Meme packs"]
        }
    }
}

@Model
final class UserProfile: Identifiable {
    var id: UUID
    var humorStyle: String
    var roastIntensity: String
    var createdAt: Date

    init(
        id: UUID = UUID(),
        humorStyle: HumorStyle = .playful,
        roastIntensity: RoastIntensity = .medium,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.humorStyle = humorStyle.rawValue
        self.roastIntensity = roastIntensity.rawValue
        self.createdAt = createdAt
    }

    var resolvedHumorStyle: HumorStyle {
        HumorStyle(rawValue: humorStyle) ?? .playful
    }

    var resolvedRoastIntensity: RoastIntensity {
        RoastIntensity(rawValue: roastIntensity) ?? .medium
    }
}

@Model
final class RoastRequest: Identifiable {
    var id: UUID
    var type: String
    var prompt: String
    var generatedRoast: String
    var createdAt: Date

    init(
        id: UUID = UUID(),
        type: RoastRequestType,
        prompt: String,
        generatedRoast: String,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.type = type.rawValue
        self.prompt = prompt
        self.generatedRoast = generatedRoast
        self.createdAt = createdAt
    }

    var resolvedType: RoastRequestType {
        RoastRequestType(rawValue: type) ?? .bio
    }
}

@Model
final class VoiceTranscript: Identifiable {
    var id: UUID
    var transcript: String
    var roastOutput: String
    var createdAt: Date

    init(
        id: UUID = UUID(),
        transcript: String,
        roastOutput: String,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.transcript = transcript
        self.roastOutput = roastOutput
        self.createdAt = createdAt
    }
}

@Model
final class RoastBattle: Identifiable {
    var id: UUID
    var participantA: String
    var participantB: String
    var generatedBattle: String
    var createdAt: Date

    init(
        id: UUID = UUID(),
        participantA: String,
        participantB: String,
        generatedBattle: String,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.participantA = participantA
        self.participantB = participantB
        self.generatedBattle = generatedBattle
        self.createdAt = createdAt
    }
}

@Model
final class Clapback: Identifiable {
    var id: UUID
    var context: String
    var response: String
    var createdAt: Date

    init(
        id: UUID = UUID(),
        context: String,
        response: String,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.context = context
        self.response = response
        self.createdAt = createdAt
    }
}

@Model
final class ComedyPersona: Identifiable {
    var id: UUID
    var name: String
    var tagline: String
    var unlocked: Bool
    var createdAt: Date

    init(
        id: UUID = UUID(),
        name: String,
        tagline: String,
        unlocked: Bool = false,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.tagline = tagline
        self.unlocked = unlocked
        self.createdAt = createdAt
    }
}

@Model
final class SubscriptionState: Identifiable {
    var id: UUID
    var plan: String
    var isActive: Bool

    init(
        id: UUID = UUID(),
        plan: SubscriptionPlan = .free,
        isActive: Bool = false
    ) {
        self.id = id
        self.plan = plan.rawValue
        self.isActive = isActive
    }

    var resolvedPlan: SubscriptionPlan {
        SubscriptionPlan(rawValue: plan) ?? .free
    }
}

extension ComedyPersona {
    static let starterPersonas: [(name: String, tagline: String, unlocked: Bool)] = [
        ("The Roast Professor", "Older witty comedian in a luxury suit with intelligent banter.", true),
        ("Meme Goblin", "Chaotic internet culture expert with hoodie energy and reaction timing.", true),
        ("British Banter King", "Deadpan sarcasm, classy timing, and a tea-cup pause before impact.", false),
        ("Savage Queen", "Glamorous confidence with hilarious observations and premium stage presence.", false),
        ("The Friendly Bully", "Goofy, playful, non-threatening hype-roaster who keeps it fun.", false)
    ]
}
