/** Site-relative link that respects the deploy base path ("/MacSai/"). */
export function href(path = '/'): string {
  const base = import.meta.env.BASE_URL.replace(/\/$/, '');
  const clean = path.startsWith('/') ? path : `/${path}`;
  return `${base}${clean}`;
}

/** Absolute URL, for canonical links, Open Graph and structured data. */
export function absolute(path = '/'): string {
  return new URL(href(path), import.meta.env.SITE).toString();
}
