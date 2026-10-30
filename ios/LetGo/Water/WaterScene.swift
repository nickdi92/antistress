import Foundation

/// Soft light patch drifting under the surface (positions are fractions of the screen).
struct Blob {
    let px, py, r, sx, sy, ph: Double
}

/// Tiny speck floating on the surface.
struct Speck {
    var x, y: Double
    let s, a, vx, vy, ph: Double
}

struct Ripple: Equatable {
    let x, y: Double
    var age: Double
    let life: Double
    let maxRadius: Double

    /// nil while the ripple is still waiting for its delay
    var progress: Double? { age < 0 ? nil : age / life }
    var radius: Double { Easing.out(progress ?? 0) * maxRadius }
    var alpha: Double { (1 - (progress ?? 0)) * 0.38 }
    var lineWidth: Double { 1.4 * (1 - (progress ?? 0)) + 0.4 }
}

/// The animated water, without drawing (values from the PWA's canvas code).
struct WaterScene {
    var reduceMotion: Bool
    private(set) var blobs: [Blob]
    private(set) var specks: [Speck]
    private(set) var ripples: [Ripple] = []

    init(reduceMotion: Bool, rng: inout some RandomNumberGenerator) {
        self.reduceMotion = reduceMotion
        blobs = (0..<6).map { _ in
            Blob(px: .random(in: 0...1, using: &rng), py: .random(in: 0...1, using: &rng),
                 r: .random(in: 0.35...0.7, using: &rng),
                 sx: .random(in: 0.02...0.05, using: &rng) * (Bool.random(using: &rng) ? -1 : 1),
                 sy: .random(in: 0.015...0.04, using: &rng), ph: .random(in: 0...6.28, using: &rng))
        }
        specks = (0..<46).map { _ in
            Speck(x: .random(in: 0..<1, using: &rng), y: .random(in: 0..<1, using: &rng),
                  s: .random(in: 0.6...1.8, using: &rng), a: .random(in: 0.08...0.3, using: &rng),
                  vx: .random(in: -0.004...0.004, using: &rng), vy: .random(in: -0.003...0.003, using: &rng),
                  ph: .random(in: 0...6.28, using: &rng))
        }
    }

    mutating func addRipple(x: Double, y: Double, size: Double = 1, delay: Double = 0) {
        ripples.append(Ripple(x: x, y: y, age: -delay, life: reduceMotion ? 1.6 : 3.2,
                              maxRadius: (reduceMotion ? 50 : 110) * size))
        if !reduceMotion {
            ripples.append(Ripple(x: x, y: y, age: -delay - 0.28, life: 2.8, maxRadius: 70 * size))
        }
    }

    mutating func step(dt: Double) {
        if !reduceMotion {
            for i in specks.indices {
                specks[i].x = (specks[i].x + specks[i].vx * dt + 1).truncatingRemainder(dividingBy: 1)
                specks[i].y = (specks[i].y + specks[i].vy * dt + 1).truncatingRemainder(dividingBy: 1)
            }
        }
        for i in ripples.indices { ripples[i].age += dt }
        ripples.removeAll { ($0.progress ?? 0) >= 1 }
    }
}
