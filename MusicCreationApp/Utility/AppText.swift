import SwiftUI

public struct AppText {
    // Headings & Titles
    public static func title() -> Font { .headline }
    public static func subtitle() -> Font { .subheadline }

    // Body / Labels
    public static func body() -> Font { .system(size: 16, weight: .regular) }
    public static func button() -> Font { .system(size: 15, weight: .semibold) }
    public static func smallLabel() -> Font { .caption2 }

    // Numeric / Emphasis
    public static func numericSmall() -> Font { .system(size: 13, weight: .bold, design: .rounded) }
    public static func numericMedium() -> Font { .system(size: 13, weight: .semibold, design: .rounded) }
    public static func stage() -> Font { .system(size: 14, weight: .medium) }

    // Text colors helpers
    public static var primary: Color { AppColors.textPrimary }
    public static var secondary: Color { AppColors.textSecondary }
    public static var tertiary: Color { AppColors.textTertiary }
    public static var muted: Color { AppColors.textMuted }
}
