//
//  GeneratedTrack.swift
//  MusicCreationApp
//
//  Created by Gurzu on 02/03/2026.
//

import Foundation

// MARK: - GeneratedTrack

struct GeneratedTrack: Identifiable, Equatable {
    let id = UUID()
    let title: String
    let subtitle: String
    let duration: TimeInterval

    static func fromPrompt(_ prompt: String) -> GeneratedTrack {

        // Basic cleanup
        let cleanedWords = prompt
            .lowercased()
            .split(separator: " ")
            .map { $0.trimmingCharacters(in: .punctuationCharacters) }

        // Simple filler words to ignore
        let stopWords: Set<String> = [
            "a","an","the","make","create","generate", "that","feels", "write","produce","some","with","and", "for","of","in","on","at","i","want","to", "like"
        ]

        let meaningfulWords = cleanedWords.filter {
            $0.count > 2 && !stopWords.contains(String($0))
        }

        // Title = first 1–2 meaningful words
        let titleWords = meaningfulWords.prefix(2)
        let title = titleWords.isEmpty
            ? "Untitled"
            : titleWords.map { $0.capitalized }.joined(separator: " ")

        // Subtitle = remaining words
        let subtitleWords = meaningfulWords.dropFirst(2)
        let subtitle = subtitleWords.isEmpty
            ? "AI Generated Content"
            : subtitleWords.map { $0.capitalized }.joined(separator: " ")

        return GeneratedTrack(
            title: title,
            subtitle: subtitle,
            duration: Double.random(in: 120...240)
        )
    }
}
