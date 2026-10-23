// Sahte sunucu: `GET /api/reports` henüz yokken (#20) istemciyi denemek için.
// Adrese `?mock=1` eklenince uygulama.js gerçek fetch yerine bunu kullanır.
// Veriler uydurmadır; gerçek kişi ve kampüs bilgisi içermez.

const VARSAYILAN_GECIKME_MS = 400;
const SAHTE_KAYIT_SAYISI = 46;
const KAYITLAR_ARASI_SAAT = 7;
const SAAT_MS = 60 * 60 * 1000;
const BASLANGIC = Date.parse('2026-10-22T15:00:00Z');

/** Sahte modda her e-posta bu parolayla girer. */
export const SAHTE_PAROLA = 'demo';

const SORUNLAR = [
  ['Ariza', 'Koridor lambası yanmıyor'],
  ['Ariza', 'Sınıf projektörü görüntü vermiyor'],
  ['Temizlik', 'Çöp kutusu taşmış'],
  ['Guvenlik', 'Acil çıkış kapısı kilitli'],
  ['Ariza', 'Musluk sürekli akıyor'],
  ['Temizlik', 'Merdivende dökülmüş çay var'],
  ['Diger', 'Bank kırılmış, oturulamıyor'],
  ['Guvenlik', 'Otopark aydınlatması yetersiz'],
  ['Ariza', 'Asansör katlar arasında duruyor'],
  ['Diger', 'Duyuru panosu düşmek üzere'],
];

const YERLER = [
  ['A Blok 1. kat', null],
  ['B Blok 2. kat', null],
  [null, 'Kütüphane'],
  ['Mühendislik Fakültesi giriş', null],
  [null, 'Yemekhane'],
  ['C Blok bodrum', null],
  [null, 'Spor Salonu'],
];

const DURUM_SIRASI = ['Yeni', 'Yeni', 'Ustlenildi', 'Cozuldu', 'Yeni', 'Ustlenildi'];

export const SAHTE_RAPORLAR = Array.from({ length: SAHTE_KAYIT_SAYISI }, (_, i) => {
  const [category, description] = SORUNLAR[i % SORUNLAR.length];
  const [place, buildingName] = YERLER[i % YERLER.length];
  const status = DURUM_SIRASI[i % DURUM_SIRASI.length];
  const sira = String(i + 1).padStart(12, '0');
  return {
    reportId: `00000000-0000-4000-8000-${sira}`,
    category,
    description,
    status,
    place,
    buildingName,
    photoUrl: null,
    assigneeId: status === 'Yeni' ? null : '00000000-0000-4000-8000-0000000000aa',
    createdAt: new Date(BASLANGIC - i * KAYITLAR_ARASI_SAAT * SAAT_MS).toISOString(),
  };
});

export function sahteFetchOlustur({ gecikmeMs = VARSAYILAN_GECIKME_MS } = {}) {
  return async (url, secenekler = {}) => {
    await new Promise((coz) => setTimeout(coz, gecikmeMs));
    const adres = new URL(url);
    const govde = secenekler.body ? JSON.parse(secenekler.body) : null;
    const rol = belirtectenRol(secenekler.headers?.Authorization);

    switch (`${secenekler.method ?? 'GET'} ${adres.pathname}`) {
      case 'POST /api/auth/login':
        return giris(govde);
      case 'POST /api/auth/refresh':
        return yenile(govde);
      case 'GET /api/reports':
        return liste(rol, adres.searchParams);
      default:
        return hata(404, 'NOT_FOUND', 'Sahte sunucuda bu yol yok.');
    }
  };
}

function giris({ email, password }) {
  if (password !== SAHTE_PAROLA) {
    return hata(401, 'INVALID_CREDENTIALS', 'E-posta veya parola hatalı.');
  }
  const rol = email.startsWith('ogrenci') ? 'Student' : 'Staff';
  return yanit(200, belirtecCifti(rol, email));
}

function yenile({ refreshToken }) {
  const rol = /^sahte-yenileme-(Staff|Student)$/.exec(refreshToken)?.[1];
  if (!rol) return hata(401, 'UNAUTHORIZED', 'Yenileme belirteci geçersiz.');
  return yanit(200, belirtecCifti(rol, 'sahte@ornek.edu'));
}

function liste(rol, p) {
  if (!rol) return hata(401, 'UNAUTHORIZED', 'Giriş gerekli.');
  if (rol !== 'Staff') return hata(403, 'FORBIDDEN', 'Bu işlem için yetkiniz yok.');

  const page = Number(p.get('page') ?? 1);
  const pageSize = Number(p.get('pageSize') ?? 20);
  const eslesen = SAHTE_RAPORLAR.filter(
    (r) =>
      (!p.get('status') || r.status === p.get('status')) &&
      (!p.get('category') || r.category === p.get('category')),
  ).sort((a, b) => Date.parse(b.createdAt) - Date.parse(a.createdAt));

  return yanit(200, {
    items: eslesen.slice((page - 1) * pageSize, page * pageSize),
    page,
    pageSize,
    total: eslesen.length,
  });
}

function belirtecCifti(rol, email) {
  return {
    accessToken: `sahte-erisim-${rol}`,
    refreshToken: `sahte-yenileme-${rol}`,
    user: {
      userId: '00000000-0000-4000-8000-0000000000aa',
      fullName: rol === 'Staff' ? 'Demo Görevli' : 'Demo Öğrenci',
      role: rol,
      email,
    },
  };
}

function belirtectenRol(baslik) {
  return /^Bearer sahte-erisim-(Staff|Student)$/.exec(baslik ?? '')?.[1] ?? null;
}

function hata(durum, code, message) {
  return yanit(durum, { error: { code, message, details: '' } });
}

function yanit(durum, json) {
  return {
    status: durum,
    ok: durum >= 200 && durum < 300,
    text: async () => JSON.stringify(json),
  };
}
