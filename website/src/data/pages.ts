import type { PageSlug } from './modules';

/**
 * Copy for the feature pages. Each page targets the searches people already
 * make, answers them plainly and stays true to what the app does.
 */

export interface Section {
  heading: string;
  body: string[];
  bullets?: string[];
}

export interface FAQ { q: string; a: string }

export interface FeaturePage {
  slug: PageSlug;
  /** <title>, under 60 characters. */
  title: string;
  /** Meta description, under 155 characters. */
  description: string;
  h1: string;
  lede: string;
  shot: string;
  shotAlt: string;
  sections: Section[];
  faq: FAQ[];
}

export const FEATURE_PAGES: FeaturePage[] = [
  {
    slug: 'system-junk',
    title: 'Clean system junk and caches on your Mac, free',
    description: 'Mac Sai finds caches, logs, language files, old iOS backups and 16+ other kinds of junk on your Mac, and moves them to the Trash so you can undo.',
    h1: 'Clear caches and system junk without the guesswork',
    lede: 'Smart Scan looks through caches, logs, leftover language files, broken preferences, old iOS backups and more in one click. You see every item and its size before anything moves, and everything goes to the Trash first.',
    shot: 'system-junk',
    shotAlt: 'Mac Sai System Junk, ready to scan for caches, logs and language files',
    sections: [
      {
        heading: 'What System Junk looks for',
        body: ['Each category is listed with its size, and you can open it to see the exact files.'],
        bullets: [
          'User and system caches, and log files',
          'Language files for languages you don’t use',
          'Broken preferences and broken login items',
          'Old document versions and iOS device backups',
          'Xcode leftovers and package manager, IDE and AI tool caches',
          'Files left behind by deleted user accounts',
          'Universal apps that carry both Apple silicon and Intel code, slimmed down to your Mac’s own architecture',
        ],
      },
      {
        heading: 'One click with Smart Scan',
        body: [
          'Smart Scan runs cleanup, protection and performance checks together with live progress, then shows what each one freed. It is the quickest way to see where your space went.',
        ],
      },
      {
        heading: 'Undo a clean if you change your mind',
        body: [
          'Everything goes to the Trash by default, never straight to oblivion. Clean History keeps your recent cleans for 30 days and can put a whole clean back from the Trash in one click. The history stays on your Mac and is never sent anywhere.',
        ],
      },
      {
        heading: 'Mail attachments and every Trash',
        body: [
          'Mail Attachments finds cached attachments from Apple Mail, Outlook and Spark. Trash Bins empties the Trash on your Mac and on connected drives in one go.',
        ],
      },
    ],
    faq: [
      { q: 'Is it safe to delete caches on a Mac?', a: 'Caches are copies apps can rebuild, so clearing them is generally safe. Apps may feel a little slower the first time they rebuild what they need. Mac Sai skips system locations macOS protects and moves everything to the Trash first, so you can restore an item if something misbehaves.' },
      { q: 'How much space will I get back?', a: 'It depends on how you use your Mac. Smart Scan shows the exact size of each category before you clean, so you decide with real numbers in front of you.' },
      { q: 'Does Mac Sai delete anything without asking?', a: 'No. Scans only look. Nothing moves until you review the list and choose Clean, and items meant for careful review are never selected for you.' },
    ],
  },
  {
    slug: 'developer-cleanup',
    title: 'Free up developer disk space: Xcode, Docker, node_modules',
    description: 'Find gigabytes held by node_modules, Rust and Gradle builds, Python virtualenvs, Xcode DerivedData, simulators and Docker. Mac Sai shows it all and cleans safely.',
    h1: 'Get back the gigabytes your tools quietly keep',
    lede: 'Build folders, package caches, simulators and Docker images grow until the disk is full. Mac Sai finds them across your projects and shows what is safe to remove, without touching your source code.',
    shot: 'disk-hogs',
    shotAlt: 'Mac Sai Disk Hogs showing Docker and Xcode simulator disk usage',
    sections: [
      {
        heading: 'Project Junk: build folders your projects can rebuild',
        body: [
          'Mac Sai finds node_modules, .next, dist, Rust and Maven target, Gradle build, Python virtualenvs and CocoaPods Pods. A folder only counts when the files next to it confirm the project type, and dist and Pods only when your .gitignore names them. Everything goes to the Trash.',
        ],
      },
      {
        heading: 'Disk Hogs: Docker and Xcode simulators',
        body: [
          'See how much space Docker and the Xcode simulators take. Mac Sai can prune stopped containers, dangling images and dangling build cache, each behind a confirmation, and delete unavailable simulators and old simulator runtimes.',
          'Docker volumes and the newest runtime for each platform are never touched. Docker Desktop’s disk image size is shown even when Docker isn’t running, and Mac Sai never deletes it.',
        ],
      },
      {
        heading: 'Caches from the tools you use every day',
        body: ['System Junk lists caches from package managers, code editors and AI coding tools, each as its own category. Package manager caches stay unselected until you pick them, because rebuilding them means downloading everything again.'],
        bullets: [
          'Xcode DerivedData, archives and device support files',
          'npm, pip, uv, Cargo, Gradle and Homebrew caches, and pnpm stores with each version listed separately',
          'Cursor and Antigravity editor caches',
          'Claude and Codex caches, never their history or sessions',
        ],
      },
    ],
    faq: [
      { q: 'Is it safe to delete Xcode DerivedData?', a: 'Yes. DerivedData holds build products and indexes that Xcode recreates on the next build. Your first build afterwards takes longer.' },
      { q: 'Will deleting node_modules break my project?', a: 'Your code is untouched. Running your package manager’s install command brings node_modules back. Mac Sai only lists folders whose neighbouring files confirm they are rebuildable.' },
      { q: 'Does Mac Sai delete Docker volumes?', a: 'No. Volumes can hold real data, so Mac Sai never touches them. It only prunes stopped containers, dangling images and dangling build cache, each after you confirm.' },
    ],
  },
  {
    slug: 'malware-scanner',
    title: 'Free Mac malware scanner, open source',
    description: 'Scan launch agents, apps and browser extensions against Apple XProtect signatures, offline. Mac Sai is a free, open-source malware scanner for macOS.',
    h1: 'Check your Mac for known malware and adware',
    lede: 'Mac Sai looks where Mac malware hides: launch agents and daemons, app bundles and browser extensions. It matches files against the XProtect signatures Apple already keeps on your Mac, offline.',
    shot: 'malware',
    shotAlt: 'Mac Sai Malware Removal, ready to scan for viruses, adware and other threats',
    sections: [
      {
        heading: 'Three depths, one honest promise',
        body: [
          'Choose Quick, Balanced or Deep. Every scan checks launch agents and daemons, app bundles, browser extensions and known adware patterns.',
          'Mac Sai is not an antivirus and says so. It finds known threats by exact match, and it never guesses.',
        ],
      },
      {
        heading: 'Apple XProtect signatures, offline',
        body: [
          'Mac Sai matches file hashes against the XProtect signatures that macOS already keeps up to date on your Mac, so the core scan needs no network at all.',
          'For a wider list, add your own free abuse.ch Auth-Key in Settings and download the MalwareBazaar hash feed. Mac Sai sends only your key and the query, never file hashes or paths. When a downloaded hash matches a signed file, macOS asks Apple whether its signing certificate was revoked, the same check Gatekeeper makes.',
        ],
      },
      {
        heading: 'You decide what goes',
        body: [
          'Possible threats and community-reported files are listed for review and never selected for you. Anything you remove goes to the Trash first.',
        ],
      },
    ],
    faq: [
      { q: 'Do Macs need a malware scanner?', a: 'macOS has strong built-in protection, but adware and unwanted launch agents still reach Macs, often bundled with downloads. A periodic scan that checks the usual hiding places is a sensible habit.' },
      { q: 'Does the scan upload my files?', a: 'No. The core scan runs offline against signatures already on your Mac. The optional MalwareBazaar feed only downloads a list of hashes. Your files and scan results never leave your Mac.' },
    ],
  },
  {
    slug: 'privacy-cleaner',
    title: 'Clear browser history and cookies on Mac, free',
    description: 'Clear Safari, Chrome and Firefox history, cookies and cache, review browser extensions, forget saved Wi-Fi and see every app’s permissions. Free and open source.',
    h1: 'Clear what your browsers and apps keep about you',
    lede: 'Clear browsing traces in one place, see which apps can use your camera, microphone and files, and tidy the extensions and networks your Mac has collected over the years.',
    shot: 'privacy',
    shotAlt: 'Mac Sai Privacy, ready to clear browser data, history and cookies',
    sections: [
      {
        heading: 'Browser history, cookies and cache',
        body: [
          'Clear Safari, Chrome and Firefox history, cookies and cache, with time filters for today, the last week, month or year, or everything. Safari bookmarks are never touched.',
        ],
      },
      {
        heading: 'Browser extensions in one list',
        body: [
          'See the extensions installed in Safari, Chrome, Brave, Edge, Arc and Firefox together. Extensions you installed yourself can go to the Trash while that browser is closed. Ones installed by policy or by the browser itself are shown and left alone.',
        ],
      },
      {
        heading: 'App permissions, app by app',
        body: [
          'A read-only view of which privacy permissions each app holds, from the camera and microphone to your files and screen. Every action opens the right page in System Settings, which owns the switches.',
        ],
      },
      {
        heading: 'Saved Wi-Fi networks',
        body: ['See every network your Mac remembers and forget the ones you no longer use.'],
      },
    ],
    faq: [
      { q: 'Will clearing cookies log me out?', a: 'Yes, clearing cookies signs you out of websites. Use the time filters to clear only recent data if you want to stay signed in elsewhere.' },
      { q: 'Can Mac Sai change app permissions?', a: 'It shows them and takes you straight to the right page in System Settings. macOS keeps those switches in System Settings, and Mac Sai respects that.' },
    ],
  },
  {
    slug: 'mac-maintenance',
    title: 'Speed up your Mac: login items and maintenance, free',
    description: 'Turn off login items, free RAM, flush DNS, reindex Spotlight and verify your disk, with a live menu bar monitor for CPU, memory and storage. Free and open source.',
    h1: 'Keep your Mac quick with a few safe routines',
    lede: 'Most slowdowns come from too many things starting at login and from routine tasks nobody runs. Mac Sai puts them in one place and keeps an eye on your Mac from the menu bar.',
    shot: 'maintenance',
    shotAlt: 'Mac Sai Maintenance tasks such as free RAM, flush DNS and reindex Spotlight',
    sections: [
      {
        heading: 'Login items and launch agents',
        body: ['Optimization lists what starts with your Mac and lets you turn each item on or off.'],
      },
      {
        heading: 'Maintenance tasks',
        body: ['Each task is tagged by how much it changes, and Run Safe Tasks runs them in order, asking for your password once.'],
        bullets: [
          'Free up RAM and flush the DNS cache',
          'Run macOS maintenance scripts',
          'Verify the startup disk',
          'Rebuild Launch Services and reindex Spotlight',
          'Thin Time Machine local snapshots',
        ],
      },
      {
        heading: 'A live monitor in your menu bar',
        body: [
          'CPU, memory, disk and battery in four rings, plus network speed, uptime and swap. It suggests what to clean when caches grow and can alert you when the disk runs low or memory pressure stays high. Alerts are opt-in.',
        ],
      },
    ],
    faq: [
      { q: 'Does freeing RAM make my Mac faster?', a: 'Sometimes, briefly. macOS manages memory well on its own. Freeing RAM helps most after a heavy app quits and memory pressure stays high. The menu bar monitor shows you when that happens.' },
      { q: 'Why does maintenance ask for my password?', a: 'Some tasks, like verifying the disk or flushing DNS, need administrator rights. Mac Sai asks for your password once per run instead of once per task.' },
    ],
  },
  {
    slug: 'uninstaller',
    title: 'Completely uninstall apps on Mac, leftovers included',
    description: 'Dragging an app to the Trash leaves its caches, preferences and support files behind. Mac Sai finds them across 17+ Library folders and removes them too.',
    h1: 'Uninstall apps completely, leftovers and all',
    lede: 'Dragging an app to the Trash leaves its caches, preferences, containers and support files behind. Mac Sai finds them across 17+ Library folders and removes the app with everything that belongs to it.',
    shot: 'uninstaller',
    shotAlt: 'Mac Sai Uninstaller with its list of installed apps',
    sections: [
      {
        heading: 'Every file that belongs to an app',
        body: [
          'Mac Sai matches an app’s identifiers against more than 17 Library locations, including apps nested in vendor folders, and lists each file with its size before you remove anything.',
        ],
      },
      {
        heading: 'Reset an app instead of removing it',
        body: ['Reset to Defaults clears an app’s caches and preferences but keeps the app, which fixes many misbehaving apps.'],
      },
      {
        heading: 'Find the apps you forgot about',
        body: [
          'Unused Apps lists apps you haven’t opened in 3, 6 or 12 months, largest first, using the last-used date Spotlight records. Running apps are never listed, and when Spotlight has no data Mac Sai says so instead of guessing.',
        ],
      },
      {
        heading: 'Extensions and app updates',
        body: [
          'Review preference panes, internet plug-ins and Safari extensions. The Updater checks your other apps for new versions through their own update feeds, reading version numbers only.',
        ],
      },
    ],
    faq: [
      { q: 'Does dragging an app to the Trash uninstall it?', a: 'It removes the app itself, but caches, preferences, containers and support files stay in your Library folder. Mac Sai finds and removes those as well.' },
      { q: 'Can I uninstall Apple’s built-in apps?', a: 'No. Apple’s system apps are on Mac Sai’s protected list, because macOS relies on them.' },
    ],
  },
  {
    slug: 'disk-space',
    title: 'See what is taking up space on your Mac',
    description: 'A clickable map of your disk, large and old files, duplicate finder with APFS clone consolidation, and a file shredder. Find what fills your Mac, free.',
    h1: 'See what is filling your disk, then decide',
    lede: 'Space Lens draws your disk as a map you can click into, so the biggest folders stand out at once. Then find large old files and duplicates, and reclaim space without losing anything you need.',
    shot: 'large-old-files',
    shotAlt: 'Mac Sai Large & Old Files, ready to find files over 50 MB',
    sections: [
      {
        heading: 'Space Lens',
        body: [
          'Every folder is a block sized by what it holds. Click into any block to go deeper. Files that share storage through hard links are counted once, so the sizes match what you would actually get back.',
        ],
      },
      {
        heading: 'Large & Old Files',
        body: ['Files over 50 MB, sorted by size and by when you last opened them, so forgotten downloads and old videos surface first.'],
      },
      {
        heading: 'Duplicates, with a way to keep every copy',
        body: [
          'Mac Sai compares sizes, then partial and full SHA-256 hashes, and checks that copies are truly separate files. Consolidate reclaims the space with APFS copy-on-write clones, so every copy stays where it is.',
        ],
      },
      {
        heading: 'Shredder',
        body: ['Erase files you want gone for good, with standard, permanent and overwrite modes.'],
      },
    ],
    faq: [
      { q: 'Why is "System Data" so large on my Mac?', a: 'System Data in macOS Settings includes caches, logs, local Time Machine snapshots, developer files and more. Smart Scan, System Junk and Space Lens show what those actually are, with sizes.' },
      { q: 'What does Consolidate do to duplicates?', a: 'It replaces identical copies with APFS clones that share storage. Every file stays in place and opens as before, but the space is counted once.' },
    ],
  },
];

export const pageBySlug = (slug: PageSlug) => {
  const page = FEATURE_PAGES.find((p) => p.slug === slug);
  if (!page) throw new Error(`Unknown feature page ${slug}`);
  return page;
};
