//
//  PlayerManager.swift
//  MusicCreationApp
//
//  Created by Sabal on 2/26/26.
//

import Foundation
import SwiftUI
import Combine

/// Injected at the root via environmentObject so any view in the tree can play a track or dismiss the player without prop drilling.
final class PlayerManager: ObservableObject {
    
    @Published private(set) var currentTrack: MusicTrack?
    @Published private(set) var isPlayerVisible: Bool = false
    @Published var isPlaying: Bool = false
    @Published var progress: Double = 0.0

    func play(_ track: MusicTrack) {
        if currentTrack == track {
            isPlaying.toggle()
        } else {
            currentTrack = track
            isPlaying = true
            progress = 0.0
            // thats why ContentView wraps this in withAnimation.
            isPlayerVisible = true
        }
    }

    /// the caller is responsible for driving the exit animation before invoking this.
    func dismissWithoutAnimation() {
        var transaction = Transaction()
        transaction.disablesAnimations = true
        withTransaction(transaction) {
            isPlayerVisible = false
        }
    }

    func skipForward() {
        
    }

    func skipBackward() {
        
    }
}
