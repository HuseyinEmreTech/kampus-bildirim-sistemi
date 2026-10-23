// Bildirim yanıtlarını elle okur (fromJson karşılığı) ve görünüm metinlerini üretir.
// Alanlar: application ReportSummary (reportId, category, description, status,
// place, buildingName, photoUrl, assigneeId, createdAt).

/** 03-domain-design: ReportStatus. Değer → ekranda görünen etiket. */
export const DURUMLAR = {
  Yeni: 'Yeni',
  Ustlenildi: 'Üstlenildi',
  Cozuldu: 'Çözüldü',
};

/** 03-domain-design: Category. Değer → ekranda görünen etiket. */
export const KATEGORILER = {
  Ariza: 'Arıza',
  Temizlik: 'Temizlik',
  Guvenlik: 'Güvenlik',
  Diger: 'Diğer',
};

const TARIH_BICIMI = new Intl.DateTimeFormat('tr-TR', {
  day: 'numeric',
  month: 'short',
  year: 'numeric',
  hour: '2-digit',
  minute: '2-digit',
  timeZone: 'Europe/Istanbul',
});

/** Tek bildirimi okur; zorunlu alan eksik veya geçersizse null döner. */
export function raporOku(json) {
  if (typeof json !== 'object' || json === null) return null;
  if (typeof json.reportId !== 'string' || json.reportId === '') return null;
  if (!Object.hasOwn(DURUMLAR, json.status)) return null;
  if (!Object.hasOwn(KATEGORILER, json.category)) return null;

  const olusturma = new Date(json.createdAt);
  if (typeof json.createdAt !== 'string' || Number.isNaN(olusturma.getTime())) return null;

  return {
    id: json.reportId,
    kategori: json.category,
    durum: json.status,
    aciklama: metinVeyaBos(json.description),
    yer: metinVeyaNull(json.place) ?? metinVeyaNull(json.location?.place),
    bina: metinVeyaNull(json.buildingName),
    fotografUrl: metinVeyaNull(json.photoUrl),
    ustlenenId: metinVeyaNull(json.assigneeId),
    olusturma,
  };
}

/**
 * Sayfalı liste yanıtını okur. Biçim bozuksa null döner.
 * Okunamayan kayıtlar atlanır ve sayısı `atlanan` alanında bildirilir.
 */
export function sayfaliYanitOku(json) {
  if (typeof json !== 'object' || json === null) return null;
  if (!Array.isArray(json.items)) return null;
  if (![json.page, json.pageSize, json.total].every(Number.isInteger)) return null;

  const items = json.items.map(raporOku).filter((r) => r !== null);
  return {
    items,
    atlanan: json.items.length - items.length,
    page: json.page,
    pageSize: json.pageSize,
    total: json.total,
  };
}

export function yerMetni(rapor) {
  return rapor.yer ?? rapor.bina ?? 'Konum belirtilmedi';
}

export function tarihBicimle(tarih) {
  return TARIH_BICIMI.format(tarih);
}

function metinVeyaNull(deger) {
  return typeof deger === 'string' && deger.trim() !== '' ? deger : null;
}

function metinVeyaBos(deger) {
  return typeof deger === 'string' ? deger : '';
}
