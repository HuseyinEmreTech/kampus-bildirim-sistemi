import { OTURUM_ANAHTARI } from './yapilandirma.js';

/**
 * Giriş yanıtını (belirteçler + kullanıcı) tarayıcı deposunda tutar.
 * Depo dışarıdan verilir: tarayıcıda `sessionStorage`, testte sahte depo.
 * `sessionStorage` seçildi: sekme kapanınca belirteç silinir.
 */
export function oturumOlustur(depo) {
  function oku() {
    const ham = depo.getItem(OTURUM_ANAHTARI);
    if (ham === null) return null;
    try {
      const kayit = JSON.parse(ham);
      return gecerliMi(kayit) ? kayit : null;
    } catch {
      return null;
    }
  }

  return {
    kaydet(girisYaniti) {
      if (!gecerliMi(girisYaniti)) return;
      const { accessToken, refreshToken, user } = girisYaniti;
      depo.setItem(OTURUM_ANAHTARI, JSON.stringify({ accessToken, refreshToken, user }));
    },
    temizle() {
      depo.removeItem(OTURUM_ANAHTARI);
    },
    girisYapildiMi: () => oku() !== null,
    erisimBelirteci: () => oku()?.accessToken ?? null,
    yenilemeBelirteci: () => oku()?.refreshToken ?? null,
    kullanici: () => oku()?.user ?? null,
  };
}

function gecerliMi(kayit) {
  return (
    typeof kayit?.accessToken === 'string' &&
    typeof kayit.refreshToken === 'string' &&
    typeof kayit.user === 'object' &&
    kayit.user !== null
  );
}
