import SwiftUI

enum RoastVisualTheme: String, CaseIterable, Identifiable {
    case comedyClub
    case neonRoast
    case britishBanter
    case memeUniverse

    var id: String { rawValue }

    var name: String {
        switch self {
        case .comedyClub: "Comedy Club"
        case .neonRoast: "Neon Roast"
        case .britishBanter: "British Banter"
        case .memeUniverse: "Meme Universe"
        }
    }

    var primary: Color {
        switch self {
        case .comedyClub: Color(red: 0.72, green: 0.05, blue: 0.13)
        case .neonRoast: RoastLabTheme.neonPurple
        case .britishBanter: Color(red: 0.02, green: 0.22, blue: 0.14)
        case .memeUniverse: RoastLabTheme.hotPink
        }
    }

    var secondary: Color {
        switch self {
        case .comedyClub: RoastLabTheme.warning
        case .neonRoast: RoastLabTheme.electricBlue
        case .britishBanter: Color(red: 0.88, green: 0.68, blue: 0.32)
        case .memeUniverse: RoastLabTheme.acidGreen
        }
    }

    var third: Color {
        switch self {
        case .comedyClub: Color(red: 0.2, green: 0.02, blue: 0.08)
        case .neonRoast: RoastLabTheme.hotPink
        case .britishBanter: Color(red: 0.0, green: 0.08, blue: 0.06)
        case .memeUniverse: RoastLabTheme.electricBlue
        }
    }

    var gradient: LinearGradient {
        LinearGradient(
            colors: [primary, third, secondary.opacity(0.86)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

enum RoastMascot: String, CaseIterable, Identifiable {
    case roastProfessor
    case memeGoblin
    case britishBanterKing
    case savageQueen
    case friendlyBully

    var id: String { rawValue }

    var name: String {
        switch self {
        case .roastProfessor: "The Roast Professor"
        case .memeGoblin: "Meme Goblin"
        case .britishBanterKing: "British Banter King"
        case .savageQueen: "Savage Queen"
        case .friendlyBully: "The Friendly Bully"
        }
    }

    var personality: String {
        switch self {
        case .roastProfessor: "Witty, polished, and dangerously observant."
        case .memeGoblin: "Chaotic internet timing with screenshot energy."
        case .britishBanterKing: "Deadpan, classy, and tea-level sarcastic."
        case .savageQueen: "Glamorous confidence with surgical punchlines."
        case .friendlyBully: "Goofy hype friend who keeps the roast playful."
        }
    }

    var visualIdentity: String {
        switch self {
        case .roastProfessor: "Glasses, luxury suit, velvet lecture stage."
        case .memeGoblin: "Oversized hoodie, expressive eyes, neon stickers."
        case .britishBanterKing: "Dark green tailoring, gold trim, tea cup prop."
        case .savageQueen: "High-fashion silhouette, spotlight glow, chrome mic."
        case .friendlyBully: "Round shapes, warm grin, varsity comedy jacket."
        }
    }

    var animationStyle: String {
        switch self {
        case .roastProfessor: "Subtle eyebrow raises and chalkboard flourishes."
        case .memeGoblin: "Elastic bounces and quick reaction pops."
        case .britishBanterKing: "Slow nods, dry pauses, tiny cup lift."
        case .savageQueen: "Spotlight turns, shimmer sweeps, confident poses."
        case .friendlyBully: "Soft wiggles, confetti pops, encouraging waves."
        }
    }

    var theme: RoastVisualTheme {
        switch self {
        case .roastProfessor: .comedyClub
        case .memeGoblin: .memeUniverse
        case .britishBanterKing: .britishBanter
        case .savageQueen: .neonRoast
        case .friendlyBully: .comedyClub
        }
    }

    var accent: Color { theme.secondary }

    var symbol: String {
        switch self {
        case .roastProfessor: "graduationcap.fill"
        case .memeGoblin: "bolt.fill"
        case .britishBanterKing: "cup.and.saucer.fill"
        case .savageQueen: "sparkles"
        case .friendlyBully: "face.smiling.fill"
        }
    }

    static func persona(named name: String) -> RoastMascot {
        let lowered = name.lowercased()
        if lowered.contains("professor") { return .roastProfessor }
        if lowered.contains("goblin") || lowered.contains("meme") { return .memeGoblin }
        if lowered.contains("british") || lowered.contains("banter") { return .britishBanterKing }
        if lowered.contains("queen") || lowered.contains("savage") { return .savageQueen }
        return .friendlyBully
    }
}

enum RoastReaction: String, CaseIterable, Identifiable {
    case laughing
    case shocked
    case cryingWithLaughter
    case impressed
    case savage
    case facepalm
    case applause

    var id: String { rawValue }

    var label: String {
        switch self {
        case .laughing: "Laughing"
        case .shocked: "Shocked"
        case .cryingWithLaughter: "Crying with laughter"
        case .impressed: "Impressed"
        case .savage: "Savage reaction"
        case .facepalm: "Facepalm"
        case .applause: "Applause"
        }
    }

    var systemImage: String {
        switch self {
        case .laughing: "face.smiling.fill"
        case .shocked: "exclamationmark.bubble.fill"
        case .cryingWithLaughter: "drop.fill"
        case .impressed: "star.fill"
        case .savage: "flame.fill"
        case .facepalm: "hand.raised.fill"
        case .applause: "hands.clap.fill"
        }
    }

    var tint: Color {
        switch self {
        case .laughing: RoastLabTheme.acidGreen
        case .shocked: RoastLabTheme.electricBlue
        case .cryingWithLaughter: RoastLabTheme.hotPink
        case .impressed: RoastLabTheme.warning
        case .savage: RoastLabTheme.hotPink
        case .facepalm: Color.white.opacity(0.74)
        case .applause: RoastLabTheme.warning
        }
    }
}

enum RoastScene: String, CaseIterable, Identifiable {
    case friends
    case creators
    case groupChat
    case battle
    case audience
    case socialHumor

    var id: String { rawValue }

    var title: String {
        switch self {
        case .friends: "Friends Roasting Each Other"
        case .creators: "Creators Making Content"
        case .groupChat: "Group Chat Banter"
        case .battle: "Comedy Battle"
        case .audience: "Live Audience Reactions"
        case .socialHumor: "Social Media Humor"
        }
    }

    var theme: RoastVisualTheme {
        switch self {
        case .friends: .comedyClub
        case .creators: .neonRoast
        case .groupChat: .memeUniverse
        case .battle: .britishBanter
        case .audience: .comedyClub
        case .socialHumor: .memeUniverse
        }
    }
}

enum RoastAchievement: String, CaseIterable, Identifiable {
    case firstRoast
    case banterBeginner
    case memeMachine
    case roastLord
    case savageSupreme
    case clapbackChampion
    case comedyGenius

    var id: String { rawValue }

    var title: String {
        switch self {
        case .firstRoast: "First Roast"
        case .banterBeginner: "Banter Beginner"
        case .memeMachine: "Meme Machine"
        case .roastLord: "Roast Lord"
        case .savageSupreme: "Savage Supreme"
        case .clapbackChampion: "Clapback Champion"
        case .comedyGenius: "Comedy Genius"
        }
    }

    var symbol: String {
        switch self {
        case .firstRoast: "sparkles"
        case .banterBeginner: "quote.bubble.fill"
        case .memeMachine: "photo.on.rectangle.angled"
        case .roastLord: "crown.fill"
        case .savageSupreme: "flame.fill"
        case .clapbackChampion: "bolt.fill"
        case .comedyGenius: "brain.head.profile"
        }
    }

    var tint: Color {
        switch self {
        case .firstRoast: RoastLabTheme.electricBlue
        case .banterBeginner: RoastLabTheme.acidGreen
        case .memeMachine: RoastLabTheme.hotPink
        case .roastLord: RoastLabTheme.warning
        case .savageSupreme: RoastLabTheme.hotPink
        case .clapbackChampion: RoastLabTheme.acidGreen
        case .comedyGenius: RoastLabTheme.neonPurple
        }
    }
}

struct ComedyHeroStageView: View {
    var title: String
    var subtitle: String
    var kicker: String
    var mascot: RoastMascot
    var theme: RoastVisualTheme
    var compact = false

    @State private var isLive = false

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(theme.gradient)
                .overlay(StageLightRig(theme: theme, isLive: isLive))
                .overlay(
                    RoundedRectangle(cornerRadius: 26, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.16), lineWidth: 1)
                )

            HStack(alignment: .bottom, spacing: 16) {
                VStack(alignment: .leading, spacing: compact ? 8 : 12) {
                    Text(kicker.uppercased())
                        .font(.caption.weight(.black))
                        .foregroundStyle(theme.secondary)
                    Text(title)
                        .font(.system(size: compact ? 28 : 40, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                        .lineLimit(3)
                        .minimumScaleFactor(0.72)
                    Text(subtitle)
                        .font(.callout.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.8))
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: 0)
                MascotIllustration(mascot: mascot, expression: .performing, size: compact ? 112 : 142, animated: true)
            }
            .padding(compact ? 18 : 22)
        }
        .frame(minHeight: compact ? 150 : 220)
        .shadow(color: theme.primary.opacity(0.28), radius: 24, y: 12)
        .onAppear { isLive = true }
    }
}

private struct StageLightRig: View {
    var theme: RoastVisualTheme
    var isLive: Bool

    var body: some View {
        ZStack {
            ForEach(0..<4, id: \.self) { index in
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [theme.secondary.opacity(0.34), .clear],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 78, height: 240)
                    .rotationEffect(.degrees(Double(index) * 28 - 44 + (isLive ? 5 : -5)))
                    .offset(x: CGFloat(index - 1) * 72, y: -44)
                    .blur(radius: 1.4)
                    .opacity(0.72)
            }

            VStack {
                HStack(spacing: 16) {
                    ForEach(0..<5, id: \.self) { index in
                        Circle()
                            .fill(index.isMultiple(of: 2) ? theme.secondary : Color.white.opacity(0.72))
                            .frame(width: 9, height: 9)
                            .shadow(color: theme.secondary.opacity(0.8), radius: 8)
                    }
                    Spacer()
                }
                Spacer()
                AudienceSilhouette()
                    .opacity(0.3)
            }
            .padding(18)
        }
        .animation(.easeInOut(duration: 2.4).repeatForever(autoreverses: true), value: isLive)
    }
}

private struct AudienceSilhouette: View {
    var body: some View {
        HStack(alignment: .bottom, spacing: -4) {
            ForEach(0..<12, id: \.self) { index in
                Circle()
                    .fill(Color.black.opacity(0.82))
                    .frame(width: CGFloat(18 + (index % 3) * 4), height: CGFloat(18 + (index % 3) * 4))
                    .offset(y: CGFloat(index % 4) * 3)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

enum MascotExpression {
    case calm
    case performing
    case shocked
    case laughing
}

struct MascotIllustration: View {
    var mascot: RoastMascot
    var expression: MascotExpression = .calm
    var size: CGFloat = 120
    var animated = false

    @State private var bounce = false

    var body: some View {
        ZStack {
            Circle()
                .fill(mascot.theme.gradient)
                .frame(width: size, height: size)
                .shadow(color: mascot.accent.opacity(0.3), radius: 16, y: 10)

            Circle()
                .fill(Color.white.opacity(0.12))
                .frame(width: size * 0.78, height: size * 0.78)
                .offset(x: -size * 0.06, y: -size * 0.04)

            mascotBody
                .offset(y: size * 0.22)
            mascotHead
                .offset(y: -size * 0.08)
            mascotProp
        }
        .frame(width: size, height: size * 1.08)
        .scaleEffect(animated && bounce ? 1.035 : 1.0)
        .rotationEffect(.degrees(animated && bounce ? 1.4 : -1.1))
        .animation(.spring(response: 0.8, dampingFraction: 0.62).repeatForever(autoreverses: true), value: bounce)
        .onAppear { bounce = animated }
        .accessibilityLabel(mascot.name)
    }

    private var skin: Color {
        switch mascot {
        case .roastProfessor: Color(red: 0.72, green: 0.52, blue: 0.38)
        case .memeGoblin: Color(red: 0.48, green: 0.86, blue: 0.54)
        case .britishBanterKing: Color(red: 0.76, green: 0.57, blue: 0.4)
        case .savageQueen: Color(red: 0.66, green: 0.38, blue: 0.54)
        case .friendlyBully: Color(red: 0.84, green: 0.59, blue: 0.42)
        }
    }

    private var outfit: Color {
        switch mascot {
        case .roastProfessor: Color.black.opacity(0.88)
        case .memeGoblin: RoastLabTheme.neonPurple
        case .britishBanterKing: Color(red: 0.0, green: 0.18, blue: 0.12)
        case .savageQueen: RoastLabTheme.hotPink
        case .friendlyBully: RoastLabTheme.electricBlue
        }
    }

    private var mascotHead: some View {
        ZStack {
            Circle()
                .fill(skin)
                .frame(width: size * 0.42, height: size * 0.42)
                .overlay(
                    Circle()
                        .strokeBorder(Color.white.opacity(0.28), lineWidth: 2)
                )

            if mascot == .savageQueen {
                Capsule()
                    .fill(Color.black.opacity(0.86))
                    .frame(width: size * 0.52, height: size * 0.18)
                    .offset(y: -size * 0.22)
            }

            if mascot == .memeGoblin {
                Capsule()
                    .fill(outfit.opacity(0.96))
                    .frame(width: size * 0.54, height: size * 0.26)
                    .offset(y: -size * 0.16)
            }

            HStack(spacing: size * 0.08) {
                eye
                eye
            }
            .offset(y: -size * 0.04)

            mouth
                .offset(y: size * 0.09)

            if mascot == .roastProfessor {
                RoundedRectangle(cornerRadius: 5)
                    .stroke(Color.white.opacity(0.78), lineWidth: 2)
                    .frame(width: size * 0.31, height: size * 0.1)
                    .offset(y: -size * 0.04)
            }
        }
    }

    private var eye: some View {
        Circle()
            .fill(Color.black.opacity(0.82))
            .frame(width: size * 0.045, height: expression == .shocked ? size * 0.062 : size * 0.045)
    }

    private var mouth: some View {
        Group {
            switch expression {
            case .calm:
                Capsule()
                    .fill(Color.black.opacity(0.68))
                    .frame(width: size * 0.13, height: size * 0.018)
            case .performing:
                Capsule()
                    .fill(Color.black.opacity(0.72))
                    .frame(width: size * 0.2, height: size * 0.04)
            case .shocked:
                Circle()
                    .fill(Color.black.opacity(0.72))
                    .frame(width: size * 0.09, height: size * 0.09)
            case .laughing:
                Capsule()
                    .fill(Color.black.opacity(0.74))
                    .frame(width: size * 0.22, height: size * 0.08)
            }
        }
    }

    private var mascotBody: some View {
        ZStack {
            RoundedRectangle(cornerRadius: size * 0.16, style: .continuous)
                .fill(outfit)
                .frame(width: size * 0.52, height: size * 0.34)

            if mascot == .britishBanterKing || mascot == .roastProfessor {
                RoundedRectangle(cornerRadius: 2)
                    .fill(mascot.accent)
                    .frame(width: size * 0.08, height: size * 0.3)
            }

            if mascot == .friendlyBully {
                Text("RL")
                    .font(.system(size: size * 0.13, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
            }
        }
    }

    private var mascotProp: some View {
        Group {
            switch mascot {
            case .roastProfessor:
                Image(systemName: "graduationcap.fill")
                    .font(.system(size: size * 0.2, weight: .black))
                    .foregroundStyle(mascot.accent)
                    .offset(y: -size * 0.33)
            case .memeGoblin:
                Image(systemName: "sparkles")
                    .font(.system(size: size * 0.18, weight: .black))
                    .foregroundStyle(RoastLabTheme.acidGreen)
                    .offset(x: size * 0.31, y: -size * 0.18)
            case .britishBanterKing:
                Image(systemName: "cup.and.saucer.fill")
                    .font(.system(size: size * 0.17, weight: .black))
                    .foregroundStyle(mascot.accent)
                    .offset(x: size * 0.32, y: size * 0.1)
            case .savageQueen:
                Image(systemName: "crown.fill")
                    .font(.system(size: size * 0.18, weight: .black))
                    .foregroundStyle(mascot.accent)
                    .offset(y: -size * 0.33)
            case .friendlyBully:
                Image(systemName: "hands.clap.fill")
                    .font(.system(size: size * 0.16, weight: .black))
                    .foregroundStyle(mascot.accent)
                    .offset(x: size * 0.32, y: -size * 0.05)
            }
        }
    }
}

struct MascotProfileCard: View {
    var mascot: RoastMascot
    var isUnlocked = true

    var body: some View {
        GlassPanel {
            HStack(spacing: 14) {
                MascotIllustration(mascot: mascot, expression: isUnlocked ? .performing : .calm, size: 78, animated: isUnlocked)
                    .saturation(isUnlocked ? 1 : 0.18)
                    .opacity(isUnlocked ? 1 : 0.62)

                VStack(alignment: .leading, spacing: 7) {
                    HStack(spacing: 8) {
                        Text(mascot.name)
                            .font(.headline.weight(.black))
                            .foregroundStyle(.white)
                        if !isUnlocked {
                            Image(systemName: "lock.fill")
                                .foregroundStyle(RoastLabTheme.warning)
                        }
                    }
                    Text(mascot.personality)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(RoastLabTheme.textSecondary)
                    Text(mascot.animationStyle)
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(mascot.accent)
                }
                Spacer(minLength: 0)
            }
        }
    }
}

struct MascotCommitteeStrip: View {
    var mascots: [RoastMascot] = RoastMascot.allCases

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(mascots) { mascot in
                    MascotCommitteeItem(mascot: mascot)
                }
            }
            .padding(.vertical, 2)
        }
    }
}

private struct MascotCommitteeItem: View {
    var mascot: RoastMascot

    var body: some View {
        VStack(spacing: 8) {
            MascotIllustration(mascot: mascot, expression: .performing, size: 76, animated: true)
            Text(mascot.name)
                .font(.caption2.weight(.black))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .frame(width: 92)
                .frame(minHeight: 30)
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.white.opacity(0.07))
                .overlay(RoundedRectangle(cornerRadius: 18).strokeBorder(mascot.accent.opacity(0.28)))
        )
    }
}

struct HumanizedSceneIllustration: View {
    var scene: RoastScene
    var height: CGFloat = 190

    @State private var isAnimating = false

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(scene.theme.gradient)
            StageLightRig(theme: scene.theme, isLive: isAnimating)
                .opacity(0.7)

            HStack(alignment: .bottom, spacing: -4) {
                ForEach(0..<characterCount, id: \.self) { index in
                    scenePerson(index: index)
                        .offset(y: isAnimating && index.isMultiple(of: 2) ? -5 : 3)
                }
            }
            .padding(.bottom, 22)

            VStack {
                HStack {
                    Text(scene.title.uppercased())
                        .font(.caption.weight(.black))
                        .foregroundStyle(.white.opacity(0.82))
                    Spacer()
                    Image(systemName: sceneIcon)
                        .foregroundStyle(scene.theme.secondary)
                }
                .padding(18)
                Spacer()
            }
        }
        .frame(height: height)
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .strokeBorder(Color.white.opacity(0.14), lineWidth: 1)
        )
        .onAppear { isAnimating = true }
        .animation(.spring(response: 0.9, dampingFraction: 0.64).repeatForever(autoreverses: true), value: isAnimating)
        .accessibilityLabel(scene.title)
    }

    private var characterCount: Int {
        switch scene {
        case .battle: 2
        case .audience: 6
        default: 4
        }
    }

    private var sceneIcon: String {
        switch scene {
        case .friends: "person.3.fill"
        case .creators: "movieclapper.fill"
        case .groupChat: "bubble.left.and.bubble.right.fill"
        case .battle: "person.2.fill"
        case .audience: "theatermasks.fill"
        case .socialHumor: "play.rectangle.fill"
        }
    }

    private func scenePerson(index: Int) -> some View {
        let colors = [RoastLabTheme.hotPink, RoastLabTheme.electricBlue, RoastLabTheme.warning, RoastLabTheme.acidGreen, RoastLabTheme.neonPurple]
        return VStack(spacing: -3) {
            ZStack {
                Circle()
                    .fill(Color(red: 0.72, green: 0.5, blue: 0.38).opacity(0.95))
                HStack(spacing: 6) {
                    Circle().fill(Color.black.opacity(0.8)).frame(width: 4, height: 4)
                    Circle().fill(Color.black.opacity(0.8)).frame(width: 4, height: 4)
                }
                Capsule()
                    .fill(Color.black.opacity(0.62))
                    .frame(width: 16, height: scene == .audience ? 5 : 7)
                    .offset(y: 8)
            }
            .frame(width: 42, height: 42)

            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(colors[index % colors.count])
                .frame(width: scene == .battle ? 72 : 58, height: CGFloat(64 + (index % 2) * 12))
                .overlay(
                    Image(systemName: index.isMultiple(of: 2) ? "mic.fill" : "bubble.left.fill")
                        .foregroundStyle(.white.opacity(0.72))
                )
        }
        .scaleEffect(scene == .audience ? 0.78 : 1)
    }
}

struct ReactionAvatarView: View {
    var reaction: RoastReaction
    var size: CGFloat = 56
    var animated = true

    @State private var pop = false

    var body: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [reaction.tint, RoastLabTheme.neonPurple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            Circle()
                .fill(Color.white.opacity(0.12))
                .frame(width: size * 0.62, height: size * 0.62)
                .offset(x: -size * 0.08, y: -size * 0.08)
            Image(systemName: reaction.systemImage)
                .font(.system(size: size * 0.36, weight: .black))
                .foregroundStyle(.white)
        }
        .frame(width: size, height: size)
        .scaleEffect(animated && pop ? 1.08 : 0.96)
        .shadow(color: reaction.tint.opacity(0.28), radius: 12, y: 8)
        .animation(.spring(response: 0.52, dampingFraction: 0.58).repeatForever(autoreverses: true), value: pop)
        .onAppear { pop = animated }
        .accessibilityLabel(reaction.label)
    }
}

struct ReactionRailView: View {
    var reactions: [RoastReaction] = [.laughing, .shocked, .cryingWithLaughter, .impressed, .applause]

    var body: some View {
        HStack(spacing: -8) {
            ForEach(reactions) { reaction in
                ReactionAvatarView(reaction: reaction, size: 44, animated: true)
                    .overlay(Circle().stroke(Color.black.opacity(0.5), lineWidth: 2))
            }
        }
    }
}

struct ComedyLoadingView: View {
    var mascot: RoastMascot = .roastProfessor
    var messages: [String] = [
        "Finding something embarrassing...",
        "Consulting the roast committee...",
        "Searching your digital crimes...",
        "Trying not to laugh...",
        "Contacting British Banter Headquarters..."
    ]

    @State private var messageIndex = 0
    @State private var pulse = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        GlassPanel {
            HStack(spacing: 16) {
                MascotIllustration(mascot: mascot, expression: .performing, size: 82, animated: !reduceMotion)
                VStack(alignment: .leading, spacing: 10) {
                    Text(messages[messageIndex])
                        .font(.headline.weight(.black))
                        .foregroundStyle(.white)
                    HStack(spacing: 5) {
                        ForEach(0..<5, id: \.self) { index in
                            Capsule()
                                .fill(index <= messageIndex % 5 ? mascot.accent : Color.white.opacity(0.18))
                                .frame(width: 22, height: 6)
                                .scaleEffect(pulse && index == messageIndex % 5 ? 1.25 : 1)
                        }
                    }
                    Text(mascot.animationStyle)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(RoastLabTheme.textSecondary)
                }
                Spacer(minLength: 0)
            }
        }
        .task {
            guard !reduceMotion else { return }
            pulse = true
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 1_350_000_000)
                guard !Task.isCancelled else { break }
                messageIndex = (messageIndex + 1) % messages.count
            }
        }
        .animation(.easeInOut(duration: 0.55), value: messageIndex)
        .animation(.spring(response: 0.5, dampingFraction: 0.62).repeatForever(autoreverses: true), value: pulse)
    }
}

struct PremiumEmptyStateView: View {
    var title: String
    var message: String
    var mascot: RoastMascot = .friendlyBully
    var scene: RoastScene = .groupChat
    var framed = true
    var showsScene = true

    var body: some View {
        if framed {
            GlassPanel {
                content
            }
        } else {
            content
        }
    }

    private var content: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 14) {
                MascotIllustration(mascot: mascot, expression: .performing, size: 82, animated: true)
                VStack(alignment: .leading, spacing: 6) {
                    Text(title)
                        .font(.headline.weight(.black))
                        .foregroundStyle(.white)
                    Text(message)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(RoastLabTheme.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            if showsScene {
                HumanizedSceneIllustration(scene: scene, height: 118)
            }
        }
    }
}

struct AchievementBadgeView: View {
    var achievement: RoastAchievement
    var isUnlocked = false

    @State private var glow = false

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [achievement.tint.opacity(0.95), Color.black.opacity(0.82)],
                            center: .topLeading,
                            startRadius: 4,
                            endRadius: 56
                        )
                    )
                    .frame(width: 74, height: 74)
                    .overlay(
                        Circle()
                            .strokeBorder(Color.white.opacity(0.22), lineWidth: 1)
                    )
                    .shadow(color: isUnlocked && glow ? achievement.tint.opacity(0.65) : .clear, radius: 18)

                Image(systemName: achievement.symbol)
                    .font(.system(size: 28, weight: .black))
                    .foregroundStyle(isUnlocked ? .white : Color.white.opacity(0.38))
            }

            Text(achievement.title)
                .font(.caption2.weight(.black))
                .foregroundStyle(isUnlocked ? .white : RoastLabTheme.textSecondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .frame(width: 86)
                .frame(minHeight: 30)
        }
        .onAppear { glow = true }
        .animation(.easeInOut(duration: 1.4).repeatForever(autoreverses: true), value: glow)
    }
}

struct AchievementShelfView: View {
    var unlockedCount: Int

    var body: some View {
        GlassPanel {
            VStack(alignment: .leading, spacing: 14) {
                SectionHeader(title: "Achievement Art", subtitle: "Metal badges, glow states, and unlock moments.", systemImage: "medal.fill")
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(Array(RoastAchievement.allCases.enumerated()), id: \.element.id) { index, achievement in
                            AchievementBadgeView(achievement: achievement, isUnlocked: index < max(1, unlockedCount))
                        }
                    }
                }
            }
        }
    }
}

struct ComedyClubVoiceStageView: View {
    var levels: [CGFloat]
    var isGenerating: Bool

    @State private var lightsOn = false

    var body: some View {
        ZStack(alignment: .bottom) {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(RoastVisualTheme.comedyClub.gradient)
                .overlay(StageLightRig(theme: .comedyClub, isLive: lightsOn))

            VStack(spacing: 14) {
                HStack(alignment: .bottom, spacing: 18) {
                    MascotIllustration(mascot: .roastProfessor, expression: isGenerating ? .laughing : .performing, size: 88, animated: true)
                    VStack(alignment: .leading, spacing: 8) {
                        Label(isGenerating ? "Audience is laughing" : "Comedy club mic is live", systemImage: isGenerating ? "hands.clap.fill" : "mic.fill")
                            .font(.caption.weight(.black))
                            .foregroundStyle(RoastLabTheme.warning)
                        VoiceWaveformView(levels: levels, tint: RoastLabTheme.warning)
                            .frame(height: 76)
                    }
                }

                HStack(spacing: 8) {
                    ForEach(0..<8, id: \.self) { index in
                        Capsule()
                            .fill(Color.black.opacity(0.72))
                            .frame(width: 22, height: CGFloat(22 + (index % 3) * 8))
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .padding(18)
        }
        .frame(minHeight: 220)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .onAppear { lightsOn = true }
    }
}
