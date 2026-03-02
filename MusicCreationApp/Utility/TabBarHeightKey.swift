//
//  TabBarHeightKey.swift
//  MusicCreationApp
//
//  Created by Gurzu on 02/03/2026.
//

import SwiftUI

/// Preference key that propagates the measured height of CustomTabBar up the view tree
struct TabBarHeightKey: PreferenceKey {
    static let defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}
