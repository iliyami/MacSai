// Checks the built site in dist/ before it is deployed.
//
// - Every page has a title, a description, a canonical URL (or noindex),
//   exactly one h1, a lang attribute and alt text on every image.
// - Titles stay under 70 characters and descriptions under 170.
// - No page loads anything from another origin: scripts, styles, fonts,
//   images and frames all come from this site (outbound links are fine).
// - Every internal link and asset reference resolves to a built file.
// - No em dashes in page text.
// - hreflang alternates point at pages that exist.
//
// Run after `astro build`: node scripts/check-dist.mjs

import { readFileSync, existsSync, readdirSync, statSync } from 'node:fs';
import { join, relative } from 'node:path';

const DIST = new URL('../dist/', import.meta.url).pathname;
const BASE = (process.env.SITE_BASE ?? '/MacSai').replace(/\/$/, '');
const SITE = process.env.SITE_URL ?? 'https://iliyami.github.io';
const errors = [];

function walk(dir) {
  return readdirSync(dir).flatMap((name) => {
    const path = join(dir, name);
    return statSync(path).isDirectory() ? walk(path) : [path];
  });
}

function resolveInternal(url) {
  // Map "/MacSai/features/x/" or "https://iliyami.github.io/MacSai/x/" to a dist path.
  let path = url;
  if (path.startsWith(SITE)) path = path.slice(SITE.length);
  path = path.split('#')[0].split('?')[0];
  if (!path.startsWith(`${BASE}/`) && path !== BASE) return null;
  path = decodeURIComponent(path.slice(BASE.length)) || '/';
  const file = path.endsWith('/') ? join(DIST, path, 'index.html') : join(DIST, path);
  return file;
}

const attr = (tag, name) => {
  const match = tag.match(new RegExp(`\\s${name}\\s*=\\s*("([^"]*)"|'([^']*)'|([^\\s>]+))`, 'i'));
  return match ? (match[2] ?? match[3] ?? match[4]) : null;
};

const pages = walk(DIST).filter((f) => f.endsWith('.html'));
if (pages.length < 10) errors.push(`only ${pages.length} pages built`);

for (const file of pages) {
  const html = readFileSync(file, 'utf8');
  const where = relative(DIST, file);
  const isNotFound = where === '404.html';

  const title = html.match(/<title>([^<]*)<\/title>/)?.[1];
  if (!title) errors.push(`${where}: missing <title>`);
  else if (title.length > 70) errors.push(`${where}: title is ${title.length} characters`);

  const description = html.match(/<meta name="description" content="([^"]*)"/)?.[1];
  if (!description) errors.push(`${where}: missing meta description`);
  else if (description.length > 170) errors.push(`${where}: description is ${description.length} characters`);

  if (!isNotFound && !/<link rel="canonical"/.test(html)) errors.push(`${where}: missing canonical`);
  if (!/<html lang="[^"]+"/.test(html)) errors.push(`${where}: missing <html lang>`);

  const h1s = html.match(/<h1[\s>]/g) ?? [];
  if (h1s.length !== 1) errors.push(`${where}: ${h1s.length} h1 elements`);

  for (const tag of html.match(/<img\b[^>]*>/g) ?? []) {
    if (!/\salt(?=[\s=>/])/.test(tag)) errors.push(`${where}: image without alt: ${tag.slice(0, 80)}`);
  }

  // Resources that load automatically must be same-origin.
  const resourceTags = [
    ...(html.match(/<script\b[^>]*\ssrc=[^>]*>/g) ?? []).map((t) => attr(t, 'src')),
    ...(html.match(/<link\b[^>]*>/g) ?? [])
      .filter((t) => /rel="(stylesheet|preload|icon|apple-touch-icon|modulepreload)"/.test(t))
      .map((t) => attr(t, 'href')),
    ...(html.match(/<(img|source|iframe|video|audio)\b[^>]*>/g) ?? []).flatMap((t) => [
      attr(t, 'src'),
      ...(attr(t, 'srcset') ?? '').split(',').map((s) => s.trim().split(/\s+/)[0]).filter(Boolean),
    ]),
  ].filter(Boolean);
  for (const url of resourceTags) {
    if (/^(https?:)?\/\//.test(url) && !url.startsWith(SITE)) errors.push(`${where}: loads a third-party resource ${url}`);
    const target = resolveInternal(url);
    if (target && !existsSync(target)) errors.push(`${where}: missing asset ${url}`);
  }
  if (/@import\s+url\(\s*['"]?https?:/.test(html)) errors.push(`${where}: CSS imports a remote stylesheet`);

  for (const tag of html.match(/<a\b[^>]*\shref=[^>]*>/g) ?? []) {
    const href = attr(tag, 'href');
    if (!href || href.startsWith('#') || href.startsWith('mailto:')) continue;
    const target = resolveInternal(href);
    if (target && !existsSync(target)) errors.push(`${where}: broken link ${href}`);
  }

  for (const tag of html.match(/<link rel="alternate" hreflang="[^"]+" href="[^"]+"/g) ?? []) {
    const target = resolveInternal(attr(tag, 'href'));
    if (target && !existsSync(target)) errors.push(`${where}: hreflang points at a missing page ${attr(tag, 'href')}`);
  }

  const text = html
    .replace(/<script\b[\s\S]*?<\/script>/g, '')
    .replace(/<style\b[\s\S]*?<\/style>/g, '')
    .replace(/<[^>]+>/g, ' ');
  if (text.includes('—')) errors.push(`${where}: contains an em dash`);
}

for (const required of ['robots.txt', 'llms.txt', 'sitemap-index.xml', 'favicon.svg', 'og/mac-sai.jpg']) {
  if (!existsSync(join(DIST, required))) errors.push(`missing ${required}`);
}

if (errors.length) {
  console.error(`check-dist: ${errors.length} problem(s)\n${errors.map((e) => `  - ${e}`).join('\n')}`);
  process.exit(1);
}
console.log(`check-dist: ${pages.length} pages OK`);
