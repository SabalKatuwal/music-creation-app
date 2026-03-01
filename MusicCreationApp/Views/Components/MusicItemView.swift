//
//  MusicItemView.swift
//  MusicCreationApp
//
//  Created by Sabal on 2/25/26.
//

import SwiftUI

struct MusicItemView: View {

    let track: MusicTrack
    let onTap: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: onTap) {
            HStack(alignment: .center, spacing: 0) {
    
                thumbnail
                info
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .overlay {
                moreBottom
            }
        }
        .buttonStyle(PlainButtonStyle())
        ._onButtonGesture(pressing: { isPressed = $0 }, perform: {})
    }

    // MARK: Sub-views

    private var thumbnail: some View {
        ZStack(alignment: .bottomTrailing) {
            Image(track.imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 64, height: 64)
                .cornerRadius(16)
                .clipShape(RoundedRectangle(cornerRadius: 4))
            
            Text(track.duration)
                .font(.caption2)
                .padding(.horizontal, 4)
                .padding(.vertical, 2)
                .background {
                    RoundedRectangle(cornerRadius: 12)
                        .foregroundStyle(Color.black.opacity(0.4))
                }
                .padding(4)
        }
    }

    private var info: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(track.title)

            Text(track.subtitle)
                .font(.subheadline)
                .opacity(0.7)
                .lineLimit(1)
                .overlay(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.black.opacity(0), Color.black]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: 40)
                    .allowsHitTesting(false),
                    alignment: .trailing
                )
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 11.5)
    }
    
    private var moreBottom: some View {
        HStack {
            Spacer()
            Image(systemName: "ellipsis")
                .font(.headline)
                .opacity(0.7)
        }
    }
}

//#Preview {
//    MusicItemView(track: MusicTrack(imageName: "", title: "", subtitle: "", duration: "", accentColor: "", gradient: ""), onTap: {})
//}
