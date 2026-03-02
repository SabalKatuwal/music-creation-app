import Foundation
import SwiftUI
import Combine

final class TracksStore: ObservableObject {

    @Published private(set) var tracks: [MusicTrack]

    init(initial: [MusicTrack] = MusicTrack.sampleTracks) {
        self.tracks = initial
    }

    @discardableResult
    func addGenerated(_ generated: GeneratedTrack) -> MusicTrack {
        let images = ["VoicePic", "VoicePic1", "VoicePic2", "VoicePic3"]
        let imageName = images.randomElement() ?? "VoicePic"
        let music = MusicTrack(
            id: generated.id, // uses the same id so we can map back from UI rows
            imageName: imageName,
            title: generated.title,
            subtitle: generated.subtitle,
            duration: Self.formatDuration(generated.duration)
        )
        tracks.insert(music, at: 0)
        return music
    }

    // MARK: - Helpers

    private static func formatDuration(_ seconds: TimeInterval) -> String {
        let s = Int(seconds)
        return String(format: "%d:%02d", s / 60, s % 60)
    }
}
