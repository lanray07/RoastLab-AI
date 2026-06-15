import PhotosUI
import SwiftData
import SwiftUI
import UIKit

struct OnboardingView: View {
    @EnvironmentObject private var services: AppServices
    @Environment(\.modelContext) private var modelContext
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @StateObject private var viewModel = OnboardingViewModel()

    var body: some View {
        RoastLabBackground {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    ComedyHeroStageView(
                        title: "RoastLab AI",
                        subtitle: "Pick a comedy style, then start generating playful roasts.",
                        kicker: "Premium social entertainment",
                        mascot: .roastProfessor,
                        theme: .comedyClub,
                        compact: true
                    )
                    .padding(.top, 20)

                    GlassPanel {
                        VStack(alignment: .leading, spacing: 16) {
                            SectionHeader(title: "Comedy Profile", subtitle: "Pick the flavor of your banter.", systemImage: "person.crop.circle.badge.sparkles")

                            Picker("Humor preference", selection: $viewModel.selectedStyle) {
                                ForEach(HumorStyle.allCases) { style in
                                    Text(style.displayName).tag(style)
                                }
                            }
                            .pickerStyle(.menu)
                            .tint(.white)

                            Picker("Roast intensity", selection: $viewModel.selectedIntensity) {
                                ForEach(RoastIntensity.allCases) { intensity in
                                    Text(intensity.displayName).tag(intensity)
                                }
                            }
                            .pickerStyle(.segmented)
                        }
                    }

                    if let error = viewModel.errorMessage {
                        Text(error)
                            .font(.footnote.weight(.semibold))
                            .foregroundStyle(RoastLabTheme.warning)
                    }

                    VStack(spacing: 10) {
                        NeonButton(title: "Enter RoastLab", systemImage: "flame.fill", tint: RoastLabTheme.electricBlue, isLoading: viewModel.isGenerating) {
                            Task { await completeOnboarding() }
                        }
                    }
                    .padding(.bottom, 24)
                }
                .roastLabPage(maxWidth: RoastLabLayout.compactMaxWidth)
            }
        }
    }

    private func completeOnboarding() async {
        if viewModel.sampleRoast.isEmpty {
            await viewModel.generateSample(with: services.roastGeneration)
        }

        modelContext.insert(UserProfile(
            humorStyle: viewModel.selectedStyle,
            roastIntensity: viewModel.selectedIntensity
        ))
        modelContext.insert(SubscriptionState(plan: .free, isActive: false))
        modelContext.insert(RoastRequest(
            type: .bio,
            prompt: "First Roast Sample",
            generatedRoast: viewModel.sampleRoast.isEmpty ? "RoastLab AI is ready to roast with style." : viewModel.sampleRoast
        ))
        services.comedyPersona.seedDefaultPersonas(in: modelContext, existing: [])
        try? modelContext.save()
        hasCompletedOnboarding = true
    }
}

struct DashboardView: View {
    @EnvironmentObject private var services: AppServices
    @Query(sort: \RoastRequest.createdAt, order: .reverse) private var roasts: [RoastRequest]

    var body: some View {
        RoastLabBackground {
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    SectionHeader(title: "RoastLab", subtitle: "Choose a roast type.", systemImage: "flame.fill")
                        .padding(.top, 8)

                    VStack(spacing: 10) {
                        quickAction("Photo Roast", "Use a photo or group shot.", "camera.fill", RoastLabTheme.hotPink, .photoRoast)
                        quickAction("Bio Roast", "Paste a short profile.", "text.quote", RoastLabTheme.electricBlue, .bioRoast)
                        quickAction("Voice Roast", "Record or edit a setup.", "waveform", RoastLabTheme.neonPurple, .voiceRoast)
                        quickAction("Clapback", "Write a playful reply.", "bolt.fill", RoastLabTheme.acidGreen, .clapback)
                    }

                    quickAction("Roast Battle", "Generate a safe face-off.", "person.2.fill", RoastLabTheme.warning, .roastBattle)

                    if !roasts.isEmpty {
                        SectionHeader(title: "Latest Roast", subtitle: nil, systemImage: "clock.fill")
                        if let roast = roasts.first {
                            RoastCard(title: roast.resolvedType.displayName, roast: roast.generatedRoast, observations: [roast.createdAt.formatted(date: .abbreviated, time: .shortened)])
                        }
                    }

                    NavigationLink(value: AppRoute.paywall) {
                        ActionRow(title: "RoastLab Pro", subtitle: services.subscriptionStore.activePlan == .free ? "Manage subscription." : "Pro is active.", systemImage: "crown.fill", tint: RoastLabTheme.warning)
                    }
                    .buttonStyle(.plain)
                }
                .roastLabPage(maxWidth: RoastLabLayout.compactMaxWidth)
            }
        }
        .navigationTitle("Dashboard")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func quickAction(_ title: String, _ subtitle: String, _ icon: String, _ tint: Color, _ route: AppRoute) -> some View {
        NavigationLink(value: route) {
            ActionRow(title: title, subtitle: subtitle, systemImage: icon, tint: tint)
        }
        .buttonStyle(.plain)
    }
}

struct CreateHubView: View {
    private let modules: [(title: String, subtitle: String, icon: String, tint: Color, route: AppRoute)] = [
        ("Photo Roast", "Use photos or group shots.", "camera.fill", RoastLabTheme.hotPink, .photoRoast),
        ("Bio Roast", "Paste a profile or intro.", "text.quote", RoastLabTheme.electricBlue, .bioRoast),
        ("Voice Roast", "Speak or edit a setup.", "waveform", RoastLabTheme.neonPurple, .voiceRoast),
        ("Roast Battle", "Two-person banter mode.", "person.2.fill", RoastLabTheme.warning, .roastBattle),
        ("Clapback", "Replies for friendly banter.", "bolt.fill", RoastLabTheme.acidGreen, .clapback),
        ("Creator Studio", "Scripts and captions.", "movieclapper.fill", RoastLabTheme.electricBlue, .creatorStudio)
    ]

    var body: some View {
        RoastLabBackground {
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    SectionHeader(title: "Create", subtitle: "Pick one generator.", systemImage: "wand.and.stars")
                        .padding(.top, 8)

                    VStack(spacing: 10) {
                        ForEach(modules, id: \.title) { module in
                            NavigationLink(value: module.route) {
                                ActionRow(title: module.title, subtitle: module.subtitle, systemImage: module.icon, tint: module.tint)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .roastLabPage(maxWidth: RoastLabLayout.compactMaxWidth)
            }
        }
        .navigationTitle("Create")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct PhotoRoastGeneratorView: View {
    @EnvironmentObject private var services: AppServices
    @Environment(\.modelContext) private var modelContext
    @StateObject private var generator = GenerationViewModel()
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    @State private var analysis: PhotoAnalysis?
    @State private var isAnalyzing = false
    @State private var showingCamera = false
    @State private var style: HumorStyle = .playful
    @State private var intensity: RoastIntensity = .medium
    @State private var sharePayload: SharePayload?

    var body: some View {
        generatorScreen(title: "Photo Roast", subtitle: "Photos, group shots, saved images, and visual prompts.") {
            PhotosPicker(selection: $selectedPhoto, matching: .images) {
                GlassPanel {
                    VStack(spacing: 14) {
                        if let selectedImage {
                            Image(uiImage: selectedImage)
                                .resizable()
                                .scaledToFill()
                                .frame(height: 230)
                                .frame(maxWidth: .infinity)
                                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                        } else {
                            PremiumEmptyStateView(
                                title: "No photo selected yet.",
                                message: "Add a photo, group shot, or saved image and the committee will warm up.",
                                mascot: .memeGoblin,
                                scene: .socialHumor,
                                framed: false,
                                showsScene: false
                            )
                        }

                        Label(isAnalyzing ? "Analyzing image" : analysis?.summary ?? "Ready for upload", systemImage: "eye.fill")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(RoastLabTheme.textSecondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
            .buttonStyle(.plain)
            .onChange(of: selectedPhoto) { _, newItem in
                Task { await loadPhoto(newItem) }
            }

            Button {
                showingCamera = true
            } label: {
                Label("Open Camera", systemImage: "camera.fill")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(UIImagePickerController.isSourceTypeAvailable(.camera) ? Color.white.opacity(0.1) : Color.white.opacity(0.05))
                    )
            }
            .buttonStyle(.plain)
            .disabled(!UIImagePickerController.isSourceTypeAvailable(.camera))

            StyleIntensityControls(style: $style, intensity: $intensity)

            NeonButton(title: "Generate Photo Roast", systemImage: "sparkles", isLoading: generator.isLoading) {
                Task { await generate() }
            }

            outputCard(title: "Photo Roast Output", prompt: analysis?.summary ?? "Photo roast", generator: generator, sharePayload: $sharePayload)
        }
        .sheet(item: $sharePayload) { payload in
            ActivityView(items: [payload.text])
        }
        .sheet(isPresented: $showingCamera) {
            CameraCaptureView { image, data in
                selectedImage = image
                Task { await analyzeCapturedPhoto(data) }
            }
            .ignoresSafeArea()
        }
    }

    @MainActor
    private func loadPhoto(_ item: PhotosPickerItem?) async {
        guard let item else { return }
        isAnalyzing = true
        defer { isAnalyzing = false }
        guard let data = try? await item.loadTransferable(type: Data.self) else { return }
        selectedImage = UIImage(data: data)
        analysis = await services.imageAnalysis.analyze(imageData: data)
    }

    @MainActor
    private func analyzeCapturedPhoto(_ data: Data?) async {
        isAnalyzing = true
        defer { isAnalyzing = false }
        analysis = await services.imageAnalysis.analyze(imageData: data)
    }

    private func generate() async {
        let prompt = analysis?.summary ?? "A creator photo ready for a playful roast."
        await generator.run {
            try await services.roastGeneration.generate(
                type: .photo,
                prompt: prompt,
                humorStyle: style,
                roastIntensity: intensity,
                photoAnalysis: prompt
            )
        }
        saveRoast(type: .photo, prompt: prompt, output: generator.output)
    }
}

struct BioRoastGeneratorView: View {
    @EnvironmentObject private var services: AppServices
    @Environment(\.modelContext) private var modelContext
    @StateObject private var generator = GenerationViewModel()
    @State private var bio = "Founder. Coffee enthusiast. Looking for someone who can keep up with my calendar."
    @State private var style: HumorStyle = .sarcastic
    @State private var intensity: RoastIntensity = .spicy
    @State private var sharePayload: SharePayload?

    var body: some View {
        generatorScreen(title: "Bio Roast", subtitle: "Dating profiles, creator bios, professional summaries, and short intros.") {
            promptEditor(title: "Bio", text: $bio, height: 150)
            StyleIntensityControls(style: $style, intensity: $intensity)

            NeonButton(title: "Roast This Bio", systemImage: "text.quote", isLoading: generator.isLoading) {
                Task { await generate() }
            }

            outputCard(title: "Bio Roast Output", prompt: bio, generator: generator, sharePayload: $sharePayload)
        }
        .sheet(item: $sharePayload) { payload in
            ActivityView(items: [payload.text])
        }
    }

    private func generate() async {
        await generator.run {
            try await services.roastGeneration.generate(type: .bio, prompt: bio, humorStyle: style, roastIntensity: intensity)
        }
        saveRoast(type: .bio, prompt: bio, output: generator.output)
    }
}

struct VoiceRoastFeatureView: View {
    @EnvironmentObject private var services: AppServices
    @Environment(\.modelContext) private var modelContext
    @StateObject private var speech = SpeechRecognitionService()
    @StateObject private var waveform = WaveformAnimationManager()
    @StateObject private var playback = VoicePlaybackPreviewManager()
    @StateObject private var generator = GenerationViewModel()
    @State private var style: HumorStyle = .witty
    @State private var intensity: RoastIntensity = .spicy
    @State private var sharePayload: SharePayload?

    var body: some View {
        generatorScreen(title: "Voice Roast", subtitle: "Record stories, describe friends, edit the transcript, and preview a spoken roast.") {
            GlassPanel {
                VStack(spacing: 16) {
                    ComedyClubVoiceStageView(levels: waveform.levels, isGenerating: generator.isLoading)
                    HStack(spacing: 10) {
                        NeonButton(title: speech.isRecording ? "Stop" : "Record", systemImage: speech.isRecording ? "stop.fill" : "mic.fill", tint: speech.isRecording ? RoastLabTheme.warning : RoastLabTheme.hotPink) {
                            Task { await toggleRecording() }
                        }
                        Button {
                            speech.pause()
                            waveform.stop()
                        } label: {
                            Image(systemName: "pause.fill")
                                .foregroundStyle(.white)
                                .frame(width: 48, height: 48)
                                .background(Circle().fill(Color.white.opacity(0.12)))
                        }
                        .disabled(!speech.isRecording)
                    }

                    HStack {
                        Label(speech.partialStatus, systemImage: "waveform")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(RoastLabTheme.textSecondary)
                        Spacer()
                        Button("Mock transcript") {
                            speech.insertMockTranscript()
                        }
                        .font(.caption.weight(.bold))
                        .foregroundStyle(RoastLabTheme.electricBlue)
                    }
                }
            }

            promptEditor(title: "Live Transcript", text: $speech.transcript, height: 160)
            StyleIntensityControls(style: $style, intensity: $intensity)

            NeonButton(title: "Generate Voice Roast", systemImage: "sparkles", isLoading: generator.isLoading) {
                Task { await generate() }
            }

            if !generator.output.isEmpty {
                GlassPanel {
                    VStack(alignment: .leading, spacing: 14) {
                        SectionHeader(title: "Voice Playback", subtitle: "Preview the generated roast with native speech.", systemImage: "speaker.wave.2.fill")
                        Picker("Voice style", selection: $playback.selectedVoiceStyle) {
                            Text("AI Comedian").tag("AI Comedian")
                            Text("Celebrity Parody").tag("Celebrity Parody")
                            Text("Deadpan Host").tag("Deadpan Host")
                        }
                        .pickerStyle(.menu)
                        .tint(.white)
                        HStack(spacing: 10) {
                            NeonButton(title: playback.isPlaying ? "Stop" : "Play", systemImage: playback.isPlaying ? "stop.fill" : "play.fill", tint: RoastLabTheme.electricBlue) {
                                playback.isPlaying ? playback.stop() : playback.play(generator.output)
                            }
                            Button {
                                sharePayload = SharePayload(text: generator.output)
                            } label: {
                                Image(systemName: "square.and.arrow.up")
                                    .foregroundStyle(.white)
                                    .frame(width: 50, height: 50)
                                    .background(Circle().fill(Color.white.opacity(0.12)))
                            }
                        }
                    }
                }
            }

            outputCard(title: "Voice Roast Output", prompt: speech.transcript, generator: generator, sharePayload: $sharePayload)
        }
        .sheet(item: $sharePayload) { payload in
            ActivityView(items: [payload.text])
        }
    }

    private func toggleRecording() async {
        if speech.isRecording {
            speech.stop()
            waveform.stop()
        } else {
            do {
                try await speech.start()
                waveform.start()
            } catch {
                speech.insertMockTranscript()
            }
        }
    }

    private func generate() async {
        await generator.run {
            try await services.voiceRoast.generate(transcript: speech.transcript, style: style, intensity: intensity)
        }

        guard !generator.output.isEmpty else { return }
        modelContext.insert(VoiceTranscript(transcript: speech.transcript, roastOutput: generator.output))
        modelContext.insert(RoastRequest(type: .voice, prompt: speech.transcript, generatedRoast: generator.output))
        try? modelContext.save()
    }
}

struct RoastBattleModeView: View {
    @EnvironmentObject private var services: AppServices
    @Environment(\.modelContext) private var modelContext
    @StateObject private var generator = GenerationViewModel()
    @State private var participantA = "Person A: ambitious, dramatic, always late"
    @State private var participantB = "Person B: calm, smug, owns too many productivity apps"
    @State private var style: HumorStyle = .savage
    @State private var intensity: RoastIntensity = .spicy

    var body: some View {
        generatorScreen(title: "Roast Battle", subtitle: "Generate safe banter exchanges, comeback chains, and a winner score.") {
            promptEditor(title: "Person A", text: $participantA, height: 90)
            promptEditor(title: "Person B", text: $participantB, height: 90)
            StyleIntensityControls(style: $style, intensity: $intensity)

            NeonButton(title: "Start Battle", systemImage: "person.2.fill", tint: RoastLabTheme.warning, isLoading: generator.isLoading) {
                Task { await generate() }
            }

            if generator.isLoading {
                ComedyLoadingView(mascot: .friendlyBully)
            }

            if !generator.output.isEmpty {
                RoastBattleCard(participantA: "Person A", participantB: "Person B", battle: generator.output)
            }
        }
    }

    private func generate() async {
        await generator.run {
            try await services.roastBattle.generate(participantA: participantA, participantB: participantB, style: style, intensity: intensity)
        }
        guard !generator.output.isEmpty else { return }
        modelContext.insert(RoastBattle(participantA: participantA, participantB: participantB, generatedBattle: generator.output))
        modelContext.insert(RoastRequest(type: .battle, prompt: "\(participantA) vs \(participantB)", generatedRoast: generator.output))
        try? modelContext.save()
    }
}

struct ClapbackGeneratorView: View {
    @EnvironmentObject private var services: AppServices
    @Environment(\.modelContext) private var modelContext
    @StateObject private var generator = GenerationViewModel()
    @State private var context = "Someone said my content strategy looks like it was assembled during a software update."
    @State private var style: HumorStyle = .witty
    @State private var intensity: RoastIntensity = .medium
    @State private var sharePayload: SharePayload?

    var body: some View {
        generatorScreen(title: "Clapback Generator", subtitle: "Online trolls, funny comments, friendly banter, and group chats.") {
            promptEditor(title: "Context", text: $context, height: 140)
            StyleIntensityControls(style: $style, intensity: $intensity)

            NeonButton(title: "Generate Clapback", systemImage: "bolt.fill", tint: RoastLabTheme.acidGreen, isLoading: generator.isLoading) {
                Task { await generate() }
            }

            if generator.isLoading {
                ComedyLoadingView(mascot: .britishBanterKing)
            }

            if !generator.output.isEmpty {
                ClapbackCard(context: context, response: generator.output) {
                    sharePayload = SharePayload(text: generator.output)
                }
            }
        }
        .sheet(item: $sharePayload) { payload in
            ActivityView(items: [payload.text])
        }
    }

    private func generate() async {
        await generator.run {
            try await services.clapback.generate(context: context, style: style, intensity: intensity)
        }
        guard !generator.output.isEmpty else { return }
        modelContext.insert(Clapback(context: context, response: generator.output))
        modelContext.insert(RoastRequest(type: .clapback, prompt: context, generatedRoast: generator.output))
        try? modelContext.save()
    }
}

struct WorkplaceSafeModeView: View {
    @EnvironmentObject private var services: AppServices
    @Environment(\.modelContext) private var modelContext
    @StateObject private var generator = GenerationViewModel()
    @State private var context = "A meeting that keeps moving the deadline while calling itself agile."
    @State private var sharePayload: SharePayload?

    var body: some View {
        generatorScreen(title: "Workplace Safe Mode", subtitle: "Office-friendly humor, meeting jokes, coworker banter, and professional roasts.") {
            promptEditor(title: "Office setup", text: $context, height: 140)

            GlassPanel {
                VStack(alignment: .leading, spacing: 8) {
                    Label("Workplace appropriate", systemImage: "checkmark.shield.fill")
                        .font(.headline.weight(.bold))
                        .foregroundStyle(RoastLabTheme.acidGreen)
                    Text("Clean comedy, mild intensity, no personal cruelty.")
                        .font(.caption)
                        .foregroundStyle(RoastLabTheme.textSecondary)
                }
            }

            NeonButton(title: "Generate Office Banter", systemImage: "briefcase.fill", tint: RoastLabTheme.electricBlue, isLoading: generator.isLoading) {
                Task { await generate() }
            }

            outputCard(title: "Workplace Roast", prompt: context, generator: generator, sharePayload: $sharePayload)
        }
        .sheet(item: $sharePayload) { payload in
            ActivityView(items: [payload.text])
        }
    }

    private func generate() async {
        await generator.run {
            try await services.roastGeneration.generate(type: .workplace, prompt: context, humorStyle: .cleanComedy, roastIntensity: .mild)
        }
        saveRoast(type: .workplace, prompt: context, output: generator.output)
    }
}

struct MemeGeneratorView: View {
    @EnvironmentObject private var services: AppServices
    @Environment(\.modelContext) private var modelContext
    @StateObject private var generator = GenerationViewModel()
    @State private var prompt = "A founder opens twelve tabs to avoid making one decision."
    @State private var style: HumorStyle = .absurd
    @State private var intensity: RoastIntensity = .medium
    @State private var sharePayload: SharePayload?

    var body: some View {
        generatorScreen(title: "Meme Generator", subtitle: "Roast memes, captions, reaction content, and image ideas.") {
            promptEditor(title: "Meme setup", text: $prompt, height: 130)
            StyleIntensityControls(style: $style, intensity: $intensity)

            NeonButton(title: "Generate Meme Captions", systemImage: "photo.on.rectangle.angled", isLoading: generator.isLoading) {
                Task { await generate() }
            }

            if generator.isLoading {
                ComedyLoadingView(mascot: .memeGoblin)
            }

            if !generator.output.isEmpty {
                ShareCardPreview(title: "Meme Roast", bodyText: generator.output)
                RoastCard(title: "Caption Pack", roast: generator.output, observations: generator.observations) {
                    sharePayload = SharePayload(text: generator.output)
                }
            }
        }
        .sheet(item: $sharePayload) { payload in
            ActivityView(items: [payload.text])
        }
    }

    private func generate() async {
        await generator.run {
            try await services.memeCaption.generate(prompt: prompt, style: style, intensity: intensity)
        }
        saveRoast(type: .meme, prompt: prompt, output: generator.output)
    }
}

struct CreatorStudioView: View {
    @EnvironmentObject private var services: AppServices
    @Environment(\.modelContext) private var modelContext
    @StateObject private var generator = GenerationViewModel()
    @State private var brief = "Turn a funny roast about overconfident productivity habits into a short video script."
    @State private var style: HumorStyle = .witty
    @State private var intensity: RoastIntensity = .spicy
    @State private var sharePayload: SharePayload?

    var body: some View {
        generatorScreen(title: "Creator Studio", subtitle: "Short video scripts, roast videos, funny skits, captions, and stand-up jokes.") {
            promptEditor(title: "Creator brief", text: $brief, height: 150)
            StyleIntensityControls(style: $style, intensity: $intensity)

            NeonButton(title: "Generate Creator Pack", systemImage: "movieclapper.fill", tint: RoastLabTheme.electricBlue, isLoading: generator.isLoading) {
                Task { await generate() }
            }

            if generator.isLoading {
                ComedyLoadingView(mascot: .savageQueen)
            }

            if !generator.output.isEmpty {
                RoastCard(title: "Creator Pack", roast: generator.output, observations: generator.observations) {
                    sharePayload = SharePayload(text: generator.output)
                }
            }
        }
        .sheet(item: $sharePayload) { payload in
            ActivityView(items: [payload.text])
        }
    }

    private func generate() async {
        await generator.run {
            try await services.roastGeneration.generate(type: .creator, prompt: brief, humorStyle: style, roastIntensity: intensity)
        }
        saveRoast(type: .creator, prompt: brief, output: generator.output)
    }
}

struct PersonalityProfilesView: View {
    @EnvironmentObject private var services: AppServices
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \ComedyPersona.createdAt) private var personas: [ComedyPersona]
    @Query private var roasts: [RoastRequest]

    var body: some View {
        RoastLabBackground {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    SectionHeader(title: "Roast Personality Profiles", subtitle: "Unlocked through usage and ready for future premium routing.", systemImage: "theatermasks.fill")
                    MascotCommitteeStrip(mascots: [.roastProfessor, .memeGoblin, .britishBanterKing, .savageQueen, .friendlyBully])
                    ForEach(personas) { persona in
                        ComedyPersonaCard(persona: persona)
                    }
                    if personas.isEmpty {
                        EmptyStateView(title: "Profiles loading", message: "Default comedy personas are being seeded locally.", systemImage: "lock.open.fill")
                    }
                }
                .roastLabPage()
            }
        }
        .navigationTitle("Personas")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            services.comedyPersona.seedDefaultPersonas(in: modelContext, existing: personas)
            services.comedyPersona.unlockEligiblePersonas(in: personas, roastCount: roasts.count)
            try? modelContext.save()
        }
    }
}

struct AnalyticsDashboardView: View {
    @Query private var roasts: [RoastRequest]
    @Query private var clapbacks: [Clapback]
    @Query private var battles: [RoastBattle]
    @Query private var voices: [VoiceTranscript]
    @Query private var profiles: [UserProfile]

    private var points: [AnalyticsPoint] {
        [
            AnalyticsPoint(label: "Roasts", value: roasts.count, color: RoastLabTheme.hotPink),
            AnalyticsPoint(label: "Claps", value: clapbacks.count, color: RoastLabTheme.electricBlue),
            AnalyticsPoint(label: "Battles", value: battles.count, color: RoastLabTheme.warning),
            AnalyticsPoint(label: "Voice", value: voices.count, color: RoastLabTheme.acidGreen)
        ]
    }

    var body: some View {
        RoastLabBackground {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    SectionHeader(title: "Analytics Dashboard", subtitle: "Roast count, most used style, funniest content, share rate, and streaks.", systemImage: "chart.bar.xaxis")
                    HumanizedSceneIllustration(scene: .audience, height: 170)
                    AnalyticsChartCard(title: "Content Mix", points: points)
                    AchievementShelfView(unlockedCount: roasts.count + clapbacks.count + battles.count + voices.count)

                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 170, maximum: 260), spacing: 12)], spacing: 12) {
                        MetricTile(title: "Most used style", value: profiles.first?.resolvedHumorStyle.displayName ?? "Playful", systemImage: "paintpalette.fill", tint: RoastLabTheme.hotPink)
                        MetricTile(title: "Share rate", value: roasts.isEmpty ? "0%" : "68%", systemImage: "arrowshape.turn.up.right.fill", tint: RoastLabTheme.acidGreen)
                        MetricTile(title: "Funniest content", value: roasts.first?.resolvedType.displayName ?? "Sample", systemImage: "star.fill", tint: RoastLabTheme.warning)
                        MetricTile(title: "Total outputs", value: "\(roasts.count + clapbacks.count + battles.count + voices.count)", systemImage: "sparkles", tint: RoastLabTheme.electricBlue)
                    }
                }
                .roastLabPage()
            }
        }
        .navigationTitle("Analytics")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ShareCardsView: View {
    @Query(sort: \RoastRequest.createdAt, order: .reverse) private var roasts: [RoastRequest]
    @Query(sort: \Clapback.createdAt, order: .reverse) private var clapbacks: [Clapback]
    @Query(sort: \RoastBattle.createdAt, order: .reverse) private var battles: [RoastBattle]
    @State private var sharePayload: SharePayload?

    var body: some View {
        RoastLabBackground {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    SectionHeader(title: "Share Cards", subtitle: "Optimized for messages, group chats, and short-form posts.", systemImage: "square.and.arrow.up.fill")
                    ReactionRailView(reactions: [.laughing, .shocked, .cryingWithLaughter, .savage, .applause])

                    if let roast = roasts.first {
                        ShareCardPreview(title: roast.resolvedType.displayName, bodyText: roast.generatedRoast)
                        NeonButton(title: "Share Latest Roast", systemImage: "square.and.arrow.up", tint: RoastLabTheme.acidGreen) {
                            sharePayload = SharePayload(text: roast.generatedRoast)
                        }
                    } else {
                        EmptyStateView(title: "No share cards yet", message: "Generate a roast, battle, clapback, or meme first.", systemImage: "rectangle.on.rectangle.angled")
                    }

                    ForEach(Array(clapbacks.prefix(2))) { clapback in
                        ClapbackCard(context: clapback.context, response: clapback.response) {
                            sharePayload = SharePayload(text: clapback.response)
                        }
                    }

                    ForEach(Array(battles.prefix(2))) { battle in
                        RoastBattleCard(participantA: battle.participantA, participantB: battle.participantB, battle: battle.generatedBattle)
                    }
                }
                .roastLabPage()
            }
        }
        .navigationTitle("Share Cards")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $sharePayload) { payload in
            ActivityView(items: [payload.text])
        }
    }
}

struct SettingsView: View {
    @EnvironmentObject private var services: AppServices
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [UserProfile]
    @Query private var subscriptions: [SubscriptionState]
    @Query private var roasts: [RoastRequest]
    @Query private var clapbacks: [Clapback]
    @Query private var battles: [RoastBattle]
    @Query private var voices: [VoiceTranscript]
    @Query private var personas: [ComedyPersona]
    @State private var voicePreviewsEnabled = true

    var body: some View {
        RoastLabBackground {
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    SectionHeader(title: "Settings", subtitle: nil, systemImage: "gearshape.fill")
                        .padding(.top, 8)

                    NavigationLink(value: AppRoute.paywall) {
                        ActionRow(title: "Subscription", subtitle: "Current plan: \(services.subscriptionStore.activePlan.displayName)", systemImage: "crown.fill", tint: RoastLabTheme.warning)
                    }
                    .buttonStyle(.plain)

                    GlassPanel {
                        VStack(alignment: .leading, spacing: 12) {
                            Toggle("Voice previews", isOn: $voicePreviewsEnabled)
                                .tint(RoastLabTheme.hotPink)
                            Toggle("Safe comedy mode", isOn: .constant(true))
                                .tint(RoastLabTheme.acidGreen)
                            Text("Keeps roasts playful and non-targeted.")
                                .font(.caption)
                                .foregroundStyle(RoastLabTheme.textSecondary)
                        }
                    }

                    GlassPanel {
                        VStack(alignment: .leading, spacing: 10) {
                            Link("Privacy Policy", destination: URL(string: "https://github.com/lanray07/RoastLab-AI/blob/main/PRIVACY.md")!)
                            Link("Terms of Use (EULA)", destination: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!)
                        }
                        .foregroundStyle(RoastLabTheme.electricBlue)
                    }

                    Button(role: .destructive) {
                        deleteAllData()
                    } label: {
                        Label("Delete All Data", systemImage: "trash.fill")
                            .font(.headline.weight(.bold))
                            .foregroundStyle(RoastLabTheme.warning)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 16).fill(Color.white.opacity(0.08)))
                    }
                }
                .roastLabPage()
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            seedSettings()
        }
    }

    private func seedSettings() {
        if profiles.isEmpty {
            let profile = UserProfile()
            modelContext.insert(profile)
        }

        if subscriptions.isEmpty {
            modelContext.insert(SubscriptionState(plan: .free, isActive: false))
        }

        services.comedyPersona.seedDefaultPersonas(in: modelContext, existing: personas)
        try? modelContext.save()
    }

    private func deleteAllData() {
        roasts.forEach(modelContext.delete)
        clapbacks.forEach(modelContext.delete)
        battles.forEach(modelContext.delete)
        voices.forEach(modelContext.delete)
        personas.forEach(modelContext.delete)
        subscriptions.forEach(modelContext.delete)
        profiles.forEach(modelContext.delete)
        try? modelContext.save()
        services.subscriptionStore.activateMock(plan: .free)
    }
}

@ViewBuilder
private func generatorScreen<Content: View>(title: String, subtitle: String, @ViewBuilder content: () -> Content) -> some View {
    RoastLabBackground {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                SectionHeader(title: title, subtitle: subtitle, systemImage: "sparkles")
                content()
            }
            .roastLabPage(maxWidth: RoastLabLayout.compactMaxWidth)
        }
    }
    .navigationTitle(title)
    .navigationBarTitleDisplayMode(.inline)
}

private func sceneForTitle(_ title: String) -> RoastScene {
    let lowered = title.lowercased()
    if lowered.contains("voice") { return .audience }
    if lowered.contains("battle") { return .battle }
    if lowered.contains("clapback") { return .groupChat }
    if lowered.contains("meme") { return .socialHumor }
    if lowered.contains("creator") { return .creators }
    return .friends
}

private func mascotForTitle(_ title: String) -> RoastMascot {
    let lowered = title.lowercased()
    if lowered.contains("voice") { return .roastProfessor }
    if lowered.contains("battle") { return .friendlyBully }
    if lowered.contains("clapback") { return .britishBanterKing }
    if lowered.contains("meme") || lowered.contains("photo") { return .memeGoblin }
    if lowered.contains("workplace") { return .roastProfessor }
    if lowered.contains("creator") { return .savageQueen }
    return .savageQueen
}

private func promptEditor(title: String, text: Binding<String>, height: CGFloat) -> some View {
    GlassPanel {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline.weight(.bold))
                .foregroundStyle(.white)
            TextEditor(text: text)
                .font(.callout)
                .foregroundStyle(.white)
                .scrollContentBackground(.hidden)
                .frame(minHeight: height)
                .padding(10)
                .background(RoundedRectangle(cornerRadius: 14).fill(Color.black.opacity(0.28)))
        }
    }
}

@MainActor
private func outputCard(title: String, prompt: String, generator: GenerationViewModel, sharePayload: Binding<SharePayload?>) -> some View {
    VStack(spacing: 12) {
        if generator.isLoading {
            ComedyLoadingView(mascot: mascotForTitle(title))
        }

        if let error = generator.errorMessage {
            GlassPanel {
                Label(error, systemImage: "exclamationmark.triangle.fill")
                    .font(.callout.weight(.semibold))
                    .foregroundStyle(RoastLabTheme.warning)
            }
        }

        if !generator.output.isEmpty {
            RoastCard(title: title, roast: generator.output, observations: generator.observations) {
                sharePayload.wrappedValue = SharePayload(text: generator.output)
            }
        } else if !generator.isLoading {
            EmptyStateView(
                title: "Your roast lab is suspiciously quiet.",
                message: prompt.isEmpty ? "Add a setup, then the committee will make it shareable." : "Time to create comedy history.",
                systemImage: "quote.bubble.fill"
            )
        }
    }
}

private extension PhotoRoastGeneratorView {
    func saveRoast(type: RoastRequestType, prompt: String, output: String) {
        guard !output.isEmpty else { return }
        modelContext.insert(RoastRequest(type: type, prompt: prompt, generatedRoast: output))
        try? modelContext.save()
    }
}

private extension BioRoastGeneratorView {
    func saveRoast(type: RoastRequestType, prompt: String, output: String) {
        guard !output.isEmpty else { return }
        modelContext.insert(RoastRequest(type: type, prompt: prompt, generatedRoast: output))
        try? modelContext.save()
    }
}

private extension WorkplaceSafeModeView {
    func saveRoast(type: RoastRequestType, prompt: String, output: String) {
        guard !output.isEmpty else { return }
        modelContext.insert(RoastRequest(type: type, prompt: prompt, generatedRoast: output))
        try? modelContext.save()
    }
}

private extension MemeGeneratorView {
    func saveRoast(type: RoastRequestType, prompt: String, output: String) {
        guard !output.isEmpty else { return }
        modelContext.insert(RoastRequest(type: type, prompt: prompt, generatedRoast: output))
        try? modelContext.save()
    }
}

private extension CreatorStudioView {
    func saveRoast(type: RoastRequestType, prompt: String, output: String) {
        guard !output.isEmpty else { return }
        modelContext.insert(RoastRequest(type: type, prompt: prompt, generatedRoast: output))
        try? modelContext.save()
    }
}
