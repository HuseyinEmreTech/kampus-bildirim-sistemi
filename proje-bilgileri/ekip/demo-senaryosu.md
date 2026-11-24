---
title: Demo senaryosu ve elle kabul turu
durum: Taslak
son-guncelleme: 2026-11-15
---

# Demo senaryosu ve elle kabul turu

← [İndeks](../00-index.md) · [Kullanıcı hikayeleri](../04-user-stories.md) · [Test rehberi](test-rehberi.md)

[#181](https://github.com/HuseyinEmreTech/kampus-bildirim-sistemi/issues/181) için prova planı. Mobil APK [#174](https://github.com/HuseyinEmreTech/kampus-bildirim-sistemi/issues/174), görevli web akışı [#177](https://github.com/HuseyinEmreTech/kampus-bildirim-sistemi/issues/177) ile doğrulanacak.

## Hazırlık

- Kerem demo ortamını açar, `/health` yanıtını kontrol eder ve [test rehberine](test-rehberi.md#3-sunucu-ve-demo-verisi) göre `001_ornek.sql` verisini yükler. APK ve web aynı test sunucusuna bağlanır.
- Kerem APK'yı Android telefonda öğrenci olarak, Murat web'i görevli olarak açar. İkinci öğrenci ve ikinci görevli için ayrı oturum kullanılır.
- Öğrenciler `mehmet@ornek.edu` ve `ayse@ornek.edu`. Görevliler `zeynep@ornek.edu` ve `ali@ornek.edu`. Yalnızca test rehberindeki ortak demo parolası kullanılır.
- Bildirim ve çözüm için önceden hazırlanmış iki sahte PNG kullanılır. Uygulama kamera açarsa yalnızca yapay örneği çerçevele. Ekran kaydına kişisel bildirim, dosya, erişim anahtarı veya gerçek kullanıcı verisi girmez.

## 10 dakikalık akış

| Süre | Kim ve nerede | Adım ve beklenen sonuç |
| --- | --- | --- |
| 0:00–1:00 | Kerem, Android | Mehmet ile oturum açar ve öğrenci ekranını gösterir. |
| 1:00–3:00 | Kerem, Android | Konum iznini reddeder, B Blok'u seçer, sahte fotoğraf ve `Demo: koridor lambası yanmıyor` açıklamasıyla bildirim açar. Bildirimlerim ekranında `Yeni` görünür. |
| 3:00–5:00 | Murat, web | Zeynep ile görevli listesini açar, Arıza ve Yeni filtreleriyle bildirimi bulur ve üstlenir. Ayrı oturumda Ali'nin aynı bildirimi üstlenemediğini gösterir. |
| 5:00–7:00 | Murat, web | Zeynep olarak sahte sonuç fotoğrafıyla bildirimi çözer ve not ekler. Kartın durumu `Çözüldü` olur. |
| 7:00–9:00 | Kerem, Android | Mehmet'in listesinde yeni durumu, bildirimi ve okunmamış rozetini gösterir. Detayı açıp sonuç fotoğrafını ve notu gösterir, bildirimi okundu işaretler. |
| 9:00–10:00 | Kerem ve Murat | Sorudan önce demo akışını toparlar. Bağlantı kesildiyse aynı adımdan yedek kaydı oynatır. |

## Yedek ekran kaydı

1. Prova öncesi Android ve tarayıcıda rahatsız etmeyin modunu aç. Sadece demo uygulamasını ve demo tarayıcı penceresini kaydet.
2. Tam akışı bir kez kaydet. İstemciler ayrı kaydedildiyse dosyaları akış sırasıyla `01-ogrenci.mp4`, `02-gorevli.mp4`, `03-sonuc.mp4` diye adlandır.
3. Kayıtların sesini, okunabilirliğini ve kişisel veri içermediğini oynatarak kontrol et. Yerel bir kopyayı çevrimdışı açmayı dene ve sunum günü erişilebilir tut.

## Elle kabul turu

Aşağıdaki kontrolleri sunucuyla bağlı gerçek istemcilerde çalıştır. Her satıra tarih, cihaz/model ve sürüm, geçti/kaldı sonucu ve varsa kanıtı yaz. Kalan her gözlem için ayrı GitHub issue aç ve bağlantısını satıra ekle.

| Hikaye | Kontrol | Tarih | Cihaz | Sonuç / issue |
| --- | --- | --- | --- | --- |
| USR 01 | İzinli GPS ile açma, izin reddinde bina seçimi, bina yoksa engelleme, kampüs dışı konum, eksik ve 5 MB üstü fotoğraf | — | Android | Doğrulanmadı |
| USR 02 | Yeni/Üstlenildi/Çözüldü durumları, boş liste, Ayşe'nin Mehmet'in bildirimini görememesi | — | Android | Doğrulanmadı |
| USR 03 | Sonuç fotoğrafı ve not, yalnızca açana bildirim ve rozet, okundu, boş durum | — | Android | Doğrulanmadı |
| USR 04 | Görevli listesi, sayfalama, kategori/durum filtreleri, kendi üstlendikleri ve boş durum | — | Web | Doğrulanmadı |
| USR 05 | Zeynep üstlenir, öğrenci yeni durumu görür, Ali'nin ikinci isteği reddedilir | — | Web ve Android | Doğrulanmadı |
| USR 06 | Fotoğrafsız çözüm reddedilir, Ali çözemez, Zeynep fotoğraf ve notla çözer | — | Web | Doğrulanmadı |
| USR 07 | Seed hesaplarıyla iki rolün ekranı, yanlış parola hatası, yetkisiz işlem reddi | — | Android ve web | Doğrulanmadı |
