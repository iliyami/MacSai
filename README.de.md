<p align="center">
  <img src="assets/app_icon.png" width="150" alt="Mac Sai Icon" />
</p>

<h1 align="center">Mac Sai</h1>

<p align="center">
  <strong>Der quelloffene Mac-Reiniger, Optimierer und Malware-Scanner.</strong><br>
  Eine kostenlose, von Apple notarisierte Alternative zu CleanMyMac, gebaut mit Swift 6 und SwiftUI.<br>
  <sub>Über 100.000 Mal heruntergeladen. Für immer kostenlos, ohne Telemetrie.</sub>
</p>

<p align="center">
  <a href="README.md">English</a> | <a href="README.zh-CN.md">简体中文</a> | <a href="README.zh-Hant.md">繁體中文</a> | <strong>Deutsch</strong> | <a href="README.fr.md">Français</a> | <a href="README.ru.md">Русский</a>
</p>

<p align="center">
  <a href="https://github.com/iliyami/MacSai/releases/latest"><img src="https://img.shields.io/github/downloads/iliyami/MacSai/total?style=flat-square&label=downloads&color=2ea44f" alt="Total downloads" /></a>
  <a href="https://github.com/iliyami/MacSai/stargazers"><img src="https://img.shields.io/github/stars/iliyami/MacSai?style=flat-square&color=gold" alt="GitHub stars" /></a>
  <a href="https://formulae.brew.sh/cask/mac-sai"><img src="https://img.shields.io/homebrew/cask/installs/dm/mac-sai?style=flat-square&label=homebrew&color=orange" alt="Homebrew installs" /></a>
  <a href="https://github.com/iliyami/MacSai/releases/latest"><img src="https://img.shields.io/github/v/release/iliyami/MacSai?style=flat-square&color=blue" alt="Latest release" /></a>
  <a href="https://github.com/iliyami/MacSai/graphs/commit-activity"><img src="https://img.shields.io/github/commit-activity/m/iliyami/MacSai?style=flat-square&label=commits" alt="Commit activity" /></a>
  <br>
  <img src="https://img.shields.io/badge/Apple-notarized-black?style=flat-square&logo=apple" alt="Notarized" />
  <img src="https://img.shields.io/badge/telemetry-none-brightgreen?style=flat-square" alt="No telemetry" />
  <img src="https://img.shields.io/badge/platform-macOS%2014%2B-lightgrey?style=flat-square" alt="macOS 14+" />
  <img src="https://img.shields.io/badge/swift-6-orange?style=flat-square" alt="Swift 6" />
  <a href="https://github.com/iliyami/MacSai/actions/workflows/ci.yml"><img src="https://img.shields.io/github/actions/workflow/status/iliyami/MacSai/ci.yml?branch=main&style=flat-square&label=tests" alt="Tests" /></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/license-BSD--3--Clause-green?style=flat-square" alt="License" /></a>
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

<p align="center">
  <sub>Niemals Werbung in der App. Diese Seite hat <a href="SPONSORS.md">einen geprüften Sponsorenplatz</a>, und er ist frei.</sub>
</p>

---

## Warum Mac Sai?

Ein voll ausgestatteter Mac-Reiniger sollte kein Jahresabo kosten und dich nicht bitten, einer Blackbox mit tiefem Zugriff auf deine Dateien zu vertrauen. Mac Sai gibt dir das komplette Werkzeugset, offen und einsehbar.

- **Für immer kostenlos.** Kein Abo, keine In-App-Käufe, kein "Upgrade auf Pro", keine Nag-Screens. BSD-3-lizenziert.
- **Null Telemetrie.** Keine Analytik, kein Crash-Reporter, keine Tracker, kein Server, an den etwas nach Hause gesendet werden könnte. Und du musst uns nicht einfach glauben, [überprüfe es selbst](#telemetriefreiheit-selbst-überprüfen) mit zwei Befehlen.
- **Jedes wichtige CleanMyMac-Werkzeug in einer App.** 22 Module für Bereinigung, Schutz, Leistung, Anwendungen und Speicheranalyse, plus ein Menüleisten-Widget.
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
- **Project Junk** (Build-Ordner)
- **Disk Hogs** (Docker, Simulatoren)
- **Clean History** (Wiederherstellen mit einem Klick)

</td>
<td width="33%" valign="top">

### 🛡️ Schutz
- **Malware Removal**
- **Privacy** (Browser)
- **Browser Extensions**
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
- **Unused Apps**
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
| **Project Junk** | Findet wiederherstellbare Build-Ordner in deinen Projekten: `node_modules`, `.next`, `dist`, Rust- und Maven-`target`, Gradle-`build`, Python-Virtualenvs und CocoaPods-`Pods`. Ein Ordner zählt nur, wenn die Dateien daneben den Projekttyp bestätigen, und `dist` und `Pods` nur, wenn deine `.gitignore` sie nennt. Alles geht in den Papierkorb |
| **Disk Hogs** | Zeigt, wie viel Platz Docker und Xcode-Simulatoren belegen. Entfernt gestoppte Container, verwaiste Images und verwaisten Build-Cache (jeweils nach einer Bestätigung) und löscht nicht verfügbare Simulatoren und alte Simulator-Laufzeiten. Docker-Volumes und die neueste Laufzeit jeder Plattform werden nie angerührt |
| **Clean History** | Listet deine letzten Bereinigungen auf (die letzten 30 Tage, bis zu 20) und holt eine ganze Bereinigung mit einem Klick aus dem Papierkorb zurück. Der Verlauf bleibt auf deinem Mac in `~/Library/Logs/MacClean/clean-history.json`, nur für dein Benutzerkonto lesbar, und wird nirgendwohin gesendet |

### 🛡️ Schutz
| Modul | Was es tut |
|--------|------------|
| **Malware Removal** | Signaturbasiertes Scannen in 3 Tiefen (Schnell / Ausgewogen / Tief): Launch Agents und Daemons, App-Bundles, Browser-Erweiterungen sowie bekannte Adware-/Malware-Muster. Exakter Hash-Abgleich mit Apples XProtect-Signaturen, die schon auf deinem Mac liegen, offline, dazu ein optionaler Hash-Feed von MalwareBazaar (abuse.ch). Safari-Erweiterungen auf Apples Sperrliste und MalwareBazaar-Treffer werden zur Prüfung aufgelistet und nie vorausgewählt (kein Antivirus, und das sagt es auch) |
| **Privacy** | Bereinigt Verlauf, Cookies und Cache von Safari, Chrome und Firefox, mit Zeitfiltern. Safari-**Lesezeichen werden nie angerührt** |
| **Browser Extensions** | Listet die installierten Erweiterungen in Safari, Chrome, Brave, Edge, Arc und Firefox auf. Selbst installierte Chromium- und Firefox-Erweiterungen können in den Papierkorb, solange der Browser geschlossen ist; per Richtlinie oder vom Browser selbst installierte werden angezeigt, aber nicht angerührt. Safari-Erweiterungen verlinken zu den Safari-Einstellungen |
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
| **Unused Apps** | Findet Apps, die du seit 3, 6 oder 12 Monaten nicht geöffnet hast, anhand des Spotlight-Datums der letzten Nutzung, sortiert nach Größe. Laufende Apps werden nie aufgelistet, und wenn Spotlight keine Nutzungsdaten hat, sagt es das, statt zu raten. Ein Klick übergibt eine App an den Uninstaller |
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
swift test                     # die volle Suite mit 1.048 Tests ausführen
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
rg -n 'URLSession|NSURLConnection|Sparkle|SecTrustEvaluate' Sources --glob '*.swift'
```

Die optionalen Netzwerkzugriffe sind unten aufgeführt. Die lokale Bereinigung überträgt weder Scanergebnisse noch Dateilisten:

- `Sources/MacClean/Services/SelfUpdateController.swift`: Sparkle prüft den im signierten Programm hinterlegten HTTPS-Feed und lädt signierte Versionshinweise und Update-Archive. Automatische Prüfungen und automatisches Laden/Installieren sind getrennte Einstellungen; Systemprofiling und JavaScript in Versionshinweisen sind deaktiviert. Siehe [Update-Einrichtung](docs/IN_APP_UPDATES.md). Bei konfigurierten Direktinstallationen sind automatische Update-Prüfungen standardmäßig aktiviert und laufen einmal täglich; jede Anfrage enthält die Versionen der App und von Sparkle im User-Agent, und die Prüfungen lassen sich in den Einstellungen abschalten.
- `Sources/MacCleanKit/UpdateChecker.swift`: Homebrew-Update-Prüfungen und die Release-Seite als Rückfall für Builds ohne eingerichteten signierten Feed
- `Sources/MacClean/Modules/Updater/UpdaterModule.swift`: die vom Benutzer ausgelöste Prüfung der Sparkle-Feeds *anderer Apps*, wenn du den Updater öffnest
- `Sources/MacCleanKit/MalwareBazaarFeed.swift`: der optionale Download von MalwareBazaar-Hashes. Er läuft nur, wenn du deinen eigenen abuse.ch-Auth-Key hinterlegst und unter Einstellungen > Malware-Datenbanken auf Jetzt aktualisieren klickst. Jede Anfrage sendet nur deinen Auth-Key und die Abfrage, niemals Datei-Hashes oder Pfade. Passt ein heruntergeladener Hash zu einer signierten Datei, fragt macOS bei Apple nach, ob ihr Signaturzertifikat widerrufen wurde, dieselbe Prüfung wie bei Gatekeeper; die Anfrage betrifft das Zertifikat, nicht deine Dateien

Es gibt nirgends im Code Analytik, einen Crash-Reporter oder ein Tracker-SDK.

**2. Beobachte den laufenden Prozess**

```bash
(
MACSAI_APP=$(cd "/Applications/Mac Sai.app" && pwd -P) || exit 1
MACSAI_PIDS=$(ps -ww -axo pid=,comm= | awk -v bundle="$MACSAI_APP/" '
  { pid=$1; sub(/^[[:space:]]*[0-9]+[[:space:]]+/, "")
    if (index($0, bundle) == 1) print pid }' | paste -sd, -)
if [ -n "$MACSAI_PIDS" ]; then
  ps -p "$MACSAI_PIDS" -o pid=,comm=
  lsof -nP -a -p "$MACSAI_PIDS" -i
else
  echo "No running executables from this Mac Sai bundle"
fi
)
```

Diese Momentaufnahme wählt PIDs anhand der ausführbaren Dateien im angegebenen App-Bundle aus und schließt fremde Installer-/Updater-Prozesse aus. An andere Orte kopierte Sparkle-Helfer und die macOS-Vertrauensdienste liegen außerhalb dieser Auswahl; beobachte sie mit einer prozessbezogenen Firewall. Führe den Befehl während einer Prüfung oder eines Downloads aus, um kurzlebige Verbindungen zu sehen.

Wenn keine Update-Prüfung, kein Download und keine optionale Malware-Verifikation laufen, öffnet die lokale Bereinigung keine Netzwerkverbindung. Beobachte bei Updates auch die Sparkle-Unterprozesse; Apple-Zertifikatsprüfungen laufen über die Vertrauensdienste von macOS. Little Snitch oder LuLu zeigen diese Verbindungen ebenfalls.

**3. Untersuche die Binärdatei, die du tatsächlich installiert hast**

Für eine Installation per DMG oder Homebrew braucht diese Schleife nur die macOS-Kommandozeilenwerkzeuge, keinen Quellcode-Checkout und kein Python. Sie liest alle sieben enthaltenen Binärdateien und zeigt häufige Netzwerkimporte, statische URLs und Tracker-Zeichenfolgen zur manuellen Prüfung:

```bash
(
MACSAI_APP="/Applications/Mac Sai.app"
MACSAI_SPARKLE="$MACSAI_APP/Contents/Frameworks/Sparkle.framework/Versions/B"
for MACSAI_BINARY in \
  "$MACSAI_APP/Contents/MacOS/MacClean" \
  "$MACSAI_APP/Contents/Library/LoginItems/MacCleanMenu.app/Contents/MacOS/MacCleanMenu" \
  "$MACSAI_SPARKLE/Sparkle" "$MACSAI_SPARKLE/Autoupdate" \
  "$MACSAI_SPARKLE/Updater.app/Contents/MacOS/Updater" \
  "$MACSAI_SPARKLE/XPCServices/Downloader.xpc/Contents/MacOS/Downloader" \
  "$MACSAI_SPARKLE/XPCServices/Installer.xpc/Contents/MacOS/Installer"
do
  printf '\n%s\n' "$MACSAI_BINARY"
  MACSAI_IMPORTS=$(nm -uj "$MACSAI_BINARY") || exit 1
  printf '%s\n' "$MACSAI_IMPORTS" | grep -Ei \
    'URLSession|URLConnection|CFNetwork|Network|nw_|DNSService|NetService|curl_|^_(socket|connect|connectx|send|recv)([$]|$)' || true
  MACSAI_STRINGS=$(strings -a "$MACSAI_BINARY") || exit 1
  printf '%s\n' "$MACSAI_STRINGS" | grep -Ei \
    '://|sentry|firebase|mixpanel|amplitude|bugsnag|crashlytics|posthog|appsflyer' || true
done
)
```

Diese Ausgabe ist kein automatisches Prüfurteil und kein Nachweis, dass alle zur Laufzeit gewählten Ziele sichtbar sind. Nutze die folgende automatisierte Prüfung für das vollständige Komponentenverzeichnis, ausdrückliche Freigabelisten und die eingebetteten Datenschutzeinstellungen.

Führe die Prüfung aus einem Quellcode-Checkout aus, der zur installierten Version passt. Sie untersucht das tatsächlich installierte App-Bundle: Hauptprogramm, Menüleistenhelfer, `Sparkle.framework`, `Autoupdate`, `Updater.app`, `Downloader.xpc` und `Installer.xpc`:

```bash
bash scripts/check-network-surface.sh "/Applications/Mac Sai.app"
```

Erwartet: sieben geprüfte Mach-O-Dateien. Fehlende oder unerwartete Binärdateien, nicht freigegebene Netzwerkimporte oder statische URLs sowie Tracker-Merkmale lassen die Prüfung fehlschlagen. URLSession-Importe sind in Mac Sai, seinem Menüleistenhelfer, Sparkle und Downloader erlaubt; die übrigen Sparkle-Helfer dürfen keine Netzwerkimporte haben. Sparkles Dokumentationslinks und XML-Namensraum sind ausdrücklich aufgeführt und gelten nicht als Download-Endpunkte.

Das Skript zeigt außerdem die hinterlegte `SUFeedURL` und prüft Signaturpflicht, Prüfung vor dem Entpacken und Datenschutzeinstellungen. Vergleiche die Archiv-/Versionshinweis-Adressen dieses Feeds und die von dir angefragten Feeds anderer Apps mit den beobachteten Verbindungen. Die Rückfall-Endpunkte sind `api.github.com/repos/iliyami/MacSai/releases/latest` und `formulae.brew.sh/api/cask/mac-sai.json`; der optionale Malware-Endpunkt ist `mb-api.abuse.ch/api/v1/`. Projekt-, Support- und Browsereinstellungslinks öffnen sich nur auf Anfrage. Dieselbe vollständige Bundle-Prüfung läuft beim Paketbau; CI prüft beide gebauten Programme und alle fünf Binärdateien der festgelegten Sparkle-Version. [Implementierung und Freigabelisten](scripts/check-network-surface.py).

---

## Architektur

```
Mac Sai
├── MacClean          Haupt-SwiftUI-App (22 Module)
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

Die XCTest-Suite hat **1.048 Tests** und behandelt `SafetyGuard` und `CleaningEngine` (die Dateien über Leben und Tod) als muss-perfekt-sein: adversariale Abdeckung von Symlinks, Pfad-Traversierung, NULL-Bytes, SIP, geschützten Apps, Dateianzahl-Obergrenzen, TOCTOU und Idempotenz, plus Integrationsabdeckung von Probelauf- / Papierkorb- / permanenter Bereinigung, der Scan-Zustandsmaschine, jeder System-Junk-Kategorie, der Treemap-Mathematik, der Uninstaller-Suchmaschine, der Duplikaterkennung, des Appcast-Parsings und vollständiger End-to-End-Zyklen von Fixture bis Bereinigung. Fixtures (`withTempHome`, `withFakeApp`, `withFakePlist`) halten jeden Test von deinem echten Home-Verzeichnis fern.

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

## Unterstützung und Sponsoren

Mac Sai ist kostenlos und bleibt es: keine Bezahlversion, keine Werbung, kein Tracking. Wenn es dir ein Abo für ein Reinigungsprogramm erspart hat, kannst du mir [einen Kaffee spendieren ☕](https://buymeacoffee.com/iliyami). Das hält die Releases signiert, notarisiert und regelmäßig.

### Sponsorenplatz

Mac Sai hat **einen einzigen** Sponsorenplatz, hier und oben auf dieser Seite, in jeder Sprache dieser README.

<div align="center">
<table>
  <tr>
    <td align="center" width="25%"><h3>100.000+</h3><sub>Downloads</sub></td>
    <td align="center" width="25%"><h3>2.000+</h3><sub>GitHub-Sterne</sub></td>
    <td align="center" width="25%"><h3>17.000</h3><sub>Seitenaufrufe pro Monat</sub></td>
    <td align="center" width="25%"><h3>6</h3><sub>README-Sprachen</sub></td>
  </tr>
</table>
</div>

Die meisten Besucher sind Entwickler und Mac-Power-User und kommen vor allem über die Google-Suche, danach über YouTube, GitHub und Reddit.

- **Immer nur ein Sponsor**, damit dein Name nicht in einer Logowand untergeht.
- **Geprüft.** Entwicklerwerkzeuge, Datenschutz- und Sicherheitsprodukte sowie Mac-Apps, die ihre Nutzer respektieren. Keine Reinigungs- oder „Optimierungs“-Tools, keine Kryptowährungen, keine VPN-Affiliate-Deals, nichts, was Menschen trackt.
- **Niemals in der App.** Mac Sai hat keine Werbung und keine Telemetrie, und daran ändert kein Sponsor etwas.

<p align="center">
  <strong>Dieser Platz ist frei.</strong> <a href="mailto:iliya.mi78@gmail.com?subject=Mac%20Sai%20sponsor">Sponsor werden →</a><br>
  <sub>Zielgruppe und Bewerbung: <a href="SPONSORS.md">SPONSORS.md</a> (Englisch)</sub>
</p>

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
  Wenn es dir ein Abo erspart hat, hilft ein ⭐ anderen, es zu finden, und ein <a href="https://buymeacoffee.com/iliyami">Kaffee ☕</a> hält es am Laufen.
</p>
