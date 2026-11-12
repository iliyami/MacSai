// Refreshes src/data/star-history.json, the star history the site falls back
// to when the build has no token that may list stargazers.
// Usage: GITHUB_TOKEN=$(gh auth token) node scripts/update-star-history.mjs
import { writeFileSync } from 'node:fs';

const token = process.env.GITHUB_TOKEN;
if (!token) throw new Error('Set GITHUB_TOKEN to a user token, for example $(gh auth token).');
const query = `query($after: String) {
  repository(owner: "iliyami", name: "MacSai") {
    stargazers(first: 100, after: $after) { pageInfo { hasNextPage endCursor } edges { starredAt } }
  }
}`;
const dates = [];
let after = null;
for (;;) {
  const response = await fetch('https://api.github.com/graphql', {
    method: 'POST',
    headers: { Authorization: `Bearer ${token}`, 'Content-Type': 'application/json', 'User-Agent': 'macsai-website-build' },
    body: JSON.stringify({ query, variables: { after } }),
  });
  const body = await response.json();
  if (!response.ok || body.errors) throw new Error(JSON.stringify(body.errors ?? response.status));
  const { pageInfo, edges } = body.data.repository.stargazers;
  dates.push(...edges.map((e) => e.starredAt.slice(0, 10)));
  if (!pageInfo.hasNextPage) break;
  after = pageInfo.endCursor;
}
dates.sort();
const daily = [];
let total = 0;
for (const date of dates) {
  total += 1;
  if (daily.at(-1)?.[0] === date) daily.at(-1)[1] = total;
  else daily.push([date, total]);
}
const file = new URL('../src/data/star-history.json', import.meta.url);
writeFileSync(file, `${JSON.stringify({ daily }).replace(/\],\[/g, '],\n[')}\n`);
console.log(`${daily.length} days, ${total} stars, last ${daily.at(-1)?.[0]}`);
