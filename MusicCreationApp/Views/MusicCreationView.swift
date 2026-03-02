//
//  MusicCreationView.swift
//  MusicCreationApp
//
//  Created by Sabal on 2/25/26.
//

import SwiftUI

//struct MusicCreationView: View {
//    @Binding var floatingDragOffset: CGFloat
//    let tabBarHeight: CGFloat
//    
//    @State private var floatingPlayerHeight: CGFloat = 120
//    @EnvironmentObject private var playerManager: PlayerManager
//
//    var body: some View {
//
//        ZStack {
//            ScrollView {
//                VStack(alignment: .leading, spacing: 12) {
//                    ForEach(MusicTrack.sampleTracks) { track in
//                        MusicItemView(track: track) {
//                            withAnimation(.spring(response: 0.5, dampingFraction: 0.78)) {
//                                playerManager.play(track)
//                            }
//                        }
//                    }
//                }
//                .padding(.horizontal)
//                // for scrolling till bottom part
//                .padding(.bottom, playerManager.isPlayerVisible ? 120 : 0)
//            }
//            .frame(maxWidth: .infinity)
////            .overlay {
////                VStack {
////                    Spacer()
////                    
////                    HStack(spacing: 4) {
////                        TwoCreationIconView(selectedTab: .constant(1), withColor: true)
////                        Text("Create")
////                            .font(.headline)
////                    }
////                    .padding(.vertical, 8)
////                    .padding(.horizontal, 16)
////                    .background(
////                        RoundedRectangle(cornerRadius: 16)
////                            .fill(Color(.systemGray5))
////                    )
////                }
////                .padding(.bottom, 12 + (playerManager.isPlayerVisible ? floatingPlayerHeight : 0))
////                .offset(
////                    y: min(floatingDragOffset, floatingPlayerHeight)
////                )
////            }
//            
//            MusicGenerationFlowView(
//                floatingDragOffset: $floatingDragOffset,
//                isPlayerVisible: playerManager.isPlayerVisible,
//                floatingPlayerHeight: floatingPlayerHeight
//            )
//        }
//    }
//    private var bottomScrollPadding: CGFloat {
//            let base: CGFloat = 72  // space for the Create pill itself
//            let player: CGFloat = playerManager.isPlayerVisible ? floatingPlayerHeight + 12 : 0
//            return base + player
//        }
//}

//#Preview {
//    MusicCreationView(floatingDragOffset: .constant(10), tabBarHeight: 120)
//}


struct MusicCreationView: View {

    @Binding var floatingDragOffset: CGFloat
    let tabBarHeight: CGFloat

    @EnvironmentObject private var playerManager: PlayerManager

    /// Owns the full generation lifecycle
    @StateObject private var generationManager = GenerationManager()

    private let floatingPlayerHeight: CGFloat = 120

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {

                    // 1. In-progress generating item — inserted at top
                    if generationManager.isGenerating,
                       let active = generationManager.activeTrack {
                        GeneratedTrackItemView(
                            track: active,
                            progress: generationManager.progress,
                            stage: generationManager.stage,
                            isCompleted: false
                        )
                        .padding(.horizontal)
                        .transition(.asymmetric(
                            insertion: .move(edge: .top).combined(with: .opacity),
                            removal:   .opacity
                        ))

                        rowDivider
                    }

                    // 2. Completed generated tracks (newest first)
                    ForEach(generationManager.completedTracks) { track in
                        GeneratedTrackItemView(
                            track: track,
                            progress: 1.0,
                            stage: .finalizing,
                            isCompleted: true
                        )
                        .padding(.horizontal)
                        .transition(.asymmetric(
                            insertion: .scale(scale: 0.96).combined(with: .opacity),
                            removal:   .opacity
                        ))
                        .onTapGesture {

                        }

                        rowDivider
                    }

                    // 3. Existing tracks
                    ForEach(MusicTrack.sampleTracks) { track in
                        MusicItemView(track: track) {
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.78)) {
                                playerManager.play(track)
                            }
                        }
                        .padding(.horizontal)

                        if track.id != MusicTrack.sampleTracks.last?.id {
                            rowDivider
                        }
                    }
                }
                .padding(.top, 8)
                .padding(.bottom, bottomScrollPadding)
                .animation(
                    .spring(response: 0.48, dampingFraction: 0.80),
                    value: generationManager.isGenerating
                )
                .animation(
                    .spring(response: 0.48, dampingFraction: 0.80),
                    value: generationManager.completedTracks.count
                )
            }
            .frame(maxWidth: .infinity)
            .ignoresSafeArea(.keyboard, edges: .bottom)

            MusicGenerationFlowView(
                generationManager: generationManager,
                floatingDragOffset: $floatingDragOffset,
                isPlayerVisible: playerManager.isPlayerVisible,
                floatingPlayerHeight: floatingPlayerHeight
            )
        }
    }

    // MARK: - Helpers

    private var rowDivider: some View {
        Divider()
            .background(Color.white.opacity(0.06))
            .padding(.leading, 88) // aligns with text column (64 thumbnail + 12 padding + 12 left)
    }

    private var bottomScrollPadding: CGFloat {
        let pillClearance: CGFloat = 72
        let playerClearance: CGFloat = playerManager.isPlayerVisible ? floatingPlayerHeight + 12 : 0
        return pillClearance + playerClearance
    }
}
