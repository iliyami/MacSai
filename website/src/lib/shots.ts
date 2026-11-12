import type { ImageMetadata } from 'astro';

const files = import.meta.glob<{ default: ImageMetadata }>('../assets/shots/*.webp', { eager: true });

/** Real app screenshots by file name, e.g. shot('maintenance'). */
export function shot(name: string): ImageMetadata {
  const entry = files[`../assets/shots/${name}.webp`];
  if (!entry) throw new Error(`Missing screenshot ${name}.webp`);
  return entry.default;
}

/**
 * Window corner radius in each screenshot, in image pixels, measured from the
 * transparent corners. Captures from different macOS window styles differ.
 */
const CORNER: Record<string, number> = { 'smart-scan': 28, 'system-junk': 28 };
const DEFAULT_CORNER = 17;

/** A border-radius that follows the window's own rounded corners at any size. */
export function shotRadius(name: string): string {
  const { width, height } = shot(name);
  const r = CORNER[name] ?? DEFAULT_CORNER;
  return `${((r / width) * 100).toFixed(3)}% / ${((r / height) * 100).toFixed(3)}%`;
}
