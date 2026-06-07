# RoastLab AI

RoastLab AI is a premium SwiftUI iOS app scaffold for playful, safe comedy roast generation. Mock AI is enabled by default, with a `RemoteAIService` placeholder for `https://YOUR_BACKEND_URL.com/roastlab-ai`.

## Build

Open `RoastLabAI.xcodeproj` in Xcode 15 or newer, select the shared `RoastLabAI` scheme, and run on an iOS 17+ simulator or device.

Command line build on macOS:

```sh
xcodebuild -project RoastLabAI.xcodeproj -scheme RoastLabAI -destination 'platform=iOS Simulator,name=iPhone 15' build
```

## Architecture

- SwiftUI app lifecycle with `NavigationStack` and tab navigation.
- MVVM view models for onboarding, generation flows, and dashboard scoring.
- SwiftData models for profiles, roasts, transcripts, battles, clapbacks, personas, and subscription state.
- StoreKit 2 subscription scaffolding with mock activation for local development.
- Speech-to-text, recording, waveform animation, and voice playback placeholders.
- Photo library and camera capture support with mock image analysis.
- Swift Charts analytics, native share sheet, WidgetKit placeholder, and Apple Watch placeholder.
