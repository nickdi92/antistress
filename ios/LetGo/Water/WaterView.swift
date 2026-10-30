import SwiftUI

/// Owns the frame clock and the water simulation; not observed, the timeline redraws every frame.
@MainActor
final class WaterController {
    private let launch = Date()
    private var previous: Double?
    var scene: WaterScene

    init() {
        var rng = SystemRandomNumberGenerator()
        scene = WaterScene(reduceMotion: false, rng: &rng)
    }

    func now() -> Double { Date().timeIntervalSince(launch) }
    func time(of date: Date) -> Double { date.timeIntervalSince(launch) }

    func tick(at t: Double, model: FlowModel, sound: SoundEngine) {
        let dt = min(t - (previous ?? t), 0.05)
        previous = t
        scene.step(dt: dt)
        let started = model.advance(now: t)
        for word in started {
            scene.addRipple(x: word.word.x, y: word.word.y, size: clamp(word.word.width / 70, 0.6, 1.4))
        }
        for _ in SinkingWord.audible(started, releasedAt: model.releasedAt, now: t) {
            sound.drop()
            Haptics.drop()
        }
    }
}

struct WaterView: View {
    let controller: WaterController
    let model: FlowModel
    let sound: SoundEngine
    let reduceMotion: Bool
    var onTap: (CGPoint) -> Void

    var body: some View {
        TimelineView(.animation) { timeline in
            let t = controller.time(of: timeline.date)
            Canvas { context, size in
                drawWater(&context, size: size, t: t)
                if model.phase == .release { drawWords(&context, t: t) }
            }
            .onChange(of: timeline.date) { _, date in
                controller.tick(at: controller.time(of: date), model: model, sound: sound)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture(coordinateSpace: .local) { onTap($0) }
        .accessibilityHidden(true)
    }

    private func drawWater(_ context: inout GraphicsContext, size: CGSize, t: Double) {
        let w = size.width, h = size.height
        context.fill(Path(CGRect(origin: .zero, size: size)),
                     with: .linearGradient(Gradient(stops: Theme.waterStops), startPoint: .zero, endPoint: CGPoint(x: 0, y: h)))

        let m = max(w, h)
        context.drawLayer { layer in
            layer.blendMode = .plusLighter
            for b in controller.scene.blobs {
                let x = wrap(b.px + sin(t * b.sx + b.ph) * 0.25) * w
                let y = wrap(b.py + cos(t * b.sy + b.ph) * 0.2) * h
                let r = b.r * m * (0.9 + 0.1 * sin(t * 0.3 + b.ph))
                let rect = CGRect(x: x - r, y: y - r, width: r * 2, height: r * 2)
                layer.fill(Path(rect), with: .radialGradient(
                    Gradient(colors: [Color(red: 70 / 255, green: 160 / 255, blue: 180 / 255).opacity(0.07),
                                      Color(red: 70 / 255, green: 160 / 255, blue: 180 / 255).opacity(0)]),
                    center: CGPoint(x: x, y: y), startRadius: 0, endRadius: r))
            }
        }

        for s in controller.scene.specks {
            let a = s.a * (0.6 + 0.4 * sin(t * 0.8 + s.ph))
            let rect = CGRect(x: s.x * w - s.s, y: s.y * h - s.s, width: s.s * 2, height: s.s * 2)
            context.fill(Path(ellipseIn: rect), with: .color(Color(red: 200 / 255, green: 235 / 255, blue: 235 / 255).opacity(a)))
        }

        for r in controller.scene.ripples where r.progress != nil {
            let rect = CGRect(x: r.x - r.radius, y: r.y - r.radius * 0.58, width: r.radius * 2, height: r.radius * 2 * 0.58)
            context.stroke(Path(ellipseIn: rect),
                           with: .color(Color(red: 190 / 255, green: 232 / 255, blue: 234 / 255).opacity(r.alpha)),
                           lineWidth: r.lineWidth)
        }
    }

    private func drawWords(_ context: inout GraphicsContext, t: Double) {
        let since = t - model.releasedAt
        for (i, word) in model.words.enumerated() where !word.isDone {
            let a = word.appearance(now: t, sinceRelease: since, index: i, reduceMotion: reduceMotion)
            let text = context.resolve(Text(verbatim: word.word.text)
                .font(Theme.serif(word.word.fontSize))
                .foregroundStyle(Color(red: a.color.r / 255, green: a.color.g / 255, blue: a.color.b / 255)))
            context.drawLayer { layer in
                layer.opacity = a.alpha
                if a.blur > 0 { layer.addFilter(.blur(radius: a.blur)) }
                layer.translateBy(x: word.word.x + a.offsetX, y: word.word.y + a.offsetY)
                layer.rotate(by: .radians(a.rotation))
                layer.scaleBy(x: a.scale, y: a.scale)
                layer.draw(text, at: .zero, anchor: .center)
            }
        }
    }

    private func wrap(_ v: Double) -> Double {
        (v.truncatingRemainder(dividingBy: 1) + 1).truncatingRemainder(dividingBy: 1)
    }
}
