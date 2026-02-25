//
//  MusicItemView.swift
//  MusicCreationApp
//
//  Created by Sabal on 2/25/26.
//

import SwiftUI

struct MusicItemView: View {
    let imageName: String
    let title: String
    let subtitle: String
    
    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            
            Image(imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 64, height: 64)
            
            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                
                Text(subtitle)
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
        .frame(maxWidth: .infinity, alignment: .leading)
        .overlay {
            HStack {
                Spacer()
                Image(systemName: "ellipsis")
                    .font(.headline)
                    .opacity(0.7)
            }

        }
    }
}

#Preview {
    MusicItemView(imageName: "VoicePic3", title: "Balenciaga", subtitle: "Generate a poem about a lost")
}
