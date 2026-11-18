import { LOCALES } from './locales.mjs';

/** hreflang alternates for the home page in every language. */
export const homeAlternates = LOCALES.map((l) => ({
  hreflang: l.hreflang,
  path: l.code === 'en' ? '/' : `/${l.code}/`,
}));
