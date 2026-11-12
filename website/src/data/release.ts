/**
 * Facts about the latest release, read from GitHub once at build time.
 *
 * Visitors' browsers never call GitHub: every number on the site is baked
 * into the HTML. When the API is unreachable (offline builds, rate limits)
 * the fallbacks below keep the build working and the claims conservative.
 */

const REPO = 'iliyami/MacSai';

export interface ReleaseInfo {
  version: string;
  tag: string;
  publishedAt: string;
  dmgURL: string;
  dmgSizeMB: number | null;
  /** Rounded down, for "125,000+" style copy. */
  downloadsFloor: number;
  starsFloor: number;
}

const FALLBACK: ReleaseInfo = {
  version: '1.32.0',
  tag: 'v1.32.0',
  publishedAt: '2026-11-11',
  dmgURL: `https://github.com/${REPO}/releases/latest`,
  dmgSizeMB: null,
  downloadsFloor: 125_000,
  starsFloor: 2_000,
};

function floorTo(value: number, step: number): number {
  return Math.floor(value / step) * step;
}

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

interface GHAsset { name: string; size: number; download_count: number; browser_download_url: string }
interface GHRelease { tag_name: string; published_at: string; draft: boolean; prerelease: boolean; assets: GHAsset[] }

async function load(): Promise<ReleaseInfo> {
  if (process.env.OFFLINE_BUILD === '1') return FALLBACK;
  try {
    const [latest, repo, releases] = await Promise.all([
      gh<GHRelease>(`repos/${REPO}/releases/latest`),
      gh<{ stargazers_count: number }>(`repos/${REPO}`),
      gh<GHRelease[]>(`repos/${REPO}/releases?per_page=100`),
    ]);
    const dmg = latest.assets.find((a) => /^MacSai-.*\.dmg$/.test(a.name));
    const downloads = releases
      .flatMap((r) => r.assets)
      .filter((a) => a.name.endsWith('.dmg'))
      .reduce((sum, a) => sum + a.download_count, 0);
    // Older releases fall off the first page, so this undercounts and never
    // goes below the figure already published in the README.
    const downloadsFloor = Math.max(FALLBACK.downloadsFloor, floorTo(downloads, 5_000));
    return {
      version: latest.tag_name.replace(/^v/, ''),
      tag: latest.tag_name,
      publishedAt: latest.published_at.slice(0, 10),
      dmgURL: dmg?.browser_download_url ?? FALLBACK.dmgURL,
      dmgSizeMB: dmg ? Math.round(dmg.size / 1_000_000) : null,
      downloadsFloor,
      starsFloor: Math.max(FALLBACK.starsFloor, floorTo(repo.stargazers_count, 100)),
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
