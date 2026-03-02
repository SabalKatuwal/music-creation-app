import SwiftUI

// MARK: - GeneratedTrackItemView

struct GeneratedTrackItemView: View {

    let track: GeneratedTrack
    let progress: Double       // 0.0→1.0 during generation, 1.0 when done
    let stage: LoadingStage
    let isCompleted: Bool

    @State private var showTitle:    Bool = false
    @State private var showSubtitle: Bool = false
    @State private var showDot:      Bool = false
    @State private var enteredView:  Bool = false

    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            thumbnailColumn
            infoColumn
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .overlay(alignment: .trailing) { moreButton }
        .opacity(enteredView ? 1 : 0)
        .offset(y: enteredView ? 0 : -14)        // BUG #1 FIX: Force view re-render when completion status changes to immediately show gradient and thumbnail
        .id(isCompleted)
        .onAppear {
            withAnimation(.spring(response: 0.55, dampingFraction: 0.78)) {
                enteredView = true
            }
        }
        .onChange(of: isCompleted) { _, completed in
            guard completed else { return }
            Task {
                try? await Task.sleep(nanoseconds: 120_000_000)
                withAnimation(.spring(response: 0.50, dampingFraction: 0.80)) { showDot = true }
                try? await Task.sleep(nanoseconds: 80_000_000)
                withAnimation(.spring(response: 0.45, dampingFraction: 0.82)) { showTitle = true }
                try? await Task.sleep(nanoseconds: 80_000_000)
                withAnimation(.spring(response: 0.45, dampingFraction: 0.82)) { showSubtitle = true }
            }
        }
    }

    // MARK: - Thumbnail

    private var thumbnailColumn: some View {
        ZStack(alignment: .bottomTrailing) {
            if isCompleted {
                Image(track.imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 64, height: 64)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .transition(.opacity)
            } else {
                // During generation
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(AppColors.brandDiagonal)
                    .frame(width: 64, height: 64)
            }

            // Water fill - only during generation
            if !isCompleted {
                WaterFillOverlay(progress: progress)
                    .frame(width: 64, height: 64)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .transition(.opacity)
            }

            // Percentage text - only during generation
            if !isCompleted {
                Text("\(Int(progress * 100))%")
                    .font(AppText.numericSmall())
                    .foregroundStyle(AppText.primary)
                    .shadow(color: .black.opacity(0.5), radius: 3)
                    .frame(width: 64, height: 64)
                    .contentTransition(.numericText(countsDown: false))
            }

            // Duration badge - only when completed
            if isCompleted {
                Text(formattedDuration(track.duration))
                    .font(.caption2)
                    .foregroundStyle(AppText.primary)
                    .padding(.horizontal, 4)
                    .padding(.vertical, 2)
                    .background {
                        RoundedRectangle(cornerRadius: 12)
                            .foregroundStyle(Color.black.opacity(0.4))
                    }
                    .padding(4)
                    .transition(.opacity.combined(with: .scale(scale: 0.85)))
            }
        }
        .overlay(alignment: .topLeading) {
            if showDot {
                Circle()
                    .fill(AppColors.accentGreen)
                    .frame(width: 9, height: 9)
                    .overlay(Circle().stroke(Color.black.opacity(0.35), lineWidth: 1.5))
                    .padding(5)
                    .transition(.scale(scale: 0.4).combined(with: .opacity))
            }
        }
        .frame(width: 64, height: 64)
    }

    // MARK: - Info

    private var infoColumn: some View {
        VStack(alignment: .leading, spacing: 5) {
            titleRow
            subtitleRow
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 11.5)
    }

    @ViewBuilder
    private var titleRow: some View {
        if showTitle || isCompleted {
            Text(track.title)
                .transition(.asymmetric(
                    insertion: .offset(y: 6).combined(with: .opacity),
                    removal:   .opacity
                ))
        } else {
            ShimmerBar(width: 120, height: 13)
                .transition(.opacity)
        }
    }

    @ViewBuilder
    private var subtitleRow: some View {
        if showSubtitle || isCompleted {
            Text(track.subtitle)
                .font(.subheadline)
                .opacity(0.7)
                .lineLimit(1)
                .transition(.asymmetric(
                    insertion: .offset(y: 6).combined(with: .opacity),
                    removal:   .opacity
                ))
        } else {
            HStack(spacing: 5) {
                if !isCompleted {
                    GeneratingDotsView()
                }
                Text(isCompleted ? "" : stage.message)
                    .font(AppText.subtitle())
                    .foregroundStyle(AppText.tertiary)
                    .contentTransition(.interpolate)
                    .animation(.easeInOut(duration: 0.35), value: stage.message)
            }
            .transition(.opacity)
        }
    }

    // MARK: - More button

    private var moreButton: some View {
        HStack {
            Spacer()
            Image(systemName: "ellipsis")
                .font(.headline)
                .opacity(isCompleted ? 0.7 : 0.2)
        }
    }

    // MARK: - Helpers

    private func formattedDuration(_ seconds: TimeInterval) -> String {
        let s = Int(seconds)
        return String(format: "%d:%02d", s / 60, s % 60)
    }
}

// MARK: - WaterFillOverlay
// 60fps Canvas-based water fill with two sine-wave layers. The surface rises as `progress` increases from 0→1.

struct WaterFillOverlay: View {

    let progress: Double

    // Vivid green
    private let primaryColor   = Color(red: 0.10, green: 0.88, blue: 0.52)
    private let secondaryColor = Color(red: 0.08, green: 0.70, blue: 0.42)

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 60.0)) { ctx in
            let t = ctx.date.timeIntervalSinceReferenceDate
            Canvas { context, size in
                // Layer 1 — primary wave, faster & taller
                context.fill(
                    wavePath(size: size, phase: t * 3.4, amplitude: 5.0, level: progress),
                    with: .color(primaryColor.opacity(0.58))
                )
                // Layer 2 — secondary wave, slower & shorter, slightly higher fill
                context.fill(
                    wavePath(size: size, phase: t * 2.0 + .pi * 0.65, amplitude: 3.2, level: min(progress + 0.028, 1.0)),
                    with: .color(secondaryColor.opacity(0.38))
                )
            }
        }
    }

    private func wavePath(size: CGSize, phase: Double, amplitude: CGFloat, level: Double) -> Path {
        let clampedLevel = min(max(level, 0), 1.0)
        let surfaceY = size.height * CGFloat(1.0 - clampedLevel)

        var path = Path()
        path.move(to: CGPoint(x: 0, y: size.height))
        path.addLine(to: CGPoint(x: 0, y: surfaceY))

        var x: CGFloat = 0
        while x <= size.width + 1 {
            let normalised = x / size.width
            let angle = normalised * .pi * 4.0 + phase
            let y = surfaceY + sin(angle) * amplitude
            path.addLine(to: CGPoint(x: x, y: y))
            x += 1.5
        }

        path.addLine(to: CGPoint(x: size.width, y: size.height))
        path.closeSubpath()
        return path
    }
}

// MARK: - ShimmerBar

struct ShimmerBar: View {

    let width: CGFloat
    let height: CGFloat

    @State private var phase: CGFloat = -1.0

    var body: some View {
        RoundedRectangle(cornerRadius: height / 2, style: .continuous)
            .fill(AppColors.subtleStroke)
            .frame(width: width, height: height)
            .overlay(
                GeometryReader { geo in
                    AppColors.shimmerHighlight
                        .frame(width: geo.size.width * 0.55)
                        .offset(x: phase * (geo.size.width + geo.size.width * 0.55))
                }
                .clipShape(RoundedRectangle(cornerRadius: height / 2, style: .continuous))
            )
            .onAppear {
                withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                    phase = 1.0
                }
            }
    }
}

// MARK: - GeneratingDotsView

struct GeneratingDotsView: View {

    @State private var phase: Int = 0

    private let timer = Timer.publish(every: 0.38, on: .main, in: .common).autoconnect()

    var body: some View {
        HStack(spacing: 3) {
            ForEach(0..<3) { i in
                Circle()
                    .fill(AppColors.accentGreen)
                    .frame(width: 4, height: 4)
                    .scaleEffect(phase == i ? 1.35 : 0.75)
                    .opacity(phase == i ? 1.0 : 0.38)
                    .animation(.spring(response: 0.30, dampingFraction: 0.60), value: phase)
            }
        }
        .onReceive(timer) { _ in
            phase = (phase + 1) % 3
        }
    }
}
