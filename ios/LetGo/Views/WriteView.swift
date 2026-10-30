import SwiftUI

struct WriteView: View {
    @Bindable var model: FlowModel
    var focused: FocusState<Bool>.Binding
    @Binding var fieldFrame: CGRect
    let screenSize: CGSize
    var onRelease: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Text("What's weighing on you right now?")
                .font(.custom(Theme.serifName, size: min(30, max(22, screenSize.width * 0.05))))
                .foregroundStyle(Theme.ink)
                .multilineTextAlignment(.center)
                .padding(.bottom, 18)

            TextField("", text: $model.text,
                      prompt: Text("Write it here. No one will read it.").font(Theme.serifItalic(22)).foregroundStyle(Theme.inkFaint),
                      axis: .vertical)
                .font(Theme.serif(22))
                .foregroundStyle(Theme.ink)
                .tint(Theme.accent)
                .multilineTextAlignment(.center)
                .lineLimit(2...maxLines)
                .autocorrectionDisabled()
                .noWritingTools()
                .focused(focused)
                .padding(.vertical, 16)
                .padding(.horizontal, 18)
                .background(RoundedRectangle(cornerRadius: 18).fill(Theme.deep.opacity(0.28)))
                .overlay(RoundedRectangle(cornerRadius: 18)
                    .stroke(Theme.accent.opacity(focused.wrappedValue ? 0.38 : 0.16), lineWidth: 1))
                .animation(.easeInOut(duration: 0.4), value: focused.wrappedValue)
                .frame(maxWidth: 560)
                .onGeometryChange(for: CGRect.self) { $0.frame(in: .global) } action: { fieldFrame = $0 }
                .accessibilityIdentifier("thoughtField")
                .accessibilityLabel(Text("The thought to let go of"))

            Button("Let go", action: onRelease)
                .buttonStyle(PillButtonStyle())
                .disabled(!model.canRelease)
                .opacity(model.canRelease ? 1 : 0)
                .offset(y: model.canRelease ? 0 : 6)
                .animation(.easeInOut(duration: 0.4), value: model.canRelease)
                .padding(.top, 22)
                .accessibilityIdentifier("releaseButton")
        }
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    /// The field grows up to about 46% of the screen, then scrolls.
    private var maxLines: Int { max(2, Int(screenSize.height * 0.46 / 29)) }
}

private extension View {
    @ViewBuilder
    func noWritingTools() -> some View {
        if #available(iOS 18.0, *) {
            writingToolsBehavior(.disabled)
        } else {
            self
        }
    }
}
