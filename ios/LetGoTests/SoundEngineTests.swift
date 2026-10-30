import Foundation
import os
import Testing
@testable import LetGo

@MainActor
struct SoundEngineTests {
    func freshDefaults() -> UserDefaults { UserDefaults(suiteName: "test-\(UUID())")! }

    @Test func preferencePersists() {
        let d = freshDefaults()
        #expect(SoundEngine(defaults: d).isOn)
        SoundEngine(defaults: d).setOn(false)
        #expect(!SoundEngine(defaults: d).isOn)
        SoundEngine(defaults: d).setOn(true)
        #expect(SoundEngine(defaults: d).isOn)
    }

    @Test func dropBeforeStartIsHarmless() {
        let e = SoundEngine(defaults: freshDefaults())
        e.drop()
        #expect(!e.isRunning)
    }

    @Test func interruptionRestartsEngine() {
        let e = SoundEngine(defaults: freshDefaults())
        e.start()
        #expect(e.isRunning)
        e.handleInterruption(began: true)
        #expect(!e.isRunning)
        e.handleInterruption(began: false)
        #expect(e.isRunning)
    }
}

struct PendingQueueTests {
    func storageAddress(_ lock: OSAllocatedUnfairLock<[NoteVoice]>) -> UInt {
        lock.withLock { q in q.withUnsafeBufferPointer { UInt(bitPattern: $0.baseAddress) } }
    }

    @Test func drainReturnsQueuedVoices() {
        let voice = NoteVoice(frequency: 440, softness: 1, sampleRate: 48_000)
        let lock = OSAllocatedUnfairLock(initialState: [voice, voice])
        #expect(SoundEngine.drain(lock).count == 2)
        #expect(lock.withLock { $0.isEmpty })
    }

    // the render callback drains on every cycle: an empty drain must keep the same storage (no allocation)
    @Test func emptyDrainKeepsStorage() {
        var queue = [NoteVoice(frequency: 440, softness: 1, sampleRate: 48_000)]
        queue.removeAll(keepingCapacity: true)
        let lock = OSAllocatedUnfairLock(initialState: queue)
        let before = storageAddress(lock)
        #expect(SoundEngine.drain(lock).isEmpty)
        #expect(storageAddress(lock) == before)
    }
}
