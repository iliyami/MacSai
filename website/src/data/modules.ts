/**
 * The app's modules, grouped the way its sidebar groups them. Copy here must
 * stay true to the app; README.md "Features in detail" is the source.
 */

export type GroupId = 'cleanup' | 'protection' | 'performance' | 'applications' | 'files';
export type PageSlug =
  | 'system-junk'
  | 'developer-cleanup'
  | 'malware-scanner'
  | 'privacy-cleaner'
  | 'mac-maintenance'
  | 'uninstaller'
  | 'disk-space';

export interface Module {
  id: string;
  name: string;
  group: GroupId;
  /** One plain sentence, used in lists. */
  summary: string;
  page: PageSlug;
}

export const GROUPS: { id: GroupId; name: string }[] = [
  { id: 'cleanup', name: 'Cleanup' },
  { id: 'protection', name: 'Protection' },
  { id: 'performance', name: 'Performance' },
  { id: 'applications', name: 'Applications' },
  { id: 'files', name: 'Files' },
];

export const MODULES: Module[] = [
  { id: 'smart-scan', name: 'Smart Scan', group: 'cleanup', page: 'system-junk',
    summary: 'One click runs cleanup, protection and performance checks together, then shows what each one freed.' },
  { id: 'system-junk', name: 'System Junk', group: 'cleanup', page: 'system-junk',
    summary: 'Caches, logs, unused language files, broken preferences, old iOS backups and more, in 16+ categories.' },
  { id: 'mail-attachments', name: 'Mail Attachments', group: 'cleanup', page: 'system-junk',
    summary: 'Finds cached attachments from Apple Mail, Outlook and Spark.' },
  { id: 'trash-bins', name: 'Trash Bins', group: 'cleanup', page: 'system-junk',
    summary: 'Empties the Trash everywhere, external drives included.' },
  { id: 'project-junk', name: 'Project Junk', group: 'cleanup', page: 'developer-cleanup',
    summary: 'Finds node_modules, target, build, virtualenvs and other folders your projects can rebuild.' },
  { id: 'disk-hogs', name: 'Disk Hogs', group: 'cleanup', page: 'developer-cleanup',
    summary: 'Shows what Docker and Xcode simulators take, and prunes what is safe to prune.' },
  { id: 'clean-history', name: 'Clean History', group: 'cleanup', page: 'system-junk',
    summary: 'Lists your recent cleans and puts a whole clean back from the Trash in one click.' },

  { id: 'malware-removal', name: 'Malware Removal', group: 'protection', page: 'malware-scanner',
    summary: 'Checks launch agents, apps and extensions against Apple XProtect signatures, offline.' },
  { id: 'privacy', name: 'Privacy', group: 'protection', page: 'privacy-cleaner',
    summary: 'Clears Safari, Chrome and Firefox history, cookies and cache. Bookmarks are never touched.' },
  { id: 'browser-extensions', name: 'Browser Extensions', group: 'protection', page: 'privacy-cleaner',
    summary: 'Lists extensions across Safari, Chrome, Brave, Edge, Arc and Firefox, and removes the ones you pick.' },
  { id: 'saved-wifi', name: 'Saved Wi-Fi', group: 'protection', page: 'privacy-cleaner',
    summary: 'Lists the networks your Mac remembers and forgets the ones you choose.' },
  { id: 'app-permissions', name: 'App Permissions', group: 'protection', page: 'privacy-cleaner',
    summary: 'Shows, app by app, which camera, microphone, files and other permissions each one holds.' },

  { id: 'optimization', name: 'Optimization', group: 'performance', page: 'mac-maintenance',
    summary: 'Turns login items and launch agents on or off, one by one.' },
  { id: 'maintenance', name: 'Maintenance', group: 'performance', page: 'mac-maintenance',
    summary: 'Frees RAM, flushes DNS, reindexes Spotlight, verifies the startup disk and more, asking for your password once.' },

  { id: 'uninstaller', name: 'Uninstaller', group: 'applications', page: 'uninstaller',
    summary: 'Removes an app with every file it left across 17+ Library folders, or resets it to defaults.' },
  { id: 'unused-apps', name: 'Unused Apps', group: 'applications', page: 'uninstaller',
    summary: 'Finds apps you have not opened in 3, 6 or 12 months, largest first.' },
  { id: 'extensions', name: 'Extensions', group: 'applications', page: 'uninstaller',
    summary: 'Reviews preference panes, internet plug-ins and Safari extensions.' },
  { id: 'updater', name: 'Updater', group: 'applications', page: 'uninstaller',
    summary: 'Checks your other apps for updates through their own update feeds, sending nothing about you.' },

  { id: 'space-lens', name: 'Space Lens', group: 'files', page: 'disk-space',
    summary: 'A map of your disk you can click into, so the biggest folders stand out at once.' },
  { id: 'large-old-files', name: 'Large & Old Files', group: 'files', page: 'disk-space',
    summary: 'Finds files over 50 MB, sorted by size and by when you last opened them.' },
  { id: 'duplicates', name: 'Duplicates', group: 'files', page: 'disk-space',
    summary: 'Finds identical files, and can reclaim their space with APFS clones without deleting a copy.' },
  { id: 'shredder', name: 'Shredder', group: 'files', page: 'disk-space',
    summary: 'Erases files you want gone for good.' },
];

export const MODULE_COUNT = MODULES.length;
