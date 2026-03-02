import SwiftUI

// MARK: - MusicGenerationFlowView

struct MusicGenerationFlowView: View {

    @ObservedObject var generationManager: GenerationManager
    @Binding var floatingDragOffset: CGFloat
    let isPlayerVisible: Bool
    let floatingPlayerHeight: CGFloat

    @State private var uiState: PillState = .idle
    @State private var promptText: String = ""
    @Namespace private var morphNamespace

    private enum PillState { case idle, prompt }

    // Vertical offset that mirrors player drag so the pill moves with it
    private var dragOffset: CGFloat { min(floatingDragOffset, floatingPlayerHeight) }

    // Bottom inset: clear floating player + small breathing room
    private var bottomInset: CGFloat { 12 + (isPlayerVisible ? floatingPlayerHeight : 0) }

    var body: some View {
        VStack {
            Spacer()
            pillContent
                .frame(height: 40)
        }
        .padding(.bottom, bottomInset)
        .offset(y: dragOffset)
        .animation(.spring(response: 0.42, dampingFraction: 0.80), value: uiState)
        .onChange(of: generationManager.isGenerating) { _, generating in
            // When generation starts, collapse input back to idle pill
            if generating { uiState = .idle; promptText = "" }
        }
    }

    // MARK: - Pill Content

    @ViewBuilder
    private var pillContent: some View {
        if generationManager.isGenerating {
            generatingPill
                .transition(.asymmetric(
                    insertion: .scale(scale: 0.88, anchor: .bottom).combined(with: .opacity),
                    removal:   .scale(scale: 0.88, anchor: .bottom).combined(with: .opacity)
                ))
        } else {
            switch uiState {
            case .idle:
                idlePill
                    .transition(.asymmetric(
                        insertion: .scale(scale: 0.88, anchor: .bottom).combined(with: .opacity),
                        removal:   .scale(scale: 0.88, anchor: .bottom).combined(with: .opacity)
                    ))
            case .prompt:
                PromptInputView(
                    text: $promptText,
                    morphNamespace: morphNamespace,
                    onSubmit: {
                        let p = promptText.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard !p.isEmpty else { return }
                        generationManager.generate(prompt: p)
                    },
                    onDismiss: {
                        withAnimation(.spring(response: 0.40, dampingFraction: 0.80)) {
                            uiState = .idle
                            promptText = ""
                        }
                    }
                )
                .transition(.asymmetric(
                    insertion: .scale(scale: 0.95, anchor: .bottom).combined(with: .opacity),
                    removal:   .scale(scale: 0.92, anchor: .bottom).combined(with: .opacity)
                ))
            }
        }
    }

    // MARK: - Idle Pill

    private var idlePill: some View {
        HStack(spacing: 7) {
            
            TwoCreationIconView(selectedTab: .constant(10), withColor: true)
            
            Text("Create")
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.white)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color(white: 0.14))
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                )
        )
        .matchedGeometryEffect(id: "pillMorph", in: morphNamespace)
        .shadow(color: .black.opacity(0.35), radius: 12, y: 6)
        .onTapGesture {
            withAnimation(.spring(response: 0.40, dampingFraction: 0.80)) {
                uiState = .prompt
            }
        }
    }

    // MARK: - Generating Pill

    private var generatingPill: some View {
        HStack(spacing: 10) {
            // Mini waveform bars
            MiniWaveformView(color: Color(red: 0.15, green: 0.88, blue: 0.48))
                .frame(width: 22, height: 16)

            // Stage text with smooth cross-fade
            Text(generationManager.stage.message + "…")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white.opacity(0.80))
                .contentTransition(.interpolate)
                .animation(.easeInOut(duration: 0.40), value: generationManager.stage)

            Spacer(minLength: 4)

            // Progress percentage
            Text("\(Int(generationManager.progress * 100))%")
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundColor(Color(red: 0.15, green: 0.88, blue: 0.48))
                .contentTransition(.numericText(countsDown: false))
                .animation(.linear(duration: 0.05), value: generationManager.progress)
        }
        .padding(.vertical, 11)
        .padding(.horizontal, 18)
        .frame(minWidth: 220)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color(white: 0.11))
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.15, green: 0.88, blue: 0.48).opacity(0.45),
                                    Color(red: 0.15, green: 0.88, blue: 0.48).opacity(0.10)
                                ],
                                startPoint: .topLeading, endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
        .shadow(color: Color(red: 0.10, green: 0.75, blue: 0.42).opacity(0.30), radius: 16, y: 6)
    }
}

// MARK: - MiniWaveformView
// Four bars that animate independently to suggest audio activity.

struct MiniWaveformView: View {
    let color: Color
    @State private var heights: [CGFloat] = [0.4, 0.8, 0.5, 0.9]
    private let timer = Timer.publish(every: 0.30, on: .main, in: .common).autoconnect()

    var body: some View {
        HStack(alignment: .center, spacing: 2.5) {
            ForEach(0..<4, id: \.self) { i in
                Capsule()
                    .fill(color)
                    .frame(width: 3, height: heights[i] * 14 + 3)
                    .animation(
                        .spring(response: 0.35, dampingFraction: 0.55)
                            .delay(Double(i) * 0.05),
                        value: heights[i]
                    )
            }
        }
        .onReceive(timer) { _ in
            heights = (0..<4).map { _ in CGFloat.random(in: 0.25...1.0) }
        }
    }
}

// MARK: - PromptInputView
// rotating gradient border driven by TimelineView at 60fps.

struct PromptInputView: View {

    @Binding var text: String
    let morphNamespace: Namespace.ID
    let onSubmit: () -> Void
    let onDismiss: () -> Void

    @FocusState private var isFocused: Bool
    @State private var glowPulse: Bool = false

    private var canSubmit: Bool {
        !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Color(red:0.52,green:0.22,blue:1.0), Color(red:1.0,green:0.22,blue:0.58)],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    )
                )
                .blur(radius: isFocused ? 30 : 12)
                .opacity(isFocused ? (glowPulse ? 0.60 : 0.42) : 0.16)
                .scaleEffect(isFocused ? (glowPulse ? 1.10 : 1.03) : 1.0)
                .animation(.easeInOut(duration: 1.9).repeatForever(autoreverses: true), value: glowPulse)

            // glass background
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(.ultraThinMaterial)

            // Rotating comet bordr
            // Uses AngularGradient with advancing start angle from TimelineView.
            TimelineView(.animation(minimumInterval: 1.0 / 60.0)) { ctx in
                let t = ctx.date.timeIntervalSinceReferenceDate
                let deg = (t.truncatingRemainder(dividingBy: 3.2) / 3.2) * 360.0

                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .stroke(
                        AngularGradient(
                            stops: [
                                .init(color: .clear,                                         location: 0.00),
                                .init(color: Color(red:0.58,green:0.20,blue:1.0).opacity(0.45), location: 0.08),
                                .init(color: Color(red:0.95,green:0.28,blue:0.68).opacity(0.80), location: 0.24),
                                .init(color: .white,                                         location: 0.35),
                                .init(color: Color(red:0.95,green:0.28,blue:0.68).opacity(0.70), location: 0.46),
                                .init(color: Color(red:0.48,green:0.18,blue:1.0).opacity(0.28), location: 0.64),
                                .init(color: .clear,                                         location: 0.80),
                                .init(color: .clear,                                         location: 1.00),
                            ],
                            center: .center,
                            startAngle: .degrees(deg),
                            endAngle: .degrees(deg + 360)
                        ),
                        lineWidth: isFocused ? 2.0 : 0.75
                    )
                    .animation(.easeInOut(duration: 0.38), value: isFocused)
            }

            // Specular highlight at top edge
            if isFocused {
                LinearGradient(
                    colors: [Color.white.opacity(0.07), .clear],
                    startPoint: .top, endPoint: UnitPoint(x: 0.5, y: 0.45)
                )
                .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                .transition(.opacity)
            }

            // Input row
            HStack(alignment: .center, spacing: 0) {
                TextField("Describe your music…", text: $text, axis: .vertical)
                    .focused($isFocused)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.white)
                    .tint(Color(red: 0.72, green: 0.42, blue: 1.0))
                    .lineLimit(1...4)
                    .padding(.vertical, 16)
                    .padding(.leading, 20)
                    .onSubmit {
                        if canSubmit { onSubmit() }
                    }

                Spacer(minLength: 8)
                sendButton.padding(.trailing, 14)
            }
        }
        .frame(minHeight: 60)
        .padding(.horizontal, 16)
        .matchedGeometryEffect(id: "pillMorph", in: morphNamespace)
        .shadow(
            color: Color(red:0.52,green:0.22,blue:1.0).opacity(isFocused ? 0.28 : 0.0),
            radius: 22, y: 8
        )
        .animation(.easeInOut(duration: 0.38), value: isFocused)
        .onAppear {
            // Delay so the morph spring settles before keyboard appears
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.22) {
                isFocused = true
                glowPulse = true
            }
        }
        .onChange(of: isFocused) { _, focused in
            if !focused && text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) { onDismiss() }
            }
        }
    }

    private var sendButton: some View {
        Button {
            guard canSubmit else { return }
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            onSubmit()
        } label: {
            ZStack {
                Circle()
                    .fill(
                        canSubmit
                            ? AnyShapeStyle(LinearGradient(
                                colors: [Color(red:0.52,green:0.22,blue:1.0), Color(red:1.0,green:0.28,blue:0.62)],
                                startPoint: .topLeading, endPoint: .bottomTrailing))
                            : AnyShapeStyle(Color.white.opacity(0.10))
                    )
                    .frame(width: 38, height: 38)
                    .shadow(
                        color: canSubmit ? Color(red:0.62,green:0.26,blue:1.0).opacity(0.52) : .clear,
                        radius: 10, y: 4
                    )
                Image(systemName: "arrow.up")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(canSubmit ? .white : Color.white.opacity(0.28))
            }
        }
        .buttonStyle(SpringButtonStyle())
        .disabled(!canSubmit)
        .animation(.spring(response: 0.30, dampingFraction: 0.70), value: canSubmit)
    }
}

// MARK: - SpringButtonStyle

struct SpringButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.88 : 1.0)
            .opacity(configuration.isPressed ? 0.76 : 1.0)
            .animation(.spring(response: 0.26, dampingFraction: 0.60), value: configuration.isPressed)
    }
}
