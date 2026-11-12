/**
 * Live project numbers for the "in numbers" section, read once per build.
 *
 * The site rebuilds every hour, so these stay current without the visitor's
 * browser ever calling GitHub or Homebrew: every number is baked into the HTML.
 * When a source is unreachable, its numbers fall back to null (the tile is
 * hidden) or, for the two headline counts, to conservative published figures.
 */

const REPO = 'iliyami/MacSai';
const CASK = 'mac-sai';

export interface StarPoint {
  /** YYYY-MM-DD */
  date: string;
  stars: number;
}

export interface Stats {
  /** ISO timestamp of the build that read these numbers. */
  updatedAt: string;
  /** False when GitHub could not be reached and the fallbacks are shown. */
  live: boolean;
  /** DMG downloads across every GitHub release. */
  downloads: number;
  stars: number;
  stars30d: number | null;
  forks: number | null;
  contributors: number | null;
  releases: number | null;
  /** Cumulative stars, one point per day (thinned for long histories). */
  starHistory: StarPoint[];
  brew: {
    installs365d: number;
    installs30d: number;
    rank30d: number | null;
    casks30d: number | null;
  } | null;
}

const FALLBACK: Stats = {
  updatedAt: new Date().toISOString(),
  live: false,
  downloads: 125_000,
  stars: 2_000,
  stars30d: null,
  forks: null,
  contributors: null,
  releases: null,
  starHistory: [],
  brew: null,
};

function headers(accept = 'application/vnd.github+json'): Record<string, string> {
  const h: Record<string, string> = { Accept: accept, 'User-Agent': 'macsai-website-build' };
  if (process.env.GITHUB_TOKEN) h.Authorization = `Bearer ${process.env.GITHUB_TOKEN}`;
  return h;
}

async function getJSON<T>(url: string, accept?: string): Promise<T> {
  const response = await fetch(url, { headers: headers(accept) });
  if (!response.ok) throw new Error(`${url}: HTTP ${response.status}`);
  return (await response.json()) as T;
}

/** Follows GitHub's 100-per-page pagination until a short page. */
async function allPages<T>(path: string, accept?: string, maxPages = 400): Promise<T[]> {
  const out: T[] = [];
  for (let page = 1; page <= maxPages; page++) {
    const sep = path.includes('?') ? '&' : '?';
    const items = await getJSON<T[]>(`https://api.github.com/${path}${sep}per_page=100&page=${page}`, accept);
    out.push(...items);
    if (items.length < 100) break;
  }
  return out;
}

interface GHAsset { name: string; download_count: number }
interface GHRelease { draft: boolean; assets: GHAsset[] }

function starHistory(starredAt: string[]): StarPoint[] {
  if (starredAt.length === 0) return [];
  const perDay = new Map<string, number>();
  for (const ts of starredAt) {
    const day = ts.slice(0, 10);
    perDay.set(day, (perDay.get(day) ?? 0) + 1);
  }
  const first = new Date(`${[...perDay.keys()].sort()[0]}T00:00:00Z`);
  const today = new Date(`${new Date().toISOString().slice(0, 10)}T00:00:00Z`);
  const points: StarPoint[] = [];
  let total = 0;
  for (let d = first; d <= today; d = new Date(d.getTime() + 86_400_000)) {
    const date = d.toISOString().slice(0, 10);
    total += perDay.get(date) ?? 0;
    points.push({ date, stars: total });
  }
  // Keep the chart light: at most ~180 points, always including the last day.
  const step = Math.ceil(points.length / 180);
  return points.filter((_, i) => i % step === 0 || i === points.length - 1);
}

async function loadBrew(): Promise<Stats['brew']> {
  try {
    const cask = await getJSON<{ analytics?: { install?: Record<string, Record<string, number>> } }>(
      `https://formulae.brew.sh/api/cask/${CASK}.json`,
    );
    const install = cask.analytics?.install ?? {};
    const installs365d = install['365d']?.[CASK];
    const installs30d = install['30d']?.[CASK];
    if (!installs365d || !installs30d) return null;
    let rank30d: number | null = null;
    let casks30d: number | null = null;
    try {
      const board = await getJSON<{ total_items: number; items: { number: number; cask: string }[] }>(
        'https://formulae.brew.sh/api/analytics/cask-install/30d.json',
      );
      casks30d = board.total_items;
      rank30d = board.items.find((i) => i.cask === CASK)?.number ?? null;
    } catch (error) {
      console.warn(`[stats] Homebrew rank unavailable: ${(error as Error).message}`);
    }
    return { installs365d, installs30d, rank30d, casks30d };
  } catch (error) {
    console.warn(`[stats] Homebrew analytics unavailable: ${(error as Error).message}`);
    return null;
  }
}

async function load(): Promise<Stats> {
  if (process.env.OFFLINE_BUILD === '1') return FALLBACK;
  const brew = loadBrew();
  try {
    const [repo, releases, contributors, stargazers] = await Promise.all([
      getJSON<{ stargazers_count: number; forks_count: number }>(`https://api.github.com/repos/${REPO}`),
      allPages<GHRelease>(`repos/${REPO}/releases`),
      allPages<unknown>(`repos/${REPO}/contributors`),
      allPages<{ starred_at: string }>(`repos/${REPO}/stargazers`, 'application/vnd.github.star+json'),
    ]);
    const published = releases.filter((r) => !r.draft);
    const downloads = published
      .flatMap((r) => r.assets)
      .filter((a) => a.name.endsWith('.dmg'))
      .reduce((sum, a) => sum + a.download_count, 0);
    const history = starHistory(stargazers.map((s) => s.starred_at));
    const monthAgo = new Date(Date.now() - 30 * 86_400_000).toISOString();
    return {
      updatedAt: new Date().toISOString(),
      live: true,
      downloads: Math.max(downloads, FALLBACK.downloads),
      stars: repo.stargazers_count,
      stars30d: stargazers.filter((s) => s.starred_at >= monthAgo).length,
      forks: repo.forks_count,
      contributors: contributors.length,
      releases: published.length,
      starHistory: history,
      brew: await brew,
    };
  } catch (error) {
    console.warn(`[stats] using fallback numbers: ${(error as Error).message}`);
    return { ...FALLBACK, brew: await brew };
  }
}

export const stats: Stats = await load();
