// Tarayıcıya özgü bağlantılar: gerçek depo, gerçek fetch, sayfa yönlendirmesi.
// Testler bu dosyayı içe aktarmaz; mantık oturum.js ve api.js'tedir.

import { apiIstemcisiOlustur } from './api.js';
import { oturumOlustur } from './oturum.js';
import { API_TABAN_URL, GIRIS_SAYFASI } from './yapilandirma.js';

export const oturum = oturumOlustur(window.sessionStorage);

export const api = apiIstemcisiOlustur({
  tabanUrl: API_TABAN_URL,
  fetchFn: (...argumanlar) => window.fetch(...argumanlar),
  oturum,
  yetkisizde: () => window.location.assign(GIRIS_SAYFASI),
});
