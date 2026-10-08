<p align="center">
  <img src="assets/app_icon.png" width="150" alt="Mac Sai Icon" />
</p>

<h1 align="center">Mac Sai</h1>

<p align="center">
  <strong>Der quelloffene Mac-Reiniger, Optimierer und Malware-Scanner.</strong><br>
  Eine kostenlose, von Apple notarisierte Alternative zu CleanMyMac, gebaut mit Swift 6 und SwiftUI.
</p>

<p align="center">
  <a href="README.md">English</a> | <a href="README.zh-CN.md">简体中文</a> | <a href="README.zh-Hant.md">繁體中文</a> | <strong>Deutsch</strong> | <a href="README.fr.md">Français</a> | <a href="README.ru.md">Русский</a>
</p>

<p align="center">
  <a href="https://github.com/iliyami/MacSai/stargazers"><img src="https://img.shields.io/github/stars/iliyami/MacSai?style=flat-square&color=gold" alt="GitHub stars" /></a>
  <a href="https://github.com/iliyami/MacSai/releases/latest"><img src="https://img.shields.io/github/v/release/iliyami/MacSai?style=flat-square&color=blue" alt="Latest release" /></a>
  <img src="https://img.shields.io/badge/platform-macOS%2014%2B-lightgrey?style=flat-square" alt="macOS 14+" />
  <img src="https://img.shields.io/badge/swift-6.0-orange?style=flat-square" alt="Swift 6" />
  <img src="https://img.shields.io/badge/tests-862%20passing-brightgreen?style=flat-square" alt="Tests" />
  <img src="https://img.shields.io/badge/telemetry-none-brightgreen?style=flat-square" alt="No telemetry" />
  <img src="https://img.shields.io/badge/Apple-notarized-black?style=flat-square&logo=apple" alt="Notarized" />
  <img src="https://img.shields.io/badge/license-BSD--3--Clause-green?style=flat-square" alt="License" />
  <img src="https://img.shields.io/badge/PRs-welcome-ff69b4?style=flat-square" alt="PRs Welcome" />
</p>

<p align="center">
  <img src="assets/demo.png" width="720" alt="Mac Sai Screenshot" />
</p>

<p align="center">
  <strong>In einem Befehl installieren:</strong>
</p>

```bash
brew install --cask mac-sai
```

<p align="center">
  Oder lade das <a href="https://github.com/iliyami/MacSai/releases/latest">neueste DMG</a>. Es ist von Apple notarisiert, es öffnet sich also einfach, ohne Rechtsklick, ohne Warnungen, ohne Terminal.
</p>

---

## Warum Mac Sai?

Ein voll ausgestatteter Mac-Reiniger sollte kein Jahresabo kosten und dich nicht bitten, einer Blackbox mit tiefem Zugriff auf deine Dateien zu vertrauen. Mac Sai gibt dir das komplette Werkzeugset, offen und einsehbar.

- **Für immer kostenlos.** Kein Abo, keine In-App-Käufe, kein "Upgrade auf Pro", keine Nag-Screens. BSD-3-lizenziert.
- **Null Telemetrie.** Keine Analytik, kein Crash-Reporter, keine Tracker, kein Server, an den etwas nach Hause gesendet werden könnte. Und du musst uns nicht einfach glauben, [überprüfe es selbst](#telemetriefreiheit-selbst-überprüfen) mit zwei Befehlen.
- **Jedes wichtige CleanMyMac-Werkzeug in einer App.** 17 Module für Bereinigung, Schutz, Leistung, Anwendungen und Speicheranalyse, plus ein Menüleisten-Widget.
- **Sicher von Grund auf.** Löschen zuerst in den Papierkorb, eine Sperrliste geschützter Pfade, Schutz gegen Symlinks und TOCTOU, und ein `SafetyGuard`, der jeden Pfad prüft. Es ist so gebaut, dass es deine Daten nie verliert.
- **Von Apple notarisiert und vollständig quelloffen.** Dein Mac prüft die Signatur bei jedem Start, und jede Zeile ist hier nachlesbar.

---

## Funktionen auf einen Blick

<table>
<tr>
<td width="33%" valign="top">

### 🧹 Bereinigung
- **Smart Scan** (ein Klick)
- **System Junk** (16+ Kategorien)
- **Mail Attachments**
- **Trash Bins**

</td>
<td width="33%" valign="top">

### 🛡️ Schutz
- **Malware Removal**
- **Privacy** (Browser)
- **Saved Wi-Fi**
- **Permissions Overview**

</td>
<td width="33%" valign="top">

### ⚡ Leistung
- **Optimization** (Anmeldeobjekte)
- **Maintenance** (Systemaufgaben)

</td>
</tr>
<tr>
<td width="33%" valign="top">

### 📦 Anwendungen
- **Uninstaller** (+ Auf Standard zurücksetzen)
- **Extensions** (Bereiche, Plug-ins)
- **Updater**

</td>
<td width="33%" valign="top">

### 🗂️ Dateien
- **Space Lens** (Speicher-Treemap)
- **Large & Old Files**
- **Duplicates** (+ Konsolidieren)
- **Shredder**

</td>
<td width="33%" valign="top">

### 📊 Menüleiste
- Live CPU / Speicher / Disk / Akku
- Netzwerk, Laufzeit, Swap
- Umsetzbare Empfehlungen

</td>
</tr>
</table>

---

## Funktionen im Detail

### 🧹 Bereinigung
| Modul | Was es tut |
|--------|------------|
| **Smart Scan** | Ein Klick führt die Module für Bereinigung, Schutz und Leistung gemeinsam aus, mit Live-Fortschritt, und zeigt danach genau, wie viel pro Modul freigegeben wurde |
| **System Junk** | 16+ Scan-Kategorien: Benutzer- und System-Caches, Protokolle, Sprachdateien, defekte Einstellungen, defekte Anmeldeobjekte, Dokumentversionen, iOS-Backups, Xcode-Müll, Caches von Paketmanagern / IDEs / KI-Werkzeugen, Reste gelöschter Benutzer, sowie **Universal-Binary-Verschlankung** (findet fette Mach-O-Binärdateien, die sowohl arm64 als auch x86_64 enthalten, und schreibt sie per `lipo` auf deine native Architektur um, mit Abbrechen-Unterstützung) |
| **Mail Attachments** | Findet zwischengespeicherte Anhänge aus Apple Mail, Outlook und Spark |
| **Trash Bins** | Leert den Papierkorb an jedem Ort, auch auf externen Laufwerken |

### 🛡️ Schutz
| Modul | Was es tut |
|--------|------------|
| **Malware Removal** | Signaturbasiertes Scannen in 3 Tiefen (Schnell / Ausgewogen / Tief): Launch Agents und Daemons, Browser-Erweiterungen sowie bekannte Adware-/Malware-Muster (kuratierte Liste, kein Antivirus, und das sagt es auch) |
| **Privacy** | Bereinigt Verlauf, Cookies und Cache von Safari, Chrome und Firefox, mit Zeitfiltern. Safari-**Lesezeichen werden nie angerührt** |
| **Saved Wi-Fi** | Listet deine bevorzugten Drahtlosnetzwerke auf und vergisst die von dir ausgewählten |
| **Permissions Overview** | Eine schreibgeschützte Übersicht pro App, welche Datenschutz-Berechtigungen (TCC) jede App besitzt, der Blickwinkel, den die Systemeinstellungen nicht bieten. Jede Aktion verlinkt tief in die Systemeinstellungen, die die Schalter besitzen |

### ⚡ Leistung
| Modul | Was es tut |
|--------|------------|
| **Optimization** | Verwalte Anmeldeobjekte und Launch Agents mit Ein-/Ausschalten pro Eintrag |
| **Maintenance** | Systemaufgaben: RAM freigeben, Wartungsskripte ausführen, Startvolume prüfen, Launch Services neu aufbauen, Spotlight neu indizieren, DNS leeren, Time-Machine-Schnappschüsse verschlanken. Aufgaben sind nach Schweregrad markiert, "Sichere Aufgaben ausführen" läuft sequenziell, und das Admin-Passwort wird **einmal** abgefragt |

### 📦 Anwendungen
| Modul | Was es tut |
|--------|------------|
| **Uninstaller** | Eine Muster-Suchmaschine, die jede zugehörige Datei über 17+ Library-Unterverzeichnisse findet (auch Apps, die in Hersteller-Unterordnern verschachtelt sind). Vollständige Entfernung, **Auf Standard zurücksetzen** (Caches und Einstellungen einer App löschen, die App aber behalten) und Erkennung ungenutzter Apps |
| **Extensions** | Prüfe Einstellungsbereiche von Drittanbietern, Internet-Plug-ins und Safari-Erweiterungen. Vom Benutzer installierte Bereiche und Plug-ins können in den Papierkorb |
| **Updater** | Prüft installierte Apps über deren eigene Sparkle-Appcast-Feeds auf Updates (liest nur Versionsinformationen, sendet nichts über dich) |

### 🗂️ Dateien
| Modul | Was es tut |
|--------|------------|
| **Space Lens** | Visualisierung der Speichernutzung als quadrierte Treemap mit Drilldown-Navigation |
| **Large & Old Files** | Findet Dateien über 50 MB, sortiert nach Größe und letztem Zugriffsdatum |
| **Duplicates** | Progressive Erkennung (Größengruppierung, partielles SHA-256, voller Hash, Inode-Prüfung), plus ein **Konsolidieren**-Modus, der Speicher mit APFS-Copy-on-Write-Klonen zurückgewinnt, ohne eine einzige Kopie zu löschen |
| **Shredder** | Sicheres Löschen von Dateien mit den Modi Standard, Permanent und Sicheres Überschreiben |

### 📊 Menüleisten-Widget

<p align="center">
  <img src="assets/menu_bar.png" width="300" alt="Mac Sai menu bar widget" />
</p>

Ein Menüleisten-Widget im Glasmorphismus-Stil, das die Vitalwerte deines Macs einen Klick entfernt hält. Es ist ein eigenständiger Prozess, der beim Anmelden startet und aus der Seitenleiste der App umgeschaltet wird, du musst also nie das Hauptfenster öffnen, nur um kurz nachzusehen.

- **Live-Statusringe**: CPU-Last, Speicherdruck, Speicherplatznutzung und Akku in einem 2x2-Ringraster (`host_processor_info`, `vm_statistics64`, APFS-Kapazität, IOKit-Stromquelle), farblich abgestuft von Grün über Gelb bis Rot
- **Konfigurierbare Anzeige**: zeige freien Speicher, GPU-Auslastung, Speichernutzung oder Akkutemperatur; die Auswahl bleibt erhalten, und nicht verfügbare Sensoren zeigen `--`
- **Netzwerk, Laufzeit und Swap**: Echtzeit-Durchsatz hoch/runter, System-Laufzeit, Swap-Nutzung
- **Empfehlungen**: umsetzbare, ausblendbare Tipps ("Benutzer-Caches sind auf 2,52 GB gewachsen, führe System Junk aus"), ein Tipp genügt zum Handeln, nach dem Ausblenden 30 Tage unterdrückt
- **Schutzstatus**: Zeitpunkt des letzten Malware-Scans und Anzahl der Bedrohungen, farbcodiert nach Aktualität
- **Verbundene Geräte**: externe Volumes (mit freiem Speicher) und Displays auf einen Blick
- **Zustandswarnungen**: gedrosselte, optionale Benachrichtigungen, wenn der Speicher kritisch knapp wird oder der Speicherdruck hoch bleibt

### ⌨️ Tastaturkürzel

| Kürzel | Aktion |
|----------|--------|
| **⌘R** | Einen Scan im aktuellen Modul starten |
| **⌘K** | Die aktuelle Auswahl bereinigen (wenn Ergebnisse angezeigt werden) |
| **⌘1 bis ⌘9** | Zu den ersten neun Seitenleisten-Modulen springen |
| **⌘,** | Einstellungen öffnen |

---

## Wie Mac Sai im Vergleich abschneidet

|  | Mac Sai | CleanMyMac | Pearcleaner | PureMac | OnyX | Mole |
|---|:---:|:---:|:---:|:---:|:---:|:---:|
| **Preis** | Kostenlos | 39,95 $/Jahr | Kostenlos | Kostenlos | Kostenlos | Kostenlos (CLI) |
| **Quelloffen** | ✅ BSD-3 | ❌ | ✅ Fair-Code | ✅ MIT | ❌ | ✅ MIT |
| **Telemetrie** | ❌ Keine | ⚠️ Ja | ❌ Keine | ❌ Keine | ❌ Keine | ❌ Keine |
| **Native GUI-App** | ✅ | ✅ | ✅ | ✅ | ✅ | ❌ CLI (bezahlte GUI separat) |
| **Smart Scan (ein Klick)** | ✅ | ✅ | ❌ | ➖ Teilweise | ❌ | ➖ Interaktive CLI |
| **System Junk (16+ Kategorien)** | ✅ | ✅ | ➖ | ✅ | ➖ Begrenzt | ✅ |
| **Universal-Binary-Verschlankung** | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ |
| **Malware-Scanner** | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ |
| **Browser-Datenschutzreiniger** | ✅ | ✅ | ❌ | ❌ | ➖ | ❌ |
| **Deinstallierer mit Resterkennung** | ✅ | ✅ | ✅ Fokus | ❌ | ❌ | ✅ |
| **Duplikatsuche (+ Konsolidierung)** | ✅ | ➖ | ❌ | ❌ | ❌ | ❌ |
| **Speicher-Treemap-Visualisierung** | ✅ | ❌ | ❌ | ❌ | ❌ | ➖ Analyse |
| **Menüleisten-Systemmonitor** | ✅ | ✅ Menü | ❌ | ❌ | ❌ | ❌ |
| **Wartungsskripte** | ✅ | ✅ | ❌ | ❌ | ✅ Stark | ➖ |
| **Von Apple notarisiert** | ✅ | ✅ | ✅ | ✅ | ✅ | N/V |
| **macOS-Version** | 14+ | 13+ | 13+ | 13+ | variiert | variiert |

> CleanMyMac ist ein großartiges Produkt, und wer eine polierte, unterstützte Erfahrung möchte, sollte gerne dafür bezahlen. Mac Sai ist für alle, die lieber transparenten Quellcode und null Abo hätten.

---

## Oberflächensprachen

Wähle in Einstellungen → Oberflächensprache zwischen System, Deutsch, Русский, 简体中文, 繁體中文 oder English. Deutsch und traditionelles Chinesisch übersetzen die statischen Oberflächentexte; interpolierte Meldungen behalten vorerst den englischen Wortlaut und die Pluralregeln (traditionelles Chinesisch fällt auf Vereinfachtes zurück). Das Hauptfenster und das Menüleisten-Widget teilen sich die Sprachauswahl.

## Installation

### Homebrew (empfohlen)

Mac Sai ist im offiziellen Homebrew-Cask, ein Tap wird also nicht benötigt:

```bash
brew install --cask mac-sai
```

Es ist von Apple notarisiert, es startet also aus Spotlight oder dem Programme-Ordner ohne Warnungen und ohne zusätzliche Schritte.

<details>
<summary><strong>Weitere Installationswege</strong> (Ein-Zeilen-Skript, DMG, aus dem Quellcode bauen)</summary>

<br>

**Ein-Zeilen-Installer**

```bash
curl -fsSL https://raw.githubusercontent.com/iliyami/MacSai/main/scripts/install.sh | bash
```

Lädt das neueste DMG herunter und installiert die App nach `/Applications`.

**DMG-Download**

Hol dir das neueste DMG aus den [Releases](https://github.com/iliyami/MacSai/releases/latest) und ziehe Mac Sai in deinen Programme-Ordner.

**Aus dem Quellcode bauen**

```bash
git clone https://github.com/iliyami/MacSai.git
cd MacSai
swift build
swift test                     # die volle Suite mit 862 Tests ausführen
bash scripts/build-dmg.sh      # ein lokales DMG bauen (unsigniert)
```

Erfordert die Swift-6-Toolchain (Xcode 16+).

**Über den alten Tap installiert?**

Mac Sai ist jetzt im offiziellen Cask, du kannst den Tap also entfernen: `brew untap iliyami/macsai` (deine installierte App und künftige `brew upgrade` sind davon nicht betroffen).

</details>

### Vollen Festplattenzugriff gewähren

Einige Module (Mail Attachments, Privacy, Malware) benötigen vollen Festplattenzugriff, um geschützte Bereiche zu scannen:

1. Öffne **Systemeinstellungen, Datenschutz & Sicherheit, Vollständiger Festplattenzugriff**
2. Klicke auf **+** und füge **Mac Sai.app** hinzu
3. Starte Mac Sai neu

### Deinstallieren

Homebrew-Installation:

```bash
brew uninstall --zap --cask mac-sai
```

DMG- oder manuelle Installation (funktioniert auch bei einer Homebrew-Installation):

```bash
curl -fsSL https://raw.githubusercontent.com/iliyami/MacSai/main/scripts/uninstall.sh | bash
```

Beide entfernen Mac Sai samt seiner Einstellungen, Caches, Protokolle und Datenbank unter `~/Library`.

---

## Signiert, notarisiert und vertrauenswürdig

Mac Sai ist mit einer Apple **Developer ID** code-signiert und **von Apple notarisiert**. Das zählt bei einer Reinigungs-App mehr als bei fast allem anderen, das du installierst, denn du bist im Begriff, ihr tiefen Zugriff auf deine Dateien zu geben, und du verdienst die Gewissheit, dass das, was auf deinem Mac läuft, wirklich von uns und unverändert ist. All das wird von deinem eigenen Mac erzwungen, nicht nur von uns versprochen:

- **Apple hat es geprüft.** Jedes Release wird an Apple übermittelt und vor der Auslieferung auf Malware geprüft.
- **Es kann nicht manipuliert werden.** Die Signatur ist ein kryptografisches Siegel über jede Datei; ändere ein einziges Byte, und macOS weigert sich, es zu öffnen.
- **Es stammt nachweislich von uns.** Die Signatur ist an unsere Apple-Developer-Identität gebunden, sodass niemand sonst etwas ausliefern kann, das dein Mac als Mac Sai akzeptiert.
- **Es funktioniert einfach.** Keine Gatekeeper-Warnungen, kein Rechtsklick zum Öffnen, kein Terminal.

Zusammen mit dem vollständig offenen Quellcode ist das eine Vertrauenskette, die du nicht auf gut Glauben eingehst: Der Code ist öffentlich, wir signieren jedes Release, Apple prüft es, und dein Mac prüft das Siegel jedes Mal erneut, wenn du die App öffnest.

### Telemetriefreiheit selbst überprüfen

Glaub uns nicht einfach. Sowohl der Quellcode als auch der laufende Prozess sind überprüfbar.

**1. Durchsuche den Quellcode nach Netzwerk-APIs**

```bash
rg -n 'URLSession|NSURLConnection' Sources --glob '*.swift'
```

Du solltest nur je zwei Netzwerkpfade sehen, beide optional und beide nur lesend:

- `Sources/MacCleanKit/UpdateChecker.swift`: die optionale Update-Prüfung von Mac Sai (in den Einstellungen abschaltbar)
- `Sources/MacClean/Modules/Updater/UpdaterModule.swift`: die vom Benutzer ausgelöste Prüfung der Sparkle-Feeds *anderer Apps*, wenn du den Updater öffnest

Es gibt nirgends im Code Analytik, einen Crash-Reporter oder ein Tracker-SDK.

**2. Beobachte den laufenden Prozess**

```bash
lsof -i -P -n | grep -i 'MacClean\|Mac Sai\|MacSai' || echo "no network sockets"
```

Erwartet: keine aufgebauten Verbindungen, solange du nur lokal bereinigst. Little Snitch oder LuLu machen dieselbe Prüfung sichtbar.

**3. Untersuche die Binärdatei, die du tatsächlich installiert hast**

Der Quellcode und die signierte Binärdatei sind verschiedene Artefakte, die stärkste Prüfung läuft also gegen die App auf deiner Festplatte, nicht gegen dieses Repo. Nach `brew install --cask mac-sai`:

```bash
APP="/Applications/Mac Sai.app/Contents/MacOS/MacClean"

# Netzwerk-Klassen, die die Binärdatei importiert (nur URLSession erscheint):
nm -u "$APP" | grep -iE 'URLSession|NWConnection|CFSocket' | sort -u

# Jede in die Binärdatei kompilierte URL (nur die zwei Update-Endpunkte werden abgerufen):
strings -a "$APP" | grep -iE 'https?://' | sort -u
```

Erwartet: die einzige Netzwerk-Klasse ist `_OBJC_CLASS_$_NSURLSession`, und die einzigen abgerufenen Endpunkte sind `api.github.com/repos/iliyami/MacSai/releases/latest` und `formulae.brew.sh/api/cask/mac-sai.json`. Die anderen `github.com/iliyami/MacSai`-Links öffnen nur deinen Browser. Keine Tracker, keine Analytik-Hosts, sonst nichts. Führe es nach jedem Update erneut aus; es beschreibt immer genau den Build, den du gerade betreibst.

Hinweis: Bei einer nicht-sandboxed Developer-ID-App wie dieser wird der Netzwerkzugriff nicht durch ein Entitlement geregelt, diese Symbol- und String-Prüfung, nicht `codesign --entitlements`, ist also die echte Prüfung. Dieselbe Absicherung läuft bei jeder Änderung in der CI ([`scripts/check-network-surface.sh`](scripts/check-network-surface.sh)).

---

## Architektur

```
Mac Sai
├── MacClean          Haupt-SwiftUI-App (17 Module)
├── MacCleanKit       Gemeinsames Framework (Modelle, Konstanten, Protokolle)
├── MacCleanHelper    Privilegierter XPC-Helfer (LaunchDaemon für Root-Operationen)
└── MacCleanMenu      Menüleisten-Monitor (eigenständiger Prozess)
```

### Technologie-Stack

| Ebene | Technologie |
|-------|-----------|
| Sprache | Swift 6 mit strikter Nebenläufigkeit |
| UI | SwiftUI + AppKit-Hybrid |
| Nebenläufigkeit | Actors, TaskGroup, async/await, `@Sendable` |
| Datenbank | GRDB.swift (SQLite) im WAL-Modus |
| Datei-Scan | `URLResourceKey`-Prefetching auf APFS |
| Inkrementelle Updates | FSEvents mit historischem Replay |
| Privilegierte Operationen | SMAppService + NSXPCConnection |
| Systemstatistiken | Mach-APIs (`host_processor_info`, `vm_statistics64`, `proc_pidinfo`) |

### Sicherheitsmodell

Mac Sai ist so entworfen, dass es **niemals Datenverlust verursacht**:

- **Sperrliste geschützter Pfade**: `/System`, `/usr`, `/bin`, `/sbin` und Apple-Systemapps sind unantastbar, wobei macOS-Firmlinks kanonisiert werden, damit die Erkennung von Symlink-Umleitungen bei legitimen Systempfaden nicht fälschlich anschlägt
- **Bereinigbarkeitsfilter vor dem Scan**: Objekte, die der aktuelle Prozess nicht in den Papierkorb legen könnte (root-eigene Kinder von System-Caches, datentresor-geschützte `~/Library/Caches/com.apple.*`-Verzeichnisse), werden beim Scan verworfen, sodass sie nie als bereinigbar erscheinen
- **Löschen zuerst in den Papierkorb**: jede Entfernung geht standardmäßig in den Papierkorb, und ein Probelauf-Modus zeigt eine Vorschau, ohne etwas anzurühren
- **TOCTOU-Vermeidung**: Symlinks werden unmittelbar vor dem Löschen neu aufgelöst
- **Ausgeschlossene Ordner**: wähle in den Einstellungen Ordner, die Scans komplett überspringen, und `SafetyGuard` weigert sich zusätzlich, irgendetwas darunter zu löschen
- **Gestückelte, abbrechbare Bereinigung**: große Auswahlen werden in 5k-Objekt-Blöcke aufgeteilt, die Abbrüche zwischen den Blöcken beachten, und Scans kehren nach etwa einer Sekunde in den Leerlauf zurück, wenn du auf Abbrechen tippst
- **In-App-Aktivitätsprotokoll**: jeder Fehler während einer Bereinigung wird mit vollem Pfad protokolliert, einseh- und kopierbar vom Bildschirm nach der Bereinigung, nach 30 Tagen automatisch bereinigt
- **Kernel-erzwungenes XPC-Gate**: der privilegierte Helfer nutzt `NSXPCListener.setCodeSigningRequirement`, sodass der Kernel selbst jede Verbindung ablehnt, deren Code-Signatur nicht zur Kennung und zum Team der App passt

---

## Tests

```bash
swift test
```

Die XCTest-Suite hat **862 Tests** und behandelt `SafetyGuard` und `CleaningEngine` (die Dateien über Leben und Tod) als muss-perfekt-sein: adversariale Abdeckung von Symlinks, Pfad-Traversierung, NULL-Bytes, SIP, geschützten Apps, Dateianzahl-Obergrenzen, TOCTOU und Idempotenz, plus Integrationsabdeckung von Probelauf- / Papierkorb- / permanenter Bereinigung, der Scan-Zustandsmaschine, jeder System-Junk-Kategorie, der Treemap-Mathematik, der Uninstaller-Suchmaschine, der Duplikaterkennung, des Appcast-Parsings und vollständiger End-to-End-Zyklen von Fixture bis Bereinigung. Fixtures (`withTempHome`, `withFakeApp`, `withFakePlist`) halten jeden Test von deinem echten Home-Verzeichnis fern.

---

## Mitwirken

Beiträge sind sehr willkommen. Lies die [Richtlinien für Beiträge](CONTRIBUTING.md), dann:

1. Forke das Repo und erstelle einen Feature-Branch
2. Nimm deine Änderung vor (eine fokussierte Änderung pro PR erleichtert die Prüfung)
3. Führe `swift test` aus
4. Öffne einen Pull Request

Es gibt auch eine offene [Feature-Abstimmung](https://github.com/iliyami/MacSai/issues/55): 👍 die Werkzeuge, die als Nächstes gebaut werden sollen.

## Lizenz

BSD 3-Clause. Siehe [LICENSE](LICENSE). Du darfst den Code nutzen, verändern und weitergeben, sofern du den Copyright- und Lizenztext beibehältst und den Namen "Mac Sai" oder die Namen der Mitwirkenden nicht ohne Erlaubnis zur Bewerbung abgeleiteter Produkte verwendest.

## Danksagungen

Inspiriert von der Open-Source-Community rund um Mac-Werkzeuge:

- [Pearcleaner](https://github.com/alienator88/Pearcleaner): Muster für den App-Deinstallierer
- [Mole](https://github.com/tw93/Mole): Bereinigungskategorien
- [Tencent Lemon Cleaner](https://github.com/Tencent/lemon-cleaner): modulare Architektur
- Squarified-Treemap-Algorithmus von Bruls, Huizing und van Wijk (2000)

## Sternverlauf

<p align="center">
  <a href="https://www.star-history.com/?repos=iliyami%2FMacSai&type=date&legend=top-left">
    <picture>
      <source media="(prefers-color-scheme: dark)" srcset="https://api.star-history.com/chart?repos=iliyami/MacSai&type=date&theme=dark&legend=top-left&sealed_token=U-awhgge-qJwqcwRMpeYAooRYIriMPXuNrQErHZuAQsbmKYoo3D7oum-5zvqFjZlP77FXRFg56nh-1Ie9oWSBAPeS7-NUe70kSI-3XJ_Ce97vHA0OQcqEKhE0STA4FhfJ-bkteG7lb2xAVJWcLPtIJalJjJuhE2nrgA4rrcQbs6cJPk2-sbuJw76SARx" />
      <source media="(prefers-color-scheme: light)" srcset="https://api.star-history.com/chart?repos=iliyami/MacSai&type=date&legend=top-left&sealed_token=U-awhgge-qJwqcwRMpeYAooRYIriMPXuNrQErHZuAQsbmKYoo3D7oum-5zvqFjZlP77FXRFg56nh-1Ie9oWSBAPeS7-NUe70kSI-3XJ_Ce97vHA0OQcqEKhE0STA4FhfJ-bkteG7lb2xAVJWcLPtIJalJjJuhE2nrgA4rrcQbs6cJPk2-sbuJw76SARx" />
      <img alt="Star History Chart" src="https://api.star-history.com/chart?repos=iliyami/MacSai&type=date&legend=top-left&sealed_token=U-awhgge-qJwqcwRMpeYAooRYIriMPXuNrQErHZuAQsbmKYoo3D7oum-5zvqFjZlP77FXRFg56nh-1Ie9oWSBAPeS7-NUe70kSI-3XJ_Ce97vHA0OQcqEKhE0STA4FhfJ-bkteG7lb2xAVJWcLPtIJalJjJuhE2nrgA4rrcQbs6cJPk2-sbuJw76SARx" />
    </picture>
  </a>
</p>

<p align="center">
  <strong>Mac Sai ist freie Software, gebaut von der Community, für die Community.</strong><br>
  Wenn es dir ein Abo erspart hat, hilft ein ⭐ anderen, es zu finden.
</p>
