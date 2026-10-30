import Foundation

struct RGB: Equatable {
    var r: Double
    var g: Double
    var b: Double
}

/// How a word is drawn at a given moment, relative to its laid-out position.
struct WordAppearance: Equatable {
    var offsetX: Double
    var offsetY: Double
    var rotation: Double
    var scale: Double
    var alpha: Double
    var blur: Double
    var color: RGB
}

/// A word on its way down: random drift picked once, sink timing, progress.
struct SinkingWord: Equatable {
    let word: LaidOutWord
    let dx: Double
    let dy: Double
    let rotation: Double
    let duration: Double
    /// seconds after the release at which this word starts to sink
    let sinkAt: Double
    var startedAt: Double?
    var isDone: Bool

    /// Reading order with a gentle stagger; the total sink time stays capped.
    static func make(from words: [LaidOutWord], rng: inout some RandomNumberGenerator) -> [SinkingWord] {
        let gap = clamp(9 / Double(max(words.count, 1)), 0.16, 0.55)
        return words.enumerated().map { i, word in
            SinkingWord(
                word: word,
                dx: .random(in: -14...14, using: &rng),
                dy: .random(in: 4...18, using: &rng),
                rotation: .random(in: -0.18...0.18, using: &rng),
                duration: .random(in: 2.2...3, using: &rng),
                sinkAt: 1.4 + Double(i) * gap + .random(in: 0...(gap * 0.5), using: &rng),
                startedAt: nil,
                isDone: false
            )
        }
    }

    /// The words that get a note and a haptic tick this frame: only those starting on time (after a pause
    /// in the background all the overdue words start together and would sound as one loud chord), at most `limit`.
    static func audible(_ started: [SinkingWord], releasedAt: Double, now: Double, limit: Int = 2) -> [SinkingWord] {
        Array(started.filter { now - releasedAt - $0.sinkAt <= 0.25 }.prefix(limit))
    }

    func appearance(now: Double, sinceRelease: Double, index: Int, reduceMotion: Bool) -> WordAppearance {
        let e = startedAt.map { clamp((now - $0) / duration, 0, 1) } ?? 0
        let ee = Easing.inOut(e)
        let fadeIn = clamp(sinceRelease / 0.45, 0, 1)
        let bob = reduceMotion ? 0 : sin(now * 1.6 + Double(index) * 0.7) * 1.6 * (1 - ee)
        return WordAppearance(
            offsetX: reduceMotion ? 0 : dx * ee,
            offsetY: bob + (reduceMotion ? 0 : dy * ee),
            rotation: reduceMotion ? 0 : rotation * ee,
            scale: reduceMotion ? 1 : 1 - 0.55 * ee,
            alpha: fadeIn * (1 - pow(e, 1.15)),
            blur: !reduceMotion && ee > 0.02 ? ee * 5 : 0,
            // ink cools into the water colour as it sinks
            color: RGB(r: 236 - 116 * ee, g: 232 - 52 * ee, b: 222 - 32 * ee)
        )
    }
}
