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
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(title)
                            .font(.headline.weight(.bold))
                            .foregroundStyle(.white)
                        Text("Roast score \(score)")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(RoastLabTheme.acidGreen)
                    }
                    Spacer()
                    if let onShare {
                        Button(action: onShare) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.headline)
                                .foregroundStyle(.white)
                                .frame(width: 38, height: 38)
                                .background(Circle().fill(RoastLabTheme.hotPink.opacity(0.22)))
                        }
                        .accessibilityLabel("Share roast")
                    }
                }

                Text(roast)
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.white)
                    .fixedSize(horizontal: false, vertical: true)

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
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Label("Clapback", systemImage: "bolt.fill")
                        .font(.headline.weight(.bold))
                        .foregroundStyle(RoastLabTheme.electricBlue)
                    Spacer()
                    if let onShare {
                        Button(action: onShare) {
                            Image(systemName: "paperplane.fill")
                                .foregroundStyle(.white)
                        }
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

                Text(battle)
                    .font(.callout.weight(.semibold))
                    .foregroundStyle(.white)
                    .fixedSize(horizontal: false, vertical: true)
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
        GlassPanel {
            HStack(spacing: 14) {
                Image(systemName: persona.unlocked ? "theatermasks.fill" : "lock.fill")
                    .font(.title3)
                    .foregroundStyle(persona.unlocked ? RoastLabTheme.hotPink : RoastLabTheme.textSecondary)
                    .frame(width: 44, height: 44)
                    .background(Circle().fill(Color.white.opacity(0.08)))

                VStack(alignment: .leading, spacing: 4) {
                    Text(persona.name)
                        .font(.headline.weight(.bold))
                        .foregroundStyle(.white)
                    Text(persona.tagline)
                        .font(.caption)
                        .foregroundStyle(RoastLabTheme.textSecondary)
                }
                Spacer()
                Text(persona.unlocked ? "Unlocked" : "Locked")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(persona.unlocked ? RoastLabTheme.acidGreen : RoastLabTheme.warning)
            }
        }
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
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(RoastLabTheme.brandGradient)
            VStack(alignment: .leading, spacing: 16) {
                Text(title.uppercased())
                    .font(.caption.weight(.black))
                    .foregroundStyle(.white.opacity(0.78))
                Text(bodyText)
                    .font(.system(size: 26, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                    .minimumScaleFactor(0.58)
                    .lineLimit(7)
                Spacer(minLength: 0)
                Text(footer)
                    .font(.headline.weight(.black))
                    .foregroundStyle(.white)
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
                Image(systemName: "crown.fill")
                    .foregroundStyle(.black)
                    .frame(width: 42, height: 42)
                    .background(Circle().fill(RoastLabTheme.acidGreen))
                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.headline.weight(.black))
                        .foregroundStyle(.white)
                    Text(message)
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.76))
                        .lineLimit(2)
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

    var body: some View {
        RoastLabBackground {
            ScrollView {
                VStack(spacing: 22) {
                    VStack(spacing: 10) {
                        Image(systemName: "crown.fill")
                            .font(.system(size: 48, weight: .black))
                            .foregroundStyle(RoastLabTheme.acidGreen)
                        Text("RoastLab Pro")
                            .font(.system(size: 38, weight: .black, design: .rounded))
                            .foregroundStyle(.white)
                        Text("The world's smartest roast machine, tuned for viral creators.")
                            .font(.callout.weight(.semibold))
                            .foregroundStyle(RoastLabTheme.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 24)

                    ForEach([SubscriptionPlan.roastProMonthly, .roastProYearly, .creatorProMonthly]) { plan in
                        PlanRow(plan: plan, isSelected: selectedPlan == plan) {
                            selectedPlan = plan
                        }
                    }

                    NeonButton(
                        title: "Start \(selectedPlan.displayName)",
                        systemImage: "sparkles",
                        tint: RoastLabTheme.acidGreen
                    ) {
                        store.activateMock(plan: selectedPlan)
                    }

                    if !store.products.isEmpty {
                        GlassPanel {
                            VStack(alignment: .leading, spacing: 12) {
                                SectionHeader(title: "StoreKit 2 Products", subtitle: "Live products appear here once configured in App Store Connect.", systemImage: "cart.fill")
                                ForEach(store.products, id: \.id) { product in
                                    Button {
                                        Task { try? await store.purchase(product) }
                                    } label: {
                                        HStack {
                                            Text(product.displayName)
                                            Spacer()
                                            Text(product.displayPrice)
                                        }
                                        .font(.callout.weight(.bold))
                                        .foregroundStyle(.white)
                                    }
                                }
                            }
                        }
                    }

                    Text("Mock subscription activation is enabled for local development. Replace product identifiers before App Store submission.")
                        .font(.footnote)
                        .foregroundStyle(RoastLabTheme.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.bottom, 28)
                }
                .padding(20)
            }
        }
        .navigationTitle("Paywall")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await store.refreshProducts()
        }
    }
}

private struct PlanRow: View {
    var plan: SubscriptionPlan
    var isSelected: Bool
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            GlassPanel {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(plan.displayName)
                                .font(.headline.weight(.black))
                                .foregroundStyle(.white)
                            Text(plan.pricePlaceholder)
                                .font(.title3.weight(.black))
                                .foregroundStyle(RoastLabTheme.hotPink)
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
