// Giriş ekranının DOM'dan bağımsız mantığı; giris-sayfasi.js bunu ekrana bağlar.

import { LISTE_SAYFASI } from './yapilandirma.js';

// Yalnızca bariz hataları yakalar; asıl doğrulama sunucudadır.
const EPOSTA_BICIMI = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

const GENEL_HATA = 'Giriş yapılamadı. Lütfen biraz sonra tekrar deneyin.';

/**
 * Formu sunucuya göndermeden önce denetler.
 * @returns {null | { alan: 'email' | 'parola', mesaj: string }}
 */
export function girisFormunuDogrula(email, parola) {
  const temizEposta = email.trim();
  if (temizEposta === '') return { alan: 'email', mesaj: 'E-posta zorunlu.' };
  if (!EPOSTA_BICIMI.test(temizEposta)) {
    return { alan: 'email', mesaj: 'Geçerli bir e-posta adresi girin.' };
  }
  if (parola === '') return { alan: 'parola', mesaj: 'Parola zorunlu.' };
  return null;
}

/** api.js hata nesnesini kullanıcıya gösterilecek metne çevirir. */
export function girisHataMesaji(hata) {
  switch (hata.kod) {
    case 'INVALID_CREDENTIALS':
      // Güvenlik: hangi alanın yanlış olduğu söylenmez (06-security-and-privacy).
      return 'E-posta veya parola hatalı.';
    case 'AG_HATASI':
      return 'Sunucuya ulaşılamadı. Bağlantınızı kontrol edip tekrar deneyin.';
    case 'VALIDATION_ERROR':
      return hata.mesaj || GENEL_HATA;
    default:
      // JS'te derleyici kontrolü yok; sunucu yeni bir kod eklerse genel mesaj gösterilir.
      return GENEL_HATA;
  }
}

/**
 * Girişten sonra ne yapılacağına karar verir.
 * `GET /api/reports` yalnızca görevliye açık olduğu için öğrenci listeye gönderilmez.
 */
export function girisSonrasiHedef(kullanici) {
  if (kullanici?.role === 'Staff') return { tur: 'yonlendir', sayfa: LISTE_SAYFASI };
  return {
    tur: 'uyari',
    mesaj:
      'Bu web istemcisi şimdilik yalnızca görevliler içindir. ' +
      'Öğrenciler bildirim açmak ve takip etmek için mobil uygulamayı kullanabilir.',
  };
}
