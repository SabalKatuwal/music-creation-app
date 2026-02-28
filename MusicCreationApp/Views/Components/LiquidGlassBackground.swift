//
//  LiquidGlassBackground.swift
//  MusicCreationApp
//
//  Created by Sabal on 2/26/26.
//

import SwiftUI

struct LiquidGlassBackground: View {
    let accentColor: Color

    var body: some View {
        ZStack {
            Rectangle()
                .fill(.ultraThinMaterial)

            // a micro texture noise for depth
            Rectangle()
                .fill(Color.white.opacity(0.04))

            // specular highlight that brings light catching the glass at the top just for feel
//            LinearGradient(
//                colors: [Color.white.opacity(0.12), Color.clear],
//                startPoint: .top,
//                endPoint: UnitPoint(x: 0.5, y: 0.4)
//            )
        }
    }
}
