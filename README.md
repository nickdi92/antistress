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
