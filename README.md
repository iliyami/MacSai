<p align="center">
  <img src="assets/app_icon.png" width="150" alt="Mac Sai Icon" />
</p>

<h1 align="center">Mac Sai</h1>

<p align="center">
  <strong>The open-source Mac cleaner, optimizer, and malware scanner.</strong><br>
  A free, Apple-notarized alternative to CleanMyMac, built with Swift 6 and SwiftUI.
</p>

<p align="center">
  <strong>English</strong> | <a href="README.zh-CN.md">简体中文</a> | <a href="README.ru.md">Русский</a>
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
  <strong>Install in one command:</strong>
</p>

```bash
brew install --cask mac-sai
```

<p align="center">
  Or grab the <a href="https://github.com/iliyami/MacSai/releases/latest">latest DMG</a>. It is notarized by Apple, so it just opens, no right-click, no warnings, no Terminal.
</p>

---

## Why Mac Sai?

A full-featured Mac cleaner should not cost a yearly subscription or ask you to trust a black box with deep access to your files. Mac Sai gives you the whole toolkit, in the open.

- **Free, forever.** No subscription, no in-app purchases, no "upgrade to Pro", no nag screens. BSD-3 licensed.
- **Zero telemetry.** No analytics, no crash reporter, no trackers, no server to phone home to. And you do not have to take our word for it, [verify it yourself](#verify-no-telemetry-yourself) in two commands.
- **Every major CleanMyMac tool, in one app.** 17 modules across cleanup, protection, performance, applications, and disk insight, plus a menu-bar widget.
- **Safe by design.** Trash-first deletion, a protected-paths blocklist, symlink and TOCTOU guards, and a `SafetyGuard` that validates every path. It is built to never lose your data.
- **Apple-notarized and fully open source.** Your Mac verifies the signature every launch, and every line is here to read.

---

## Features at a glance

<table>
<tr>
<td width="33%" valign="top">

### 🧹 Cleanup
- **Smart Scan** (one click)
- **System Junk** (16+ categories)
- **Mail Attachments**
- **Trash Bins**

</td>
<td width="33%" valign="top">

### 🛡️ Protection
- **Malware Removal**
- **Privacy** (browsers)
- **Saved Wi-Fi**
- **Permissions Overview**

</td>
<td width="33%" valign="top">

### ⚡ Performance
- **Optimization** (login items)
- **Maintenance** (system tasks)

</td>
</tr>
<tr>
<td width="33%" valign="top">

### 📦 Applications
- **Uninstaller** (+ Reset to Defaults)
- **Extensions** (panes, plug-ins)
- **Updater**

</td>
<td width="33%" valign="top">

### 🗂️ Files
- **Space Lens** (disk treemap)
- **Large & Old Files**
- **Duplicates** (+ Consolidate)
- **Shredder**

</td>
<td width="33%" valign="top">

### 📊 Menu Bar
- Live CPU / memory / disk / battery
- Network, uptime, swap
- Actionable recommendations

</td>
</tr>
</table>

---

## Features in detail

### 🧹 Cleanup
| Module | What it does |
|--------|------------|
| **Smart Scan** | One click runs cleanup, protection, and performance modules together with live progress, then shows exactly what it freed per module |
| **System Junk** | 16+ scan categories: user and system caches, logs, language files, broken preferences, broken login items, document versions, iOS backups, Xcode junk, package-manager / IDE / AI-tool caches, deleted-user leftovers, and **Universal Binary thinning** (finds fat Mach-O binaries carrying both arm64 and x86_64 and rewrites them to your native arch via `lipo`, honoring Cancel) |
| **Mail Attachments** | Finds cached attachments from Apple Mail, Outlook, and Spark |
| **Trash Bins** | Empties the Trash across every location, including external drives |

### 🛡️ Protection
| Module | What it does |
|--------|------------|
| **Malware Removal** | Signature-based scanning at 3 depths (Quick / Balanced / Deep): launch agents and daemons, browser extensions, and known adware/malware patterns (curated list, not an antivirus, and it says so) |
| **Privacy** | Cleans Safari, Chrome, and Firefox history, cookies, and cache, with time filters. Safari **bookmarks are never touched** |
| **Saved Wi-Fi** | Lists your preferred wireless networks and forgets the ones you pick |
| **Permissions Overview** | A read-only, by-app view of which privacy (TCC) grants each app holds, the angle System Settings does not give you. Every action deep-links to System Settings, which owns the toggles |

### ⚡ Performance
| Module | What it does |
|--------|------------|
| **Optimization** | Manage login items and launch agents with per-item enable/disable |
| **Maintenance** | System tasks: free RAM, run maintenance scripts, verify the startup disk, rebuild Launch Services, reindex Spotlight, flush DNS, thin Time Machine snapshots. Tasks are tagged by severity, "Run Safe Tasks" is sequential, and the admin password is asked **once** |

### 📦 Applications
| Module | What it does |
|--------|------------|
| **Uninstaller** | A pattern-matching engine that finds every associated file across 17+ Library subdirectories (including apps nested in vendor subfolders). Complete removal, **Reset to Defaults** (wipe an app's caches and preferences while keeping the app), and unused-app detection |
| **Extensions** | Review third-party preference panes, Internet Plug-Ins, and Safari extensions. User-installed panes and plug-ins can go to the Trash |
| **Updater** | Checks installed apps for updates via their own Sparkle appcast feeds (reads version info only, sends nothing about you) |

### 🗂️ Files
| Module | What it does |
|--------|------------|
| **Space Lens** | Squarified-treemap visualization of disk usage with drill-down navigation |
| **Large & Old Files** | Finds files over 50 MB, sorted by size and last access date |
| **Duplicates** | Progressive detection (size grouping, partial SHA-256, full hash, inode verification), plus a **Consolidate** mode that reclaims space with APFS copy-on-write clones without deleting a single copy |
| **Shredder** | Secure file erasure with standard, permanent, and secure-overwrite modes |

### 📊 Menu Bar Widget

<p align="center">
  <img src="assets/menu_bar.png" width="300" alt="Mac Sai menu bar widget" />
</p>

A glassmorphism menu-bar widget that puts your Mac's vitals one click away. It is an independent process that launches at login and is toggled from the app's sidebar, so you never have to open the main window just to check in.

- **Live stat rings**: CPU load, memory pressure, disk usage, and battery in a 2x2 ring grid (`host_processor_info`, `vm_statistics64`, APFS capacity, IOKit power source), color-graded green to amber to red
- **Configurable readout**: show free disk, GPU usage, memory usage, or battery temperature; the choice persists, and unavailable sensors show `--`
- **Network, uptime, and swap**: real-time up/down throughput, system uptime, swap usage
- **Recommendations**: actionable, dismissible tips ("User caches grew to 2.52 GB, run System Junk"), one tap to act, suppressed for 30 days once dismissed
- **Protection status**: last malware-scan time and threat count, color-coded by freshness
- **Connected devices**: external volumes (with free space) and displays at a glance
- **Health alerts**: throttled, opt-in notifications when the disk runs critically low or memory pressure stays high

### ⌨️ Keyboard shortcuts

| Shortcut | Action |
|----------|--------|
| **⌘R** | Start a scan in the current module |
| **⌘K** | Clean the current selection (when results are showing) |
| **⌘1 to ⌘9** | Jump to the first nine sidebar modules |
| **⌘,** | Open Settings |

---

## How Mac Sai compares

|  | Mac Sai | CleanMyMac | Pearcleaner | PureMac | OnyX | Mole |
|---|:---:|:---:|:---:|:---:|:---:|:---:|
| **Price** | Free | $39.95/yr | Free | Free | Free | Free (CLI) |
| **Open source** | ✅ BSD-3 | ❌ | ✅ Fair-code | ✅ MIT | ❌ | ✅ MIT |
| **Telemetry** | ❌ None | ⚠️ Yes | ❌ None | ❌ None | ❌ None | ❌ None |
| **Native GUI app** | ✅ | ✅ | ✅ | ✅ | ✅ | ❌ CLI (paid GUI separate) |
| **Smart Scan (one-click)** | ✅ | ✅ | ❌ | ➖ Partial | ❌ | ➖ Interactive CLI |
| **System Junk (16+ categories)** | ✅ | ✅ | ➖ | ✅ | ➖ Limited | ✅ |
| **Universal Binary thinning** | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ |
| **Malware scanner** | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ |
| **Browser privacy cleaner** | ✅ | ✅ | ❌ | ❌ | ➖ | ❌ |
| **Uninstaller with leftover detection** | ✅ | ✅ | ✅ Focus | ❌ | ❌ | ✅ |
| **Duplicate finder (+ consolidation)** | ✅ | ➖ | ❌ | ❌ | ❌ | ❌ |
| **Disk treemap visualizer** | ✅ | ❌ | ❌ | ❌ | ❌ | ➖ Analyzer |
| **Menu bar system monitor** | ✅ | ✅ Menu | ❌ | ❌ | ❌ | ❌ |
| **Maintenance scripts** | ✅ | ✅ | ❌ | ❌ | ✅ Strong | ➖ |
| **Notarized by Apple** | ✅ | ✅ | ✅ | ✅ | ✅ | N/A |
| **macOS version** | 14+ | 13+ | 13+ | 13+ | varies | varies |

> CleanMyMac is a great product, and the people who want a polished, supported experience should happily pay for it. Mac Sai is for everyone who would rather have transparent source code and zero subscription.

---

## Installation

### Homebrew (recommended)

Mac Sai is in the official Homebrew cask, so no tap is needed:

```bash
brew install --cask mac-sai
```

It is notarized by Apple, so it launches from Spotlight or Applications with no warnings and no extra steps.

<details>
<summary><strong>Other ways to install</strong> (one-line script, DMG, build from source)</summary>

<br>

**One-line installer**

```bash
curl -fsSL https://raw.githubusercontent.com/iliyami/MacSai/main/scripts/install.sh | bash
```

Downloads the latest DMG and installs the app to `/Applications`.

**DMG download**

Grab the latest DMG from [Releases](https://github.com/iliyami/MacSai/releases/latest) and drag Mac Sai to your Applications folder.

**Build from source**

```bash
git clone https://github.com/iliyami/MacSai.git
cd MacSai
swift build
swift test                     # run the full 862-test suite
bash scripts/build-dmg.sh      # build a local DMG (unsigned)
```

Requires the Swift 6 toolchain (Xcode 16+).

**Installed via the old tap?**

Mac Sai is in the official cask now, so you can drop the tap: `brew untap iliyami/macsai` (your installed app and future `brew upgrade` are unaffected).

</details>

### Granting Full Disk Access

A few modules (Mail Attachments, Privacy, Malware) need Full Disk Access to scan protected areas:

1. Open **System Settings, Privacy & Security, Full Disk Access**
2. Click **+** and add **Mac Sai.app**
3. Restart Mac Sai

### Uninstalling

Homebrew install:

```bash
brew uninstall --zap --cask mac-sai
```

DMG or manual install (also handles a Homebrew install):

```bash
curl -fsSL https://raw.githubusercontent.com/iliyami/MacSai/main/scripts/uninstall.sh | bash
```

Both remove Mac Sai plus its preferences, caches, logs, and database under `~/Library`.

---

## Signed, notarized, and yours to trust

Mac Sai is code-signed with an Apple **Developer ID** and **notarized by Apple**. That matters more for a cleaning app than for almost anything else you install, because you are about to give it deep access to your files, and you deserve to know that what runs on your Mac is genuinely ours and untampered with. All of this is enforced by your own Mac, not just promised by us:

- **Apple has scanned it.** Every release is submitted to Apple and checked for malware before it ships.
- **It cannot be tampered with.** The signature is a cryptographic seal over every file; change a single byte and macOS refuses to open it.
- **It is provably from us.** The signature is tied to our Apple Developer identity, so no one else can ship something your Mac accepts as Mac Sai.
- **It just works.** No Gatekeeper warnings, no right-click-to-open, no Terminal.

Put together with a fully open source, this is a chain of trust you do not take on faith: the code is public, we sign every release, Apple verifies it, and your Mac re-checks the seal every time you open the app.

### Verify no telemetry yourself

Do not take our word for it. Both the source and the running process are checkable.

**1. Search the source for networking APIs**

```bash
rg -n 'URLSession|NSURLConnection' Sources --glob '*.swift'
```

You should only ever see two network paths, both optional and both read-only:

- `Sources/MacCleanKit/UpdateChecker.swift`: the optional Mac Sai update check (turn it off in Settings)
- `Sources/MacClean/Modules/Updater/UpdaterModule.swift`: the user-driven check of *other apps'* Sparkle feeds when you open the Updater

There is no analytics, crash reporter, or tracker SDK anywhere in the codebase.

**2. Watch the live process**

```bash
lsof -i -P -n | grep -i 'MacClean\|Mac Sai\|MacSai' || echo "no network sockets"
```

Expected: no established connections while you are only cleaning locally. Little Snitch or LuLu make the same check visual.

---

## Architecture

```
Mac Sai
├── MacClean          Main SwiftUI app (17 modules)
├── MacCleanKit       Shared framework (models, constants, protocols)
├── MacCleanHelper    XPC privileged helper (LaunchDaemon for root ops)
└── MacCleanMenu      Menu-bar monitor (independent process)
```

### Tech stack

| Layer | Technology |
|-------|-----------|
| Language | Swift 6 with strict concurrency |
| UI | SwiftUI + AppKit hybrid |
| Concurrency | Actors, TaskGroup, async/await, `@Sendable` |
| Database | GRDB.swift (SQLite) with WAL mode |
| File scanning | `URLResourceKey` prefetching on APFS |
| Incremental updates | FSEvents with historical replay |
| Privileged ops | SMAppService + NSXPCConnection |
| System stats | Mach APIs (`host_processor_info`, `vm_statistics64`, `proc_pidinfo`) |

### Safety model

Mac Sai is designed to **never cause data loss**:

- **Protected-paths blocklist**: `/System`, `/usr`, `/bin`, `/sbin`, and Apple system apps are untouchable, with macOS firmlinks canonicalized so symlink-redirect detection does not false-positive on legitimate system paths
- **Pre-scan cleanability filter**: items the current process could not trash (root-owned children of system caches, data-vaulted `~/Library/Caches/com.apple.*` dirs) are dropped at scan time so they never appear as cleanable
- **Trash-first deletion**: every removal goes to the Trash by default, and a dry-run mode previews without touching anything
- **TOCTOU prevention**: symlinks are re-resolved immediately before deletion
- **Excluded Folders**: pick folders in Settings that scans skip entirely, and `SafetyGuard` additionally refuses to delete anything under them
- **Chunked, cancellable cleanup**: large selections split into 5k-item chunks honoring cancellation between chunks, and scans return to idle within about a second when you hit Cancel
- **In-app activity log**: every error during a clean is logged with its full path, viewable and copyable from the post-clean screen, auto-pruned after 30 days
- **Kernel-enforced XPC gate**: the privileged helper uses `NSXPCListener.setCodeSigningRequirement` so the kernel itself rejects any connection whose code signature does not match the app's identifier and team

---

## Tests

```bash
swift test
```

The XCTest suite has **862 tests** and treats `SafetyGuard` and `CleaningEngine` (the death-and-life files) as must-be-perfect: adversarial coverage of symlinks, path traversal, NULL bytes, SIP, protected apps, file-count caps, TOCTOU, and idempotence, plus integration coverage of dry-run / trash / permanent cleaning, the scan state machine, every System Junk category, the treemap math, the uninstaller matching engine, duplicate detection, appcast parsing, and full end-to-end fixture-to-clean cycles. Fixtures (`withTempHome`, `withFakeApp`, `withFakePlist`) keep every test off your real home directory.

---

## Contributing

Contributions are very welcome. Read the [Contributing Guidelines](CONTRIBUTING.md), then:

1. Fork the repo and create a feature branch
2. Make your change (one focused change per PR keeps review easy)
3. Run `swift test`
4. Open a Pull Request

There is also an open [feature vote](https://github.com/iliyami/MacSai/issues/55): 👍 the tools you want built next.

## License

BSD 3-Clause. See [LICENSE](LICENSE). You may use, modify, and redistribute the code, provided you keep the copyright and license text and do not use the "Mac Sai" name or contributors' names to endorse derived products without permission.

## Acknowledgments

Inspired by the open-source Mac utility community:

- [Pearcleaner](https://github.com/alienator88/Pearcleaner): app uninstaller patterns
- [Mole](https://github.com/tw93/Mole): cleanup categories
- [Tencent Lemon Cleaner](https://github.com/Tencent/lemon-cleaner): modular architecture
- Squarified Treemap algorithm by Bruls, Huizing, and van Wijk (2000)

## Star History

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
  <strong>Mac Sai is free software built by the community, for the community.</strong><br>
  If it saved you from a subscription, a ⭐ helps others find it.
</p>
