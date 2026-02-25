//
//  ContentView.swift
//  MusicCreationApp
//
//  Created by Sabal on 2/25/26.
//

import SwiftUI
import UIKit

struct ContentView: View {
    @State private var selectedTab = 0

    var body: some View {
        ZStack(alignment: .bottom) {
            
            // MARK: - Content
            Group {
                switch selectedTab {
                case 0: MusicCreationView()
                case 1: OtherTabsView(screenType: .search)
                case 2: OtherTabsView(screenType: .library)
                case 3: OtherTabsView(screenType: .profile)
                default: MusicCreationView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black)
            .ignoresSafeArea()
            
            
            // MARK: - Tab Bar
            CustomTabBar(selectedTab: $selectedTab)
        }
    }
}

#Preview {
    ContentView()
}
