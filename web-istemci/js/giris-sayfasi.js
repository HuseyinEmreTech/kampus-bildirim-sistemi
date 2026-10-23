// index.html'i giris.js mantığına bağlar.

import { girisFormunuDogrula, girisHataMesaji, girisSonrasiHedef } from './giris.js';
import { api, oturum, sahteMod } from './uygulama.js';

const form = document.querySelector('#giris-formu');
const epostaAlani = document.querySelector('#email');
const parolaAlani = document.querySelector('#parola');
const gonderButonu = document.querySelector('#giris-butonu');
const mesajKutusu = document.querySelector('#giris-mesaji');

document.querySelector('#sahte-notu').hidden = !sahteMod;

// Zaten giriş yapmış görevli formu görmeden listeye geçer.
if (oturum.girisYapildiMi()) {
  const hedef = girisSonrasiHedef(oturum.kullanici());
  if (hedef.tur === 'yonlendir') window.location.replace(hedef.sayfa);
}

form.addEventListener('submit', async (olay) => {
  olay.preventDefault();
  temizle();

  const email = epostaAlani.value.trim();
  const parola = parolaAlani.value;

  const formHatasi = girisFormunuDogrula(email, parola);
  if (formHatasi) {
    const alan = formHatasi.alan === 'email' ? epostaAlani : parolaAlani;
    alan.setAttribute('aria-invalid', 'true');
    alan.focus();
    mesajGoster(formHatasi.mesaj, 'hata');
    return;
  }

  bekliyor(true);
  const sonuc = await api.giris(email, parola);
  bekliyor(false);

  if (!sonuc.ok) {
    parolaAlani.value = '';
    parolaAlani.focus();
    mesajGoster(girisHataMesaji(sonuc.hata), 'hata');
    return;
  }

  const hedef = girisSonrasiHedef(sonuc.veri.user);
  if (hedef.tur === 'yonlendir') {
    window.location.assign(hedef.sayfa);
    return;
  }
  // Öğrenci: listeye erişimi yok; oturumu açık bırakmanın anlamı yok.
  oturum.temizle();
  mesajGoster(hedef.mesaj, 'uyari');
});

function temizle() {
  mesajKutusu.hidden = true;
  mesajKutusu.textContent = '';
  epostaAlani.removeAttribute('aria-invalid');
  parolaAlani.removeAttribute('aria-invalid');
}

function mesajGoster(metin, tur) {
  mesajKutusu.textContent = metin;
  mesajKutusu.dataset.tur = tur;
  mesajKutusu.hidden = false;
}

function bekliyor(durum) {
  gonderButonu.disabled = durum;
  gonderButonu.textContent = durum ? 'Giriş yapılıyor…' : 'Giriş yap';
  form.setAttribute('aria-busy', String(durum));
}
