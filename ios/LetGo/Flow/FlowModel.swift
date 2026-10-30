import Foundation
import Observation

enum Phase: Equatable {
    case write
    case release
    case after
}

/// write → release (words sink) → after (closing sequence) → write.
/// Time is passed in explicitly so the flow can be driven by the frame clock and tested.
@Observable
final class FlowModel {
    static let maxLength = 600

    var text = "" {
        didSet {
            if text.count > Self.maxLength { text = String(text.prefix(Self.maxLength)) }
        }
    }
    private(set) var phase: Phase = .write
    private(set) var words: [SinkingWord] = []
    private(set) var releasedAt: Double = 0
    private(set) var afterStartedAt: Double = 0
    private(set) var afterSkipped = false
    private var allDoneAt: Double?

    var canRelease: Bool {
        phase == .write && !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    @discardableResult
    func release(words: [SinkingWord], now: Double) -> Bool {
        guard canRelease, !words.isEmpty else { return false }
        self.words = words
        releasedAt = now
        allDoneAt = nil
        phase = .release
        return true
    }

    /// Moves the sinking words forward; returns the words that started sinking in this tick.
    func advance(now: Double) -> [SinkingWord] {
        guard phase == .release else { return [] }
        var started: [SinkingWord] = []
        for i in words.indices where !words[i].isDone {
            if let start = words[i].startedAt {
                if now - start >= words[i].duration { words[i].isDone = true }
            } else if now - releasedAt >= words[i].sinkAt {
                words[i].startedAt = now
                started.append(words[i])
            }
        }
        if words.allSatisfy(\.isDone) {
            let doneAt = allDoneAt ?? now
            allDoneAt = doneAt
            if now - doneAt > 1.3 {
                phase = .after
                afterStartedAt = now
                afterSkipped = false
                text = ""
                words = []
            }
        }
        return started
    }

    func afterState(now: Double) -> AfterState {
        AfterSequence.state(elapsed: now - afterStartedAt, skipped: afterSkipped)
    }

    /// A tap during the closing sequence jumps straight to the button.
    func skip(now: Double) {
        guard phase == .after, !afterState(now: now).againVisible else { return }
        afterSkipped = true
    }

    func again() {
        phase = .write
        afterSkipped = false
    }
}
