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
    let accentColor: Color
    let gradient: LinearGradient

    init(
        id: UUID = UUID(),
        imageName: String,
        title: String,
        subtitle: String,
        duration: String,
        accentColor: Color,
        gradient: LinearGradient
    ) {
        self.id = id
        self.imageName = imageName
        self.title = title
        self.subtitle = subtitle
        self.duration = duration
        self.accentColor = accentColor
        self.gradient = gradient
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
            duration: "4:12",
            accentColor: Color(red: 0.4, green: 0.6, blue: 1.0),
            gradient: LinearGradient(
                colors: [Color(red: 0.2, green: 0.3, blue: 0.9), Color(red: 0.5, green: 0.2, blue: 0.8)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
        ),
        MusicTrack(
            imageName: "VoicePic1",
            title: "Bam Bam",
            subtitle: "Generate a script for a play about the power",
            duration: "5:44",
            accentColor: Color(red: 1.0, green: 0.7, blue: 0.2),
            gradient: LinearGradient(
                colors: [Color(red: 0.9, green: 0.5, blue: 0.1), Color(red: 0.8, green: 0.3, blue: 0.3)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
        ),
        MusicTrack(
            imageName: "VoicePic2",
            title: "Enemy",
            subtitle: "Compose a poem about the meaning",
            duration: "3:58",
            accentColor: Color(red: 0.9, green: 0.2, blue: 0.35),
            gradient: LinearGradient(
                colors: [Color(red: 0.8, green: 0.1, blue: 0.3), Color(red: 0.5, green: 0.05, blue: 0.5)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
        ),
        MusicTrack(
            imageName: "VoicePic3",
            title: "Balenciaga",
            subtitle: "Generate a poem about a lost",
            duration: "4:31",
            accentColor: Color(red: 0.2, green: 0.8, blue: 0.5),
            gradient: LinearGradient(
                colors: [Color(red: 0.1, green: 0.6, blue: 0.4), Color(red: 0.05, green: 0.4, blue: 0.3)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
        ),
        MusicTrack(
            imageName: "VoicePic3",
            title: "Balenciaga",
            subtitle: "Generate a poem about a lost",
            duration: "4:31",
            accentColor: Color(red: 0.2, green: 0.8, blue: 0.5),
            gradient: LinearGradient(
                colors: [Color(red: 0.1, green: 0.6, blue: 0.4), Color(red: 0.05, green: 0.4, blue: 0.3)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
        ),
        MusicTrack(
            imageName: "VoicePic3",
            title: "Balenciaga",
            subtitle: "Generate a poem about a lost",
            duration: "4:31",
            accentColor: Color(red: 0.2, green: 0.8, blue: 0.5),
            gradient: LinearGradient(
                colors: [Color(red: 0.1, green: 0.6, blue: 0.4), Color(red: 0.05, green: 0.4, blue: 0.3)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
        ),
        MusicTrack(
            imageName: "VoicePic3",
            title: "Balenciaga",
            subtitle: "Generate a poem about a lost",
            duration: "4:31",
            accentColor: Color(red: 0.2, green: 0.8, blue: 0.5),
            gradient: LinearGradient(
                colors: [Color(red: 0.1, green: 0.6, blue: 0.4), Color(red: 0.05, green: 0.4, blue: 0.3)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
        ),
        MusicTrack(
            imageName: "VoicePic3",
            title: "Balenciaga",
            subtitle: "Generate a poem about a lost",
            duration: "4:31",
            accentColor: Color(red: 0.2, green: 0.8, blue: 0.5),
            gradient: LinearGradient(
                colors: [Color(red: 0.1, green: 0.6, blue: 0.4), Color(red: 0.05, green: 0.4, blue: 0.3)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
        ),
        MusicTrack(
            imageName: "VoicePic3",
            title: "Balenciaga",
            subtitle: "Generate a poem about a lost",
            duration: "4:31",
            accentColor: Color(red: 0.2, green: 0.8, blue: 0.5),
            gradient: LinearGradient(
                colors: [Color(red: 0.1, green: 0.6, blue: 0.4), Color(red: 0.05, green: 0.4, blue: 0.3)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
        ),
    ]
}
