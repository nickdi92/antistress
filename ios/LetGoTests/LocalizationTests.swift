import Foundation
import Testing
@testable import LetGo

struct Pair: Sendable, CustomStringConvertible {
    let en: String
    let it: String
    var description: String { en }
}

// "Lingue" table from the spec, copied verbatim
let pairs: [Pair] = [
    .init(en: "What's weighing on you right now?", it: "Cosa ti pesa, adesso?"),
    .init(en: "Write it here. No one will read it.", it: "Scrivilo qui. Non lo leggerà nessuno."),
    .init(en: "Let go", it: "Lascia andare"),
    .init(en: "Nothing is saved or sent. It stays here a moment, then it's gone.", it: "Niente viene salvato né inviato. Resta qui un momento, poi se ne va."),
    .init(en: "Gone.", it: "Andato."),
    .init(en: "One slow breath.", it: "Un respiro lento."),
    .init(en: "breathe in", it: "inspira"),
    .init(en: "breathe out", it: "espira"),
    .init(en: "Write another thought", it: "Scrivi un altro pensiero"),
    .init(en: "The thought to let go of", it: "Il pensiero da lasciare andare"),
    .init(en: "Sound on: tap to turn off", it: "Suono attivo: tocca per spegnere"),
    .init(en: "Sound off: tap to turn on", it: "Suono spento: tocca per attivare"),
]

func lproj(_ code: String) -> Bundle? {
    Bundle.main.path(forResource: code, ofType: "lproj").flatMap(Bundle.init(path:))
}

@Test(arguments: pairs) func italian(_ p: Pair) throws {
    let bundle = try #require(lproj("it"))
    #expect(bundle.localizedString(forKey: p.en, value: "MISSING", table: nil) == p.it)
}

@Test(arguments: pairs) func english(_ p: Pair) throws {
    let bundle = try #require(lproj("en"))
    #expect(bundle.localizedString(forKey: p.en, value: "MISSING", table: nil) == p.en)
}

@Test func displayNames() throws {
    let it = try #require(lproj("it"))
    let en = try #require(lproj("en"))
    #expect(it.localizedString(forKey: "CFBundleDisplayName", value: nil, table: "InfoPlist") == "Lascia andare")
    #expect(en.localizedString(forKey: "CFBundleDisplayName", value: nil, table: "InfoPlist") == "Let Go")
}
