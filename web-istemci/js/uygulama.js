// Tarayıcıya özgü bağlantılar: gerçek depo, gerçek fetch, sayfa yönlendirmesi.
// Testler bu dosyayı içe aktarmaz; mantık oturum.js ve api.js'tedir.

import { apiIstemcisiOlustur } from './api.js';
import { oturumOlustur } from './oturum.js';
import { sahteFetchOlustur } from './sahte-veri.js';
import { API_TABAN_URL, GIRIS_SAYFASI, SAHTE_MOD_ANAHTARI } from './yapilandirma.js';

// `?mock=1` sahte modu açar, `?mock=0` kapatır; seçim sekme kapanana kadar hatırlanır.
const mockParametresi = new URLSearchParams(window.location.search).get('mock');
if (mockParametresi === '1') window.sessionStorage.setItem(SAHTE_MOD_ANAHTARI, '1');
if (mockParametresi === '0') window.sessionStorage.removeItem(SAHTE_MOD_ANAHTARI);

export const sahteMod = window.sessionStorage.getItem(SAHTE_MOD_ANAHTARI) === '1';

export const oturum = oturumOlustur(window.sessionStorage);

export const api = apiIstemcisiOlustur({
  tabanUrl: API_TABAN_URL,
  fetchFn: sahteMod ? sahteFetchOlustur() : (...argumanlar) => window.fetch(...argumanlar),
  oturum,
  yetkisizde: () => window.location.assign(GIRIS_SAYFASI),
});

/** Sunucunun döndüğü göreli dosya yolunu (ör. /files/x.jpg) tam adrese çevirir. */
export function sunucuAdresi(yol) {
  return new URL(yol, API_TABAN_URL).href;
}
