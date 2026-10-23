// raporlar.html'i liste mantığına bağlar. Kullanıcı verisi yalnızca textContent ile
// yazılır (innerHTML yok); açıklama alanından HTML enjekte edilemez.

import { DURUMLAR, KATEGORILER, sayfaliYanitOku, tarihBicimle, yerMetni } from './rapor.js';
import { bosListeMesaji, listeHataMesaji, sayacMetni, YANIT_BICIMI_HATASI } from './raporlar.js';
import {
  adresSorgusu,
  apiYolu,
  filtreleriOku,
  sayfalamaBilgisi,
  tasanSayfaDuzeltmesi,
} from './sorgu.js';
import { api, oturum, sahteMod, sunucuAdresi } from './uygulama.js';
import { SAYFA_BOYUTU_SECENEKLERI, VARSAYILAN_SAYFA_BOYUTU } from './yapilandirma.js';

const $ = (secici) => document.querySelector(secici);

const ogeler = {
  form: $('#filtreler'),
  durum: $('#filtre-durum'),
  kategori: $('#filtre-kategori'),
  sayfaBoyutu: $('#filtre-sayfa-boyutu'),
  temizle: $('#filtre-temizle'),
  liste: $('#rapor-listesi'),
  baslik: $('#liste-basligi'),
  sayac: $('#sayac'),
  durumKutusu: $('#durum-kutusu'),
  durumBaslik: $('#durum-baslik'),
  durumAciklama: $('#durum-aciklama'),
  durumButon: $('#durum-buton'),
  sayfalama: $('#sayfalama'),
  onceki: $('#onceki-sayfa'),
  sonraki: $('#sonraki-sayfa'),
  sayfaBilgisi: $('#sayfa-bilgisi'),
  raporSablonu: $('#rapor-sablonu'),
  iskeletSablonu: $('#iskelet-sablonu'),
};

const ISKELET_SAYISI = 6;

// Filtre hızlı değişirse eski isteğin geç gelen yanıtı yeni listenin üstüne yazmasın.
let sonIstekNo = 0;
let durumButonuEylemi = null;

baslat();

function baslat() {
  if (!oturum.girisYapildiMi()) {
    api.cikis();
    return;
  }
  $('#kullanici-adi').textContent = oturum.kullanici()?.fullName ?? '';
  $('#sahte-rozet').hidden = !sahteMod;

  secenekleriDoldur(ogeler.durum, DURUMLAR);
  secenekleriDoldur(ogeler.kategori, KATEGORILER);

  ogeler.durum.addEventListener('change', () => filtreDegisti({ status: ogeler.durum.value }));
  ogeler.kategori.addEventListener('change', () =>
    filtreDegisti({ category: ogeler.kategori.value }),
  );
  ogeler.sayfaBoyutu.addEventListener('change', () =>
    filtreDegisti({ pageSize: Number(ogeler.sayfaBoyutu.value) }),
  );
  ogeler.temizle.addEventListener('click', filtreleriTemizle);
  ogeler.form.addEventListener('submit', (olay) => olay.preventDefault());
  ogeler.onceki.addEventListener('click', () => sayfayaGit(-1));
  ogeler.sonraki.addEventListener('click', () => sayfayaGit(1));
  ogeler.durumButon.addEventListener('click', () => durumButonuEylemi?.());
  $('#cikis-butonu').addEventListener('click', () => api.cikis());
  window.addEventListener('popstate', yukle);

  yukle();
}

function gecerliFiltre() {
  return filtreleriOku(new URLSearchParams(window.location.search));
}

function git(filtre, { degistir = false } = {}) {
  const adres = window.location.pathname + adresSorgusu(filtre);
  if (degistir) window.history.replaceState(null, '', adres);
  else window.history.pushState(null, '', adres);
  yukle();
}

function filtreDegisti(degisiklik) {
  // Filtre değişince sonuç kümesi değişir; ilk sayfadan başlanır.
  git({ ...gecerliFiltre(), ...degisiklik, page: 1 });
}

function filtreleriTemizle() {
  git({ status: '', category: '', page: 1, pageSize: gecerliFiltre().pageSize });
}

function sayfayaGit(fark) {
  const filtre = gecerliFiltre();
  git({ ...filtre, page: filtre.page + fark });
  ogeler.baslik.focus({ preventScroll: true });
  window.scrollTo({ top: 0 });
}

async function yukle() {
  const filtre = gecerliFiltre();
  formuDoldur(filtre);
  const istekNo = ++sonIstekNo;
  yukleniyorGoster();

  const sonuc = await api.getir(apiYolu(filtre));
  if (istekNo !== sonIstekNo) return;

  if (!sonuc.ok) {
    hataGoster(sonuc.hata);
    return;
  }
  const sayfa = sayfaliYanitOku(sonuc.veri);
  if (sayfa === null) {
    hataGoster(YANIT_BICIMI_HATASI);
    return;
  }
  const duzeltilmisSayfa = tasanSayfaDuzeltmesi(sayfa);
  if (duzeltilmisSayfa !== null) {
    git({ ...filtre, page: duzeltilmisSayfa }, { degistir: true });
    return;
  }
  listeyiCiz(sayfa, filtre);
}

function formuDoldur(filtre) {
  ogeler.durum.value = filtre.status;
  ogeler.kategori.value = filtre.category;
  sayfaBoyutuSecenekleri(filtre.pageSize);
  ogeler.sayfaBoyutu.value = String(filtre.pageSize);
  ogeler.temizle.disabled = filtre.status === '' && filtre.category === '';
}

function yukleniyorGoster() {
  ogeler.durumKutusu.hidden = true;
  ogeler.liste.setAttribute('aria-busy', 'true');
  ogeler.sayac.textContent = 'Yükleniyor…';
  const iskeletler = Array.from({ length: ISKELET_SAYISI }, () =>
    ogeler.iskeletSablonu.content.cloneNode(true),
  );
  ogeler.liste.replaceChildren(...iskeletler);
}

function listeyiCiz(sayfa, filtre) {
  ogeler.liste.setAttribute('aria-busy', 'false');
  ogeler.liste.replaceChildren(...sayfa.items.map(raporOgesi));
  ogeler.sayac.textContent = sayacMetni(sayfa);

  if (sayfa.items.length === 0) {
    const mesaj = bosListeMesaji(filtre);
    durumGoster(mesaj.baslik, mesaj.aciklama, mesaj.temizlenebilir ? 'Filtreleri temizle' : null, filtreleriTemizle);
  } else {
    ogeler.durumKutusu.hidden = true;
  }

  const bilgi = sayfalamaBilgisi(sayfa);
  ogeler.sayfalama.hidden = bilgi.toplamSayfa <= 1;
  ogeler.onceki.disabled = !bilgi.oncekiVar;
  ogeler.sonraki.disabled = !bilgi.sonrakiVar;
  ogeler.sayfaBilgisi.textContent = `Sayfa ${sayfa.page} / ${bilgi.toplamSayfa}`;
}

function hataGoster(hata) {
  ogeler.liste.setAttribute('aria-busy', 'false');
  ogeler.liste.replaceChildren();
  ogeler.sayfalama.hidden = true;
  ogeler.sayac.textContent = '';
  const mesaj = listeHataMesaji(hata);
  durumGoster('Bildirimler yüklenemedi', mesaj.metin, mesaj.tekrarDenenebilir ? 'Tekrar dene' : null, yukle);
  ogeler.durumKutusu.dataset.tur = 'hata';
}

function durumGoster(baslik, aciklama, butonMetni, eylem) {
  ogeler.durumKutusu.dataset.tur = 'bos';
  ogeler.durumBaslik.textContent = baslik;
  ogeler.durumAciklama.textContent = aciklama;
  ogeler.durumButon.hidden = butonMetni === null;
  ogeler.durumButon.textContent = butonMetni ?? '';
  durumButonuEylemi = eylem;
  ogeler.durumKutusu.hidden = false;
}

function raporOgesi(rapor) {
  const parca = ogeler.raporSablonu.content.cloneNode(true);
  const kok = parca.querySelector('.rapor');
  kok.dataset.durum = rapor.durum;

  const kategori = parca.querySelector('.kategori');
  kategori.textContent = KATEGORILER[rapor.kategori];

  const durum = parca.querySelector('.durum');
  durum.textContent = DURUMLAR[rapor.durum];
  durum.dataset.durum = rapor.durum;

  parca.querySelector('.rapor-aciklama').textContent = rapor.aciklama || '(Açıklama yok)';
  parca.querySelector('.rapor-yer').textContent = yerMetni(rapor);

  const tarih = parca.querySelector('.rapor-tarih');
  tarih.dateTime = rapor.olusturma.toISOString();
  tarih.textContent = tarihBicimle(rapor.olusturma);

  gorselEkle(parca.querySelector('.rapor-gorsel'), rapor);
  return parca;
}

function gorselEkle(kutu, rapor) {
  kutu.textContent = KATEGORILER[rapor.kategori].charAt(0);
  if (!rapor.fotografUrl) return;

  const resim = document.createElement('img');
  resim.src = sunucuAdresi(rapor.fotografUrl);
  resim.alt = `Bildirim fotoğrafı: ${rapor.aciklama}`;
  resim.loading = 'lazy';
  // Fotoğraf yüklenemezse kategori harfi yer tutucu olarak kalır.
  resim.addEventListener('load', () => kutu.replaceChildren(resim));
}

function secenekleriDoldur(secim, sozluk) {
  for (const [deger, etiket] of Object.entries(sozluk)) {
    secim.append(new Option(etiket, deger));
  }
}

function sayfaBoyutuSecenekleri(gecerli) {
  const boyutlar = new Set([...SAYFA_BOYUTU_SECENEKLERI, gecerli, VARSAYILAN_SAYFA_BOYUTU]);
  const sirali = [...boyutlar].sort((a, b) => a - b);
  ogeler.sayfaBoyutu.replaceChildren(...sirali.map((n) => new Option(String(n), String(n))));
}
