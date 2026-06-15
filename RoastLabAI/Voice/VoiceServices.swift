import AVFoundation
import Combine
import Foundation
import Speech
import SwiftUI

enum VoiceServiceError: LocalizedError {
    case permissionDenied
    case recognizerUnavailable

    var errorDescription: String? {
        switch self {
        case .permissionDenied:
            "Speech or microphone permission is required for live voice roasts."
        case .recognizerUnavailable:
            "Speech recognition is unavailable on this device right now."
        }
    }
}

@MainActor
final class SpeechRecognitionService: NSObject, ObservableObject {
    @Published var transcript = ""
    @Published var authorizationStatus: SFSpeechRecognizerAuthorizationStatus = .notDetermined
    @Published var isRecording = false
    @Published var partialStatus = "Ready"

    private let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "en_GB"))
    private let audioEngine = AVAudioEngine()
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?

    func requestAuthorization() async -> Bool {
        let status = await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                continuation.resume(returning: status)
            }
        }
        authorizationStatus = status
        return status == .authorized
    }

    func start() async throws {
        if authorizationStatus != .authorized {
            guard await requestAuthorization() else { throw VoiceServiceError.permissionDenied }
        }
        try startEngine()
    }

    func pause() {
        stop(keepTranscript: true)
        partialStatus = "Paused"
    }

    func resume() async throws {
        try await start()
    }

    func stop(keepTranscript: Bool = true) {
        if audioEngine.isRunning {
            audioEngine.stop()
            audioEngine.inputNode.removeTap(onBus: 0)
        }
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        recognitionRequest = nil
        recognitionTask = nil
        isRecording = false
        partialStatus = keepTranscript ? "Stopped" : "Ready"
        if !keepTranscript {
            transcript = ""
        }
    }

    func insertMockTranscript() {
        transcript = "I tried to explain my productivity system and accidentally invented a calendar with side quests."
        partialStatus = "Mock transcript loaded"
    }

    private func startEngine() throws {
        stop(keepTranscript: true)
        guard let recognizer, recognizer.isAvailable else { throw VoiceServiceError.recognizerUnavailable }

        let request = SFSpeechAudioBufferRecognitionRequest()
        request.shouldReportPartialResults = true
        recognitionRequest = request

        let inputNode = audioEngine.inputNode
        let format = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1_024, format: format) { buffer, _ in
            request.append(buffer)
        }

        audioEngine.prepare()
        try audioEngine.start()
        isRecording = true
        partialStatus = "Listening"

        recognitionTask = recognizer.recognitionTask(with: request) { [weak self] result, error in
            Task { @MainActor in
                if let result {
                    self?.transcript = result.bestTranscription.formattedString
                    self?.partialStatus = result.isFinal ? "Final transcript" : "Live transcript"
                }
                if error != nil {
                    self?.stop(keepTranscript: true)
                }
            }
        }
    }
}

@MainActor
final class VoiceRecordingService: ObservableObject {
    @Published var isRecording = false
    @Published var recordingURL: URL?

    private var recorder: AVAudioRecorder?

    func startRecording() throws {
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.playAndRecord, mode: .spokenAudio, options: [.allowBluetooth, .defaultToSpeaker])
        try audioSession.setActive(true)

        let url = FileManager.default.temporaryDirectory.appendingPathComponent("roastlab-voice-\(UUID().uuidString).m4a")
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44_100,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        recorder = try AVAudioRecorder(url: url, settings: settings)
        recorder?.record()
        recordingURL = url
        isRecording = true
    }

    func stopRecording() {
        recorder?.stop()
        recorder = nil
        isRecording = false
    }
}

@MainActor
final class WaveformAnimationManager: ObservableObject {
    @Published var levels: [CGFloat] = Array(repeating: 0.25, count: 36)

    private var timer: Timer?

    func start() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.08, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.levels = (0..<36).map { index in
                    let wave = sin(Double(index) * 0.45 + Date().timeIntervalSince1970 * 5)
                    return CGFloat(max(0.18, min(1.0, 0.42 + wave * 0.32 + Double.random(in: 0...0.22))))
                }
            }
        }
    }

    func stop() {
        timer?.invalidate()
        timer = nil
        levels = Array(repeating: 0.25, count: 36)
    }
}

@MainActor
final class VoicePlaybackPreviewManager: NSObject, ObservableObject, AVSpeechSynthesizerDelegate {
    @Published var isPlaying = false
    @Published var selectedVoiceStyle = "AI Comedian"

    private let synthesizer = AVSpeechSynthesizer()

    override init() {
        super.init()
        synthesizer.delegate = self
    }

    func play(_ text: String) {
        stop()
        let utterance = AVSpeechUtterance(string: text.isEmpty ? "RoastLab AI is ready when the joke is." : text)
        utterance.rate = 0.48
        utterance.pitchMultiplier = 1.04
        utterance.voice = AVSpeechSynthesisVoice(language: "en-GB")
        isPlaying = true
        synthesizer.speak(utterance)
    }

    func stop() {
        synthesizer.stopSpeaking(at: .immediate)
        isPlaying = false
    }

    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        Task { @MainActor in
            self.isPlaying = false
        }
    }
}
