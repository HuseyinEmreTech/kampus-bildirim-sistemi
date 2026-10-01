---
title: "Plan: Yusuf Ekenel"
durum: Güncel
son-guncelleme: 2026-10-02
---

# Plan: Yusuf Ekenel (uygulama ve test)

← [Ekip ve yol haritası](../10-ekip-ve-yol-haritasi.md) · [Başlangıç rehberi](00-baslangic-rehberi.md)

**Sorumluluk:** Test senaryoları ve sahte veri (projenin "kullanıcı gözü"); Flutter'da **öğrenci ekranları** (giriş, bildirimlerim, bildirim detayı, çözüldü haberleri); test haftasında elle test turu.

**Neden böyle başlıyor:** İlk iki hafta kod yazmadan projeye gerçek katkı veriyorsun (test senaryoları ve sahte veri herkesin kullandığı şeyler), bu sürede Dart ve Git öğreniyorsun. Hafta 5'ten itibaren her hafta bir ekran; ekranlar önce **sahte veriyle** yapılıyor, yani sunucuyu beklemiyorsun ve bir şeyi bozma ihtimalin yok.

**Dokunmayacağın yerler:** `packages/app` dışındaki tüm kod klasörleri. `packages/app` içinde de yalnızca issue'da yazan dosyalar.

**Hocanın sorabileceği:** "Bu ekranda veri nereden geliyor?", "Liste boşken ne görünüyor?", "Hangi testleri yaptın?" Her ekranın PR'ına bu üç sorunun cevabını yaz.

## Öğrenme yolu (hafta 3-4, günde 1 saat)

1. Git: [Pro Git kitabı, 1-3. bölümler](https://git-scm.com/book/tr/v2) (Türkçe). Hedef: `clone`, `switch -c`, `add`, `commit`, `push`, `pull` komutlarını açıklayabilmek.
2. Dart: [dart.dev/language](https://dart.dev/language): değişkenler, fonksiyonlar, sınıflar, listeler, `Future` ve `async`.
3. Flutter: [docs.flutter.dev, "Your first Flutter app"](https://docs.flutter.dev/get-started/codelab). Hedef: `StatelessWidget`, `StatefulWidget`, `Column`, `ListView`, `TextField`, `ElevatedButton`.
4. Yapay zekayı **öğretmen** olarak kullan: "Bu kodu satır satır açıkla", "Bu hata ne demek?" Öğrenme alıştırmalarını repoya koyma, kendi bilgisayarında tut.

## Haftalık plan

### Hafta 3 (28 Eyl - 4 Eki)
- Kurulum ([rehber](00-baslangic-rehberi.md#2-kurulum)), `flutter doctor`.
- **İlk PR:** [şablonla](../Templates/gunluk-rapor.md) ilk günlük raporun (`raporlar/yusuf-ekenel/`) ve bu dosyadaki Raporlar listesine bağlantısı. Amaç Git akışını bir kez baştan sona yaşamak.

### Hafta 4 (5 - 11 Eki): test senaryoları ve sahte veri
- `proje-bilgileri/test-senaryolari.md`: her kullanıcı hikayesi (USR 01-07) için elle test adımları. Biçim: "Ön koşul / Adımlar / Beklenen sonuç". En az 3 senaryo her hikayede: normal yol, hatalı giriş, boş durum.
- Sahte veri listesi (Ertuğrul'un seed'i için): 2 öğrenci, 2 görevli (sahte ad, `@ornek.edu` e-posta), 3 örnek bildirim açıklaması. Gerçek kişi yok.

### Hafta 5 (12 - 18 Eki): ilk ekran
- **Giriş ekranı** (`packages/app/lib/screens/login_screen.dart`): e-posta ve parola alanı, "Giriş" düğmesi, boş alan uyarısı. Sahte veri: düğmeye basınca öğrenci ana sayfasına geçer.
- Widget testi: alanlar boşken düğmeye basınca uyarı görünür.

### Hafta 6 (19 - 25 Eki)
- **Bildirimlerim ekranı**: sahte listeden bildirimleri durum rozetleriyle (Yeni, Üstlenildi, Çözüldü) göster; liste boşsa "Henüz bildirim yok".
- Widget testi: boş liste mesajı ve 3 elemanlı liste.

### Hafta 7 (26 Eki - 1 Kas)
- **Çözüldü haberleri ekranı** ve okunmamış rozeti (sayı); dokununca okundu olur (sahte veri).
- Widget testi: okunmamış sayısı doğru.

### Hafta 8 (2 - 8 Kas)
- **Bildirim detay ekranı**: fotoğraf, kategori, açıklama, yer, durum geçmişi; çözüldüyse sonuç fotoğrafı.
- Ekranlarını gerçek API'ye bağlama (Hüseyin'in `ApiClient`'ı ile, eşli çalışma).
- Hafta 4'teki test senaryolarını gerçek uygulamada ilk kez dene; uymayanlar için issue aç.

### Hafta 9 (9 - 15 Kas): 1. sunum
- Demo senaryosunu yaz ve prova et (öğrenci tarafı); ekran görüntüleri.

### Hafta 10 (16 - 22 Kas)
- Öğrenci ekranlarında yükleniyor, boş ve hata durumları (ağ yok, oturum düştü).

### Hafta 11 (23 - 29 Kas)
- Tüm ekranlarda Türkçe metin ve yazım kontrolü; düğme ve alan etiketlerinin tutarlılığı.

### Hafta 12 (30 Kas - 6 Ara)
- Test senaryolarını özellik dondurma sonrasına göre güncelle.

### Hafta 13 (7 - 13 Ara)
- README için ekran görüntüleri ve kısa kullanım kılavuzu (öğrenci ve görevli için).

### Hafta 14 (14 - 20 Ara): test haftası
- **Elle test turunun sahibi sensin:** bütün senaryoları APK üzerinde çalıştır, sonucu `test-senaryolari.md` içine "Geçti / Kaldı" olarak yaz; her "Kaldı" bir issue.

### Hafta 15 (21 - 27 Ara): teslim
- Katkı raporu, sunumdaki kendi bölümün (kullanıcı akışı ve test).

## Raporlar

Çalıştığın **her gün** için bir rapor: `ekip/raporlar/yusuf-ekenel/YYYY-AA-GG.md`. Şablon: [günlük rapor şablonu](../Templates/gunluk-rapor.md). Rapor o günün iş branch'inde, işin PR'ıyla birlikte girer; PR açılmayan günün raporu bir sonraki PR'a eklenir. Yalnızca kendi klasörüne yaz. Dönem sonundaki katkı raporun bu raporlardan derlenir.

Yeni rapor ekleyince bu listeye bir satır ekle (en yeni üstte):

- (İlk raporun hafta 3'te buraya eklenecek.)
