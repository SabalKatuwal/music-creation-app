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
                .font(AppText.smallLabel())
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
                .font(AppText.title())
                .lineLimit(1)
                .foregroundStyle(AppText.primary)

            Text(track.subtitle)
                .font(AppText.subtitle())
                .foregroundStyle(AppText.secondary)
                .lineLimit(1)
                .overlay(
                    LinearGradient(
                        gradient: Gradient(colors: [AppColors.black.opacity(0), AppColors.black]),
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
                .foregroundStyle(AppText.secondary)
        }
    }
}

//#Preview {
//    MusicItemView(track: MusicTrack(imageName: "", title: "", subtitle: "", duration: "", accentColor: "", gradient: ""), onTap: {})
//}

