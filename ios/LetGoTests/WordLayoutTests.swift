import Foundation
import Testing
@testable import LetGo

struct WordLayoutTests {
    // At font size 22: "aa" is 22 wide, a space is 11
    let m: (String, Double) -> Double = { s, fs in Double(s.count) * fs * 0.5 }

    func layout(_ text: String, maxWidth: Double = 100, screenHeight: Double = 1000) -> [LaidOutWord] {
        WordLayout.layout(text: text, maxWidth: maxWidth, centerX: 200, centerY: 300,
                          screenHeight: screenHeight, measure: m)
    }

    @Test func wrapsAndCenters() {
        let w = layout("aa bb cc", maxWidth: 60)
        #expect(w.map(\.text) == ["aa", "bb", "cc"])
        #expect(w.map(\.x) == [183.5, 216.5, 200])
        #expect(abs(w[0].y - 282.4) < 1e-9)
        #expect(abs(w[1].y - 282.4) < 1e-9)
        #expect(abs(w[2].y - 317.6) < 1e-9)
        #expect(w.allSatisfy { $0.fontSize == 22 })
        #expect(w.map(\.width) == [22, 22, 22])
    }

    @Test func shrinksFontUntilFits() {
        let text = Array(repeating: "aa", count: 10).joined(separator: "\n")
        let w = layout(text, screenHeight: 400)
        #expect(w.count == 10)
        #expect(w.allSatisfy { $0.fontSize == 15 })
    }

    @Test func neverBelow13() {
        let text = Array(repeating: "aa", count: 200).joined(separator: "\n")
        let w = layout(text, screenHeight: 100)
        #expect(w.count == 200)
        #expect(w.allSatisfy { $0.fontSize == 13 })
    }

    @Test func longSingleWordOwnLine() {
        let w = layout("a " + String(repeating: "x", count: 600) + " b")
        #expect(w.count == 3)
        #expect(w[0].y < w[1].y && w[1].y < w[2].y)
        #expect(w[1].x == 200)
    }

    @Test func blankLinesKeptTrailingDropped() {
        let w = layout("a\n\n\nb\n\n")
        #expect(w.map(\.text) == ["a", "b"])
        #expect(abs((w[1].y - w[0].y) - 3 * 22 * 1.6) < 1e-9)
        // four lines (a, blank, blank, b) centred on 300
        #expect(abs((w[0].y + w[1].y) / 2 - 300) < 1e-9)
    }

    @Test func leadingBlankLinesIgnored() {
        let w = layout("\n\na")
        #expect(w.count == 1)
        #expect(abs(w[0].y - 300) < 1e-9)
    }

    @Test func whitespaceOnlyGivesNoWords() {
        #expect(layout("  \n \t").isEmpty)
    }
}
