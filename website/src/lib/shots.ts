import type { ImageMetadata } from 'astro';

const files = import.meta.glob<{ default: ImageMetadata }>('../assets/shots/*.webp', { eager: true });

/** Real app screenshots by file name, e.g. shot('maintenance'). */
export function shot(name: string): ImageMetadata {
  const entry = files[`../assets/shots/${name}.webp`];
  if (!entry) throw new Error(`Missing screenshot ${name}.webp`);
  return entry.default;
}
