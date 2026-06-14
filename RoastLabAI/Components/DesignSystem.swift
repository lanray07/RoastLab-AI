import SwiftUI

enum RoastLabTheme {
    static let background = Color(red: 0.01, green: 0.01, blue: 0.02)
    static let elevated = Color.white.opacity(0.07)
    static let elevatedStrong = Color.white.opacity(0.11)
    static let textPrimary = Color.white
    static let textSecondary = Color.white.opacity(0.68)
    static let neonPurple = Color(red: 0.58, green: 0.18, blue: 1.0)
    static let hotPink = Color(red: 1.0, green: 0.13, blue: 0.62)
    static let electricBlue = Color(red: 0.05, green: 0.72, blue: 1.0)
    static let acidGreen = Color(red: 0.62, green: 1.0, blue: 0.18)
    static let warning = Color(red: 1.0, green: 0.74, blue: 0.22)

    static var brandGradient: LinearGradient {
        LinearGradient(
            colors: [neonPurple, hotPink, electricBlue],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

enum RoastLabLayout {
    static let readableMaxWidth: CGFloat = 860
    static let compactMaxWidth: CGFloat = 760
    static let wideMaxWidth: CGFloat = 980
}

extension View {
    func roastLabPage(maxWidth: CGFloat = RoastLabLayout.readableMaxWidth, padding: CGFloat = 20) -> some View {
        frame(maxWidth: maxWidth, alignment: .leading)
            .padding(padding)
            .frame(maxWidth: .infinity)
    }
}

struct RoastLabBackground<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        ZStack {
            RoastLabTheme.background.ignoresSafeArea()
            LinearGradient(
                colors: [
                    RoastLabTheme.neonPurple.opacity(0.18),
                    .clear,
                    RoastLabTheme.electricBlue.opacity(0.14)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            content
        }
    }
}

struct GlassPanel<Content: View>: View {
    var padding: CGFloat = 16
    let content: Content

    init(padding: CGFloat = 16, @ViewBuilder content: () -> Content) {
        self.padding = padding
        self.content = content()
    }

    var body: some View {
        content
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(RoastLabTheme.elevated)
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .strokeBorder(Color.white.opacity(0.12), lineWidth: 1)
                    )
            )
    }
}

struct NeonButton: View {
    var title: String
    var systemImage: String
    var tint: Color = RoastLabTheme.hotPink
    var isLoading = false
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                if isLoading {
                    ProgressView()
                        .tint(.white)
                } else {
                    Image(systemName: systemImage)
                        .font(.headline)
                }
                Text(title)
                    .font(.headline.weight(.bold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.78)
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 15)
            .padding(.horizontal, 16)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [tint, RoastLabTheme.neonPurple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            )
            .shadow(color: tint.opacity(0.34), radius: 16, y: 8)
        }
        .buttonStyle(.plain)
        .disabled(isLoading)
    }
}

struct SectionHeader: View {
    var title: String
    var subtitle: String?
    var systemImage: String?

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    if let systemImage {
                        Image(systemName: systemImage)
                            .foregroundStyle(RoastLabTheme.hotPink)
                    }
                    Text(title)
                        .font(.title3.weight(.bold))
                        .foregroundStyle(RoastLabTheme.textPrimary)
                }

                if let subtitle {
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(RoastLabTheme.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            Spacer(minLength: 0)
        }
    }
}

struct MetricTile: View {
    var title: String
    var value: String
    var systemImage: String
    var tint: Color

    var body: some View {
        GlassPanel(padding: 14) {
            VStack(alignment: .leading, spacing: 12) {
                Image(systemName: systemImage)
                    .font(.headline)
                    .foregroundStyle(tint)
                    .frame(width: 34, height: 34)
                    .background(Circle().fill(tint.opacity(0.14)))

                Text(value)
                    .font(.system(size: 28, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)

                Text(title)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(RoastLabTheme.textSecondary)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

struct QuickActionTile: View {
    var title: String
    var subtitle: String
    var systemImage: String
    var tint: Color

    var body: some View {
        GlassPanel(padding: 14) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    ZStack(alignment: .bottomTrailing) {
                        HumanizedSceneIllustration(scene: visualScene, height: 58)
                            .frame(width: 74)
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        Image(systemName: systemImage)
                            .font(.caption.weight(.black))
                            .foregroundStyle(.black)
                            .frame(width: 24, height: 24)
                            .background(Circle().fill(tint))
                            .offset(x: 4, y: 4)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(RoastLabTheme.textSecondary)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline.weight(.bold))
                        .foregroundStyle(.white)
                        .lineLimit(2)
                        .minimumScaleFactor(0.85)
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(RoastLabTheme.textSecondary)
                        .lineLimit(2)
                }
            }
            .frame(maxWidth: .infinity, minHeight: 118, alignment: .topLeading)
        }
    }

    private var visualScene: RoastScene {
        let lowered = title.lowercased()
        if lowered.contains("voice") { return .audience }
        if lowered.contains("battle") { return .battle }
        if lowered.contains("meme") { return .socialHumor }
        if lowered.contains("clapback") { return .groupChat }
        if lowered.contains("studio") || lowered.contains("share") { return .creators }
        return .friends
    }
}

struct StyleIntensityControls: View {
    @Binding var style: HumorStyle
    @Binding var intensity: RoastIntensity
    var includeIntensity = true

    var body: some View {
        GlassPanel {
            VStack(alignment: .leading, spacing: 14) {
                Picker("Humor style", selection: $style) {
                    ForEach(HumorStyle.allCases) { style in
                        Text(style.displayName).tag(style)
                    }
                }
                .pickerStyle(.menu)
                .tint(.white)

                if includeIntensity {
                    Picker("Roast intensity", selection: $intensity) {
                        ForEach(RoastIntensity.allCases) { intensity in
                            Text(intensity.displayName).tag(intensity)
                        }
                    }
                    .pickerStyle(.segmented)
                }
            }
        }
    }
}

struct EmptyStateView: View {
    var title: String
    var message: String
    var systemImage: String

    var body: some View {
        PremiumEmptyStateView(
            title: title,
            message: message,
            mascot: mascot,
            scene: scene
        )
    }

    private var mascot: RoastMascot {
        let lowered = "\(title) \(message) \(systemImage)".lowercased()
        if lowered.contains("profile") { return .roastProfessor }
        if lowered.contains("share") || lowered.contains("card") { return .savageQueen }
        if lowered.contains("photo") || lowered.contains("meme") { return .memeGoblin }
        if lowered.contains("voice") { return .britishBanterKing }
        return .friendlyBully
    }

    private var scene: RoastScene {
        let lowered = "\(title) \(message) \(systemImage)".lowercased()
        if lowered.contains("share") || lowered.contains("creator") { return .creators }
        if lowered.contains("battle") { return .battle }
        if lowered.contains("voice") { return .audience }
        if lowered.contains("meme") || lowered.contains("photo") { return .socialHumor }
        return .groupChat
    }
}
