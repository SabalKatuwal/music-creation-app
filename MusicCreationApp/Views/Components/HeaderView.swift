//
//  HeaderView.swift
//  MusicCreationApp
//
//  Created by Sabal on 2/25/26.
//

import SwiftUI

struct HeaderView: View {
    
    var body: some View {
        HStack {
            Image("Subtract")
                .resizable()
                .scaledToFit()
                .frame(width: 36, height: 35)
            
            Text("MusicGPT")
                .font(.headline)
            Spacer()
        }
        // because this was in the design
        .padding(.leading, 16.5)
        .padding(.trailing, 15.5)
        .padding(.vertical, 16)
    }
}

#Preview {
    HeaderView()
}
