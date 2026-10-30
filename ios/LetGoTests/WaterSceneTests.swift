import Foundation
import Testing
@testable import LetGo

struct WaterSceneTests {
    func scene(reduced: Bool = false) -> WaterScene {
        var rng = SeededRNG(seed: 3)
        return WaterScene(reduceMotion: reduced, rng: &rng)
    }

    @Test func counts() {
        let s = scene()
        #expect(s.blobs.count == 6)
        #expect(s.specks.count == 46)
        #expect(s.ripples.isEmpty)
    }

    @Test func randomRangesRespected() {
        let s = scene()
        #expect(s.blobs.allSatisfy { (0...1).contains($0.px) && (0.35...0.7).contains($0.r) && (0.015...0.04).contains($0.sy) })
        #expect(s.blobs.allSatisfy { (0.02...0.05).contains(abs($0.sx)) })
        #expect(s.specks.allSatisfy { (0.6...1.8).contains($0.s) && (0.08...0.3).contains($0.a) })
        #expect(s.specks.allSatisfy { (-0.004...0.004).contains($0.vx) && (-0.003...0.003).contains($0.vy) })
    }

    @Test func rippleIsAPair() {
        var s = scene()
        s.addRipple(x: 10, y: 20, size: 1)
        #expect(s.ripples == [
            Ripple(x: 10, y: 20, age: 0, life: 3.2, maxRadius: 110),
            Ripple(x: 10, y: 20, age: -0.28, life: 2.8, maxRadius: 70),
        ])
    }

    @Test func reducedRippleIsSingle() {
        var s = scene(reduced: true)
        s.addRipple(x: 10, y: 20, size: 2)
        #expect(s.ripples == [Ripple(x: 10, y: 20, age: 0, life: 1.6, maxRadius: 100)])
    }

    @Test func delayMakesAgeNegative() {
        var s = scene()
        s.addRipple(x: 0, y: 0, delay: 0.5)
        #expect(s.ripples.map(\.age) == [-0.5, -0.78])
        #expect(s.ripples.allSatisfy { $0.progress == nil })
    }

    @Test func stepRemovesFinished() {
        var s = scene()
        s.addRipple(x: 0, y: 0)
        s.step(dt: 1)
        #expect(s.ripples.count == 2)
        s.step(dt: 2.3)
        #expect(s.ripples.isEmpty)
    }

    @Test func rippleGeometryAtHalf() {
        let r = Ripple(x: 0, y: 0, age: 1.6, life: 3.2, maxRadius: 100)
        #expect(r.progress == 0.5)
        #expect(abs(r.radius - 87.5) < 1e-9)
        #expect(abs(r.alpha - 0.19) < 1e-9)
        #expect(abs(r.lineWidth - 1.1) < 1e-9)
    }

    @Test func specksWrapInUnitSquare() {
        var s = scene()
        let before = s.specks.map(\.x)
        for _ in 0..<100 { s.step(dt: 0.05) }
        #expect(s.specks.allSatisfy { (0..<1).contains($0.x) && (0..<1).contains($0.y) })
        #expect(s.specks.map(\.x) != before)
    }

    @Test func reducedSpecksStill() {
        var s = scene(reduced: true)
        let before = s.specks.map(\.x)
        s.step(dt: 1)
        #expect(s.specks.map(\.x) == before)
    }
}
