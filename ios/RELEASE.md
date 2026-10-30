# Pubblicare Let Go su App Store

Guida passo-passo, pensata per la prima volta e riusabile per le app successive.
I nomi dei menu di Xcode sono in inglese (Xcode non è tradotto); quelli di App Store Connect in italiano,
con l'inglese tra parentesi.

Tutto il materiale per la scheda è in `ios/store/` (vedi `ios/store/listing.md`).

---

## 0. Prima di iniziare

- Iscrizione all'Apple Developer Program **approvata** (arriva un'email "Welcome to the Apple Developer Program").
- Xcode aggiornato all'ultima versione dal Mac App Store: Apple accetta solo build fatte con l'SDK più recente.
- Su appstoreconnect.apple.com → **Accordi, imposte e banche** (Agreements, Tax, and Banking): accetta gli accordi
  in sospeso. Per un'app gratuita non servono dati bancari né fiscali.

## 1. Mettere online le pagine privacy e supporto

Apple controlla che i due link funzionino. Le pagine sono nel repo e GitHub Pages le pubblica da `main`.

1. Unisci il branch `ios-app` in `main` e fai push.
2. Dopo un paio di minuti verifica che rispondano:
   ```sh
   curl -sI https://nickdi92.github.io/antistress/privacy.html | head -1
   curl -sI https://nickdi92.github.io/antistress/support.html | head -1
   ```
   Devono rispondere entrambe `HTTP/2 200`.

## 2. Collegare Xcode al tuo account

1. Xcode → **Settings…** → **Accounts** → **+** → **Apple Account** → accedi.
2. Apri `ios/LetGo.xcodeproj`.
3. Nella barra laterale seleziona il progetto **LetGo** → target **LetGo** → scheda **Signing & Capabilities**.
4. Lascia attivo **Automatically manage signing** e scegli il tuo **Team** (il tuo nome, *non* "Personal Team").
   Il bundle ID `io.github.nickdi92.letgo` è già impostato.

> Il progetto si rigenera con `xcodegen generate` partendo da `ios/project.yml`. Se un giorno lo rigeneri,
> il Team scelto in Xcode si perde: aggiungi in `project.yml`, sotto `settings: base:`, la riga
> `DEVELOPMENT_TEAM: <Team ID>` (il Team ID è su developer.apple.com → Account → Membership details).

## 3. Provarla sul tuo iPhone (via cavo)

1. Collega l'iPhone al Mac e accetta "Autorizza questo computer".
2. Sull'iPhone: Impostazioni → Privacy e sicurezza → **Modalità sviluppatore** → attiva e riavvia.
3. In Xcode scegli il tuo iPhone come destinazione in alto e premi ▶︎ (**Product → Run**).

## 4. Creare l'app su App Store Connect

1. appstoreconnect.apple.com → **App** (Apps) → **+** → **Nuova app** (New App).
2. Compila:
   - Piattaforme: **iOS**
   - Nome: **Let Go** (se è già preso: **Let Go: Breathe**)
   - Lingua principale: **English (U.S.)**
   - ID pacchetto (Bundle ID): **io.github.nickdi92.letgo** (compare nel menu dopo il passo 2)
   - SKU: **letgo-ios-1**
   - Accesso utenti: **Accesso completo**
3. **Crea**.

## 5. Dichiarare lo stato di trader (normativa UE)

App Store Connect → **Attività** (Business) → sezione **Digital Services Act** / stato di trader →
scegli **Non sono un trader** (app gratuita, senza pubblicità né acquisti, fatta senza scopo commerciale).
Se ti dichiari trader, indirizzo, telefono ed email diventano pubblici sullo Store UE.

## 6. Archiviare e caricare la build

1. In Xcode, come destinazione in alto scegli **Any iOS Device (arm64)**.
2. **Product → Archive**. A fine archiviazione si apre l'**Organizer**.
3. Seleziona l'archivio → **Distribute App** → **App Store Connect** → **Distribute**.
4. Aspetta l'email "The following build has completed processing" (da pochi minuti a un'ora).

> Ogni nuovo caricamento richiede un numero di build più alto: in `project.yml` aumenta
> `CURRENT_PROJECT_VERSION` (2, 3, …) e rigenera, oppure cambialo in Xcode (target → General → Build).
> Per una nuova versione pubblica aumenta anche `MARKETING_VERSION` (1.0 → 1.1).

## 7. TestFlight sul tuo iPhone

1. App Store Connect → la tua app → **TestFlight** → **Test interno** (Internal Testing) → **+** → crea un gruppo
   e aggiungi te stesso.
2. Installa l'app **TestFlight** sull'iPhone e accetta l'invito.
3. Controlla queste cose, che nel simulatore non si possono verificare:
   - [ ] il suono si sente, e sparisce con l'interruttore silenzioso attivo;
   - [ ] il pulsante dell'altoparlante spegne/accende il suono, e la scelta resta dopo aver chiuso l'app;
   - [ ] una vibrazione leggera per ogni parola che affonda;
   - [ ] scrivi qualcosa, poi apri il selettore delle app: si vede solo l'acqua, non il testo;
   - [ ] durante il respiro vai alla Home e torna: l'app prosegue senza bloccarsi e l'audio riparte;
   - [ ] con Impostazioni → Accessibilità → Movimento → Riduci movimento, le parole affondano senza deriva né sfocatura;
   - [ ] con l'iPhone in italiano l'app è in italiano e sulla Home si chiama "Lascia andare".

## 8. Compilare la scheda dello Store

App Store Connect → la tua app → **Distribuzione** (Distribution) → versione **1.0**.

1. Lingua **English (U.S.)**: copia i testi da `ios/store/en/`:
   `promotional_text.txt` → Testo promozionale, `description.txt` → Descrizione, `keywords.txt` → Parole chiave,
   `subtitle.txt` → Sottotitolo (in **Informazioni app**). URL di supporto: `https://nickdi92.github.io/antistress/support.html`.
2. Screenshot: trascina i tre file di `ios/store/screenshots/en/` nella sezione **iPhone 6,9"**.
   Le altre misure di iPhone vengono ricavate da queste.
3. In alto a destra, menu della lingua → **Aggiungi lingua** → **Italiano**, e ripeti con `ios/store/it/` e
   `ios/store/screenshots/it/`. Nome in italiano: **Lascia andare** (o **Lascia andare: respira** se preso).
4. **Informazioni app** (App Information): categoria principale **Salute e fitness**, secondaria **Stile di vita**;
   diritti sui contenuti: nessun contenuto di terze parti; copyright `2026 Nome Cognome`.
5. **Classificazione per età** (Age Rating): rispondi **No/Nessuno** a tutto.
6. **Privacy dell'app** (App Privacy): URL privacy `https://nickdi92.github.io/antistress/privacy.html`;
   "Raccogli dati da questa app?" → **No** → risulta **Dati non raccolti** (Data Not Collected).
7. **Prezzi e disponibilità** (Pricing and Availability): **Gratis**; disponibilità: tutti i paesi tranne
   **Cina continentale**.

## 9. Inviare a revisione

1. Nella pagina della versione 1.0 → sezione **Build** → **+** → scegli la build caricata.
   La domanda sulla crittografia non compare: è già risolta nell'Info.plist.
2. **Informazioni per la revisione** (App Review Information):
   - Accesso richiesto: **No**.
   - Contatto: nome, telefono ed email (li vede solo Apple).
   - Note: incolla `ios/store/review_notes.txt`.
3. **Rilascio della versione**: "Rilascia manualmente" se vuoi scegliere tu il momento, altrimenti automatico.
4. **Aggiungi per la revisione** → **Invia a App Review**.

La revisione di solito dura da qualche ora a due giorni. Lo stato passa da "In attesa di revisione" a
"In revisione" e poi a "Pronta per la distribuzione".

## 10. Se Apple la rifiuta per "funzionalità minima" (4.2)

Rispondi nel **Resolution Center** senza cambiare l'app, con un testo come questo:

> Thank you for the review. Let Go is a native SwiftUI app, not a web view: the water and the sinking words are
> rendered live with Canvas, the sound is synthesised in real time with AVAudioEngine, and each word gives
> haptic feedback. It is designed as a single, focused calming ritual (write a thought, watch it sink, take one
> guided breath), fully offline, with no data collected. We believe this focused experience provides lasting value
> beyond a website, and we would appreciate a second look.

Se arriva un secondo rifiuto, fermati e valuta con calma cosa aggiungere: è una decisione di prodotto,
non una modifica da fare in fretta.

---

## Checklist per la prossima app

Cosa si riusa da qui:

- **Prefisso bundle ID**: `io.github.nickdi92.<nomeapp>`.
- **`ios/project.yml`**: struttura del progetto XcodeGen (target app + test unitari + test UI, Info.plist,
  localizzazioni). Copia, cambia nome e bundle ID, `xcodegen generate`.
- **`tools/render-icon.swift`**: icona 1024×1024 senza trasparenza da un SVG.
- **`PrivacyInfo.xcprivacy`** e **`ITSAppUsesNonExemptEncryption = NO`** se l'app non raccoglie dati.
- **`ios/store/check.sh`**: controllo di lunghezze dei testi, parole "mediche", misura degli screenshot.
- **`StoreScreenshotTests`**: screenshot automatici per lingua dal simulatore 6,9".
- **Pagine `privacy.html` / `support.html`**: stesso schema, su GitHub Pages.
- Passi 2–9 di questa guida, nello stesso ordine.
