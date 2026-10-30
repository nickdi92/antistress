import Foundation
import Testing
@testable import LetGo

struct AfterSequenceTests {
    @Test(arguments: [
        (0.1, nil, false, false),
        (1.0, .gone, true, false),
        (3.0, .gone, false, false),
        (5.0, .slowBreath, true, false),
        (14.0, .slowBreath, true, true),
    ] as [(Double, AfterMessage?, Bool, Bool)])
    func messageAndAgain(_ c: (Double, AfterMessage?, Bool, Bool)) {
        let s = AfterSequence.state(elapsed: c.0, skipped: false)
        #expect(s.message == c.1)
        #expect(s.messageVisible == c.2)
        #expect(s.againVisible == c.3)
    }

    @Test func breathLabels() {
        let a = AfterSequence.state(elapsed: 4.0, skipped: false)
        #expect(a.breathVisible && a.label == .breatheIn && a.labelVisible)
        #expect(abs(a.breathElapsed! - 0.4) < 1e-9)
        let b = AfterSequence.state(elapsed: 7.5, skipped: false)
        #expect(b.label == .breatheIn && !b.labelVisible)
        let c = AfterSequence.state(elapsed: 8.0, skipped: false)
        #expect(c.label == .breatheOut && c.labelVisible)
        let d = AfterSequence.state(elapsed: 13.5, skipped: false)
        #expect(d.label == .breatheOut && !d.labelVisible && !d.againVisible)
        #expect(!AfterSequence.state(elapsed: 3.0, skipped: false).breathVisible)
        #expect(AfterSequence.state(elapsed: 3.0, skipped: false).breathElapsed == nil)
    }

    @Test func skippedState() {
        let s = AfterSequence.state(elapsed: 5, skipped: true)
        #expect(s.message == .gone && s.messageVisible)
        #expect(!s.breathVisible && s.breathElapsed == nil && !s.labelVisible)
        #expect(s.againVisible)
    }

    @Test(arguments: [(0.0, 0.42), (2.0, 0.71), (4.0, 1.0), (7.0, 0.71), (10.0, 0.42), (12.0, 0.42), (-1.0, 0.42)])
    func breathScaleKeyframes(_ c: (Double, Double)) {
        #expect(abs(AfterSequence.breathScale(elapsed: c.0) - c.1) < 1e-9)
    }
}
