# MusicGPT - AI Music Generation App

A modern iOS music generation app built with SwiftUI. Create custom music by describing it in natural language, manage your music library, and enjoy seamless playback with an elegant floating player interface.

## Demo Video
[![Watch the video](https://img.youtube.com/vi/VIDEO_ID/0.jpg)](https://www.youtube.com/shorts/7IRbJfiQbkU)


## Tech Stack

- **Language**: Swift 5.7+
- **Framework**: SwiftUI
- **iOS Target**: 16.0+
- **Architecture**: MVVM with Combine publishers
- **Additional Tools**: Canvas for 60fps animations, TimelineView for real-time effects

## How to Run

### Prerequisites
- Xcode 14.0+ with iOS 16.0 SDK
- macOS 12+ to run Xcode

### Build & Run

```bash
# Open the project
open MusicCreationApp/MusicCreationApp.xcodeproj

# Run on simulator
xcodebuild -scheme MusicCreationApp -destination 'generic/platform=iOS Simulator' run

# Or use Cmd+R in Xcode
```

## Architecture Overview

### Project Structure

```
Views/
├── ContentView.swift              # Root view with tab navigation
├── MusicCreationView.swift         # Main creation screen
├── MusicGenerationFlowView.swift   # Creation pill & input UI
├── GeneratedTrackItemView.swift    # Track card with progress
├── OtherTabsView.swift             # Secondary screens
└── Components/
    ├── FloatingPlayerView.swift    # Draggable player
    ├── MusicItemView.swift         # Library track display
    ├── CustomCreationShape.swift   # Custom icon (dual-shape home icon)
    ├── CustomTabBar.swift          # Bottom navigation
    └── HeaderView.swift            # App header

ViewModels/
└── MusicCreationViewModel.swift    # Combines generation & library data

Managers/
├── GenerationManager.swift         # Simulates music generation
├── PlayerManager.swift             # Playback state management
└── TracksStore.swift               # Music library data store

Models/
├── GeneratedTrack.swift            # AI-generated track model
└── MusicTrack.swift                # Library track model

Utility/
├── AppColors.swift                 # Color definitions
├── AppText.swift                   # Typography
├── LiquidGlassBackground.swift     # Glass effect background
└── TabBarHeightKey.swift          # Safe area preference key
```

### Data Flow

```
GenerationManager (state) → MusicCreationViewModel (combines) 
  → MusicCreationView (displays) → GeneratedTrackItemView (cells)

PlayerManager (state) → ContentView → FloatingPlayerView (display)
```

## Key Components

### GenerationManager
Handles AI music simulation with real-time progress tracking (0→1.0 with easing), stage transitions, and completed tracks storage.

### PlayerManager
Manages playback state with current track tracking, player visibility, play/pause toggling, and proper state reset on dismiss.

### MusicCreationViewModel
Reactive data composition that merges generating, generated, and library tracks while updating based on manager state changes.

## Animation Decisions

### Timing & Easing
- **Spring Animations**: Primary choice for natural motion (response: 0.4-0.5s, dampingFraction: 0.78-0.80)
- **Ease-in-out**: Used for morph transitions (0.38s duration)
- **Linear**: Progress updates (5-50ms for smooth bars)
- **Repeat Forever**: Shimmer and pulse effects

### View Transitions
- **Generated Tracks**: Scale(0.96) + opacity on insertion
- **Generating Tracks**: Slide + opacity combined
- **Player**: Bottom edge slide + opacity (asymmetric in/out)
- **Textfield Input**: Matched geometry morph from pill to expanded state

### Real-time Effects (60fps)
- **Water Fill**: TimelineView animates 2-layer sine waves for progressive fill
- **Waveform Bars**: Independent spring animations with staggered delays
- **Rotating Border**: AngularGradient driven by continuous timeline updates
- **Shimmer Glow**: Linear infinite animation across gradient background


## Custom UI Elements

The home tab icon (`TwoCreationIconView`) uses a custom Swift UIView subclass that renders:
- Primary larger custom shape
- Secondary smaller custom shape at offset (-10, +10)
- Animated selection state with color fill
- Smooth morphing between states
