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
                VStack(alignment: .leading, spacing: 24) {
                    ComedyHeroStageView(
                        title: "RoastLab AI",
                        subtitle: "Upload anything. Get roasted instantly with a comedy cast that feels more late-night show than utility app.",
                        kicker: "Premium social entertainment",
                        mascot: .roastProfessor,
                        theme: .comedyClub
                    )
                    .padding(.top, 36)

                    MascotCommitteeStrip(mascots: [.roastProfessor, .memeGoblin, .britishBanterKing, .savageQueen, .friendlyBully])

                    GlassPanel {
                        VStack(alignment: .leading, spacing: 16) {
                            SectionHeader(title: "Comedy Profile", subtitle: "Pick the flavor of your banter.", systemImage: "person.crop.circle.badge.sparkles")

                            HumanizedSceneIllustration(scene: .friends, height: 152)

                            Picker("Humor preference", selection: $viewModel.selectedStyle) {
                                ForEach(HumorStyle.allCases) { style in
                                    Text(style.displayName).tag(style)
                                }
                            }
                            .pickerStyle(.wheel)
                            .frame(height: 140)

                            Picker("Roast intensity", selection: $viewModel.selectedIntensity) {
                                ForEach(RoastIntensity.allCases) { intensity in
                                    Text(intensity.displayName).tag(intensity)
                                }
                            }
                            .pickerStyle(.segmented)
                        }
                    }

                    if !viewModel.sampleRoast.isEmpty {
                        RoastCard(
                            title: "First Roast Sample",
                            roast: viewModel.sampleRoast,
                            observations: ["Comedy profile generated", "Mock AI enabled by default"],
                            score: 94
                        )
                    }

                    if let error = viewModel.errorMessage {
                        Text(error)
                            .font(.footnote.weight(.semibold))
                            .foregroundStyle(RoastLabTheme.warning)
                    }

                    VStack(spacing: 12) {
                        NeonButton(title: "Generate Sample", systemImage: "sparkles", isLoading: viewModel.isGenerating) {
                            Task { await viewModel.generateSample(with: services.roastGeneration) }
                        }

                        NeonButton(title: "Enter RoastLab", systemImage: "flame.fill", tint: RoastLabTheme.electricBlue, isLoading: viewModel.isGenerating) {
                            Task { await completeOnboarding() }
                        }
                    }
                    .padding(.bottom, 28)
                }
                .padding(20)
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
    @Query(sort: \Clapback.createdAt, order: .reverse) private var clapbacks: [Clapback]
    @Query(sort: \RoastBattle.createdAt, order: .reverse) private var battles: [RoastBattle]
    @Query(sort: \VoiceTranscript.createdAt, order: .reverse) private var voices: [VoiceTranscript]

    private let dashboardModel = DashboardViewModel()
    private let grid = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]

    var body: some View {
        RoastLabBackground {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    ComedyHeroStageView(
                        title: "RoastLab AI",
                        subtitle: "A premium roast lab for creators, group chats, battles, and shareable comedy cards.",
                        kicker: "Tonight's comedy dashboard",
                        mascot: .memeGoblin,
                        theme: .memeUniverse,
                        compact: true
                    )
                    .padding(.top, 10)

                    LazyVGrid(columns: grid, spacing: 12) {
                        MetricTile(title: "Roast streak", value: "\(dashboardModel.streak(from: roasts.map(\.createdAt)))", systemImage: "flame.fill", tint: RoastLabTheme.hotPink)
                        MetricTile(title: "Favorites", value: "\(max(1, roasts.count / 2))", systemImage: "heart.fill", tint: RoastLabTheme.electricBlue)
                        MetricTile(title: "Roast score", value: "\(dashboardModel.roastScore(roasts: roasts.count, clapbacks: clapbacks.count, battles: battles.count, voices: voices.count))", systemImage: "bolt.fill", tint: RoastLabTheme.acidGreen)
                        MetricTile(title: "Plan", value: services.subscriptionStore.activePlan == .free ? "Free" : "Pro", systemImage: "crown.fill", tint: RoastLabTheme.warning)
                    }

                    UpgradeBanner()

                    AchievementShelfView(unlockedCount: roasts.count + clapbacks.count + battles.count + voices.count)

                    SectionHeader(title: "Quick Actions", subtitle: "Jump straight into the roast lab.", systemImage: "wand.and.stars")
                    LazyVGrid(columns: grid, spacing: 12) {
                        quickAction("Roast Photo", "Selfies, groups, profile shots", "camera.fill", RoastLabTheme.hotPink, .photoRoast)
                        quickAction("Roast Bio", "Dating, LinkedIn, socials", "text.quote", RoastLabTheme.electricBlue, .bioRoast)
                        quickAction("Voice Roast", "Record stories and situations", "waveform", RoastLabTheme.neonPurple, .voiceRoast)
                        quickAction("Roast Battle", "Two names enter", "person.2.fill", RoastLabTheme.warning, .roastBattle)
                        quickAction("Clapback", "Replies for trolls and banter", "bolt.fill", RoastLabTheme.acidGreen, .clapback)
                        quickAction("Meme Roast", "Captions and reactions", "photo.on.rectangle.angled", RoastLabTheme.hotPink, .meme)
                    }

                    SectionHeader(title: "Trending Styles", subtitle: "Comedy modes ready for creator content.", systemImage: "chart.line.uptrend.xyaxis")
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(HumorStyle.allCases) { style in
                                Text(style.displayName)
                                    .font(.caption.weight(.black))
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 10)
                                    .background(Capsule().fill(Color.white.opacity(0.1)))
                            }
                        }
                    }

                    SectionHeader(title: "Recent Content", subtitle: nil, systemImage: "clock.fill")
                    if roasts.isEmpty {
                        EmptyStateView(title: "No roasts yet", message: "Your first sample is waiting to become a share card.", systemImage: "sparkles")
                    } else {
                        ForEach(Array(roasts.prefix(3))) { roast in
                            RoastCard(title: roast.resolvedType.displayName, roast: roast.generatedRoast, observations: ["Saved locally", roast.createdAt.formatted(date: .abbreviated, time: .shortened)])
                        }
                    }
                }
                .padding(20)
            }
        }
        .navigationTitle("Dashboard")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func quickAction(_ title: String, _ subtitle: String, _ icon: String, _ tint: Color, _ route: AppRoute) -> some View {
        NavigationLink(value: route) {
            QuickActionTile(title: title, subtitle: subtitle, systemImage: icon, tint: tint)
        }
        .buttonStyle(.plain)
    }
}

struct CreateHubView: View {
    private let modules: [(title: String, subtitle: String, icon: String, tint: Color, route: AppRoute)] = [
        ("Photo Roast", "Upload profile photos and social screenshots.", "camera.fill", RoastLabTheme.hotPink, .photoRoast),
        ("Bio Roast", "Roast Tinder, Instagram, LinkedIn, or X bios.", "text.quote", RoastLabTheme.electricBlue, .bioRoast),
        ("Voice Roast", "Speak, transcribe, edit, and generate.", "waveform", RoastLabTheme.neonPurple, .voiceRoast),
        ("Roast Battle", "Generate comeback chains and winner scores.", "person.2.fill", RoastLabTheme.warning, .roastBattle),
        ("Clapback", "Witty responses for friendly banter.", "bolt.fill", RoastLabTheme.acidGreen, .clapback),
        ("Workplace Safe", "Office-friendly jokes and meeting banter.", "briefcase.fill", RoastLabTheme.electricBlue, .workplaceSafe),
        ("Meme Generator", "Captions and image macro placeholders.", "photo.on.rectangle.angled", RoastLabTheme.hotPink, .meme),
        ("Share Cards", "Export roast, meme, and battle cards.", "square.and.arrow.up.fill", RoastLabTheme.acidGreen, .shareCards)
    ]

    private let grid = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]

    var body: some View {
        RoastLabBackground {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    SectionHeader(title: "Create", subtitle: "Every roast tool in one premium studio.", systemImage: "wand.and.stars")
                    HumanizedSceneIllustration(scene: .creators, height: 186)
                    MascotCommitteeStrip(mascots: [.savageQueen, .roastProfessor, .memeGoblin])

                    LazyVGrid(columns: grid, spacing: 12) {
                        ForEach(modules, id: \.title) { module in
                            NavigationLink(value: module.route) {
                                QuickActionTile(title: module.title, subtitle: module.subtitle, systemImage: module.icon, tint: module.tint)
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    NavigationLink(value: AppRoute.personas) {
                        GlassPanel {
                            HStack(spacing: 14) {
                                MascotIllustration(mascot: .britishBanterKing, expression: .performing, size: 64, animated: true)
                                VStack(alignment: .leading, spacing: 3) {
                                    Text("Roast Personality Profiles")
                                        .font(.headline.weight(.black))
                                        .foregroundStyle(.white)
                                    Text("Unlock comedy voices through usage.")
                                        .font(.caption)
                                        .foregroundStyle(RoastLabTheme.textSecondary)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundStyle(RoastLabTheme.textSecondary)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                }
                .padding(20)
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
        generatorScreen(title: "Photo Roast", subtitle: "Selfies, profile photos, group shots, and social images.") {
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
                                title: "No victims selected yet.",
                                message: "Add a selfie, group shot, or social screenshot and the committee will warm up.",
                                mascot: .memeGoblin,
                                scene: .socialHumor,
                                framed: false
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
        generatorScreen(title: "Bio Roast", subtitle: "Dating profiles, Instagram bios, LinkedIn summaries, and X intros.") {
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
    @StateObject private var playback = VoicePlaybackPlaceholder()
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
                        SectionHeader(title: "AI Voice Playback", subtitle: "Architecture placeholder with native speech preview.", systemImage: "speaker.wave.2.fill")
                        Picker("Voice style", selection: $playback.selectedVoiceStyle) {
                            Text("AI Comedian").tag("AI Comedian")
                            Text("Celebrity Parody").tag("Celebrity Parody")
                            Text("Deadpan Host").tag("Deadpan Host")
                        }
                        .pickerStyle(.segmented)
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
        generatorScreen(title: "Meme Generator", subtitle: "Roast memes, captions, reaction content, and image macro placeholders.") {
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
    @State private var brief = "Turn a funny roast about overconfident productivity habits into a TikTok script."
    @State private var style: HumorStyle = .witty
    @State private var intensity: RoastIntensity = .spicy
    @State private var sharePayload: SharePayload?

    var body: some View {
        generatorScreen(title: "Creator Studio", subtitle: "TikTok scripts, roast videos, YouTube Shorts ideas, funny skits, and stand-up jokes.") {
            HStack(spacing: 10) {
                NavigationLink(value: AppRoute.shareCards) {
                    QuickActionTile(title: "Share Cards", subtitle: "Export roast visuals", systemImage: "square.and.arrow.up.fill", tint: RoastLabTheme.acidGreen)
                }
                .buttonStyle(.plain)
                NavigationLink(value: AppRoute.personas) {
                    QuickActionTile(title: "Personas", subtitle: "Unlock roast voices", systemImage: "theatermasks.fill", tint: RoastLabTheme.hotPink)
                }
                .buttonStyle(.plain)
            }

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
                .padding(20)
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

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        MetricTile(title: "Most used style", value: profiles.first?.resolvedHumorStyle.displayName ?? "Playful", systemImage: "paintpalette.fill", tint: RoastLabTheme.hotPink)
                        MetricTile(title: "Share rate", value: roasts.isEmpty ? "0%" : "68%", systemImage: "arrowshape.turn.up.right.fill", tint: RoastLabTheme.acidGreen)
                        MetricTile(title: "Funniest content", value: roasts.first?.resolvedType.displayName ?? "Sample", systemImage: "star.fill", tint: RoastLabTheme.warning)
                        MetricTile(title: "Total outputs", value: "\(roasts.count + clapbacks.count + battles.count + voices.count)", systemImage: "sparkles", tint: RoastLabTheme.electricBlue)
                    }
                }
                .padding(20)
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
                    SectionHeader(title: "Share Cards", subtitle: "Optimized for TikTok, Instagram, X, and WhatsApp.", systemImage: "square.and.arrow.up.fill")
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
                .padding(20)
            }
        }
        .navigationTitle("Share Cards")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $sharePayload) { payload in
            ActivityView(items: [payload.text])
        }
    }
}

struct WidgetPlaceholderView: View {
    var body: some View {
        placeholderScreen(
            title: "WidgetKit Placeholder",
            subtitle: "Daily roast, joke of the day, roast streak, and random clapback widgets.",
            icon: "platter.filled.top.iphone",
            rows: ["Daily roast timeline", "Joke of the day entry", "Roast streak snapshot", "Random clapback provider"]
        )
    }
}

struct WatchPlaceholderView: View {
    var body: some View {
        placeholderScreen(
            title: "Apple Watch Placeholder",
            subtitle: "Daily roast notifications, clapback suggestions, and roast prompts.",
            icon: "applewatch",
            rows: ["Daily roast notification", "Quick clapback suggestion", "Voice prompt handoff", "Companion app architecture"]
        )
    }
}

struct SettingsView: View {
    @EnvironmentObject private var services: AppServices
    @Environment(\.modelContext) private var modelContext
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = true
    @Query private var profiles: [UserProfile]
    @Query private var subscriptions: [SubscriptionState]
    @Query private var roasts: [RoastRequest]
    @Query private var clapbacks: [Clapback]
    @Query private var battles: [RoastBattle]
    @Query private var voices: [VoiceTranscript]
    @Query private var personas: [ComedyPersona]
    @State private var style: HumorStyle = .playful
    @State private var intensity: RoastIntensity = .medium
    @State private var voicePreviewsEnabled = true

    var body: some View {
        RoastLabBackground {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    SectionHeader(title: "Settings", subtitle: "Subscription, comedy preferences, voice settings, privacy, safety, and local data.", systemImage: "gearshape.fill")
                    HumanizedSceneIllustration(scene: .groupChat, height: 160)

                    GlassPanel {
                        VStack(alignment: .leading, spacing: 14) {
                            Label("Subscription", systemImage: "crown.fill")
                                .font(.headline.weight(.bold))
                                .foregroundStyle(.white)
                            Text("Current plan: \(services.subscriptionStore.activePlan.displayName)")
                                .foregroundStyle(RoastLabTheme.textSecondary)
                            NavigationLink(value: AppRoute.paywall) {
                                Text("Manage Subscription")
                                    .font(.headline.weight(.bold))
                                    .foregroundStyle(RoastLabTheme.acidGreen)
                            }
                        }
                    }

                    StyleIntensityControls(style: $style, intensity: $intensity)
                        .onChange(of: style) { _, newValue in updateProfile(style: newValue, intensity: intensity) }
                        .onChange(of: intensity) { _, newValue in updateProfile(style: style, intensity: newValue) }

                    GlassPanel {
                        VStack(alignment: .leading, spacing: 14) {
                            Toggle("Voice previews", isOn: $voicePreviewsEnabled)
                                .tint(RoastLabTheme.hotPink)
                            Toggle("Mock AI enabled", isOn: .constant(true))
                                .tint(RoastLabTheme.acidGreen)
                            Text("Remote AI can be connected in AppServices when your production roast endpoint is ready.")
                                .font(.caption)
                                .foregroundStyle(RoastLabTheme.textSecondary)
                        }
                    }

                    GlassPanel {
                        VStack(alignment: .leading, spacing: 12) {
                            SectionHeader(title: "Safety Guidelines", subtitle: "Comedic roasts only. No hate speech, harassment, threats, sexual abuse content, protected-class attacks, bullying minors, self-harm, or extremist content.", systemImage: "checkmark.shield.fill")
                            Link("Privacy Policy", destination: URL(string: "https://github.com/lanray07/RoastLab-AI/blob/main/PRIVACY.md")!)
                            Link("Terms of Use", destination: URL(string: "https://github.com/lanray07/RoastLab-AI")!)
                        }
                        .foregroundStyle(RoastLabTheme.electricBlue)
                    }

                    GlassPanel {
                        VStack(alignment: .leading, spacing: 12) {
                            SectionHeader(title: "Placeholders", subtitle: nil, systemImage: "shippingbox.fill")
                            NavigationLink("WidgetKit placeholder", value: AppRoute.widgets)
                            NavigationLink("Apple Watch placeholder", value: AppRoute.watch)
                        }
                        .font(.headline.weight(.bold))
                        .foregroundStyle(.white)
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
                .padding(20)
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
            style = profile.resolvedHumorStyle
            intensity = profile.resolvedRoastIntensity
        } else if let profile = profiles.first {
            style = profile.resolvedHumorStyle
            intensity = profile.resolvedRoastIntensity
        }

        if subscriptions.isEmpty {
            modelContext.insert(SubscriptionState(plan: .free, isActive: false))
        }

        services.comedyPersona.seedDefaultPersonas(in: modelContext, existing: personas)
        try? modelContext.save()
    }

    private func updateProfile(style: HumorStyle, intensity: RoastIntensity) {
        guard let profile = profiles.first else { return }
        profile.humorStyle = style.rawValue
        profile.roastIntensity = intensity.rawValue
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
        hasCompletedOnboarding = false
    }
}

@ViewBuilder
private func generatorScreen<Content: View>(title: String, subtitle: String, @ViewBuilder content: () -> Content) -> some View {
    RoastLabBackground {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                SectionHeader(title: title, subtitle: subtitle, systemImage: "sparkles")
                HumanizedSceneIllustration(scene: sceneForTitle(title), height: 176)
                content()
            }
            .padding(20)
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

private func placeholderScreen(title: String, subtitle: String, icon: String, rows: [String]) -> some View {
    RoastLabBackground {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                SectionHeader(title: title, subtitle: subtitle, systemImage: icon)
                HumanizedSceneIllustration(scene: .audience, height: 170)
                ForEach(rows, id: \.self) { row in
                    GlassPanel {
                        Label(row, systemImage: "checkmark.circle.fill")
                            .font(.headline.weight(.bold))
                            .foregroundStyle(.white)
                    }
                }
            }
            .padding(20)
        }
    }
    .navigationTitle(title)
    .navigationBarTitleDisplayMode(.inline)
}
