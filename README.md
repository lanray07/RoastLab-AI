# RoastLab AI

RoastLab AI is a premium SwiftUI iOS app for playful, safe comedy roast generation, voice roasts, roast battles, clapbacks, share cards, and creator-friendly comedy prompts.

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
- StoreKit 2 subscription handling with restore support and review-ready legal links.
- Speech-to-text, recording, waveform animation, and voice playback previews.
- Photo library and camera capture support with local image prompt preparation.
- Swift Charts analytics and native share sheet support.
