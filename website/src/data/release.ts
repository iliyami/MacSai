/**
 * Facts about the latest release, read from GitHub once at build time.
 *
 * Visitors' browsers never call GitHub: every fact is baked into the HTML.
 * When the API is unreachable (offline builds, rate limits) the fallbacks
 * below keep the build working. Download and star counts are in stats.ts.
 */

const REPO = 'iliyami/MacSai';

export interface ReleaseInfo {
  version: string;
  tag: string;
  publishedAt: string;
  dmgURL: string;
  dmgSizeMB: number | null;
}

const FALLBACK: ReleaseInfo = {
  version: '1.32.0',
  tag: 'v1.32.0',
  publishedAt: '2026-11-11',
  dmgURL: `https://github.com/${REPO}/releases/latest`,
  dmgSizeMB: null,
};

async function gh<T>(path: string): Promise<T> {
  const headers: Record<string, string> = {
    Accept: 'application/vnd.github+json',
    'User-Agent': 'macsai-website-build',
  };
  const token = process.env.GITHUB_TOKEN;
  if (token) headers.Authorization = `Bearer ${token}`;
  const response = await fetch(`https://api.github.com/${path}`, { headers });
  if (!response.ok) throw new Error(`GitHub ${path}: HTTP ${response.status}`);
  return (await response.json()) as T;
}

interface GHAsset { name: string; size: number; browser_download_url: string }
interface GHRelease { tag_name: string; published_at: string; assets: GHAsset[] }

async function load(): Promise<ReleaseInfo> {
  if (process.env.OFFLINE_BUILD === '1') return FALLBACK;
  try {
    const latest = await gh<GHRelease>(`repos/${REPO}/releases/latest`);
    const dmg = latest.assets.find((a) => /^MacSai-.*\.dmg$/.test(a.name));
    return {
      version: latest.tag_name.replace(/^v/, ''),
      tag: latest.tag_name,
      publishedAt: latest.published_at.slice(0, 10),
      dmgURL: dmg?.browser_download_url ?? FALLBACK.dmgURL,
      dmgSizeMB: dmg ? Math.round(dmg.size / 1_000_000) : null,
    };
  } catch (error) {
    console.warn(`[release] using fallback facts: ${(error as Error).message}`);
    return FALLBACK;
  }
}

export const release: ReleaseInfo = await load();

export const REPO_URL = `https://github.com/${REPO}`;
export const RELEASES_URL = `${REPO_URL}/releases/latest`;
export const BREW_COMMAND = 'brew install --cask mac-sai';
