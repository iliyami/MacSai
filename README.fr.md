<p align="center">
  <img src="assets/app_icon.png" width="150" alt="Mac Sai Icon" />
</p>

<h1 align="center">Mac Sai</h1>

<p align="center">
  <strong>Le nettoyeur, optimiseur et scanner de logiciels malveillants open source pour Mac.</strong><br>
  Une alternative gratuite et notariée par Apple à CleanMyMac, conçue avec Swift 6 et SwiftUI.
</p>

<p align="center">
  <a href="README.md">English</a> | <a href="README.zh-CN.md">简体中文</a> | <a href="README.zh-Hant.md">繁體中文</a> | <a href="README.de.md">Deutsch</a> | <strong>Français</strong> | <a href="README.ru.md">Русский</a>
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
  <strong>Installez en une commande :</strong>
</p>

```bash
brew install --cask mac-sai
```

<p align="center">
  Ou récupérez le <a href="https://github.com/iliyami/MacSai/releases/latest">dernier DMG</a>. Il est notarié par Apple, il s'ouvre donc directement, sans clic droit, sans avertissement, sans Terminal.
</p>

---

## Pourquoi Mac Sai ?

Un nettoyeur Mac complet ne devrait pas coûter un abonnement annuel ni vous demander de faire confiance à une boîte noire disposant d'un accès étendu à vos fichiers. Mac Sai vous offre toute la boîte à outils, à découvert.

- **Gratuit, pour toujours.** Pas d'abonnement, pas d'achats intégrés, pas de « passage à Pro », pas de fenêtres insistantes. Sous licence BSD-3.
- **Zéro télémétrie.** Pas d'analytique, pas de rapport de plantage, pas de traqueurs, aucun serveur où téléphoner. Et vous n'avez pas à nous croire sur parole, [vérifiez-le vous-même](#vérifiez-labsence-de-télémétrie-vous-même) en deux commandes.
- **Chaque outil majeur de CleanMyMac, dans une seule app.** 17 modules couvrant le nettoyage, la protection, les performances, les applications et l'analyse du disque, plus un widget dans la barre des menus.
- **Sûr par conception.** Suppression d'abord vers la corbeille, une liste de chemins protégés, des protections contre les liens symboliques et TOCTOU, et un `SafetyGuard` qui valide chaque chemin. Conçu pour ne jamais perdre vos données.
- **Notarié par Apple et entièrement open source.** Votre Mac vérifie la signature à chaque lancement, et chaque ligne est ici, à lire.

---

## Fonctionnalités en un coup d'œil

<table>
<tr>
<td width="33%" valign="top">

### 🧹 Nettoyage
- **Smart Scan** (un clic)
- **System Junk** (16+ catégories)
- **Mail Attachments**
- **Trash Bins**

</td>
<td width="33%" valign="top">

### 🛡️ Protection
- **Malware Removal**
- **Privacy** (navigateurs)
- **Saved Wi-Fi**
- **Permissions Overview**

</td>
<td width="33%" valign="top">

### ⚡ Performances
- **Optimization** (objets d'ouverture)
- **Maintenance** (tâches système)

</td>
</tr>
<tr>
<td width="33%" valign="top">

### 📦 Applications
- **Uninstaller** (+ Réinitialiser aux valeurs par défaut)
- **Extensions** (volets, modules)
- **Updater**

</td>
<td width="33%" valign="top">

### 🗂️ Fichiers
- **Space Lens** (treemap du disque)
- **Large & Old Files**
- **Duplicates** (+ Consolider)
- **Shredder**

</td>
<td width="33%" valign="top">

### 📊 Barre des menus
- CPU / mémoire / disque / batterie en direct
- Réseau, temps de fonctionnement, swap
- Recommandations actionnables

</td>
</tr>
</table>

---

## Fonctionnalités en détail

### 🧹 Nettoyage
| Module | Ce que ça fait |
|--------|------------|
| **Smart Scan** | Un clic exécute ensemble les modules de nettoyage, de protection et de performances avec une progression en direct, puis montre exactement ce qui a été libéré par module |
| **System Junk** | 16+ catégories de scan : caches utilisateur et système, journaux, fichiers de langue, préférences corrompues, objets d'ouverture invalides, versions de documents, sauvegardes iOS, résidus Xcode, caches des gestionnaires de paquets / IDE / outils d'IA, restes d'utilisateurs supprimés, ainsi que l'**amincissement des binaires universels** (repère les binaires Mach-O gras contenant à la fois arm64 et x86_64 et les réécrit pour votre architecture native via `lipo`, en respectant l'annulation) |
| **Mail Attachments** | Trouve les pièces jointes mises en cache par Apple Mail, Outlook et Spark |
| **Trash Bins** | Vide la corbeille à chaque emplacement, y compris sur les disques externes |

### 🛡️ Protection
| Module | Ce que ça fait |
|--------|------------|
| **Malware Removal** | Analyse par signatures à 3 profondeurs (Rapide / Équilibré / Approfondi) : agents et démons de lancement, extensions de navigateur et motifs connus d'adware/malware (liste organisée, pas un antivirus, et il le dit) |
| **Privacy** | Nettoie l'historique, les cookies et le cache de Safari, Chrome et Firefox, avec des filtres temporels. Les **favoris de Safari ne sont jamais touchés** |
| **Saved Wi-Fi** | Liste vos réseaux sans fil préférés et oublie ceux que vous choisissez |
| **Permissions Overview** | Une vue en lecture seule, par app, des autorisations de confidentialité (TCC) détenues par chaque app, l'angle que les Réglages Système ne vous donnent pas. Chaque action renvoie vers les Réglages Système, qui possèdent les interrupteurs |

### ⚡ Performances
| Module | Ce que ça fait |
|--------|------------|
| **Optimization** | Gère les objets d'ouverture et les agents de lancement avec activation/désactivation par élément |
| **Maintenance** | Tâches système : libérer la RAM, exécuter les scripts de maintenance, vérifier le disque de démarrage, reconstruire Launch Services, réindexer Spotlight, vider le DNS, amincir les instantanés Time Machine. Les tâches sont étiquetées par gravité, « Exécuter les tâches sûres » est séquentiel, et le mot de passe administrateur est demandé **une seule fois** |

### 📦 Applications
| Module | Ce que ça fait |
|--------|------------|
| **Uninstaller** | Un moteur de correspondance par motifs qui trouve chaque fichier associé dans 17+ sous-dossiers de Library (y compris les apps imbriquées dans des sous-dossiers d'éditeur). Suppression complète, **Réinitialiser aux valeurs par défaut** (effacer les caches et préférences d'une app tout en la conservant) et détection des apps inutilisées |
| **Extensions** | Passez en revue les volets de préférences tiers, les modules Internet et les extensions Safari. Les volets et modules installés par l'utilisateur peuvent aller à la corbeille |
| **Updater** | Vérifie les mises à jour des apps installées via leurs propres flux d'appcast Sparkle (lit uniquement les informations de version, n'envoie rien vous concernant) |

### 🗂️ Fichiers
| Module | Ce que ça fait |
|--------|------------|
| **Space Lens** | Visualisation en treemap carré de l'utilisation du disque avec navigation par exploration |
| **Large & Old Files** | Trouve les fichiers de plus de 50 Mo, triés par taille et date de dernier accès |
| **Duplicates** | Détection progressive (regroupement par taille, SHA-256 partiel, hachage complet, vérification d'inode), plus un mode **Consolider** qui récupère de l'espace avec des clones APFS en copie sur écriture sans supprimer une seule copie |
| **Shredder** | Effacement sécurisé de fichiers avec les modes standard, permanent et réécriture sécurisée |

### 📊 Widget de la barre des menus

<p align="center">
  <img src="assets/menu_bar.png" width="300" alt="Mac Sai menu bar widget" />
</p>

Un widget de barre des menus au style glassmorphisme qui met les constantes vitales de votre Mac à un clic. C'est un processus indépendant qui se lance à l'ouverture de session et se bascule depuis la barre latérale de l'app, vous n'avez donc jamais à ouvrir la fenêtre principale juste pour jeter un œil.

- **Anneaux de statistiques en direct** : charge CPU, pression mémoire, utilisation du disque et batterie dans une grille d'anneaux 2x2 (`host_processor_info`, `vm_statistics64`, capacité APFS, source d'alimentation IOKit), graduée en couleur du vert à l'ambre au rouge
- **Affichage configurable** : montrez l'espace disque libre, l'utilisation du GPU, l'utilisation de la mémoire ou la température de la batterie ; le choix persiste, et les capteurs indisponibles affichent `--`
- **Réseau, temps de fonctionnement et swap** : débit montant/descendant en temps réel, temps de fonctionnement du système, utilisation du swap
- **Recommandations** : conseils actionnables et masquables (« Les caches utilisateur ont atteint 2,52 Go, lancez System Junk »), une touche pour agir, supprimés pendant 30 jours une fois masqués
- **Statut de protection** : heure du dernier scan de logiciels malveillants et nombre de menaces, codé en couleur selon la fraîcheur
- **Appareils connectés** : volumes externes (avec espace libre) et écrans en un coup d'œil
- **Alertes de santé** : notifications limitées et optionnelles lorsque le disque devient critiquement plein ou que la pression mémoire reste élevée

### ⌨️ Raccourcis clavier

| Raccourci | Action |
|----------|--------|
| **⌘R** | Démarrer un scan dans le module actuel |
| **⌘K** | Nettoyer la sélection actuelle (quand des résultats sont affichés) |
| **⌘1 à ⌘9** | Sauter aux neuf premiers modules de la barre latérale |
| **⌘,** | Ouvrir les Réglages |

---

## Comment Mac Sai se compare

|  | Mac Sai | CleanMyMac | Pearcleaner | PureMac | OnyX | Mole |
|---|:---:|:---:|:---:|:---:|:---:|:---:|
| **Prix** | Gratuit | 39,95 $/an | Gratuit | Gratuit | Gratuit | Gratuit (CLI) |
| **Open source** | ✅ BSD-3 | ❌ | ✅ Fair-code | ✅ MIT | ❌ | ✅ MIT |
| **Télémétrie** | ❌ Aucune | ⚠️ Oui | ❌ Aucune | ❌ Aucune | ❌ Aucune | ❌ Aucune |
| **App GUI native** | ✅ | ✅ | ✅ | ✅ | ✅ | ❌ CLI (GUI payante séparée) |
| **Smart Scan (un clic)** | ✅ | ✅ | ❌ | ➖ Partiel | ❌ | ➖ CLI interactive |
| **System Junk (16+ catégories)** | ✅ | ✅ | ➖ | ✅ | ➖ Limité | ✅ |
| **Amincissement des binaires universels** | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ |
| **Scanner de logiciels malveillants** | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ |
| **Nettoyeur de confidentialité des navigateurs** | ✅ | ✅ | ❌ | ❌ | ➖ | ❌ |
| **Désinstalleur avec détection des restes** | ✅ | ✅ | ✅ Spécialisé | ❌ | ❌ | ✅ |
| **Recherche de doublons (+ consolidation)** | ✅ | ➖ | ❌ | ❌ | ❌ | ❌ |
| **Visualiseur treemap du disque** | ✅ | ❌ | ❌ | ❌ | ❌ | ➖ Analyseur |
| **Moniteur système dans la barre des menus** | ✅ | ✅ Menu | ❌ | ❌ | ❌ | ❌ |
| **Scripts de maintenance** | ✅ | ✅ | ❌ | ❌ | ✅ Robuste | ➖ |
| **Notarié par Apple** | ✅ | ✅ | ✅ | ✅ | ✅ | N/D |
| **Version de macOS** | 14+ | 13+ | 13+ | 13+ | variable | variable |

> CleanMyMac est un excellent produit, et ceux qui veulent une expérience soignée et prise en charge devraient volontiers payer pour cela. Mac Sai est pour tous ceux qui préfèrent un code source transparent et zéro abonnement.

---

## Langues de l'interface

Choisissez System, Deutsch, Français, Русский, 简体中文, 繁體中文 ou English dans Réglages → Langue de l'interface. L'allemand, le français et le chinois traditionnel traduisent les textes statiques de l'interface ; les messages interpolés conservent pour l'instant le texte anglais et ses règles de pluriel (le chinois traditionnel se rabat sur le simplifié). La fenêtre principale et le widget de la barre des menus partagent le réglage de langue.

## Installation

### Homebrew (recommandé)

Mac Sai est dans le cask Homebrew officiel, aucun tap n'est donc nécessaire :

```bash
brew install --cask mac-sai
```

Il est notarié par Apple, il se lance donc depuis Spotlight ou le dossier Applications sans avertissement et sans étape supplémentaire.

<details>
<summary><strong>Autres façons d'installer</strong> (script en une ligne, DMG, compilation depuis les sources)</summary>

<br>

**Installateur en une ligne**

```bash
curl -fsSL https://raw.githubusercontent.com/iliyami/MacSai/main/scripts/install.sh | bash
```

Télécharge le dernier DMG et installe l'app dans `/Applications`.

**Téléchargement du DMG**

Récupérez le dernier DMG depuis les [Releases](https://github.com/iliyami/MacSai/releases/latest) et glissez Mac Sai dans votre dossier Applications.

**Compiler depuis les sources**

```bash
git clone https://github.com/iliyami/MacSai.git
cd MacSai
swift build
swift test                     # exécuter la suite complète de 862 tests
bash scripts/build-dmg.sh      # compiler un DMG local (non signé)
```

Nécessite la chaîne d'outils Swift 6 (Xcode 16+).

**Installé via l'ancien tap ?**

Mac Sai est maintenant dans le cask officiel, vous pouvez donc retirer le tap : `brew untap iliyami/macsai` (votre app installée et les futurs `brew upgrade` ne sont pas affectés).

</details>

### Accorder l'accès complet au disque

Quelques modules (Mail Attachments, Privacy, Malware) ont besoin de l'accès complet au disque pour scanner les zones protégées :

1. Ouvrez **Réglages Système, Confidentialité et sécurité, Accès complet au disque**
2. Cliquez sur **+** et ajoutez **Mac Sai.app**
3. Redémarrez Mac Sai

### Désinstaller

Installation Homebrew :

```bash
brew uninstall --zap --cask mac-sai
```

Installation DMG ou manuelle (gère aussi une installation Homebrew) :

```bash
curl -fsSL https://raw.githubusercontent.com/iliyami/MacSai/main/scripts/uninstall.sh | bash
```

Les deux retirent Mac Sai ainsi que ses préférences, caches, journaux et base de données sous `~/Library`.

---

## Signé, notarié, et digne de votre confiance

Mac Sai est signé avec un **Developer ID** Apple et **notarié par Apple**. Cela compte davantage pour une app de nettoyage que pour presque tout ce que vous installez, car vous êtes sur le point de lui donner un accès étendu à vos fichiers, et vous méritez de savoir que ce qui s'exécute sur votre Mac est vraiment le nôtre et non altéré. Tout cela est imposé par votre propre Mac, pas seulement promis par nous :

- **Apple l'a analysé.** Chaque version est soumise à Apple et vérifiée contre les logiciels malveillants avant d'être publiée.
- **Il ne peut pas être altéré.** La signature est un sceau cryptographique sur chaque fichier ; changez un seul octet et macOS refuse de l'ouvrir.
- **Il provient incontestablement de nous.** La signature est liée à notre identité Apple Developer, personne d'autre ne peut donc publier quelque chose que votre Mac accepte comme Mac Sai.
- **Ça marche, tout simplement.** Pas d'avertissement Gatekeeper, pas de clic droit pour ouvrir, pas de Terminal.

Associé à un code entièrement open source, c'est une chaîne de confiance que vous ne prenez pas sur parole : le code est public, nous signons chaque version, Apple la vérifie, et votre Mac revérifie le sceau à chaque ouverture de l'app.

### Vérifiez l'absence de télémétrie vous-même

Ne nous croyez pas sur parole. Le code source comme le processus en cours d'exécution sont vérifiables.

**1. Cherchez dans le code les API réseau**

```bash
rg -n 'URLSession|NSURLConnection' Sources --glob '*.swift'
```

Vous ne devriez jamais voir que deux chemins réseau, tous deux optionnels et en lecture seule :

- `Sources/MacCleanKit/UpdateChecker.swift` : la vérification optionnelle des mises à jour de Mac Sai (désactivable dans les Réglages)
- `Sources/MacClean/Modules/Updater/UpdaterModule.swift` : la vérification, déclenchée par l'utilisateur, des flux Sparkle *d'autres apps* lorsque vous ouvrez l'Updater

Il n'y a aucun SDK d'analytique, de rapport de plantage ou de traqueur nulle part dans le code.

**2. Observez le processus en direct**

```bash
lsof -i -P -n | grep -i 'MacClean\|Mac Sai\|MacSai' || echo "no network sockets"
```

Attendu : aucune connexion établie tant que vous ne faites que nettoyer localement. Little Snitch ou LuLu rendent la même vérification visuelle.

**3. Inspectez le binaire que vous avez réellement installé**

Le code source et le binaire signé sont deux artefacts différents, la vérification la plus forte s'exécute donc contre l'app sur votre disque, pas contre ce dépôt. Après `brew install --cask mac-sai` :

```bash
APP="/Applications/Mac Sai.app/Contents/MacOS/MacClean"

# Les classes réseau que le binaire importe (seul URLSession apparaît) :
nm -u "$APP" | grep -iE 'URLSession|NWConnection|CFSocket' | sort -u

# Chaque URL compilée dans le binaire (seuls les deux points de terminaison de mise à jour sont appelés) :
strings -a "$APP" | grep -iE 'https?://' | sort -u
```

Attendu : la seule classe réseau est `_OBJC_CLASS_$_NSURLSession`, et les seuls points de terminaison appelés sont `api.github.com/repos/iliyami/MacSai/releases/latest` et `formulae.brew.sh/api/cask/mac-sai.json`. Les autres liens `github.com/iliyami/MacSai` ouvrent simplement votre navigateur. Aucun traqueur, aucun hôte d'analytique, rien d'autre. Relancez-le après chaque mise à jour ; il décrit toujours exactement la version que vous exécutez.

Note : sur une app Developer ID sans bac à sable comme celle-ci, l'accès réseau n'est pas régi par un entitlement, c'est donc cette inspection des symboles et des chaînes, et non `codesign --entitlements`, qui est la vraie vérification. La même protection s'exécute dans la CI à chaque changement ([`scripts/check-network-surface.sh`](scripts/check-network-surface.sh)).

---

## Architecture

```
Mac Sai
├── MacClean          App SwiftUI principale (17 modules)
├── MacCleanKit       Framework partagé (modèles, constantes, protocoles)
├── MacCleanHelper    Assistant XPC privilégié (LaunchDaemon pour les opérations root)
└── MacCleanMenu      Moniteur de barre des menus (processus indépendant)
```

### Pile technique

| Couche | Technologie |
|-------|-----------|
| Langage | Swift 6 avec concurrence stricte |
| UI | Hybride SwiftUI + AppKit |
| Concurrence | Actors, TaskGroup, async/await, `@Sendable` |
| Base de données | GRDB.swift (SQLite) en mode WAL |
| Analyse de fichiers | Préchargement `URLResourceKey` sur APFS |
| Mises à jour incrémentielles | FSEvents avec relecture historique |
| Opérations privilégiées | SMAppService + NSXPCConnection |
| Statistiques système | API Mach (`host_processor_info`, `vm_statistics64`, `proc_pidinfo`) |

### Modèle de sécurité

Mac Sai est conçu pour **ne jamais causer de perte de données** :

- **Liste de chemins protégés** : `/System`, `/usr`, `/bin`, `/sbin` et les apps système Apple sont intouchables, les firmlinks macOS étant canonicalisés pour que la détection de redirection par lien symbolique ne déclenche pas de faux positif sur des chemins système légitimes
- **Filtre de nettoyabilité avant scan** : les éléments que le processus actuel ne pourrait pas mettre à la corbeille (enfants appartenant à root des caches système, dossiers `~/Library/Caches/com.apple.*` sous coffre de données) sont écartés au moment du scan pour ne jamais apparaître comme nettoyables
- **Suppression d'abord vers la corbeille** : chaque suppression va à la corbeille par défaut, et un mode simulation prévisualise sans rien toucher
- **Prévention TOCTOU** : les liens symboliques sont réévalués immédiatement avant la suppression
- **Dossiers exclus** : choisissez dans les Réglages des dossiers que les scans ignorent entièrement, et `SafetyGuard` refuse en plus de supprimer quoi que ce soit en dessous
- **Nettoyage par lots annulable** : les grandes sélections sont découpées en blocs de 5k éléments qui respectent l'annulation entre les blocs, et les scans reviennent au repos en une seconde environ lorsque vous cliquez sur Annuler
- **Journal d'activité intégré** : chaque erreur durant un nettoyage est journalisée avec son chemin complet, consultable et copiable depuis l'écran post-nettoyage, purgé automatiquement après 30 jours
- **Barrière XPC imposée par le noyau** : l'assistant privilégié utilise `NSXPCListener.setCodeSigningRequirement` afin que le noyau lui-même rejette toute connexion dont la signature de code ne correspond pas à l'identifiant et à l'équipe de l'app

---

## Tests

```bash
swift test
```

La suite XCTest compte **862 tests** et traite `SafetyGuard` et `CleaningEngine` (les fichiers de vie ou de mort) comme devant être parfaits : couverture adversariale des liens symboliques, de la traversée de chemins, des octets NULL, de SIP, des apps protégées, des plafonds de nombre de fichiers, du TOCTOU et de l'idempotence, plus une couverture d'intégration du nettoyage en simulation / corbeille / permanent, de la machine à états du scan, de chaque catégorie de System Junk, des calculs de treemap, du moteur de correspondance du désinstalleur, de la détection des doublons, de l'analyse d'appcast, et de cycles complets de bout en bout de la préparation au nettoyage. Les fixtures (`withTempHome`, `withFakeApp`, `withFakePlist`) gardent chaque test hors de votre vrai dossier personnel.

---

## Contribuer

Les contributions sont très bienvenues. Lisez les [Directives de contribution](CONTRIBUTING.md), puis :

1. Forkez le dépôt et créez une branche de fonctionnalité
2. Faites votre modification (une modification ciblée par PR facilite la revue)
3. Exécutez `swift test`
4. Ouvrez une Pull Request

Il y a aussi un [vote de fonctionnalités](https://github.com/iliyami/MacSai/issues/55) ouvert : mettez un 👍 sur les outils que vous voulez voir construits ensuite.

## Licence

BSD 3-Clause. Voir [LICENSE](LICENSE). Vous pouvez utiliser, modifier et redistribuer le code, à condition de conserver le texte de copyright et de licence et de ne pas utiliser le nom « Mac Sai » ni les noms des contributeurs pour promouvoir des produits dérivés sans autorisation.

## Remerciements

Inspiré par la communauté open source des utilitaires Mac :

- [Pearcleaner](https://github.com/alienator88/Pearcleaner) : motifs du désinstalleur d'apps
- [Mole](https://github.com/tw93/Mole) : catégories de nettoyage
- [Tencent Lemon Cleaner](https://github.com/Tencent/lemon-cleaner) : architecture modulaire
- Algorithme de treemap carré de Bruls, Huizing et van Wijk (2000)

## Historique des étoiles

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
  <strong>Mac Sai est un logiciel libre construit par la communauté, pour la communauté.</strong><br>
  S'il vous a évité un abonnement, une ⭐ aide les autres à le trouver.
</p>
