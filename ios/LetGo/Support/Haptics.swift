import UIKit

enum Haptics {
    private static let generator = UIImpactFeedbackGenerator(style: .soft)

    static func prepare() { generator.prepare() }

    /// A light tick for each word touching the water.
    static func drop() { generator.impactOccurred(intensity: 0.6) }
}
