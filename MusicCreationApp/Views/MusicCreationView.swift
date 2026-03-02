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

    @EnvironmentObject private var playerManager: PlayerManager

    let store: TracksStore

    @StateObject private var viewModel: MusicCreationViewModel

    private let floatingPlayerHeight: CGFloat = 120

    init(floatingDragOffset: Binding<CGFloat>, tabBarHeight: CGFloat, store: TracksStore) {
        self._floatingDragOffset = floatingDragOffset
        self.tabBarHeight = tabBarHeight
        self.store = store
        _viewModel = StateObject(wrappedValue: MusicCreationViewModel(
            generationManager: GenerationManager(),
            store: store
        ))
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {

                    ForEach(Array(viewModel.listItems.enumerated()), id: \.element.id) { index, item in
                        switch item {
                        case .generating(let active, let progress, let stage):
                            GeneratedTrackItemView(
                                track: active,
                                progress: progress,
                                stage: stage,
                                isCompleted: false
                            )
                            .padding(.horizontal)
                            .transition(.asymmetric(
                                insertion: .move(edge: .top).combined(with: .opacity),
                                removal:   .opacity
                            ))

                        case .generated(let track):
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
                                // Play the corresponding library item (with same id)
                                if let lib = store.tracks.first(where: { $0.id == track.id }) {
                                    withAnimation(.spring(response: 0.5, dampingFraction: 0.78)) {
                                        playerManager.play(lib)
                                    }
                                } else {
                                    // Fallback: insert then play
                                    let lib = store.addGenerated(track)
                                    withAnimation(.spring(response: 0.5, dampingFraction: 0.78)) {
                                        playerManager.play(lib)
                                    }
                                }
                            }

                        case .library(let track):
                            MusicItemView(track: track) {
                                withAnimation(.spring(response: 0.5, dampingFraction: 0.78)) {
                                    playerManager.play(track)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                .padding(.top, 8)
                .padding(.bottom, bottomScrollPadding)
                .animation(
                    .spring(response: 0.48, dampingFraction: 0.80),
                    value: viewModel.generationManager.isGenerating
                )
                .animation(
                    .spring(response: 0.48, dampingFraction: 0.80),
                    value: viewModel.generationManager.completedTracks.count
                )
            }
            .frame(maxWidth: .infinity)

            MusicGenerationFlowView(
                generationManager: viewModel.generationManager,
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
            .padding(.leading, 88)
    }

    private var bottomScrollPadding: CGFloat {
        let pillClearance: CGFloat = 72
        let playerClearance: CGFloat = playerManager.isPlayerVisible ? floatingPlayerHeight + 12 : 0
        return pillClearance + playerClearance
    }
}
