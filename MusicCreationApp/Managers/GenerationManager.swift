//
//  GenerationManager.swift
//  MusicCreationApp
//
//  Created by Gurzu on 02/03/2026.
//

import SwiftUI

// MARK: - LoadingStage

enum LoadingStage: Equatable {
    case analyzing, composing, addingInstruments, finalizing

    var message: String {
        switch self {
        case .analyzing:          return "Analyzing prompt"
        case .composing:          return "Composing melody"
        case .addingInstruments:  return "Adding instruments"
        case .finalizing:         return "Finalizing track"
        }
    }

    static func from(progress: Double) -> LoadingStage {
        switch progress {
        case ..<0.26: return .analyzing
        case ..<0.58: return .composing
        case ..<0.85: return .addingInstruments
        default:      return .finalizing
        }
    }
}


// MARK: - GeneratedTrack

struct GeneratedTrack: Identifiable, Equatable {
    let id: UUID
    let title: String
    let tagline: String
    let bpm: Int
    let key: String
    let genre: String
    let duration: TimeInterval
    let gradient: LinearGradient
    let accentColor: Color
    let accentColorSecondary: Color

    static func == (lhs: GeneratedTrack, rhs: GeneratedTrack) -> Bool { lhs.id == rhs.id }

    static func fromPrompt(_ prompt: String) -> GeneratedTrack {
        struct Preset {
            let title: String; let tagline: String; let genre: String; let key: String; let bpm: Int
            let accent: Color; let accent2: Color; let colors: [Color]
        }
        let presets: [Preset] = [
            Preset(title: "Neon Echoes",       tagline: "Electronic ambient with driving pulse",       genre: "Electronic",  key: "F# Minor", bpm: 128, accent: Color(red:0.35,green:0.55,blue:1.00), accent2: Color(red:0.65,green:0.30,blue:1.00), colors: [Color(red:0.18,green:0.25,blue:0.85), Color(red:0.45,green:0.10,blue:0.75)]),
            Preset(title: "Golden Drift",      tagline: "Warm acoustic with orchestral swells",        genre: "Cinematic",   key: "D Major",  bpm: 72,  accent: Color(red:1.00,green:0.72,blue:0.20), accent2: Color(red:1.00,green:0.45,blue:0.15), colors: [Color(red:0.90,green:0.52,blue:0.08), Color(red:0.75,green:0.28,blue:0.18)]),
            Preset(title: "Midnight Protocol", tagline: "Dark synthwave, cinematic tension",           genre: "Synthwave",   key: "B Minor",  bpm: 96,  accent: Color(red:0.90,green:0.18,blue:0.40), accent2: Color(red:0.55,green:0.05,blue:0.75), colors: [Color(red:0.70,green:0.08,blue:0.28), Color(red:0.38,green:0.04,blue:0.52)]),
            Preset(title: "Coral Resonance",   tagline: "Upbeat tropical with jazz undertones",       genre: "Jazz-Pop",    key: "G Major",  bpm: 108, accent: Color(red:1.00,green:0.50,blue:0.28), accent2: Color(red:0.95,green:0.28,blue:0.52), colors: [Color(red:0.88,green:0.38,blue:0.18), Color(red:0.68,green:0.18,blue:0.40)]),
            Preset(title: "Quantum Bloom",     tagline: "Experimental glitch with melodic resolve",   genre: "Experimental",key: "A Minor",  bpm: 140, accent: Color(red:0.15,green:0.88,blue:0.58), accent2: Color(red:0.05,green:0.50,blue:0.88), colors: [Color(red:0.08,green:0.65,blue:0.48), Color(red:0.04,green:0.38,blue:0.68)]),
            Preset(title: "Velvet Static",     tagline: "Lo-fi hip hop with soulful chord progressions", genre: "Lo-fi",  key: "Eb Major", bpm: 85,  accent: Color(red:0.75,green:0.55,blue:1.00), accent2: Color(red:0.45,green:0.28,blue:0.88), colors: [Color(red:0.55,green:0.28,blue:0.82), Color(red:0.28,green:0.18,blue:0.65)]),
        ]

        let index = abs(prompt.hashValue) % presets.count
        let p = presets[index]

        let stopWords: Set<String> = ["a","an","the","make","create","generate","write","produce","some","with","and","for","of","in","on","at","i","want"]
        let derived = prompt
            .split(separator: " ")
            .map { $0.trimmingCharacters(in: .punctuationCharacters) }
            .first { $0.count > 3 && !stopWords.contains($0.lowercased()) }?
            .capitalized

        let suffixes = ["Dreams", "Waves", "Pulse", "Signal", "Drift", "Veil", "Rush", "Arc"]
        let finalTitle = derived.map { "\($0) \(suffixes[abs(prompt.hashValue) % suffixes.count])" } ?? p.title

        return GeneratedTrack(
            id: UUID(),
            title: finalTitle,
            tagline: p.tagline,
            bpm: p.bpm,
            key: p.key,
            genre: p.genre,
            duration: Double.random(in: 155...252),
            gradient: LinearGradient(colors: p.colors, startPoint: .topLeading, endPoint: .bottomTrailing),
            accentColor: p.accent,
            accentColorSecondary: p.accent2
        )
    }
}

// MARK: - GenerationManager

final class GenerationManager: ObservableObject {

    // MARK: Published

    /// The track that is currently being generated (pre-computed from prompt).
    @Published private(set) var activeTrack: GeneratedTrack? = nil
    @Published private(set) var isGenerating: Bool = false
    @Published private(set) var progress: Double = 0.0
    @Published private(set) var stage: LoadingStage = .analyzing
    @Published private(set) var completedTracks: [GeneratedTrack] = []

    // MARK: Private

    private var generationTask: Task<Void, Never>?
    private let totalDuration: Double = 4.0

    // MARK: API

    func generate(prompt: String) {
        // Pre-compute the result now so thumbnail gradient is stable during load
        let track = GeneratedTrack.fromPrompt(prompt)
        activeTrack  = track
        isGenerating = true
        progress     = 0.0
        stage        = .analyzing

        generationTask?.cancel()
        generationTask = Task { [weak self] in
            await self?.runLoadingSequence()
        }
    }

    func cancel() {
        generationTask?.cancel()
        generationTask = nil
        activeTrack  = nil
        isGenerating = false
        progress     = 0.0
    }

    // MARK: Private

    @MainActor
    private func runLoadingSequence() async {
        let startTime = Date.now

        while !Task.isCancelled {
            try? await Task.sleep(nanoseconds: 16_000_000) // ~60fps

            let elapsed = Date.now.timeIntervalSince(startTime)
            let raw = min(elapsed / totalDuration, 1.0)

            // Ease-in-out-quart: snappy start, satisfying deceleration
            let eased: Double = raw < 0.5
                ? 8 * raw * raw * raw * raw
                : 1 - pow(-2 * raw + 2, 4) / 2

            withAnimation(.linear(duration: 0.02)) {
                progress = eased
            }

            // Stage transitions
            let newStage = LoadingStage.from(progress: eased)
            if newStage != stage {
                withAnimation(.easeInOut(duration: 0.35)) { stage = newStage }
            }

            if eased >= 1.0 { break }
        }

        guard !Task.isCancelled, let track = activeTrack else { return }

        // Brief hold at 100% before completing
        try? await Task.sleep(nanoseconds: 420_000_000)
        guard !Task.isCancelled else { return }

        withAnimation(.spring(response: 0.55, dampingFraction: 0.78)) {
            completedTracks.insert(track, at: 0)
            isGenerating = false
            activeTrack  = nil
            progress     = 0.0
        }
    }
}

