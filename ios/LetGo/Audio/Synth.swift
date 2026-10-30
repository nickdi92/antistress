import Foundation

/// Sound building blocks, kept free of AVFoundation so they can be tested sample by sample
/// (values from the PWA's Web Audio code).
enum Synth {
    /// Pentatonic: any two notes sound consonant together.
    static let pentatonic: [Double] = [392.0, 440.0, 523.25, 587.33, 659.25, 783.99]

    static func noteFrequency(rng: inout some RandomNumberGenerator) -> Double {
        let note = pentatonic.randomElement(using: &rng)!
        return note * (Double.random(in: 0..<1, using: &rng) < 0.35 ? 0.5 : 1)
    }

    /// Brown noise that loops without a click: the linear drift between the ends is removed.
    static func brownNoiseLoop(sampleRate: Double, seconds: Double, rng: inout some RandomNumberGenerator) -> [Float] {
        let count = Int(sampleRate * seconds)
        var data = [Float](repeating: 0, count: count)
        var last = 0.0
        for i in 0..<count {
            last = (last + 0.02 * Double.random(in: -1...1, using: &rng)) / 1.02
            data[i] = Float(last * 3.5)
        }
        guard let a0 = data.first, let a1 = data.last else { return data }
        for i in 0..<count { data[i] -= a0 + (a1 - a0) * Float(i) / Float(count) }
        return data
    }
}

/// One water-drop note: a sine that glides up into pitch, with a quick attack and a 0.7 s decay.
struct NoteVoice {
    private let sampleRate: Double
    private let frequency: Double
    private let peak: Double
    private let attackEnd: Int
    private let decayEnd: Int
    private let glideEnd: Int
    private let total: Int
    private let attackRatio: Double
    private let decayRatio: Double
    private let glideRatio: Double
    private var index = 0
    private var phase = 0.0
    private var gain = 0.0001
    private var currentFrequency: Double

    init(frequency: Double, softness: Double, sampleRate: Double) {
        self.sampleRate = sampleRate
        self.frequency = frequency
        peak = 0.16 * softness
        attackEnd = Int(0.008 * sampleRate)
        decayEnd = Int(0.7 * sampleRate)
        glideEnd = Int(0.055 * sampleRate)
        total = Int(0.75 * sampleRate)
        // exponential ramps as per-sample multipliers
        attackRatio = pow(peak / 0.0001, 1 / Double(attackEnd))
        decayRatio = pow(0.0001 / peak, 1 / Double(decayEnd - attackEnd))
        glideRatio = pow(1 / 0.72, 1 / Double(glideEnd))
        currentFrequency = frequency * 0.72
    }

    var isFinished: Bool { index >= total }

    mutating func nextSample() -> Float {
        guard !isFinished else { return 0 }
        let sample = Float(sin(phase) * gain)
        phase += 2 * .pi * currentFrequency / sampleRate
        if phase > 2 * .pi { phase -= 2 * .pi }
        if index < glideEnd { currentFrequency *= glideRatio } else { currentFrequency = frequency }
        if index < attackEnd {
            gain *= attackRatio
        } else if index < decayEnd {
            gain *= decayRatio
        } else {
            gain = 0.0001
        }
        index += 1
        return sample
    }
}
