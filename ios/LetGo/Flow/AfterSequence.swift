import Foundation

enum AfterMessage: Equatable {
    case gone        // "Gone."
    case slowBreath  // "One slow breath."
}

enum BreathLabel: Equatable {
    case breatheIn
    case breatheOut
}

/// What the closing screen shows at a given moment.
struct AfterState: Equatable {
    var message: AfterMessage?
    var messageVisible: Bool
    var breathVisible: Bool
    /// seconds since the breathing circle appeared
    var breathElapsed: Double?
    var label: BreathLabel
    var labelVisible: Bool
    var againVisible: Bool
}

/// The closing sequence as a pure function of time (timings from `showAfter()` in the PWA).
enum AfterSequence {
    static let breathStart = 3.6

    static func state(elapsed t: Double, skipped: Bool) -> AfterState {
        if skipped {
            return AfterState(message: .gone, messageVisible: true, breathVisible: false, breathElapsed: nil,
                              label: .breatheIn, labelVisible: false, againVisible: true)
        }
        var s = AfterState(message: nil, messageVisible: false, breathVisible: false, breathElapsed: nil,
                           label: .breatheIn, labelVisible: false, againVisible: false)
        switch t {
        case ..<0.2:
            break
        case ..<2.6:
            s.message = .gone
            s.messageVisible = true
        case ..<breathStart:
            s.message = .gone
        default:
            s.message = .slowBreath
            s.messageVisible = true
            s.breathVisible = true
            s.breathElapsed = t - breathStart
            s.label = t < 7.7 ? .breatheIn : .breatheOut
            s.labelVisible = t < 7.3 || (t >= 7.7 && t < 13.2)
            s.againVisible = t >= 13.8
        }
        return s
    }

    /// One 10 s breath: grow from 0.42 to 1 in 4 s, shrink back in 6 s.
    static func breathScale(elapsed t: Double) -> Double {
        switch t {
        case ..<0: return 0.42
        case ..<4: return 0.42 + 0.58 * Easing.inOut(t / 4)
        case ..<10: return 1 - 0.58 * Easing.inOut((t - 4) / 6)
        default: return 0.42
        }
    }
}
