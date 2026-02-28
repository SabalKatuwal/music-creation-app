//
//  FloatingPlayerView.swift
//  MusicCreationApp
//
//  Created by Sabal on 2/26/26.
//

import SwiftUI

struct FloatingPlayerView: View {

    @EnvironmentObject private var playerManager: PlayerManager

    // MARK: Private State

    @State private var dragOffset: CGFloat = 0
    @GestureState private var isDragging: Bool = false

    // MARK: Constants

    private let dismissThreshold: CGFloat = 80

    // MARK: Variables

    /// Normalised 0→1 value that drives all dismiss-progress visual changes.
    private var dismissProgress: Double {
        min(Double(max(0, dragOffset)) / Double(dismissThreshold), 1.0)
    }

    // MARK: Body

    var body: some View {
        if let track = playerManager.currentTrack {
            playerContent(for: track)
        }
    }

    // MARK: - Player Content

    @ViewBuilder
    private func playerContent(for track: MusicTrack) -> some View {
        VStack(spacing: 0) {
            dragHandle
            trackRow(for: track)
            progressBar(for: track)
        }
        .padding(.bottom, 14)
        .background(LiquidGlassBackground(accentColor: track.accentColor))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(glassStroke(dismissProgress: dismissProgress))
        .shadow(color: .black.opacity(0.45 - dismissProgress * 0.3), radius: 30, y: 10)
        .padding(.horizontal, 16)
        .offset(y: dragOffset)
        .opacity(1.0 - dismissProgress * 0.6)
        .scaleEffect(1.0 - dismissProgress * 0.03)
        .gesture(dismissGesture)
    }

    // MARK: - Sub-views

    private var dragHandle: some View {
        Capsule()
            .fill(Color.white.opacity(0.3 - dismissProgress * 0.3))
            .frame(width: 36, height: 4)
            .padding(.top, 10)
            .padding(.bottom, 12)
    }

    @ViewBuilder
    private func trackRow(for track: MusicTrack) -> some View {
        HStack(spacing: 12) {
            albumImage(for: track)
            trackInfo(for: track)
            Spacer()
            controls(for: track)
        }
        .padding(.horizontal, 16)
    }

    @ViewBuilder
    private func albumImage(for track: MusicTrack) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .frame(width: 56, height: 56)

            Image(track.imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 56, height: 56)
                .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .opacity(1.0 - dismissProgress *  0.6)
        .scaleEffect(playerManager.isPlaying ? 1.0 : 0.92)
        .animation(.spring(response: 0.35, dampingFraction: 0.65), value: playerManager.isPlaying)
    }

    @ViewBuilder
    private func trackInfo(for track: MusicTrack) -> some View {
        VStack(alignment: .leading) {
            Text(track.title)
                .font(.headline)
                .foregroundColor(.white.opacity(1.0 - dismissProgress * 0.6))
                .lineLimit(1)
        }
    }

    @ViewBuilder
    private func controls(for track: MusicTrack) -> some View {
        HStack(spacing: 16) {
            Button(action: playerManager.skipBackward) {
                Image(systemName: "backward.fill")
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.8 - dismissProgress * 0.6))
            }

            Button(action: { playerManager.isPlaying.toggle() }) {
                ZStack {
                    Image(systemName: playerManager.isPlaying ? "pause.fill" : "play.fill")
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.8 - dismissProgress * 0.6))
                        .offset(x: playerManager.isPlaying ? 0 : 1)
                }
            }

            Button(action: playerManager.skipForward) {
                Image(systemName: "forward.fill")
                    .font(.system(size: 18))
                    .foregroundColor(.white.opacity(0.8 - dismissProgress * 0.6))
            }
        }
    }

    @ViewBuilder
    private func progressBar(for track: MusicTrack) -> some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.white.opacity(0.12))
                    .frame(height: 3)

                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [track.accentColor, track.accentColor.opacity(0.6)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: geo.size.width * playerManager.progress, height: 3)
                    .animation(.linear(duration: 0.1), value: playerManager.progress)
            }
        }
        .frame(height: 3)
        .padding(.horizontal, 18)
        .padding(.top, 12)
    }

    private func glassStroke(dismissProgress: Double) -> some View {
        RoundedRectangle(cornerRadius: 20, style: .continuous)
            .stroke(
                LinearGradient(
                    colors: [
                        Color.white.opacity(0.25 - dismissProgress * 0.2),
                        Color.white.opacity(0.05)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                lineWidth: 1
            )
    }

    // MARK: - Gesture

    private var dismissGesture: some Gesture {
        DragGesture(minimumDistance: 8)
            .updating($isDragging) { _, state, _ in state = true }
            .onChanged { value in
                let translation = value.translation.height
                // Only allow downward drag; resist upward with rubber-band factor
                dragOffset = translation > 0 ? translation : translation * 0.1
            }
            .onEnded { value in
                let velocity = value.predictedEndTranslation.height - value.translation.height
                let shouldDismiss = dragOffset > dismissThreshold || velocity > 300

                if shouldDismiss {
                    // Animate the view sliding fully off-screen first…
                    withAnimation(.spring(response: 0.38, dampingFraction: 0.88)) {
                        dragOffset = 500
                    }
                    // …then silently remove it from the hierarchy without re-triggering
                    // the .transition removal, which would cause a double-dismiss artifact.
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.32) {
                        dragOffset = 0
                        playerManager.dismissWithoutAnimation()
                    }
                } else {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.78)) {
                        dragOffset = 0
                    }
                }
            }
    }
}
