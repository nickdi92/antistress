import SwiftUI
import UIKit

/// Colours and type from the PWA's CSS.
enum Theme {
    static let deep = Color(red: 6 / 255, green: 20 / 255, blue: 31 / 255)
    static let ink = Color(red: 236 / 255, green: 232 / 255, blue: 222 / 255)
    static let inkSoft = ink.opacity(0.62)
    static let inkFaint = ink.opacity(0.34)
    static let accent = Color(red: 159 / 255, green: 211 / 255, blue: 214 / 255)
    static let waterStops: [Gradient.Stop] = [
        .init(color: Color(red: 12 / 255, green: 47 / 255, blue: 64 / 255), location: 0),
        .init(color: Color(red: 8 / 255, green: 34 / 255, blue: 49 / 255), location: 0.55),
        .init(color: Color(red: 5 / 255, green: 18 / 255, blue: 28 / 255), location: 1),
    ]

    static let serifName = "IowanOldStyle-Roman"
    static let serifItalicName = "IowanOldStyle-Italic"

    /// Fixed size: the written words are measured at exactly this size when they sink.
    static func serif(_ size: CGFloat) -> Font { .custom(serifName, fixedSize: size) }
    static func serifItalic(_ size: CGFloat) -> Font { .custom(serifItalicName, fixedSize: size) }

    static func uiSerif(_ size: CGFloat) -> UIFont {
        UIFont(name: serifName, size: size) ?? .systemFont(ofSize: size)
    }
}

struct PillButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 15, weight: .medium))
            .tracking(0.9)
            .foregroundStyle(Theme.deep)
            .padding(.vertical, 15)
            .padding(.horizontal, 28)
            .background(Capsule().fill(Theme.accent))
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}

struct GhostButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 15, weight: .medium))
            .tracking(0.9)
            .foregroundStyle(configuration.isPressed ? Theme.ink : Theme.inkSoft)
            .padding(.vertical, 15)
            .padding(.horizontal, 28)
            .overlay(Capsule().stroke(Theme.ink.opacity(configuration.isPressed ? 0.5 : 0.25), lineWidth: 1))
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}
