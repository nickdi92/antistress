# Lascia andare

Piccola webapp antistress: scrivi quello che ti pesa e guardalo affondare nell'acqua, poi un respiro guidato.

- Un solo file HTML, nessuna dipendenza, nessun build.
- Niente di quello che scrivi viene salvato o inviato.
- Installabile come app (PWA) e usabile offline quando è servita in https (es. GitHub Pages).

## Provarla in locale

Apri `index.html` nel browser, oppure servila (serve per testare il service worker):

```sh
php -S localhost:8000
# oppure
python3 -m http.server 8000
```

## File

| File | Cosa fa |
| --- | --- |
| `index.html` | L'app intera (HTML, CSS, JS) |
| `manifest.webmanifest` | Nome, colori e icone per l'installazione |
| `sw.js` | Service worker: rete prima, cache come fallback offline |
| `icon.svg`, `icon-*.png` | Icone (PNG per iOS/Android) |
| `privacy.html`, `support.html` | Pagine privacy e supporto (linkate dall'App Store) |
| `ios/` | App iOS nativa in SwiftUI (Let Go / Lascia andare) |
| `tools/render-icon.swift` | Genera le icone PNG da `icon.svg` |

## App iOS

La cartella `ios/` contiene l'app nativa per iPhone (SwiftUI, iOS 17+, italiano e inglese), con la stessa
esperienza della webapp.

- Aprire il progetto: `ios/LetGo.xcodeproj` in Xcode.
- Il progetto è generato da `ios/project.yml` con [XcodeGen](https://github.com/yonaskolb/XcodeGen):
  dopo aver aggiunto o tolto file, `cd ios && xcodegen generate`.
- Test: in Xcode **Product → Test**, oppure
  `xcodebuild -project ios/LetGo.xcodeproj -scheme LetGo -destination 'platform=iOS Simulator,name=iPhone 17' test`.
- Testi, screenshot e dati per la scheda dello Store: `ios/store/` (controllo: `bash ios/store/check.sh`).
- Pubblicazione passo-passo: [`ios/RELEASE.md`](ios/RELEASE.md).
