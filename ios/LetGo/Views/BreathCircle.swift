import SwiftUI

struct BreathCircle: View {
    let scale: Double
    let label: BreathLabel
    let labelVisible: Bool

    var body: some View {
        ZStack {
            Circle()
                .fill(RadialGradient(stops: [
                    .init(color: Theme.accent.opacity(0.30), location: 0),
                    .init(color: Theme.accent.opacity(0.10), location: 0.55),
                    .init(color: Theme.accent.opacity(0), location: 0.72),
                ], center: .center, startRadius: 0, endRadius: 95 * 1.414))
                .overlay(Circle().stroke(Theme.accent.opacity(0.28), lineWidth: 1))
                .scaleEffect(scale)
            Text(label == .breatheIn ? "breathe in" : "breathe out")
                .font(.system(size: 13))
                .tracking(1.8)
                .textCase(.uppercase)
                .foregroundStyle(Theme.inkSoft)
                .opacity(labelVisible ? 1 : 0)
                .animation(.easeInOut(duration: 0.6), value: labelVisible)
                .animation(.easeInOut(duration: 0.6), value: label)
        }
        .frame(width: 190, height: 190)
    }
}
