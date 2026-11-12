import type { APIRoute } from 'astro';
import { FEATURE_PAGES } from '../data/pages';
import { MODULES } from '../data/modules';
import { release, REPO_URL } from '../data/release';
import { absolute } from '../lib/url';

// A plain-text summary for AI assistants and other tools that read llms.txt.
export const GET: APIRoute = () => {
  const lines = [
    '# Mac Sai',
    '',
    '> Mac Sai is a free, open-source (BSD 3-Clause) Mac cleaner, optimizer and malware scanner for macOS 14 or later, on Apple silicon and Intel. It is signed and notarized by Apple and has no analytics, crash reporter or tracking.',
    '',
    `Latest version: ${release.version}. Install with \`brew install --cask mac-sai\` or download the DMG from ${absolute('/download/')}.`,
    `Source code: ${REPO_URL}`,
    '',
    '## Pages',
    `- [Home](${absolute('/')})`,
    `- [All features](${absolute('/features/')})`,
    ...FEATURE_PAGES.map((p) => `- [${p.h1}](${absolute(`/features/${p.slug}/`)}): ${p.description}`),
    `- [Mac Sai and CleanMyMac](${absolute('/cleanmymac-alternative/')})`,
    `- [Download](${absolute('/download/')})`,
    `- [Privacy and verification](${absolute('/privacy/')})`,
    '',
    '## Tools',
    ...MODULES.map((m) => `- ${m.name}: ${m.summary}`),
    '',
  ];
  return new Response(lines.join('\n'), { headers: { 'Content-Type': 'text/plain; charset=utf-8' } });
};
