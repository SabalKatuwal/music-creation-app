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
            VStack(spacing: 20) {
                
                ForEach(0..<20) { index in
                    Text("Item \(index)")
                        .foregroundColor(.white)
                }
                
            }
            .padding()
        }
        .frame(maxWidth: .infinity)
        .background(Color.gray)
    }
}

#Preview {
    MusicCreationView()
}
