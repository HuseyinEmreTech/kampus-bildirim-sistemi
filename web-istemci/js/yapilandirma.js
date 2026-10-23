// Web istemcisinin tüm sabitleri. Sihirli sayı yok: limitler burada adlandırılır.

/** Çekirdek Dart sunucusunun adresi (compose ile yerelde 8080). */
export const API_TABAN_URL = 'http://localhost:8080';

/** 05-api-design: liste varsayılan sayfa boyutu. */
export const VARSAYILAN_SAYFA_BOYUTU = 20;

/** 05-api-design: sunucunun kabul ettiği en büyük sayfa boyutu. */
export const EN_FAZLA_SAYFA_BOYUTU = 100;

/** Oturum bilgisinin tarayıcıda saklandığı anahtar. */
export const OTURUM_ANAHTARI = 'campus.oturum';

/** Giriş ekranı; oturum düşünce buraya dönülür. */
export const GIRIS_SAYFASI = 'index.html';

/** Giriş sonrası açılan liste ekranı. */
export const LISTE_SAYFASI = 'raporlar.html';

/** Liste ekranında seçilebilen sayfa boyutları. */
export const SAYFA_BOYUTU_SECENEKLERI = [10, 20, 50, 100];

/** `?mock=1` ile açılan sahte veri modunun sekme boyunca hatırlandığı anahtar. */
export const SAHTE_MOD_ANAHTARI = 'campus.sahteMod';
