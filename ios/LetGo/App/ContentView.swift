import SwiftUI

struct ContentView: View {
    @State private var model = FlowModel()
    @State private var water = WaterController()
    @State private var sound = SoundEngine()
    @State private var soundOn = true
    @State private var fieldFrame: CGRect = .zero
    @State private var screenSize: CGSize = .zero
    @FocusState private var fieldFocused: Bool
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack {
            WaterView(controller: water, model: model, sound: sound, reduceMotion: reduceMotion, onTap: tapWater)
                .ignoresSafeArea()
                .onGeometryChange(for: CGSize.self) { $0.size } action: { screenSize = $0 }

            WriteView(model: model, focused: $fieldFocused, fieldFrame: $fieldFrame,
                      screenSize: screenSize, onRelease: release)
                .opacity(model.phase == .write ? 1 : 0)
                .allowsHitTesting(model.phase == .write)
                .accessibilityHidden(model.phase != .write)
                .animation(.easeInOut(duration: 0.7), value: model.phase)

            if model.phase == .after {
                AfterView(model: model, clock: water, screenWidth: screenSize.width, onAgain: again)
                    .transition(.opacity.animation(.easeInOut(duration: 0.7)))
            }

            Text("Nothing is saved or sent. It stays here a moment, then it's gone.")
                .font(.system(size: 12))
                .lineSpacing(2)
                .foregroundStyle(Theme.inkFaint)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 16)
                .padding(.bottom, 14)
                .frame(maxHeight: .infinity, alignment: .bottom)
                .opacity(model.phase == .write ? 1 : 0)
                .animation(.easeInOut(duration: 0.6), value: model.phase)
                .allowsHitTesting(false)
                .ignoresSafeArea(.keyboard)

            SoundButton(isOn: soundOn, action: toggleSound)
                .padding(.top, 14)
                .padding(.trailing, 14)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)

            // the app switcher snapshot must never show what was written
            if scenePhase != .active {
                LinearGradient(stops: Theme.waterStops, startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()
            }
        }
        .preferredColorScheme(.dark)
        .onAppear {
            soundOn = sound.isOn
            water.scene.reduceMotion = reduceMotion
            sound.start()
        }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active { sound.resumeIfNeeded() }
        }
        .onChange(of: reduceMotion) { _, reduce in
            water.scene.reduceMotion = reduce
        }
    }

    private func tapWater(_ point: CGPoint) {
        fieldFocused = false
        guard model.phase == .write else { return }
        water.scene.addRipple(x: point.x, y: point.y, size: 0.8)
        sound.drop(softness: 0.6)
    }

    private func release() {
        guard model.canRelease else { return }
        var fonts: [Double: UIFont] = [:]
        let measure: (String, Double) -> Double = { text, size in
            let font = fonts[size] ?? Theme.uiSerif(size)
            fonts[size] = font
            return (text as NSString).size(withAttributes: [.font: font]).width
        }
        let laidOut = WordLayout.layout(text: model.text,
                                        maxWidth: min(fieldFrame.width - 36, screenSize.width - 32),
                                        centerX: screenSize.width / 2, centerY: fieldFrame.midY,
                                        screenHeight: screenSize.height, measure: measure)
        var rng = SystemRandomNumberGenerator()
        Haptics.prepare()
        if model.release(words: SinkingWord.make(from: laidOut, rng: &rng), now: water.now()) {
            fieldFocused = false
        }
    }

    private func again() {
        model.again()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) { fieldFocused = true }
    }

    private func toggleSound() {
        soundOn.toggle()
        sound.setOn(soundOn)
    }
}
