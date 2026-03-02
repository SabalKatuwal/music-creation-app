import SwiftUI

public struct AppColors {
    // MARK: - Text
    public static let textPrimary    = Color.white
    public static let textSecondary  = Color.white.opacity(0.70)
    public static let textTertiary   = Color.white.opacity(0.48)
    public static let textMuted      = Color.white.opacity(0.28)

    // MARK: - Surfaces / Strokes
    public static let pillBackground = Color(white: 0.14)   // idle pill bg
    public static let pillBackgroundDark = Color(white: 0.11) // generating pill bg
    public static let glassStrokePrimary = Color.white.opacity(0.25)
    public static let glassStrokeSecondary = Color.white.opacity(0.05)
    public static let subtleStroke   = Color.white.opacity(0.08)
    public static let divider        = Color.white.opacity(0.40)
    public static let progressTrack  = Color.white.opacity(0.12)

    // MARK: - Accents
    // Vivid greens used for progress, dots, and waveform
    public static let accentGreen        = Color(red: 0.15, green: 0.88, blue: 0.48)
    public static let accentGreenPrimary = Color(red: 0.10, green: 0.88, blue: 0.52)
    public static let accentGreenSecondary = Color(red: 0.08, green: 0.70, blue: 0.42)
    public static let accentGreenShadow  = Color(red: 0.10, green: 0.75, blue: 0.42)

    // Brand purple/pink hues used across gradients
    public static let brandPurple = Color(red: 0.52, green: 0.22, blue: 1.00)
    public static let brandPurpleDeep = Color(red: 0.48, green: 0.18, blue: 1.00)
    public static let brandPink   = Color(red: 1.00, green: 0.22, blue: 0.58)
    public static let brandPinkBright = Color(red: 1.00, green: 0.28, blue: 0.62)

    // MARK: - Utility
    public static let black = Color.black

    // MARK: - Gradients
    public static let brandDiagonal: LinearGradient = LinearGradient(
        colors: [brandPurple, brandPink],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )

    public static let brandDiagonalBright: LinearGradient = LinearGradient(
        colors: [brandPurple, brandPinkBright],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )

    public static let greenStroke: LinearGradient = LinearGradient(
        colors: [accentGreen.opacity(0.45), accentGreen.opacity(0.10)],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )

    public static let shimmerHighlight: LinearGradient = LinearGradient(
        colors: [.clear, Color.white.opacity(0.20), .clear],
        startPoint: .leading, endPoint: .trailing
    )

    public static let topSpecular: LinearGradient = LinearGradient(
        colors: [Color.white.opacity(0.07), .clear],
        startPoint: .top, endPoint: UnitPoint(x: 0.5, y: 0.45)
    )
}
