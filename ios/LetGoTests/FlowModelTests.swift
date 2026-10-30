import Foundation
import Testing
@testable import LetGo

struct FlowModelTests {
    func word(sinkAt: Double, duration: Double = 2) -> SinkingWord {
        SinkingWord(word: LaidOutWord(text: "w", x: 0, y: 0, width: 10, fontSize: 22),
                    dx: 0, dy: 0, rotation: 0, duration: duration, sinkAt: sinkAt, startedAt: nil, isDone: false)
    }

    /// A model that entered the "after" phase at t = 2.4
    func modelInAfter() -> FlowModel {
        let model = FlowModel()
        model.text = "a"
        model.release(words: [word(sinkAt: 0, duration: 1)], now: 0)
        _ = model.advance(now: 0)    // starts
        _ = model.advance(now: 1)    // done
        _ = model.advance(now: 2.4)  // 1.4 s later → after
        return model
    }

    @Test func cannotReleaseWhitespace() {
        let model = FlowModel()
        model.text = "  \n\t "
        #expect(!model.canRelease)
        #expect(!model.release(words: [word(sinkAt: 1.4)], now: 0))
        #expect(model.phase == .write)
    }

    @Test func releaseOnlyOnce() {
        let model = FlowModel()
        model.text = "a"
        #expect(model.release(words: [word(sinkAt: 1.4)], now: 0))
        #expect(!model.release(words: [word(sinkAt: 1.4), word(sinkAt: 2)], now: 0.1))
        #expect(model.words.count == 1)
        #expect(model.releasedAt == 0)
    }

    @Test func emptyWordsDoNotRelease() {
        let model = FlowModel()
        model.text = "a"
        #expect(!model.release(words: [], now: 0))
        #expect(model.phase == .write)
    }

    @Test func textTruncatedTo600() {
        let model = FlowModel()
        model.text = String(repeating: "x", count: 700)
        #expect(model.text.count == 600)
    }

    @Test func advanceTimeline() {
        let model = FlowModel()
        model.text = "a b"
        model.release(words: [word(sinkAt: 1.4), word(sinkAt: 2.0)], now: 100)
        #expect(model.advance(now: 101.0).isEmpty)
        #expect(model.advance(now: 101.5).count == 1)
        #expect(model.advance(now: 102.1).count == 1)
        _ = model.advance(now: 104.2)
        #expect(model.words.allSatisfy { $0.isDone })
        _ = model.advance(now: 105.4)
        #expect(model.phase == .release)
        _ = model.advance(now: 105.6)
        #expect(model.phase == .after)
        #expect(model.text.isEmpty && model.words.isEmpty)
        #expect(model.afterStartedAt == 105.6)
    }

    @Test func advanceDoesNothingOutsideRelease() {
        let model = FlowModel()
        #expect(model.advance(now: 10).isEmpty)
        #expect(model.phase == .write)
    }

    @Test func skipShowsAgain() {
        let model = modelInAfter()
        model.skip(now: 2.4 + 5)
        let s = model.afterState(now: 2.4 + 5)
        #expect(s.againVisible && s.message == .gone)
    }

    @Test func skipIgnoredOnceAgainVisible() {
        let model = modelInAfter()
        model.skip(now: 2.4 + 14)
        #expect(!model.afterSkipped)
    }

    @Test func againReturnsToWrite() {
        let model = modelInAfter()
        model.skip(now: 3)
        model.again()
        #expect(model.phase == .write)
        #expect(!model.afterSkipped)
    }

    @Test func longGapStillReachesAfter() {
        let model = FlowModel()
        model.text = "a b"
        model.release(words: [word(sinkAt: 1.4, duration: 3), word(sinkAt: 2.0, duration: 3)], now: 0)
        #expect(model.advance(now: 100).count == 2)
        _ = model.advance(now: 103.5)
        _ = model.advance(now: 105)
        #expect(model.phase == .after)
    }
}
