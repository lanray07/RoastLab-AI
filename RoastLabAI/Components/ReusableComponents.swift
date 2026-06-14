import Charts
import StoreKit
import SwiftUI
import UIKit

struct SharePayload: Identifiable {
    var id = UUID()
    var text: String
}

struct RoastCard: View {
    var title: String
    var roast: String
    var observations: [String]
    var score: Int = 92
    var onShare: (() -> Void)?

    var body: some View {
        GlassPanel {
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .top, spacing: 12) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(title)
                            .font(.headline.weight(.bold))
                            .foregroundStyle(.white)
                        Text("Share-ready comedy card")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(RoastLabTheme.acidGreen)
                    }
                    Spacer()
                    ZStack(alignment: .bottomTrailing) {
                        MascotIllustration(mascot: .savageQueen, expression: .laughing, size: 72, animated: true)
                        if let onShare {
                            Button(action: onShare) {
                                Image(systemName: "square.and.arrow.up")
                                    .font(.headline)
                                    .foregroundStyle(.black)
                                    .frame(width: 36, height: 36)
                                    .background(Circle().fill(RoastLabTheme.acidGreen))
                            }
                            .accessibilityLabel("Share roast")
                        }
                    }
                }

                Text(roast)
                    .font(.title3.weight(.black))
                    .foregroundStyle(.white)
                    .minimumScaleFactor(0.74)
                    .fixedSize(horizontal: false, vertical: true)

                HStack(spacing: 12) {
                    ReactionRailView(reactions: [.laughing, .cryingWithLaughter, .savage, .applause])
                    Spacer()
                    Text("\(score)")
                        .font(.system(size: 34, weight: .black, design: .rounded))
                        .foregroundStyle(RoastLabTheme.acidGreen)
                        .accessibilityLabel("Roast score \(score)")
                }

                if !observations.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(observations, id: \.self) { observation in
                            Label(observation, systemImage: "sparkles")
                                .font(.caption)
                                .foregroundStyle(RoastLabTheme.textSecondary)
                        }
                    }
                }
            }
        }
    }
}

struct ClapbackCard: View {
    var context: String
    var response: String
    var onShare: (() -> Void)?

    var body: some View {
        GlassPanel {
            VStack(alignment: .leading, spacing: 14) {
                HStack(alignment: .center, spacing: 12) {
                    ReactionAvatarView(reaction: .savage, size: 54)
                    VStack(alignment: .leading, spacing: 3) {
                        Text("Clapback")
                            .font(.headline.weight(.black))
                            .foregroundStyle(.white)
                        Text("Instant reply energy")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(RoastLabTheme.electricBlue)
                    }
                    Spacer()
                    if let onShare {
                        Button(action: onShare) {
                            Image(systemName: "paperplane.fill")
                                .font(.headline)
                                .foregroundStyle(.black)
                                .frame(width: 36, height: 36)
                                .background(Circle().fill(RoastLabTheme.electricBlue))
                        }
                        .accessibilityLabel("Share clapback")
                    }
                }
                Text(context)
                    .font(.caption)
                    .foregroundStyle(RoastLabTheme.textSecondary)
                    .lineLimit(3)
                Text(response)
                    .font(.body.weight(.bold))
                    .foregroundStyle(.white)
            }
        }
    }
}

struct RoastBattleCard: View {
    var participantA: String
    var participantB: String
    var battle: String

    var body: some View {
        GlassPanel {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    Text(participantA)
                        .font(.headline.weight(.black))
                    Spacer()
                    Text("VS")
                        .font(.caption.weight(.black))
                        .foregroundStyle(RoastLabTheme.hotPink)
                    Spacer()
                    Text(participantB)
                        .font(.headline.weight(.black))
                }
                .foregroundStyle(.white)

                HumanizedSceneIllustration(scene: .battle, height: 150)

                Text(battle)
                    .font(.callout.weight(.semibold))
                    .foregroundStyle(.white)
                    .fixedSize(horizontal: false, vertical: true)

                ReactionRailView(reactions: [.shocked, .laughing, .facepalm, .applause])
            }
        }
    }
}

struct VoiceWaveformView: View {
    var levels: [CGFloat]
    var tint: Color = RoastLabTheme.hotPink

    var body: some View {
        HStack(alignment: .center, spacing: 4) {
            ForEach(Array(levels.enumerated()), id: \.offset) { _, level in
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [tint, RoastLabTheme.electricBlue],
                            startPoint: .bottom,
                            endPoint: .top
                        )
                    )
                    .frame(width: 5, height: max(10, level * 82))
                    .animation(.spring(response: 0.22, dampingFraction: 0.72), value: level)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 96)
        .accessibilityLabel("Live voice waveform")
    }
}

struct ComedyPersonaCard: View {
    var persona: ComedyPersona

    var body: some View {
        MascotProfileCard(mascot: RoastMascot.persona(named: persona.name), isUnlocked: persona.unlocked)
    }
}

struct AnalyticsPoint: Identifiable {
    var id = UUID()
    var label: String
    var value: Int
    var color: Color
}

struct AnalyticsChartCard: View {
    var title: String
    var points: [AnalyticsPoint]

    var body: some View {
        GlassPanel {
            VStack(alignment: .leading, spacing: 16) {
                SectionHeader(title: title, subtitle: "Local SwiftData analytics", systemImage: "chart.bar.xaxis")

                Chart(points) { point in
                    BarMark(
                        x: .value("Metric", point.label),
                        y: .value("Count", point.value)
                    )
                    .foregroundStyle(point.color)
                    .cornerRadius(6)
                }
                .chartYAxis(.hidden)
                .frame(height: 190)
            }
        }
    }
}

struct ShareCardPreview: View {
    var title: String
    var bodyText: String
    var footer: String = "RoastLab AI"

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(RoastVisualTheme.memeUniverse.gradient)
                .overlay(
                    RoundedRectangle(cornerRadius: 26, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.18), lineWidth: 1)
                )
            VStack(alignment: .leading, spacing: 14) {
                HStack(alignment: .center) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(title.uppercased())
                            .font(.caption.weight(.black))
                            .foregroundStyle(.white.opacity(0.78))
                        Text("Creator share card")
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(RoastLabTheme.acidGreen)
                    }
                    Spacer()
                    ReactionAvatarView(reaction: .laughing, size: 48)
                }

                Text(bodyText)
                    .font(.system(size: 26, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                    .minimumScaleFactor(0.58)
                    .lineLimit(6)
                Spacer(minLength: 0)
                HumanizedSceneIllustration(scene: .socialHumor, height: 116)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                HStack {
                    Text(footer)
                        .font(.headline.weight(.black))
                        .foregroundStyle(.white)
                    Spacer()
                    ReactionRailView(reactions: [.laughing, .shocked, .savage])
                }
            }
            .padding(24)
        }
        .aspectRatio(4 / 5, contentMode: .fit)
        .shadow(color: RoastLabTheme.hotPink.opacity(0.24), radius: 20, y: 10)
    }
}

struct UpgradeBanner: View {
    var title: String = "Unlock Roast Pro"
    var message: String = "Unlimited roasts, battles, premium styles, voice features, and creator exports."

    var body: some View {
        NavigationLink(value: AppRoute.paywall) {
            HStack(spacing: 14) {
                MascotIllustration(mascot: .roastProfessor, expression: .performing, size: 64, animated: true)
                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.headline.weight(.black))
                        .foregroundStyle(.white)
                    Text(message)
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.76))
                        .lineLimit(3)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(.white.opacity(0.7))
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color.white.opacity(0.09))
                    .overlay(RoundedRectangle(cornerRadius: 18).strokeBorder(RoastLabTheme.acidGreen.opacity(0.45)))
            )
        }
        .buttonStyle(.plain)
    }
}

struct PaywallView: View {
    @EnvironmentObject private var services: AppServices

    var body: some View {
        PaywallContent(store: services.subscriptionStore)
    }
}

private struct PaywallContent: View {
    @ObservedObject var store: SubscriptionStore
    @State private var selectedPlan: SubscriptionPlan = .roastProMonthly
    @State private var isPurchasing = false
    @State private var isRestoring = false

    var body: some View {
        RoastLabBackground {
            ScrollView {
                VStack(spacing: 22) {
                    ComedyHeroStageView(
                        title: "RoastLab Pro",
                        subtitle: "Unlimited battles, voice roasts, premium share cards, achievement art, and creator exports.",
                        kicker: "Premium comedy membership",
                        mascot: .savageQueen,
                        theme: .neonRoast
                    )
                    .padding(.top, 24)

                    MascotCommitteeStrip(mascots: [.roastProfessor, .memeGoblin, .britishBanterKing, .savageQueen, .friendlyBully])

                    AchievementShelfView(unlockedCount: 4)

                    ForEach(SubscriptionPlan.paidPlans) { plan in
                        PlanRow(plan: plan, price: priceText(for: plan), isSelected: selectedPlan == plan) {
                            selectedPlan = plan
                        }
                    }

                    NeonButton(
                        title: purchaseButtonTitle,
                        systemImage: "cart.fill",
                        tint: RoastLabTheme.acidGreen,
                        isLoading: isPurchasing
                    ) {
                        Task {
                            await purchaseSelectedPlan()
                        }
                    }

                    RestorePurchasesButton(isRestoring: isRestoring) {
                        Task {
                            await restorePurchases()
                        }
                    }

                    if store.isActive {
                        GlassPanel {
                            Label("Unlocked: \(store.activePlan.displayName)", systemImage: "checkmark.seal.fill")
                                .font(.callout.weight(.bold))
                                .foregroundStyle(RoastLabTheme.acidGreen)
                        }
                    }

                    if let restoreMessage = store.restoreMessage {
                        GlassPanel {
                            Label(restoreMessage, systemImage: "arrow.clockwise.circle.fill")
                                .font(.footnote.weight(.semibold))
                                .foregroundStyle(RoastLabTheme.acidGreen)
                        }
                    }

                    if let storeError = store.storeError {
                        GlassPanel {
                            HStack(alignment: .top, spacing: 10) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundStyle(RoastLabTheme.warning)
                                Text(storeError)
                                    .font(.footnote.weight(.semibold))
                                    .foregroundStyle(RoastLabTheme.textSecondary)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                    }

                    SubscriptionLegalPanel(plan: selectedPlan, price: priceText(for: selectedPlan))

                    Text("Purchases are processed securely by Apple. You can manage or cancel subscriptions in your App Store account settings.")
                        .font(.footnote)
                        .foregroundStyle(RoastLabTheme.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.bottom, 28)
                }
                .roastLabPage(maxWidth: RoastLabLayout.compactMaxWidth)
            }
        }
        .navigationTitle("Paywall")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await store.refreshProducts()
        }
    }

    private var purchaseButtonTitle: String {
        if isPurchasing {
            "Opening App Store"
        } else if store.product(for: selectedPlan) == nil {
            "Load \(selectedPlan.displayName)"
        } else {
            "Start \(selectedPlan.displayName)"
        }
    }

    private func priceText(for plan: SubscriptionPlan) -> String {
        store.product(for: plan)?.displayPrice ?? plan.pricePlaceholder
    }

    private func purchaseSelectedPlan() async {
        guard !isPurchasing else { return }
        isPurchasing = true
        defer { isPurchasing = false }

        do {
            try await store.purchase(plan: selectedPlan)
        } catch {
            if store.storeError == nil {
                store.storeError = error.localizedDescription
            }
        }
    }

    private func restorePurchases() async {
        guard !isRestoring else { return }
        isRestoring = true
        defer { isRestoring = false }

        await store.restorePurchases()
    }
}

private struct PlanRow: View {
    var plan: SubscriptionPlan
    var price: String
    var isSelected: Bool
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            GlassPanel {
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 12) {
                        ReactionAvatarView(reaction: plan.reaction, size: 46, animated: isSelected)
                        VStack(alignment: .leading, spacing: 4) {
                            Text(plan.displayName)
                                .font(.headline.weight(.black))
                                .foregroundStyle(.white)
                            Text(price)
                                .font(.title3.weight(.black))
                                .foregroundStyle(RoastLabTheme.hotPink)
                            Text("\(plan.subscriptionLength) subscription, \(price) per \(plan.billingUnit)")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(RoastLabTheme.textSecondary)
                        }
                        Spacer()
                        Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                            .font(.title3)
                            .foregroundStyle(isSelected ? RoastLabTheme.acidGreen : RoastLabTheme.textSecondary)
                    }

                    ForEach(plan.includedFeatures, id: \.self) { feature in
                        Label(feature, systemImage: "checkmark")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(RoastLabTheme.textSecondary)
                    }
                }
            }
        }
        .buttonStyle(.plain)
    }
}

private struct RestorePurchasesButton: View {
    var isRestoring: Bool
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                if isRestoring {
                    ProgressView()
                        .tint(.white)
                } else {
                    Image(systemName: "arrow.clockwise")
                        .font(.headline)
                }
                Text(isRestoring ? "Restoring Purchases" : "Restore Purchases")
                    .font(.headline.weight(.bold))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .padding(.horizontal, 16)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.white.opacity(0.1))
                    .overlay(RoundedRectangle(cornerRadius: 16).strokeBorder(Color.white.opacity(0.18)))
            )
        }
        .buttonStyle(.plain)
        .disabled(isRestoring)
    }
}

private struct SubscriptionLegalPanel: View {
    var plan: SubscriptionPlan
    var price: String

    var body: some View {
        GlassPanel {
            VStack(alignment: .leading, spacing: 12) {
                SectionHeader(
                    title: "Subscription Terms",
                    subtitle: "\(plan.displayName) renews every \(plan.subscriptionLength) at \(price) per \(plan.billingUnit) until cancelled.",
                    systemImage: "doc.text.fill"
                )

                VStack(alignment: .leading, spacing: 8) {
                    Label(plan.displayName, systemImage: "crown.fill")
                    Label("Length: \(plan.subscriptionLength)", systemImage: "calendar")
                    Label("Price: \(price) per \(plan.billingUnit)", systemImage: "tag.fill")
                }
                .font(.footnote.weight(.semibold))
                .foregroundStyle(RoastLabTheme.textSecondary)

                VStack(alignment: .leading, spacing: 8) {
                    Link("Terms of Use (EULA)", destination: LegalLinks.termsOfUse)
                    Link("Privacy Policy", destination: LegalLinks.privacyPolicy)
                }
                .font(.footnote.weight(.bold))
                .foregroundStyle(RoastLabTheme.acidGreen)
            }
        }
    }
}

private enum LegalLinks {
    static let termsOfUse = URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!
    static let privacyPolicy = URL(string: "https://github.com/lanray07/RoastLab-AI/blob/main/PRIVACY.md")!
}

private extension SubscriptionPlan {
    var reaction: RoastReaction {
        switch self {
        case .free: .impressed
        case .roastProMonthly: .laughing
        case .roastProYearly: .applause
        case .creatorProMonthly: .savage
        }
    }
}

struct ActivityView: UIViewControllerRepresentable {
    var items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

struct CameraCaptureView: UIViewControllerRepresentable {
    @Environment(\.dismiss) private var dismiss
    var onCapture: (UIImage, Data?) -> Void

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            picker.sourceType = .camera
            picker.cameraCaptureMode = .photo
        } else {
            picker.sourceType = .photoLibrary
        }
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    final class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        var parent: CameraCaptureView

        init(parent: CameraCaptureView) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.onCapture(image, image.jpegData(compressionQuality: 0.86))
            }
            parent.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}
