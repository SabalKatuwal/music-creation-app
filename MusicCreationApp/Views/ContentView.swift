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
    @StateObject private var playerManager = PlayerManager()
    @StateObject private var tracksStore = TracksStore()
    @State private var tabBarHeight: CGFloat = 0 // to calculate height of tabbar and propagate above
    @State var floatingDragOffset: CGFloat = 0
    
    var body: some View {
        
        ZStack(alignment: .bottom) {
                    
            VStack(spacing: 0) {
                
                // MARK: - Header
                HeaderView()
                tabContent
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .padding(.bottom, tabBarHeight)
            
            // MARK: - Tab Bar
            CustomTabBar(selectedTab: $selectedTab)
                .background(
                    GeometryReader { geo in
                        Color.clear
                            .preference(key: TabBarHeightKey.self, value: geo.size.height)
                    }
                )
                .onPreferenceChange(TabBarHeightKey.self) { height in
                    tabBarHeight = height
                }
        }
        .overlay(alignment: .bottom) {
            if playerManager.isPlayerVisible {
                FloatingPlayerView(dragOffset: $floatingDragOffset)
                    .padding(.bottom, tabBarHeight + 10)
                    .transition(
                        .asymmetric(
                            insertion: .move(edge: .bottom).combined(with: .opacity),
                            removal: .move(edge: .bottom).combined(with: .opacity)
                        )
                    )
            }
        }
        .environmentObject(playerManager)
        .animation(.spring(response: 0.5, dampingFraction: 0.78), value: playerManager.isPlayerVisible)
        .preferredColorScheme(.dark)
    }
    
    // MARK: - Tab Content
    @ViewBuilder
    private var tabContent: some View {
        switch selectedTab {
        case 0: MusicCreationView(floatingDragOffset: $floatingDragOffset, tabBarHeight: tabBarHeight, store: tracksStore)
        case 1:  OtherTabsView(screenType: .search)
        case 2:  OtherTabsView(screenType: .library)
        case 3:  OtherTabsView(screenType: .profile)
        default: MusicCreationView(floatingDragOffset: $floatingDragOffset, tabBarHeight: tabBarHeight, store: tracksStore)
        }
    }
}

#Preview {
    ContentView()
}

