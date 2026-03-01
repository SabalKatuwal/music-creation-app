//
//  MusicCreationView.swift
//  MusicCreationApp
//
//  Created by Sabal on 2/25/26.
//

import SwiftUI

struct MusicCreationView: View {
    @Binding var floatingDragOffset: CGFloat
    let tabBarHeight: CGFloat
    
    @State private var floatingPlayerHeight: CGFloat = 120
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
        .overlay {
            VStack {
                Spacer()
                
                HStack(spacing: 4) {
                    TwoCreationIconView(selectedTab: .constant(1), withColor: true)
                    Text("Create")
                        .font(.headline)
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.systemGray5))
                )
            }
            .padding(.bottom, 12 + (playerManager.isPlayerVisible ? floatingPlayerHeight : 0))
            .offset(
                y: min(floatingDragOffset, floatingPlayerHeight)
            )
        }
    }
}

//#Preview {
//    MusicCreationView(floatingDragOffset: .constant(10), tabBarHeight: 120)
//}
