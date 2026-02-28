//
//  MusicCreationView.swift
//  MusicCreationApp
//
//  Created by Sabal on 2/25/26.
//

import SwiftUI

struct MusicCreationView: View {
    
    @EnvironmentObject private var playerManager: PlayerManager

    var body: some View {

        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                ForEach(MusicTrack.sampleTracks) { track in
                    MusicItemView(track: track) {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.78)) {
                            playerManager.play(track)
                        }
                    }
                }
            }
            .padding(.horizontal)
            // for scrolling till bottom part
            .padding(.bottom, playerManager.isPlayerVisible ? 120 : 0)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    MusicCreationView()
}
