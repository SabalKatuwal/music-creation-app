//
//  MusicCreationView.swift
//  MusicCreationApp
//
//  Created by Sabal on 2/25/26.
//

import SwiftUI

struct MusicCreationView: View {
    var body: some View {

        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                MusicItemView(imageName: "VoicePic", title: "Language Training", subtitle: "Create a presentation that explains how large")
                
                MusicItemView(imageName: "VoicePic1", title: "Bam Bam", subtitle: "Generate a script for a play abou the power")
                
                MusicItemView(imageName: "VoicePic2", title: "Enemy", subtitle: "Compose a poem about the meaning")
                
                MusicItemView(imageName: "VoicePic3", title: "Balenciaga", subtitle: "Generate a poem about a lost")
            }
            .padding(.horizontal)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    MusicCreationView()
}
