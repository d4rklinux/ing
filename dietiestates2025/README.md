# 🏘️ DietiEstates 2025 — Software Engineering

**Progetto di Ingegneria del Software** per l'Università degli Studi di Napoli Federico II

**DietiEstates 2025** è una piattaforma mobile full-stack per la gestione e la compravendita di immobili, sviluppata con **Flutter** (frontend) e **Node.js/Express** (backend). L’applicazione consente agli **amministratori** di creare account per i **manager**, ai **manager** di registrare nuovi **agenti**, e permette ad **agenti** e **utenti finali** di interagire tramite funzionalità come la visualizzazione degli annunci, la prenotazione di visite, l’invio di proposte e la ricezione di notifiche in tempo reale.

---

## 📱 Tech Stack

### Frontend
- 🔷 **Flutter** & **Dart**
- **Provider** per la gestione dello stato utente
- **Cloudinary** per il caricamento e la gestione delle immagini

### Backend
- 🟨 **Node.js** + **Express**
- **PostgreSQL**
- Architettura modulare per le route
- Middleware personalizzati per autenticazione e gestione errori
- **dotenv** per la gestione sicura delle variabili ambientali

---

## 📁 Struttura delle Cartelle

### 📦 `lib/` (Frontend - Flutter)

- `data/` — Modelli dei dati (es. `utente.dart`, `immobile.dart`, `visita.dart`, ecc.)
- `repositories/` — Gestione delle chiamate API e dei data source
- `pages/` — Pagine principali dell’app:
    - `administrator/` — Interfacce per la gestione amministrativa
    - `manager/` — Sezioni riservate ai manager
    - `agent/` — Funzionalità per gli agenti immobiliari
    - `user/` — Schermate per gli utenti finali
- `provider/` — Provider per l’autenticazione (`auth_provider.dart`)
- `screens/` — UI generali e schermate condivise (es. `splash_screen.dart`)
- `services/` — Servizi comuni (login, immagini, geolocalizzazione, navigazione, ecc.)
- `widgets/` — Componenti UI riutilizzabili (es. bottom bar, animazioni)
- `main.dart` — Entry point dell’app

### 📦 `backend/` (Node.js + Express)

- `routes/` — Definizione delle API REST, organizzate per funzionalità:
    - `immobileRoutes.js` — Gestione degli immobili
    - `visitaRoutes.js` — Prenotazione e gestione delle visite
    - `propostaRoutes.js` — Invio e gestione delle proposte di acquisto
    - `utenteRoutes.js` — Operazioni sugli utenti
    - `ruoloRoutes.js` — Gestione dei ruoli (amministratore, manager, agente, utente)
    - `geoapifyRoutes.js` — Geolocalizzazione e geocoding tramite API Geoapify
    - `fotoRoutes.js` — Upload e gestione delle immagini immobiliari
    - `filtroAvanzatoRoutes.js` — Ricerca avanzata degli immobili
    - `servizioUlterioreRoutes.js` — Gestione dei servizi aggiuntivi associati agli immobili
    - `indirizzoRoutes.js` — Gestione degli indirizzi legati agli immobili
    - `modificaRoutes.js` —  Gestione delle modifiche agli immobili
    - `ricercaRoutes.js` — Ricerca semplice di annunci
- `db.js` — Configurazione e connessione al database PostgreSQL
- `server.js` — Entry point dell'applicazione e avvio del server Express
- `.env` — Variabili ambientali (es. credenziali DB, API key, JWT secret)

### 📗 `test/` (TestUnit)

  - `advanced_filter_test.dart` — Test filtro avanzato
  - `agent_insert_test.dart` — Test inserimento immobile
  - `user_send_offer_page_test.dart` — Test inserimento offerta
  - `user_send_visits_page_test.dart` — Test inserimento visita

---

## 🚀 Funzionalità Chiave

- 🏘️ Elenco e ricerca avanzata degli immobili
- 📍 Geolocalizzazione con **Geoapify**
- 📆 Prenotazione di visite con agenti
- 💬 Invio e gestione di proposte
- 🔔 Notifiche push (visite, offerte, controproposte)
- 👨🏼‍💼 Dashboard personalizzata per ogni tipologia di utente (amministratore, gestore, agente, utente)


---

## 👥 Funzionalità per i Ruoli

### 👨‍💼 Amministratore
- ✅ Modifica della password di amministrazione
- ✅ Creazione di account per i gestori dell’agenzia

### 🧑‍💼 Gestore dell’Agenzia
- ✅ Creazione di account per agenti immobiliari

### 🏡 Agente Immobiliare
- ✅ Inserimento di nuovi immobili con dettagli completi:
    - Foto, descrizione, prezzo, dimensione, indirizzo
    - Numero di stanze, piano, presenza di ascensore
    - Classe energetica, servizi aggiuntivi (es. portineria, climatizzazione, ecc.)
    - Tipo di contratto: **vendita** o **affitto**
    - Geolocalizzazione precisa dell’immobile
- ✅ Gestione delle offerte ricevute:
    - Accettazione, rifiuto e invio di controproposte
- ✅ Tracciamento storico delle offerte effettuate e ricevute
- ✅ Ricezione notifiche per prenotazione visite
- ✅ Gestione visite: conferma o rifiuto appuntamenti

### 👤 Utente
- ✅ Registrazione sicura con email e password
- ✅ Login e gestione autenticazione
- ✅ Visualizzazione immobili e verifica automatica della presenza di:
    - Scuole, parchi, fermate dei trasporti pubblici nelle vicinanze (tramite API)
- ✅ Filtraggio annunci per posizione geografica (comune, città)
- ✅ Ricerca avanzata con parametri multipli:
    - Prezzo minimo/massimo, numero di stanze, classe energetica, posizione, ecc.
- ✅ Prenotazione di visite entro le due settimane successive:
    - Possibilità di selezionare un altro orario in caso di rifiuto
    - Integrazione con calendario visivo per appuntamenti
- ✅ Invio offerte con prezzo inferiore rispetto a quello richiesto
- ✅ Tracciamento e storico delle offerte inviate
- ✅ Visualizzazione riepilogo attività svolte:
    - Immobili visualizzati, visite prenotate, offerte inviate

---

## 🛠️ Setup del Progetto

### ⚙️ Installazione Flutter & Dart

Per poter eseguire il frontend dell’applicazione è necessario **installare Flutter e Dart**, che costituiscono il framework e il linguaggio di programmazione principali dell’interfaccia mobile.

#### 🔵 Windows

1. Scarica lo **SDK di Flutter** da:  
   [https://flutter.dev/docs/get-started/install/windows](https://flutter.dev/docs/get-started/install/windows)

2. Estrai il contenuto in una directory (es. `C:\flutter`).

3. Aggiungi `flutter\bin` al **PATH** del sistema:
    - Cerca *"Variabili d'ambiente"* nel menu Start
    - Aggiungi il percorso `C:\flutter\bin` tra le variabili d’ambiente del sistema (`PATH`)

4. Apri un terminale PowerShell o CMD e verifica l’installazione con:

   ```bash
   flutter doctor
   ```

   Segui le istruzioni per completare eventuali installazioni mancanti (Android Studio, SDK, plugin, ecc.).

#### 🍎 macOS (tramite Homebrew)

1. Assicurati di avere [Homebrew](https://brew.sh/) installato.

2. Esegui i seguenti comandi nel terminale:

   ```bash
   brew install --cask flutter
   ```

3. Dopo l'installazione, aggiungi Flutter al `PATH` (se necessario):

   ```bash
   export PATH="$PATH:`flutter doctor --flutter-path`/bin"
   ```

   *(Puoi aggiungerlo anche al tuo `.zshrc` o `.bash_profile` per renderlo permanente)*

4. Controlla lo stato dell’installazione:

   ```bash
   flutter doctor
   ```

   Flutter installerà anche Dart automaticamente.

> ⚠️ Assicurati di avere installato **Android Studio** e **Xcode** (su macOS) per eseguire l'app su emulatori o dispositivi reali.

---

### 1. Clonazione del Repository

```bash
git clone https://github.com/d4rklinux/Software-Engineering-DietiEstates25.git
```

### 2 Installazione delle Dipendenze Node.js

All’interno della cartella dietiestate2025, esegui il comando:

```bash
npm install
```
Questo comando analizzerà il file package.json e scaricherà tutte le dipendenze, creando la cartella node_modules.

Verifica di avere installato Node.js e npm con:

```bash
node -v
npm -v
```

### 3. Backup del Database

Per popolare o ripristinare il database con i dati preesistenti di utenti, immobili, proposte e offerte, segui questi semplici passaggi:

-  **Connessione al server PostgreSQL:** Accedi al server come amministratore (ad esempio, con l'utente `postgres`).
-  **Creazione del database (se necessario):** Se il database `DietiEstates2025` non esiste ancora, crealo eseguendo il comando:

    ```sql
    CREATE DATABASE DietiEstates2025;
    ```
-  **Ripristino del backup:** Assicurati di trovarti nella directory contenente il file di backup `dumpDatabase.sql` e procedi con il restore nel database appena creato.

📂 `dumpDatabase.sql`

Questo file SQL contiene un dump completo del database, pronto per essere utilizzato per il ripristino o per popolare il tuo ambiente con dati di test.

### 4. Setup Backend

Assicurati di creare un file `.env` nella cartella `backend` con le seguenti variabili:

```env
PORT=3000
DB_USER=postgres
DB_PASSWORD=*********
DB_HOST=localhost
DB_PORT=5432
DB_DATABASE=DietiEstates2025
GEOAPIFY_API_KEY=****************************
JWT_SECRET=****************************
```

> ⚠️ Le variabili sensibili (password, chiavi API, segreti JWT) **non vanno condivise pubblicamente**.

Avvio del server

```bash
cd dietiestates2025/backend
node server.js
```

---

### 🔐 Configurazione della API Key Geoapify

Per utilizzare i servizi di **geolocalizzazione** e **geocoding** tramite **Geoapify**, è necessario ottenere una API Key gratuita e inserirla nel file `.env` del backend.

#### ✅ Come ottenere la API Key:

1. Vai su 👉 [https://myprojects.geoapify.com/](https://myprojects.geoapify.com/)
2. Registrati o accedi con il tuo account
3. Clicca su **"Create new project"** per generare un nuovo progetto
4. Copia la **API Key** assegnata al progetto

#### 🔧 Inserisci la chiave nel file `.env`:

Apri il file `.env` all’interno della cartella `backend/` e inserisci la tua chiave nell'apposita variabile:

```env
GEOAPIFY_API_KEY=la_tua_api_key_qui
```

> ⚠️ Questa chiave viene utilizzata nelle route `geoapifyRoutes.js` per ottenere coordinate GPS, luoghi d’interesse vicini e altre funzionalità geografiche offerte da Geoapify.

---

### 5. Creazione del Progetto Flutter (Solo Android e iOS) in Android Studio

Questa guida spiega come creare da zero un progetto Flutter compatibile **solo con Android e iOS**, utilizzando **Android Studio**:

#### ➤ Passaggi:

1. **Apri Android Studio**
2. Clicca su **“New Flutter Project”**
3. Scegli **“Flutter Application”** e clicca su **Next**
4. Inserisci i dettagli del progetto:
   - **Project name**: `dietiestates2025`
   - **Description**: `Piattaforma mobile per la gestione e la compravendita di immobili`
   - **Project location**: scegli una cartella di destinazione appropriata
   - **Flutter SDK path**: assicurati che punti al percorso corretto dell’SDK
5. Clicca su **Next**
6. **Seleziona le piattaforme supportate**:
   - ✅ **Android**
   - ✅ **iOS**
   - ❌ **Deseleziona Web, Windows, Linux e macOS** se presenti
7. Clicca su **Finish** per creare il progetto

---

### 🧹 Rimozione Manuale delle Altre Piattaforme (Se già create)

Se per errore hai creato anche le piattaforme desktop e web, puoi rimuoverle manualmente eseguendo il seguente comando nel terminale (nella root del progetto):

```bash
rm -rf web linux macos windows
```

---

### ⚙️ Verifica Configurazione

Dalla cartella del progetto, esegui:

```bash
flutter devices
```

Per controllare i dispositivi/emulatori disponibili.

E per ricreare eventuali file mancanti o aggiornare la configurazione:

```bash
flutter pub get
flutter create .
```

---

### 🚀 Esecuzione dell'App

Per avviare l’app su un emulatore Android o iOS:

```bash
flutter run
```

---

> ✅ Ora il tuo progetto Flutter è pronto, configurato solo per Android e iOS!

### 6. Eseguire Test

Per eseguire i test, posizionarsi nella cartella dietiestates2025 ed eseguire il comando seguente:

```bash
flutter test
```

---

## ✅ TODO

### Frontend (Flutter)
- [x] UI principale per tutti i ruoli (utente, agente, manager, amministratore)
- [x] Sistema di navigazione e gestione ruoli dinamica
- [x] Prenotazione visite e invio proposte
- [x] Notifiche push integrate
- [x] Integrazione con Cloudinary per la gestione immagini
- [x] Ricerca avanzata e ricerca semplice

### Backend (Node.js/Express)
- [x] API REST modulari per immobili, visite, utenti, proposte, ecc.
- [x] Middleware di autenticazione (JWT)
- [x] Geolocalizzazione tramite Geoapify
- [x] Connessione a PostgreSQL tramite pool
- [x] Gestione upload immagini con Cloudinary

---

## 📄 Licenza

Distribuito sotto licenza **MIT**. Libero utilizzo per scopi accademici o personali.

---

## 👥 Autori

-  [d4rklinux](https://github.com/d4rklinux)
-  [crymar02](https://github.com/crymar02)
-  [luigidg2002](https://github.com/luigidg2002)
