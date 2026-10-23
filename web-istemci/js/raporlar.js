// Liste ekranının DOM'dan bağımsız metinleri; raporlar-sayfasi.js bunları ekrana bağlar.

import { sayfalamaBilgisi } from './sorgu.js';

/** Sunucu yanıtı beklenen biçimde değilse api.js hatasına ek olarak kullanılan kod. */
export const YANIT_BICIMI_HATASI = {
  durum: 200,
  kod: 'YANIT_BICIMI',
  mesaj: '',
  detay: '',
};

const BULUNAMADI = 404;
const YASAK = 403;

export function bosListeMesaji(filtre) {
  const filtreli = filtre.status !== '' || filtre.category !== '';
  if (filtreli) {
    return {
      baslik: 'Bu filtrelere uyan bildirim yok',
      aciklama: 'Farklı bir durum veya kategori seçin ya da filtreleri temizleyin.',
      temizlenebilir: true,
    };
  }
  return {
    baslik: 'Henüz bildirim yok',
    aciklama: 'Öğrenciler mobil uygulamadan bildirim açtığında burada görünecek.',
    temizlenebilir: false,
  };
}

/** api.js hata nesnesini liste ekranındaki mesaja çevirir. */
export function listeHataMesaji(hata) {
  if (hata.durum === YASAK) {
    return {
      metin: 'Bu listeyi yalnızca görevliler görebilir. Görevli hesabıyla giriş yapın.',
      tekrarDenenebilir: false,
    };
  }
  if (hata.durum === BULUNAMADI) {
    return {
      metin:
        'Sunucuda bildirim listesi henüz yok (Issue #20). ' +
        'Arayüzü denemek için adrese ?mock=1 ekleyerek sahte veriyle açın.',
      tekrarDenenebilir: false,
    };
  }
  switch (hata.kod) {
    case 'AG_HATASI':
      return {
        metin: 'Sunucuya ulaşılamadı. Bağlantınızı kontrol edip tekrar deneyin.',
        tekrarDenenebilir: true,
      };
    case 'YANIT_BICIMI':
      return {
        metin: 'Sunucunun yanıtı anlaşılamadı. Lütfen ekibe bildirin.',
        tekrarDenenebilir: true,
      };
    default:
      return {
        metin: hata.mesaj || 'Bildirimler yüklenemedi. Lütfen tekrar deneyin.',
        tekrarDenenebilir: true,
      };
  }
}

export function sayacMetni(sayfa) {
  if (sayfa.total === 0) return '0 bildirim';
  const { ilk, son } = sayfalamaBilgisi(sayfa);
  return `${sayfa.total} bildirimden ${ilk}–${son} arası`;
}
