import Foundation

/// One word placed on screen, `x`/`y` being its centre.
struct LaidOutWord: Equatable {
    let text: String
    let x: Double
    let y: Double
    let width: Double
    let fontSize: Double
}

/// Breaks the written text into words laid out the way they sat in the text field
/// (same algorithm as `layoutWords()` in the PWA).
enum WordLayout {
    private struct Item { let text: String; let width: Double }
    private struct Line { var items: [Item] = []; var width: Double = 0 }

    static func layout(text: String, maxWidth: Double, centerX: Double, centerY: Double,
                       screenHeight: Double, measure: (String, Double) -> Double) -> [LaidOutWord] {
        var fontSize = 22.0
        var lines: [Line]
        while true {
            lines = breakLines(text, maxWidth: maxWidth, fontSize: fontSize, measure: measure)
            if Double(lines.count) * fontSize * 1.6 <= screenHeight * 0.62 || fontSize <= 13 { break }
            fontSize -= 1
        }

        let lineHeight = fontSize * 1.6
        let space = measure(" ", fontSize)
        var y = centerY - Double(lines.count) * lineHeight / 2 + lineHeight / 2
        var words: [LaidOutWord] = []
        for line in lines {
            var x = centerX - line.width / 2
            for item in line.items {
                words.append(LaidOutWord(text: item.text, x: x + item.width / 2, y: y,
                                         width: item.width, fontSize: fontSize))
                x += item.width + space
            }
            y += lineHeight
        }
        return words
    }

    private static func breakLines(_ text: String, maxWidth: Double, fontSize: Double,
                                   measure: (String, Double) -> Double) -> [Line] {
        let space = measure(" ", fontSize)
        var lines: [Line] = []
        for paragraph in text.split(separator: "\n", omittingEmptySubsequences: false) {
            let words = paragraph.split(whereSeparator: \.isWhitespace)
            if words.isEmpty {
                // a blank line only counts once something was written above it
                if !lines.isEmpty { lines.append(Line()) }
                continue
            }
            var line = Line()
            for word in words {
                let width = measure(String(word), fontSize)
                if !line.items.isEmpty && line.width + space + width > maxWidth {
                    lines.append(line)
                    line = Line()
                }
                line.width += (line.items.isEmpty ? 0 : space) + width
                line.items.append(Item(text: String(word), width: width))
            }
            lines.append(line)
        }
        while let last = lines.last, last.items.isEmpty { lines.removeLast() }
        return lines
    }
}
