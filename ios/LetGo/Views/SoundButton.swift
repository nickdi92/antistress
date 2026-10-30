import SwiftUI

struct SoundButton: View {
    let isOn: Bool
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: isOn ? "speaker.wave.2" : "speaker.slash")
                .font(.system(size: 17, weight: .light))
                .foregroundStyle(Theme.inkSoft)
                .frame(width: 44, height: 44)
                .background(Circle().fill(Theme.deep.opacity(0.3)))
                .overlay(Circle().stroke(Theme.ink.opacity(0.14), lineWidth: 1))
        }
        .accessibilityIdentifier("soundButton")
        .accessibilityLabel(Text(isOn ? "Sound on: tap to turn off" : "Sound off: tap to turn on"))
    }
}
