// Çekirdek REST API'sine erişim. İstisna fırlatmaz; her çağrı bir sonuç döner:
//   { ok: true, veri }  veya  { ok: false, hata: { durum, kod, mesaj, detay } }
// Hata biçimi 05-api-design.md "Hata biçimi ve durum kodları" bölümüyle aynıdır.

const YETKISIZ = 401;

const AG_HATASI = {
  durum: 0,
  kod: 'AG_HATASI',
  mesaj: 'Sunucuya ulaşılamadı. Bağlantınızı kontrol edip tekrar deneyin.',
  detay: '',
};

const OTURUM_YOK = {
  durum: YETKISIZ,
  kod: 'UNAUTHORIZED',
  mesaj: 'Oturumunuzun süresi doldu. Lütfen tekrar giriş yapın.',
  detay: '',
};

/**
 * @param {object} p
 * @param {string} p.tabanUrl      Sunucu adresi, ör. http://localhost:8080
 * @param {Function} p.fetchFn     Tarayıcıda `fetch`, testte sahte fetch
 * @param {object} p.oturum        oturumOlustur() sonucu
 * @param {Function} p.yetkisizde  Oturum düştüğünde çağrılır (girişe yönlendirme)
 */
export function apiIstemcisiOlustur({ tabanUrl, fetchFn, oturum, yetkisizde }) {
  // Aynı anda birden çok 401 gelirse tek yenileme isteği yapılır;
  // sunucu kullanılan yenileme belirtecini iptal ettiği için bu şart.
  let suankiYenileme = null;

  async function gonder(yol, { metot = 'GET', govde, belirtec } = {}) {
    const headers = { Accept: 'application/json' };
    if (govde !== undefined) headers['Content-Type'] = 'application/json';
    if (belirtec) headers.Authorization = `Bearer ${belirtec}`;

    let yanit;
    try {
      yanit = await fetchFn(tabanUrl + yol, {
        method: metot,
        headers,
        body: govde === undefined ? undefined : JSON.stringify(govde),
      });
    } catch {
      return { ok: false, hata: AG_HATASI };
    }

    const icerik = await jsonOku(yanit);
    if (yanit.ok) return { ok: true, veri: icerik };
    return { ok: false, hata: hataAyikla(yanit.status, icerik) };
  }

  function yenile() {
    suankiYenileme ??= (async () => {
      const sonuc = await gonder('/api/auth/refresh', {
        metot: 'POST',
        govde: { refreshToken: oturum.yenilemeBelirteci() },
      });
      if (sonuc.ok) oturum.kaydet(sonuc.veri);
      return sonuc.ok;
    })().finally(() => {
      suankiYenileme = null;
    });
    return suankiYenileme;
  }

  function oturumuKapat(hata) {
    oturum.temizle();
    yetkisizde();
    return { ok: false, hata };
  }

  async function yetkiliIstek(yol, secenekler = {}) {
    if (!oturum.girisYapildiMi()) return oturumuKapat(OTURUM_YOK);

    const ilk = await gonder(yol, { ...secenekler, belirtec: oturum.erisimBelirteci() });
    if (ilk.ok || ilk.hata.durum !== YETKISIZ) return ilk;

    const yenilendi = await yenile();
    if (!yenilendi) return oturumuKapat(ilk.hata);

    const ikinci = await gonder(yol, { ...secenekler, belirtec: oturum.erisimBelirteci() });
    if (!ikinci.ok && ikinci.hata.durum === YETKISIZ) return oturumuKapat(ikinci.hata);
    return ikinci;
  }

  return {
    async giris(email, parola) {
      const sonuc = await gonder('/api/auth/login', {
        metot: 'POST',
        govde: { email, password: parola },
      });
      if (sonuc.ok) oturum.kaydet(sonuc.veri);
      return sonuc;
    },
    cikis() {
      oturum.temizle();
      yetkisizde();
    },
    getir: (yol) => yetkiliIstek(yol),
  };
}

async function jsonOku(yanit) {
  const metin = await yanit.text();
  if (metin === '') return null;
  try {
    return JSON.parse(metin);
  } catch {
    return null;
  }
}

function hataAyikla(durum, icerik) {
  const hata = icerik?.error;
  if (typeof hata?.code !== 'string') {
    return {
      durum,
      kod: 'BILINMEYEN_HATA',
      mesaj: `Beklenmeyen bir hata oluştu (HTTP ${durum}).`,
      detay: '',
    };
  }
  return {
    durum,
    kod: hata.code,
    mesaj: typeof hata.message === 'string' ? hata.message : '',
    detay: typeof hata.details === 'string' ? hata.details : '',
  };
}
