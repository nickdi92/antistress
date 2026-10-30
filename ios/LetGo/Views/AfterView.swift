import SwiftUI

struct AfterView: View {
    let model: FlowModel
    let clock: WaterController
    let screenWidth: CGFloat
    var onAgain: () -> Void

    var body: some View {
        TimelineView(.animation) { timeline in
            let state = model.afterState(now: clock.time(of: timeline.date))
            VStack(spacing: 0) {
                Text(state.message == .slowBreath ? "One slow breath." : "Gone.")
                    .font(Theme.serifItalic(min(34, max(24, screenWidth * 0.06))))
                    .foregroundStyle(Theme.ink)
                    .multilineTextAlignment(.center)
                    .opacity(state.messageVisible ? 1 : 0)
                    .animation(.easeInOut(duration: 0.9), value: state.messageVisible)
                    .animation(.easeInOut(duration: 0.9), value: state.message)

                BreathCircle(scale: AfterSequence.breathScale(elapsed: state.breathElapsed ?? 0),
                             label: state.label, labelVisible: state.labelVisible)
                    .opacity(state.breathVisible ? 1 : 0)
                    .animation(.easeInOut(duration: 1), value: state.breathVisible)
                    .padding(.top, 34)
                    .padding(.bottom, 6)
                    .accessibilityHidden(!state.breathVisible)

                ZStack {
                    if state.againVisible {
                        Button("Write another thought", action: onAgain)
                            .buttonStyle(GhostButtonStyle())
                            .accessibilityIdentifier("againButton")
                            .transition(.opacity)
                    }
                }
                .frame(height: 52)
                .padding(.top, 22)
                .animation(.easeInOut(duration: 0.7), value: state.againVisible)
            }
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .contentShape(Rectangle())
            .onTapGesture { model.skip(now: clock.now()) }
        }
    }
}
