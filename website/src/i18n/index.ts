import type { HomeStrings } from './types';
import { en } from './en';
import { zhCN } from './zh-cn';
import { zhHant } from './zh-hant';
import { de } from './de';
import { fr } from './fr';
import { ru } from './ru';
import { es } from './es';
import { it } from './it';
import { ptBR } from './pt-br';
import { ja } from './ja';
import { ko } from './ko';
import { tr } from './tr';
import { fa } from './fa';

export const STRINGS: Record<string, HomeStrings> = {
  en,
  'zh-cn': zhCN,
  'zh-hant': zhHant,
  de,
  fr,
  ru,
  es,
  it,
  'pt-br': ptBR,
  ja,
  ko,
  tr,
  fa,
};
