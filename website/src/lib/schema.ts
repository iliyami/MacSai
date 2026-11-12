import { absolute } from './url';
import { release, REPO_URL } from '../data/release';
import type { FAQ } from '../data/pages';

export function softwareApplication(description: string, inLanguage = 'en') {
  return {
    '@context': 'https://schema.org',
    '@type': 'SoftwareApplication',
    name: 'Mac Sai',
    description,
    applicationCategory: 'UtilitiesApplication',
    operatingSystem: 'macOS 14 or later',
    softwareVersion: release.version,
    datePublished: release.publishedAt,
    downloadUrl: release.dmgURL,
    installUrl: absolute('/download/'),
    url: absolute('/'),
    image: absolute('/og/mac-sai.jpg'),
    license: 'https://opensource.org/license/bsd-3-clause',
    isAccessibleForFree: true,
    codeRepository: REPO_URL,
    inLanguage,
    offers: { '@type': 'Offer', price: '0', priceCurrency: 'USD' },
  };
}

export function faqPage(faq: FAQ[]) {
  return {
    '@context': 'https://schema.org',
    '@type': 'FAQPage',
    mainEntity: faq.map((f) => ({
      '@type': 'Question',
      name: f.q,
      acceptedAnswer: { '@type': 'Answer', text: f.a },
    })),
  };
}

export function breadcrumbs(items: { name: string; path: string }[]) {
  return {
    '@context': 'https://schema.org',
    '@type': 'BreadcrumbList',
    itemListElement: items.map((item, i) => ({
      '@type': 'ListItem',
      position: i + 1,
      name: item.name,
      item: absolute(item.path),
    })),
  };
}

/** The 44-second tour on the home page, so search engines can show it as a video result. */
export function tourVideo(name: string, description: string) {
  return {
    '@context': 'https://schema.org',
    '@type': 'VideoObject',
    name,
    description,
    thumbnailUrl: absolute('/video/mac-sai-tour.jpg'),
    contentUrl: absolute('/video/mac-sai-tour.mp4'),
    uploadDate: '2026-11-12',
    duration: 'PT44S',
    inLanguage: 'en',
  };
}
