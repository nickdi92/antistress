import Foundation
import Testing
@testable import LetGo

struct SinkingWordTests {
    let word = LaidOutWord(text: "peso", x: 100, y: 200, width: 40, fontSize: 22)

    func words(_ n: Int) -> [LaidOutWord] {
        (0..<n).map { LaidOutWord(text: "w\($0)", x: Double($0), y: 0, width: 10, fontSize: 22) }
    }

    @Test func sinkScheduleFollowsGap() {
        var rng = SeededRNG(seed: 1)
        let few = SinkingWord.make(from: words(4), rng: &rng)   // gap 0.55
        for (i, w) in few.enumerated() {
            #expect(w.sinkAt >= 1.4 + 0.55 * Double(i))
            #expect(w.sinkAt <= 1.4 + 0.55 * Double(i) + 0.275)
        }
        let many = SinkingWord.make(from: words(100), rng: &rng)  // gap 0.16
        #expect(zip(many, many.dropFirst()).allSatisfy { $0.sinkAt < $1.sinkAt })
        #expect(many.last!.sinkAt <= 1.4 + 0.16 * 99 + 0.08)
        #expect(many.map(\.word) == words(100))
    }

    @Test func randomRangesRespected() {
        var rng = SeededRNG(seed: 2)
        let all = SinkingWord.make(from: words(200), rng: &rng)
        #expect(all.allSatisfy { (-14...14).contains($0.dx) })
        #expect(all.allSatisfy { (4...18).contains($0.dy) })
        #expect(all.allSatisfy { (-0.18...0.18).contains($0.rotation) })
        #expect(all.allSatisfy { (2.2...3).contains($0.duration) })
        #expect(all.allSatisfy { $0.startedAt == nil && !$0.isDone })
        // values are actually random, not constants
        #expect(Set(all.map(\.dx)).count > 100)
    }

    @Test func appearanceBeforeStart() {
        let w = SinkingWord(word: word, dx: 10, dy: 8, rotation: 0.1, duration: 2, sinkAt: 1.4, startedAt: nil, isDone: false)
        let a = w.appearance(now: 0, sinceRelease: 0.225, index: 0, reduceMotion: false)
        #expect(abs(a.alpha - 0.5) < 1e-9)
        #expect(a.scale == 1)
        #expect(a.blur == 0)
        #expect(a.color == RGB(r: 236, g: 232, b: 222))
    }

    @Test func appearanceMidSink() {
        let w = SinkingWord(word: word, dx: 10, dy: 8, rotation: 0.1, duration: 2, sinkAt: 1.4, startedAt: 0, isDone: false)
        let a = w.appearance(now: 1, sinceRelease: 5, index: 0, reduceMotion: false)   // e = ee = 0.5
        #expect(abs(a.scale - 0.725) < 1e-9)
        #expect(abs(a.blur - 2.5) < 1e-9)
        #expect(abs(a.offsetX - 5) < 1e-9)
        #expect(abs(a.rotation - 0.05) < 1e-9)
        #expect(a.color == RGB(r: 178, g: 206, b: 206))
        #expect(abs(a.alpha - (1 - pow(0.5, 1.15))) < 1e-9)
        #expect(abs(a.offsetY - (sin(1.6) * 1.6 * 0.5 + 4)) < 1e-9)
    }

    @Test func reduceMotionAppearance() {
        let w = SinkingWord(word: word, dx: 10, dy: 8, rotation: 0.1, duration: 2, sinkAt: 1.4, startedAt: 0, isDone: false)
        let a = w.appearance(now: 1, sinceRelease: 5, index: 0, reduceMotion: true)
        #expect(a.offsetX == 0 && a.offsetY == 0 && a.rotation == 0)
        #expect(a.scale == 1 && a.blur == 0)
        #expect(a.color == RGB(r: 178, g: 206, b: 206))
        #expect(abs(a.alpha - (1 - pow(0.5, 1.15))) < 1e-9)
    }

    @Test func noBlurAtVeryStart() {
        let w = SinkingWord(word: word, dx: 10, dy: 8, rotation: 0.1, duration: 3, sinkAt: 1.4, startedAt: 0, isDone: false)
        #expect(w.appearance(now: 0.05, sinceRelease: 5, index: 0, reduceMotion: false).blur == 0)
    }

    func sinking(_ sinkAt: Double) -> SinkingWord {
        SinkingWord(word: word, dx: 0, dy: 0, rotation: 0, duration: 2, sinkAt: sinkAt, startedAt: nil, isDone: false)
    }

    @Test func onTimeWordIsAudible() {
        #expect(SinkingWord.audible([sinking(1.4)], releasedAt: 10, now: 11.42).count == 1)
    }

    // back from the background, every overdue word starts in the same frame: no burst of notes
    @Test func lateWordsStaySilent() {
        let overdue = (0..<50).map { sinking(1.4 + Double($0) * 0.16) }
        #expect(SinkingWord.audible(overdue, releasedAt: 0, now: 100).isEmpty)
    }

    @Test func atMostTwoPerFrame() {
        let together = Array(repeating: sinking(1.4), count: 5)
        #expect(SinkingWord.audible(together, releasedAt: 0, now: 1.45).count == 2)
    }
}
