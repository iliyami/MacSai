import type { HomeStrings } from './types';

export const en: HomeStrings = {
  meta: {
    title: 'Mac Sai: the free, open-source Mac cleaner',
    description: 'Clean junk, uninstall apps completely, scan for malware and see what fills your disk. Free, open source, notarized by Apple, with no tracking.',
  },
  nav: { features: 'Features', compare: 'Compare', privacy: 'Privacy', download: 'Download', github: 'GitHub', menu: 'Menu', skip: 'Skip to content' },
  footer: {
    tagline: 'The free, open-source Mac cleaner.',
    noTracking: 'This website has no analytics, no cookies and loads nothing from anyone else.',
    languages: 'Languages',
  },
  englishOnly: 'in English',
  hero: {
    title: 'A cleaner Mac, with nothing hidden.',
    lede: 'Mac Sai clears junk, removes apps completely, checks for malware and shows what is filling your disk. It is free and open source, notarized by Apple, and it never tracks you.',
    download: 'Download for Mac',
    downloadMeta: 'Version {version}, {size} MB',
    requirements: 'macOS 14 Sonoma or later, on Apple silicon or Intel.',
    brewLabel: 'Or install with Homebrew',
    copy: 'Copy',
    copied: 'Copied',
    shotAlt: 'The Mac Sai window with its sidebar of cleanup, protection, performance, application and file tools, ready to run Smart Scan',
  },
  proof: {
    downloads: "{count} downloads",
    stars: "{count} stars on GitHub",
    languages: '13 languages',
    trackers: '0 trackers',
  },
  showcase: {
    heading: "See Mac Sai in 44 seconds",
    body: "A short tour of the tools, with real screens from the app.",
    play: "Play the tour",
  },
  stats: {
    heading: "Mac Sai in numbers",
    intro: "Counted from GitHub and Homebrew. The site refreshes these numbers every hour.",
    downloads: "Downloads from GitHub",
    brewInstalls: "Homebrew installs in the last 12 months",
    brewRank: "Homebrew rank by installs in the last 30 days, out of {total} apps",
    stars: "Stars on GitHub",
    starsDelta: "{count} in the last 30 days",
    contributors: "People who contributed code",
    chartTitle: "GitHub stars since launch",
    table: "Show the numbers",
    date: "Date",
    updated: "Updated {time}",
  },
  trust: {
    heading: 'Built to be trusted with your files',
    intro: 'A cleaner needs deep access to your Mac. So Mac Sai keeps nothing from you: the code, the network activity and every file it removes are yours to check.',
    items: [
      { title: 'Free, with nothing held back', body: 'No subscription, no in-app purchases, no Pro version and no nagging. Every tool is in the free app, under the BSD 3-Clause license.' },
      { title: 'Nothing about you leaves your Mac', body: 'No analytics, no crash reporter and no tracking code. The only network requests are update checks you can turn off and downloads you start yourself.' },
      { title: 'Careful by design', body: 'Removed items go to the Trash first, system locations are on a protected list, and anything that needs a judgment call is left for you to pick.' },
      { title: 'Signed, notarized, open', body: 'Every release is signed with an Apple Developer ID and checked by Apple before it ships. Every line of code is public on GitHub.' },
    ],
  },
  modules: {
    heading: '22 tools in one window',
    intro: 'Mac Sai groups its tools the way you think about your Mac. Start with Smart Scan, or go straight to the one you need.',
    tabsLabel: 'Tool groups',
    groups: { cleanup: 'Cleanup', protection: 'Protection', performance: 'Performance', applications: 'Applications', files: 'Files' },
    items: {},
    more: 'More about these tools',
    shotAlt: {
      cleanup: 'Mac Sai System Junk, ready to scan for caches, logs and language files',
      protection: 'Mac Sai Malware Removal, ready to scan for viruses, adware and other threats',
      performance: 'Mac Sai Maintenance with tasks like Free Up RAM, Flush DNS Cache and Reindex Spotlight',
      applications: 'Mac Sai Uninstaller with its list of installed apps',
      files: 'Mac Sai Duplicates, ready to find duplicate files',
    },
  },
  developers: {
    heading: 'Made for people who build things, too',
    body: 'Build folders, package caches, simulators and Docker images quietly fill developer Macs. Mac Sai finds them across your projects and only lists what your tools can rebuild.',
    items: [
      'node_modules, Rust and Maven target, Gradle build, Python virtualenvs',
      'Xcode DerivedData, archives, device support and old simulators',
      'Docker images, stopped containers and build cache',
      'npm, pnpm, pip, uv, Cargo, Gradle and Homebrew caches',
    ],
    link: 'Developer cleanup in detail',
  },
  verify: {
    heading: 'Don’t take our word for it',
    body: 'Run this in Terminal while Mac Sai is open. It lists every network connection held by the app you installed. Unless an update check or a malware database download is running, the list is empty.',
    note: 'Update checks and the optional malware database download are the only times Mac Sai goes online, and both are documented.',
    link: 'Everything Mac Sai sends, and how to check it',
  },
  compare: {
    heading: 'Mac Sai and CleanMyMac',
    body: 'Both clean junk, remove apps, scan for malware and keep your Mac in shape. The difference is in what you pay and what you can see.',
    columns: { feature: 'Feature', macsai: 'Mac Sai', other: 'CleanMyMac' },
    rows: [
      { label: 'Price', macsai: 'Free', other: 'Paid' },
      { label: 'Source code', macsai: 'Open, BSD 3-Clause', other: 'Closed' },
      { label: 'In-app analytics', macsai: 'None, and you can verify it', other: 'Can’t be checked without the source' },
      { label: 'Cleanup, uninstaller, malware, privacy, maintenance', macsai: 'Yes', other: 'Yes' },
      { label: 'Support', macsai: 'Community on GitHub', other: 'Paid support from MacPaw' },
    ],
    footnote: 'Compared in November 2026 from public information. CleanMyMac is a polished product with paid support, and if that is what you want, it is worth paying for.',
    link: 'The full comparison',
  },
  faq: {
    heading: 'Questions people ask',
    items: [
      { q: 'Is Mac Sai really free?', a: 'Yes. There is no subscription, no trial, no in-app purchase and no paid version. Mac Sai is open source under the BSD 3-Clause license and is supported by people who choose to chip in.' },
      { q: 'Is Mac Sai safe to use?', a: 'Mac Sai is signed with an Apple Developer ID and notarized by Apple, and its code is public. Removed items go to the Trash first, system locations are protected, and items that need a judgment call are never selected for you.' },
      { q: 'Does Mac Sai collect any data?', a: 'No. It has no analytics, crash reporter or tracking code. It goes online only to check for its own updates (once a day, and you can turn this off), when you check your other apps for updates, and if you choose to download the MalwareBazaar malware list.' },
      { q: 'Which Macs does it run on?', a: 'Any Mac with macOS 14 Sonoma or later, on Apple silicon or Intel.' },
      { q: 'Why does Mac Sai ask for Full Disk Access?', a: 'macOS protects folders like Mail and browser data. Mail Attachments, Privacy and Malware Removal need Full Disk Access to look inside them. Everything else works without it, and you can grant it later in System Settings.' },
      { q: 'How do I uninstall Mac Sai?', a: 'If you installed with Homebrew, run brew uninstall --zap --cask mac-sai. Otherwise run the uninstall script from the README, which removes the app and its preferences, caches and logs.' },
    ],
  },
  cta: {
    heading: 'Give your Mac a fresh start',
    body: 'Free, signed and notarized by Apple. It opens like any other app, with no warnings and nothing to configure.',
    download: 'Download Mac Sai',
  },
};

// English module copy comes straight from data/modules.ts.
import { MODULES } from '../data/modules';
en.modules.items = Object.fromEntries(MODULES.map((m) => [m.id, { name: m.name, summary: m.summary }]));
