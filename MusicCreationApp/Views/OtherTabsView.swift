//
//  OtherTabsView.swift
//  MusicCreationApp
//
//  Created by Sabal on 2/25/26.
//

import SwiftUI

enum OtherScreens: String {
    case search
    case library
    case profile
    
    var description: String {
        return self.rawValue + " screen"
    }
}

struct OtherTabsView: View {
    var screenType: OtherScreens
    
    var body: some View {
        Text(screenType.description)
    }
}

#Preview {
    OtherTabsView(screenType: OtherScreens.library)
}
