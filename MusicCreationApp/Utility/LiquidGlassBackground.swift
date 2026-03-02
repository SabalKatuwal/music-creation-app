//
//  LiquidGlassBackground.swift
//  MusicCreationApp
//
//  Created by Sabal on 2/26/26.
//

import SwiftUI

struct LiquidGlassBackground: View {

    var body: some View {
        ZStack {
            Rectangle()
                .fill(.ultraThinMaterial)

            // a micro texture noise for depth
            Rectangle()
                .fill(Color.white.opacity(0.04))
        }
    }
}
