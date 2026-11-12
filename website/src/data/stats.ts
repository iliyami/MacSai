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

const GITHUB_API = 'https://api.github.com/';

/** The build token is only ever sent to api.github.com, never to Homebrew. */
function headers(url: string, accept: string | undefined, auth: boolean): Record<string, string> {
  const github = url.startsWith(GITHUB_API);
  const h: Record<string, string> = {
    Accept: accept ?? (github ? 'application/vnd.github+json' : 'application/json'),
    'User-Agent': 'macsai-website-build',
  };
  if (auth && github && process.env.GITHUB_TOKEN) h.Authorization = `Bearer ${process.env.GITHUB_TOKEN}`;
  return h;
}

async function getJSON<T>(url: string, accept?: string): Promise<T> {
  let response = await fetch(url, { headers: headers(url, accept, true) });
  // Some endpoints refuse the Actions token; the public data is readable without it.
  if (response.status === 403 && url.startsWith(GITHUB_API) && process.env.GITHUB_TOKEN) {
    response = await fetch(url, { headers: headers(url, accept, false) });
  }
  if (!response.ok) {
    const detail = (await response.text()).slice(0, 160).replace(/\s+/g, ' ');
    throw new Error(`${url}: HTTP ${response.status} ${detail}`);
  }
  return (await response.json()) as T;
}

/** Runs an optional lookup; a failure hides that number instead of the section. */
async function optional<T>(label: string, task: () => Promise<T>): Promise<T | null> {
  try {
    return await task();
  } catch (error) {
    console.warn(`[stats] ${label} unavailable: ${(error as Error).message}`);
    return null;
  }
}

/** Follows GitHub's 100-per-page pagination until a short page. */
async function allPages<T>(path: string, accept?: string, maxPages = 400): Promise<T[]> {
  const out: T[] = [];
  for (let page = 1; page <= maxPages; page++) {
    const sep = path.includes('?') ? '&' : '?';
    const items = await getJSON<T[]>(`${GITHUB_API}${path}${sep}per_page=100&page=${page}`, accept);
    out.push(...items);
    if (items.length < 100) break;
  }
  return out;
}

/**
 * Star dates through GraphQL. The REST stargazers list refuses the GitHub
 * Actions token, while GraphQL accepts it for public repositories.
 */
async function starDates(): Promise<string[]> {
  const token = process.env.GITHUB_TOKEN;
  if (!token) throw new Error('GraphQL needs GITHUB_TOKEN');
  const [owner, name] = REPO.split('/');
  const query = `query($owner: String!, $name: String!, $after: String) {
    repository(owner: $owner, name: $name) {
      stargazers(first: 100, after: $after) { pageInfo { hasNextPage endCursor } edges { starredAt } }
    }
  }`;
  const dates: string[] = [];
  let after: string | null = null;
  for (let page = 0; page < 400; page++) {
    const response = await fetch(`${GITHUB_API}graphql`, {
      method: 'POST',
      headers: { ...headers(`${GITHUB_API}graphql`, undefined, true), 'Content-Type': 'application/json' },
      body: JSON.stringify({ query, variables: { owner, name, after } }),
    });
    if (!response.ok) throw new Error(`GraphQL stargazers: HTTP ${response.status}`);
    const body = (await response.json()) as {
      errors?: { message: string }[];
      data?: { repository: { stargazers: { pageInfo: { hasNextPage: boolean; endCursor: string }; edges: { starredAt: string }[] } } };
    };
    if (body.errors?.length || !body.data) throw new Error(`GraphQL stargazers: ${body.errors?.[0]?.message ?? 'no data'}`);
    const { pageInfo, edges } = body.data.repository.stargazers;
    dates.push(...edges.map((e) => e.starredAt));
    if (!pageInfo.hasNextPage) break;
    after = pageInfo.endCursor;
  }
  return dates;
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
  const contributors = optional('contributors', () => allPages<unknown>(`repos/${REPO}/contributors`));
  const starsTask = optional('star history', starDates);
  try {
    const [repo, releases] = await Promise.all([
      getJSON<{ stargazers_count: number; forks_count: number }>(`${GITHUB_API}repos/${REPO}`),
      allPages<GHRelease>(`repos/${REPO}/releases`),
    ]);
    const starred = (await starsTask) ?? [];
    const published = releases.filter((r) => !r.draft);
    const downloads = published
      .flatMap((r) => r.assets)
      .filter((a) => a.name.endsWith('.dmg'))
      .reduce((sum, a) => sum + a.download_count, 0);
    const history = starHistory(starred);
    const monthAgo = new Date(Date.now() - 30 * 86_400_000).toISOString();
    return {
      updatedAt: new Date().toISOString(),
      live: true,
      downloads: Math.max(downloads, FALLBACK.downloads),
      stars: repo.stargazers_count,
      stars30d: starred.length ? starred.filter((d) => d >= monthAgo).length : null,
      forks: repo.forks_count,
      contributors: (await contributors)?.length ?? null,
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
