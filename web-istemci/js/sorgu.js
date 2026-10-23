// Filtre ve sayfa durumunu adres çubuğu ile API sorgusu arasında çevirir.
// Filtreler adreste tutulur: sayfa yenilenince veya bağlantı paylaşılınca kaybolmaz.

import { DURUMLAR, KATEGORILER } from './rapor.js';
import { EN_FAZLA_SAYFA_BOYUTU, VARSAYILAN_SAYFA_BOYUTU } from './yapilandirma.js';

const ILK_SAYFA = 1;

/** Adres parametrelerini doğrulanmış filtreye çevirir; geçersiz değer varsayılana döner. */
export function filtreleriOku(parametreler) {
  return {
    status: listedeVarsa(parametreler.get('status'), DURUMLAR),
    category: listedeVarsa(parametreler.get('category'), KATEGORILER),
    page: pozitifTamsayi(parametreler.get('page')) ?? ILK_SAYFA,
    pageSize: Math.min(
      pozitifTamsayi(parametreler.get('pageSize')) ?? VARSAYILAN_SAYFA_BOYUTU,
      EN_FAZLA_SAYFA_BOYUTU,
    ),
  };
}

/** `GET /api/reports` yolu; boş filtreler gönderilmez. */
export function apiYolu(filtre) {
  const p = new URLSearchParams();
  if (filtre.status) p.set('status', filtre.status);
  if (filtre.category) p.set('category', filtre.category);
  p.set('page', String(filtre.page));
  p.set('pageSize', String(filtre.pageSize));
  return `/api/reports?${p}`;
}

/** Adres çubuğu için sorgu; varsayılan değerler yazılmaz ki adres kısa kalsın. */
export function adresSorgusu(filtre) {
  const p = new URLSearchParams();
  if (filtre.status) p.set('status', filtre.status);
  if (filtre.category) p.set('category', filtre.category);
  if (filtre.page !== ILK_SAYFA) p.set('page', String(filtre.page));
  if (filtre.pageSize !== VARSAYILAN_SAYFA_BOYUTU) p.set('pageSize', String(filtre.pageSize));
  const metin = p.toString();
  return metin === '' ? '' : `?${metin}`;
}

/** "41-45 / 45" metni ve önceki/sonraki düğmelerinin durumu. */
export function sayfalamaBilgisi({ page, pageSize, total }) {
  const toplamSayfa = Math.max(ILK_SAYFA, Math.ceil(total / pageSize));
  if (total === 0) {
    return { toplamSayfa, ilk: 0, son: 0, oncekiVar: false, sonrakiVar: false };
  }
  return {
    toplamSayfa,
    ilk: (page - 1) * pageSize + 1,
    son: Math.min(page * pageSize, total),
    oncekiVar: page > ILK_SAYFA,
    sonrakiVar: page < toplamSayfa,
  };
}

/**
 * Adresteki sayfa artık yoksa (ör. filtre değişti, kayıt silindi) gidilecek son sayfa.
 * Düzeltme gerekmiyorsa null.
 */
export function tasanSayfaDuzeltmesi({ page, pageSize, total, items }) {
  if (items.length > 0 || total === 0 || page === ILK_SAYFA) return null;
  return Math.max(ILK_SAYFA, Math.ceil(total / pageSize));
}

function listedeVarsa(deger, sozluk) {
  return deger !== null && Object.hasOwn(sozluk, deger) ? deger : '';
}

function pozitifTamsayi(metin) {
  if (metin === null || !/^\d+$/.test(metin)) return null;
  const sayi = Number(metin);
  return sayi >= 1 ? sayi : null;
}
