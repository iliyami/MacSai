// @ts-check
import { defineConfig } from 'astro/config';
import sitemap from '@astrojs/sitemap';
import { LOCALES } from './src/i18n/locales.mjs';

// The site lives at https://iliyami.github.io/MacSai/ until a custom domain
// is set up. Switching domains means changing SITE and BASE here (or through
// the environment) and nothing else.
const SITE = process.env.SITE_URL ?? 'https://iliyami.github.io';
const BASE = process.env.SITE_BASE ?? '/MacSai';

export default defineConfig({
  site: SITE,
  base: BASE,
  trailingSlash: 'always',
  build: { format: 'directory', inlineStylesheets: 'always' },
  compressHTML: true,
  prefetch: false,
  integrations: [
    sitemap({
      i18n: {
        defaultLocale: 'en',
        locales: Object.fromEntries(LOCALES.map((l) => [l.code, l.hreflang])),
      },
      filter: (page) => !page.includes('/404'),
    }),
  ],
  image: {
    // Responsive images are generated at build time; nothing is fetched by
    // visitors' browsers from anywhere but this site.
    responsiveStyles: true,
  },
});
