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
        case .analyzing:          
            return "Analyzing prompt"
        case .composing:          
            return "Composing melody"
        case .addingInstruments:  
            return "Adding instruments"
        case .finalizing:         
            return "Finalizing track"
        }
    }

    static func from(progress: Double) -> LoadingStage {
        switch progress {
        case ..<0.26:
            return .analyzing
        case ..<0.58:
            return .composing
        case ..<0.85:
            return .addingInstruments
        default:
            return .finalizing
        }
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

