import Foundation
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
