//
//  CustomTabBar.swift
//  MusicCreationApp
//
//  Created by Sabal on 2/25/26.
//

import Foundation
import SwiftUI

struct CustomTabBar: View {
    
    @Binding var selectedTab: Int
    
    var body: some View {
        VStack(spacing: 4) {
            
            Rectangle()
                .fill(Color.white.opacity(0.4))
                .frame(height: 0.5)
            
            HStack {
                tabButton(index: 0) {
                    CustomIconRepresentable(isSelected: selectedTab == 0)
                        .frame(width: 22, height: 22)
                }
                
                tabButton(index: 1) {
                    Image(systemName: "magnifyingglass")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 22, height: 22)
                }
                
                tabButton(index: 2) {
                    Image(systemName: "heart")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 22, height: 22)
                }
                
                tabButton(index: 3) {
                    Image(systemName: "person")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 22, height: 22)
                }
            }
            .frame(height: 60)
        }
        .background(Color.black)
    }
    
    
    // MARK: - Tab Button
    private func tabButton<Content: View>(
        index: Int,
        @ViewBuilder content: () -> Content
    ) -> some View {
        
        Button {
            selectedTab = index
        } label: {
            content()
                .foregroundColor(selectedTab == index ? .white : .white.opacity(0.4))
                .frame(maxWidth: .infinity)
        }
    }
}
