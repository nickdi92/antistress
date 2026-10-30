import Foundation

func clamp(_ value: Double, _ low: Double, _ high: Double) -> Double {
    max(low, min(high, value))
}

enum Easing {
    static func inOut(_ t: Double) -> Double {
        t < 0.5 ? 2 * t * t : 1 - pow(-2 * t + 2, 2) / 2
    }

    static func out(_ t: Double) -> Double {
        1 - pow(1 - t, 3)
    }
}
