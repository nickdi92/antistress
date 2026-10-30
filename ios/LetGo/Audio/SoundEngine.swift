import AVFoundation
import os

/// Ambient water sound plus a note for every word that sinks, synthesised live.
/// Uses the `.ambient` session: silent with the ring switch off, mixes with other apps' audio.
@MainActor
final class SoundEngine {
    private static let key = "sound"

    private let defaults: UserDefaults
    private(set) var isOn: Bool
    private var engine: AVAudioEngine?
    private var sampleRate = 48_000.0
    private let pending = OSAllocatedUnfairLock(initialState: [NoteVoice]())
    private var observers: [NSObjectProtocol] = []
    private var fadeTimer: Timer?

    var isRunning: Bool { engine?.isRunning ?? false }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        isOn = defaults.object(forKey: Self.key) as? Bool ?? true
    }

    deinit {
        observers.forEach(NotificationCenter.default.removeObserver)
    }

    func start() {
        guard engine == nil else { resumeIfNeeded(); return }
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.ambient)
        try? session.setActive(true)

        let engine = AVAudioEngine()
        let hardwareRate = engine.outputNode.outputFormat(forBus: 0).sampleRate
        sampleRate = hardwareRate > 0 ? hardwareRate : 48_000
        let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1)!

        let ambient = Self.makeAmbientNode(sampleRate: sampleRate)
        let voices = Self.makeVoicesNode(pending: pending)
        let delay = AVAudioUnitDelay()
        delay.delayTime = 0.23
        delay.feedback = 33
        delay.lowPassCutoff = 1700
        delay.wetDryMix = 100
        let wet = AVAudioMixerNode()
        wet.outputVolume = 0.45

        let main = engine.mainMixerNode
        [ambient, voices, delay, wet].forEach(engine.attach)
        engine.connect(ambient, to: main, format: format)
        engine.connect(voices, to: [AVAudioConnectionPoint(node: main, bus: main.nextAvailableInputBus),
                                    AVAudioConnectionPoint(node: wet, bus: 0)], fromBus: 0, format: format)
        engine.connect(wet, to: delay, format: format)
        engine.connect(delay, to: main, format: format)
        main.outputVolume = isOn ? 1 : 0

        self.engine = engine
        observe()
        try? engine.start()
    }

    func setOn(_ on: Bool) {
        isOn = on
        defaults.set(on, forKey: Self.key)
        fade(to: on ? 1 : 0)
    }

    func drop(softness: Double = 1) {
        guard isOn, isRunning else { return }
        var rng = SystemRandomNumberGenerator()
        let voice = NoteVoice(frequency: Synth.noteFrequency(rng: &rng), softness: softness, sampleRate: sampleRate)
        pending.withLock { $0.append(voice) }
    }

    func resumeIfNeeded() {
        guard let engine else { start(); return }
        guard !engine.isRunning else { return }
        try? AVAudioSession.sharedInstance().setActive(true)
        try? engine.start()
    }

    func handleInterruption(began: Bool) {
        if began {
            engine?.pause()
        } else {
            resumeIfNeeded()
        }
    }

    // MARK: - private

    private func observe() {
        let center = NotificationCenter.default
        observers.append(center.addObserver(forName: AVAudioSession.interruptionNotification, object: nil, queue: .main) { [weak self] note in
            let raw = note.userInfo?[AVAudioSessionInterruptionTypeKey] as? UInt
            let began = raw.flatMap(AVAudioSession.InterruptionType.init) == .began
            MainActor.assumeIsolated { self?.handleInterruption(began: began) }
        })
        observers.append(center.addObserver(forName: .AVAudioEngineConfigurationChange, object: nil, queue: .main) { [weak self] _ in
            MainActor.assumeIsolated { self?.resumeIfNeeded() }
        })
    }

    /// Short fade of the master volume so switching sound off or on never clicks.
    private func fade(to target: Float) {
        fadeTimer?.invalidate()
        guard let main = engine?.mainMixerNode else { return }
        let start = main.outputVolume
        let steps = 10
        var step = 0
        fadeTimer = Timer.scheduledTimer(withTimeInterval: 0.15 / Double(steps), repeats: true) { timer in
            step += 1
            main.outputVolume = start + (target - start) * Float(step) / Float(steps)
            if step >= steps { timer.invalidate() }
        }
    }

    /// Brown noise, low-passed around 420 Hz with a slow 0.09 Hz sweep, fading in like small waves.
    private nonisolated static func makeAmbientNode(sampleRate: Double) -> AVAudioSourceNode {
        var rng = SystemRandomNumberGenerator()
        let loop = Synth.brownNoiseLoop(sampleRate: sampleRate, seconds: 6, rng: &rng)
        var position = 0
        var time = 0.0
        var low1: Float = 0, low2: Float = 0
        var gain: Float = 0
        let gainStep = Float(1 - exp(-1 / (2.5 * sampleRate)))
        return AVAudioSourceNode { _, _, frameCount, audioBufferList in
            let buffers = UnsafeMutableAudioBufferListPointer(audioBufferList)
            for frame in 0..<Int(frameCount) {
                let cutoff = 420 + 180 * sin(2 * .pi * 0.09 * time)
                let alpha = Float(1 - exp(-2 * .pi * cutoff / sampleRate))
                // two one-pole stages ≈ a 12 dB/octave low-pass
                low1 += alpha * (loop[position] - low1)
                low2 += alpha * (low1 - low2)
                gain += (0.06 - gain) * gainStep
                let sample = low2 * gain
                for buffer in buffers { buffer.mData?.assumingMemoryBound(to: Float.self)[frame] = sample }
                position = (position + 1) % loop.count
                time += 1 / sampleRate
            }
            return noErr
        }
    }

    /// Takes the queued voices. Runs on the audio thread, so an empty queue must not touch the allocator.
    nonisolated static func drain(_ pending: OSAllocatedUnfairLock<[NoteVoice]>) -> [NoteVoice] {
        pending.withLock { queued in
            guard !queued.isEmpty else { return [] }
            defer { queued = [] }
            return queued
        }
    }

    /// Sums the active note voices; new ones arrive through `pending`.
    private nonisolated static func makeVoicesNode(pending: OSAllocatedUnfairLock<[NoteVoice]>) -> AVAudioSourceNode {
        var active: [NoteVoice] = []
        return AVAudioSourceNode { _, _, frameCount, audioBufferList in
            active.append(contentsOf: drain(pending))
            let buffers = UnsafeMutableAudioBufferListPointer(audioBufferList)
            for frame in 0..<Int(frameCount) {
                var sample: Float = 0
                for i in active.indices { sample += active[i].nextSample() }
                for buffer in buffers { buffer.mData?.assumingMemoryBound(to: Float.self)[frame] = sample }
            }
            active.removeAll { $0.isFinished }
            return noErr
        }
    }
}
