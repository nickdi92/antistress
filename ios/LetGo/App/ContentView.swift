import SwiftUI

struct ContentView: View {
    var body: some View {
        ZStack {
            Color(red: 6 / 255, green: 20 / 255, blue: 31 / 255).ignoresSafeArea()
            Text("What's weighing on you right now?")
                .foregroundStyle(.white)
        }
    }
}
