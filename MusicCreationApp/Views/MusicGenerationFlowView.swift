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
                .font(AppText.button())
                .foregroundStyle(AppText.primary)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(AppColors.pillBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(AppColors.subtleStroke, lineWidth: 1)
                )
        )
        .matchedGeometryEffect(id: "pillMorph", in: morphNamespace)
        .shadow(color: AppColors.black.opacity(0.35), radius: 12, y: 6)
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
            MiniWaveformView(color: AppColors.accentGreen)
                .frame(width: 22, height: 16)

            // Stage text with smooth cross-fade
            Text(generationManager.stage.message + "…")
                .font(AppText.stage())
                .foregroundStyle(AppColors.textPrimary.opacity(0.80))
                .contentTransition(.interpolate)
                .animation(.easeInOut(duration: 0.40), value: generationManager.stage)

            Spacer(minLength: 4)

            // Progress percentage
            Text("\(Int(generationManager.progress * 100))%")
                .font(AppText.numericMedium())
                .foregroundStyle(AppColors.accentGreen)
                .contentTransition(.numericText(countsDown: false))
                .animation(.linear(duration: 0.05), value: generationManager.progress)
        }
        .padding(.vertical, 11)
        .padding(.horizontal, 18)
        .frame(minWidth: 220)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(AppColors.pillBackgroundDark)
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(AppColors.greenStroke, lineWidth: 1)
                )
        )
        .shadow(color: AppColors.accentGreenShadow.opacity(0.30), radius: 16, y: 6)
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
                .fill(AppColors.brandDiagonal)
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
                                .init(color: .clear,                            location: 0.00),
                                .init(color: AppColors.brandPurpleDeep.opacity(0.45), location: 0.08),
                                .init(color: AppColors.brandPink.opacity(0.80),       location: 0.24),
                                .init(color: .white,                            location: 0.35),
                                .init(color: AppColors.brandPink.opacity(0.70),       location: 0.46),
                                .init(color: AppColors.brandPurpleDeep.opacity(0.28), location: 0.64),
                                .init(color: .clear,                            location: 0.80),
                                .init(color: .clear,                            location: 1.00),
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
                AppColors.topSpecular
                    .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                    .transition(.opacity)
            }

            // Input row
            HStack(alignment: .center, spacing: 0) {
                TextField("Describe your music…", text: $text, axis: .vertical)
                    .focused($isFocused)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundStyle(.white)
                    .tint(AppColors.brandPurple)
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
            color: AppColors.brandPurple.opacity(isFocused ? 0.28 : 0.0),
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
                            ? AnyShapeStyle(AppColors.brandDiagonalBright)
                            : AnyShapeStyle(Color.white.opacity(0.10))
                    )
                    .frame(width: 38, height: 38)
                    .shadow(
                        color: canSubmit ? AppColors.brandPurple.opacity(0.52) : .clear,
                        radius: 10, y: 4
                    )
                Image(systemName: "arrow.up")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(canSubmit ? .white : AppColors.textMuted)
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
