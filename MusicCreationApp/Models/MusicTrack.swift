//
//  MusicTrack.swift
//  MusicCreationApp
//
//  Created by Sabal on 2/26/26.
//

import Foundation
import SwiftUI

struct MusicTrack: Identifiable, Equatable {
    let id: UUID
    let imageName: String
    let title: String
    let subtitle: String
    let duration: String

    init(
        id: UUID = UUID(),
        imageName: String,
        title: String,
        subtitle: String,
        duration: String
    ) {
        self.id = id
        self.imageName = imageName
        self.title = title
        self.subtitle = subtitle
        self.duration = duration
    }

    static func == (lhs: MusicTrack, rhs: MusicTrack) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Sample Data

extension MusicTrack {
    static let sampleTracks: [MusicTrack] = [
        MusicTrack(
            imageName: "VoicePic",
            title: "Language Training",
            subtitle: "Create a presentation that explains how large",
            duration: "4:12"
        ),
        MusicTrack(
            imageName: "VoicePic1",
            title: "Bam Bam",
            subtitle: "Generate a script for a play about the power",
            duration: "5:44"
        ),
        MusicTrack(
            imageName: "VoicePic2",
            title: "Enemy",
            subtitle: "Compose a poem about the meaning",
            duration: "3:58"
        ),
        MusicTrack(
            imageName: "VoicePic3",
            title: "Balenciaga",
            subtitle: "Generate a poem about a lost",
            duration: "4:31"
        )
    ]
}
