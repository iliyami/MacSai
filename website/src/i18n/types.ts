import type { GroupId } from '../data/modules';

/**
 * Every string on the home page. English is the source; each localized home
 * page provides the same shape. Placeholders in braces ({version}, {size},
 * {count}) are filled at build time.
 */
export interface HomeStrings {
  meta: { title: string; description: string };
  nav: { features: string; compare: string; privacy: string; download: string; github: string; menu: string; skip: string };
  footer: { tagline: string; noTracking: string; languages: string };
  hero: {
    title: string;
    lede: string;
    download: string;
    /** e.g. "Version {version}, {size} MB" */
    downloadMeta: string;
    requirements: string;
    brewLabel: string;
    copy: string;
    copied: string;
    shotAlt: string;
  };
  proof: { downloads: string; stars: string; languages: string; trackers: string };
  /** The live numbers section. {total}, {count} and {time} are filled in at build time. */
  stats: {
    heading: string;
    intro: string;
    downloads: string;
    brewInstalls: string;
    brewRank: string;
    stars: string;
    starsDelta: string;
    contributors: string;
    chartTitle: string;
    table: string;
    date: string;
    updated: string;
  };
  trust: {
    heading: string;
    intro: string;
    items: { title: string; body: string }[];
  };
  modules: {
    heading: string;
    intro: string;
    tabsLabel: string;
    groups: Record<GroupId, string>;
    /** Keyed by module id from data/modules.ts */
    items: Record<string, { name: string; summary: string }>;
    more: string;
    shotAlt: Record<GroupId, string>;
  };
  developers: { heading: string; body: string; items: string[]; link: string };
  verify: { heading: string; body: string; note: string; link: string };
  compare: {
    heading: string;
    body: string;
    columns: { feature: string; macsai: string; other: string };
    rows: { label: string; macsai: string; other: string }[];
    footnote: string;
    link: string;
  };
  faq: { heading: string; items: { q: string; a: string }[] };
  cta: { heading: string; body: string; download: string };
  /** Shown on localized pages next to links that lead to English pages. */
  englishOnly?: string;
}
