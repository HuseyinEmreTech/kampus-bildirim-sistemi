---
title: Kullanıcı Hikayeleri
durum: Taslak
son-guncelleme: 2026-10-02
---

# Kullanıcı Hikayeleri

← [İndeks](00-index.md)

Kabul ölçütleri "verilen / olduğunda / o zaman" biçimindedir. Her hikaye en az bir teste karşılık gelir. Kurallar için bkz. [Domain tasarımı](03-domain-design.md).

## Öğrenci

### USR 01: Sorun bildir

Öğrenci olarak kampüste gördüğüm sorunu fotoğrafı ve konumuyla bildirmek istiyorum ki görevli nerede olduğunu bilsin.

- **Verilen** giriş yapmış öğrenci, **olduğunda** fotoğraf, kategori, açıklama ve kampüs içi konumla bildirim gönderirse, **o zaman** bildirim `Yeni` durumunda kaydolur.
- **Verilen** konum izni verilmemiş, **o zaman** uygulama bina listesini gösterir; seçilen binanın konumu kullanılır.
- **Verilen** konum izni verilmemiş ve bina seçilmemiş, **o zaman** bildirim gönderilemez ve nedeni söylenir.
- **Verilen** kampüs dışı konum, **o zaman** bildirim reddedilir ve nedeni söylenir.
- **Verilen** eksik ya da 5 MB'tan büyük fotoğraf, **o zaman** anlaşılır bir hata döner.

### USR 02: Bildirimimin durumunu gör

Öğrenci olarak bildirimimin ilerlemesini görmek istiyorum.

- **Verilen** bildirimlerim var, **o zaman** listede durumlarını (Yeni, Üstlenildi, Çözüldü) görürüm.
- **Verilen** hiç bildirimim yok, **o zaman** "henüz bildirim yok" görürüm.
- Başka bir öğrencinin bildirimini göremem.

### USR 03: Çözüldü bildirimini al

Öğrenci olarak bildirimim çözülünce sistemde bana haber gelmesini istiyorum ki sorunun giderildiğini öğreneyim.

- **Verilen** bildirimim `Cozuldu` oldu, **o zaman** bildirimler listemde "çözüldü" bildirimi görünür ve okunmamış rozeti çıkar.
- Bildirim detayında görevlinin sonuç fotoğrafını ve notunu görürüm.
- Bildirim yalnızca sorunu açan öğrenciye gider.
- Bildirimi okundu işaretleyebilirim.
- Hiç bildirimim yoksa "henüz bildirim yok" görürüm.

## Görevli

### USR 04: Gelen bildirimleri gör

Görevli olarak yeni bildirimleri listelemek istiyorum.

- **O zaman** `Yeni` bildirimleri sayfalı görürüm; kategori ve duruma göre filtreleyebilirim.
- **Verilen** hiç bildirim yok, **o zaman** boş liste ve açıklayıcı bir mesaj görürüm.
- Kendi üstlendiğim bildirimleri ayrıca listeleyebilirim.

### USR 05: "İlgileniyorum" de

Görevli olarak bir bildirimi üstlenmek istiyorum ki başkası aynı işe gitmesin.

- **Verilen** bildirim `Yeni`, **olduğunda** üstlenirsem, **o zaman** `Ustlenildi` olur ve öğrenci durumu görür.
- **Verilen** başka görevli zaten üstlenmiş, **o zaman** istek `409` ile reddedilir.

### USR 06: Çözüldü işaretle

Görevli olarak sorunu çözünce kapatmak istiyorum.

- **Verilen** bildirimi ben üstlendim, **olduğunda** sonuç fotoğrafı ile (ve isteğe bağlı notla) çözüldü işaretlersem, **o zaman** `Cozuldu` olur ve öğrenciye sistemde "çözüldü" bildirimi oluşur.
- **Verilen** sonuç fotoğrafı yok, **o zaman** çözüldü işaretlenemez ve nedeni söylenir.
- Başkasının üstlendiği bildirimi çözüldü işaretleyemem.

## Ortak

### USR 07: Giriş ve rol

Kullanıcı olarak giriş yapıp rolüme uygun ekranları görmek istiyorum.

- Yanlış parola hata verir; rolü olmayan işlem `403` döner.
- İlk sürümde hesaplar örnek veriden (seed) yüklenir; kayıt ekranı yoktur.

## Ekranlar

| Ekran | Rol | Hikaye |
| --- | --- | --- |
| Giriş | Ortak | USR 07 |
| Yeni bildirim | Öğrenci | USR 01 |
| Bildirimlerim | Öğrenci | USR 02 |
| Bildirim detayı | Öğrenci | USR 02 |
| Bildirimler ("çözüldü" haberleri) | Öğrenci | USR 03 |
| Gelen bildirimler | Görevli | USR 04 |
| Görev detayı | Görevli | USR 05, USR 06 |

Her liste ekranında boş, yükleniyor ve hata durumu bulunur.
