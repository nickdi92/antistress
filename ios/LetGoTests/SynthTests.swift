import Foundation
import Testing
@testable import LetGo

struct SynthTests {
    @Test func pentatonicChoice() {
        var rng = SeededRNG(seed: 7)
        let fs = (0..<1000).map { _ in Synth.noteFrequency(rng: &rng) }
        let allowed = Set(Synth.pentatonic + Synth.pentatonic.map { $0 / 2 })
        #expect(fs.allSatisfy { allowed.contains($0) })
        let low = Double(fs.filter { !Synth.pentatonic.contains($0) }.count) / 1000
        #expect(low > 0.28 && low < 0.42)
    }

    func render(_ voice: inout NoteVoice) -> [Float] {
        var out: [Float] = []
        while !voice.isFinished { out.append(voice.nextSample()) }
        return out
    }

    @Test func noteVoiceEnvelope() {
        var voice = NoteVoice(frequency: 440, softness: 1, sampleRate: 48000)
        let x = render(&voice)
        #expect(x.count == 36000)
        let peak = x.prefix(960).map { abs($0) }.max()!
        #expect(peak >= 0.15 && peak <= 0.17)
        #expect(x.dropFirst(33600).map { abs($0) }.max()! < 0.001)
    }

    @Test func noteVoiceSoftness() {
        var voice = NoteVoice(frequency: 440, softness: 0.6, sampleRate: 48000)
        let peak = render(&voice).prefix(960).map { abs($0) }.max()!
        #expect(peak >= 0.09 && peak <= 0.1)
    }

    @Test func brownNoiseSeamless() {
        var rng = SeededRNG(seed: 9)
        let x = Synth.brownNoiseLoop(sampleRate: 48000, seconds: 6, rng: &rng)
        #expect(x.count == 288_000)
        #expect(abs(x[0]) < 1e-6)
        #expect(abs(x.last!) < 0.01)
        let rms = sqrt(x.reduce(0) { $0 + Double($1) * Double($1) } / Double(x.count))
        #expect(rms > 0.01)
    }
}
