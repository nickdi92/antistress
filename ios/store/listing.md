# Scheda App Store — Let Go / Lascia andare

Valori da inserire in App Store Connect. I testi per lingua sono nelle cartelle `en/` e `it/`
(un file per campo), gli screenshot in `screenshots/<lingua>/`. Prima di caricarli: `bash ios/store/check.sh`.

## Informazioni app

| Campo | Valore |
| --- | --- |
| Bundle ID | `io.github.nickdi92.letgo` |
| SKU | `letgo-ios-1` |
| Lingua principale | English (U.S.) |
| Localizzazioni | English (U.S.), Italiano |
| Categoria principale | Health & Fitness (Salute e fitness) |
| Categoria secondaria | Lifestyle (Stile di vita) |
| Diritti sui contenuti | Nessun contenuto di terze parti |
| Copyright | `2026 <nome e cognome legale>` — da compilare |

## URL

| Campo | Valore |
| --- | --- |
| Privacy Policy URL | https://nickdi92.github.io/antistress/privacy.html |
| Support URL | https://nickdi92.github.io/antistress/support.html |
| Marketing URL | (vuoto) |

## Prezzo e disponibilità

- Prezzo: gratis.
- Disponibilità: tutti i paesi e le regioni **tranne Cina continentale** (lì serve una registrazione governativa).

## App Privacy

- "Do you or your third-party partners collect data from this app?" → **No, we do not collect data from this app.**
- Risultato in scheda: **Data Not Collected**.

## Età (questionario)

Tutte le risposte **No / None**: niente violenza, contenuti per adulti, gioco d'azzardo, contenuti generati dagli utenti condivisi,
chat, accesso web libero, acquisti, pubblicità. Fascia risultante: la più bassa disponibile.

## Export compliance

Già risolta: `ITSAppUsesNonExemptEncryption = NO` nell'Info.plist, App Store Connect non la chiede.

## Note per la revisione

Incollare `review_notes.txt` nel campo "Notes". Nessun account demo: "Sign-in required" → No.
