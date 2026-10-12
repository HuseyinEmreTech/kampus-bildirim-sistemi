# Güvenlik Politikası

**Campus Report** — kampüs sorun bildirim sistemi (Flutter istemci + Dart/Shelf sunucu + PostgreSQL 16). Bu depo, Yapay Zeka Destekli Yazılım Geliştirme dersi kapsamında geliştirilen bir **öğrenci projesidir**; ticari veya üretim sistemi değildir. Yine de güvenlik bildirimlerini ciddiye alıyoruz.

## Desteklenen sürümler

| Sürüm | Destek |
| --- | --- |
| `main` dalı (güncel geliştirme) | Evet |
| Eski sürümler / etiketli sürümler | Hayır |

## Güvenlik açığı bildirimi

Lütfen güvenlik açıklarını **herkese açık issue açarak bildirmeyin.** İki yol vardır:

1. **Özel güvenlik bildirimi (tercih edilen).** Bu depoda **Security → Report a vulnerability**. Bildirim gizli kalır ve yalnızca proje ekibi görür.
2. **E-posta:** `huseyinemre.tech@gmail.com` — konu satırına `[GÜVENLİK]` yazın.

### Bildirimde neler bulunmalı

- Açığın türü ve etkilenen bölüm (API ucu, dosya, ekran)
- Adım adım yeniden üretme (mümkünse örnek istek/yanıt)
- Olası etki ve varsa önerilen düzeltme
- İsteğe bağlı: nasıl anılmak istediğiniz

### Süreç

- Bildirimi mümkün olan en kısa sürede (hedefimiz **3 iş günü**) yanıtlar ve değerlendiririz.
- Doğrulanan açıkları, düzeltme yayımlanmadan önce kamuya açıklamayız; sizinle koordinasyonu koruruz.
- Düzeltmeden sonra, isterseniz katkınızı anarız.

## Kapsam

**Kapsam içi:** API uçları, kimlik doğrulama ve yetkilendirme, dosya yükleme/indirme, veritabanı erişimi, mobil/web istemci.

**Kapsam dışı:** Üçüncü taraf hizmetler (SonarQube Cloud, GitHub), sosyal mühendislik, hizmet dışı bırakma (DoS) testleri, otomatik tarayıcı gürültüsü.

## Uyguladığımız güvenlik uygulamaları

- **Sır yönetimi:** Şifre, token ve `.env` repoya girmez (`.gitignore`); bir sır sızarsa ilgili anahtar derhal iptal edilir ve yalnızca GitHub Secrets'ta tutulur.
- **Statik analiz ve kalite:** Her push/PR'da SonarQube Cloud ile Dart analizi; Quality Gate zorunlu kontrol.
- **Sır taraması:** GitHub secret scanning açıktır.
- **Bağımlılıklar:** GitHub Dependabot uyarıları açıktır.
- **Dal koruması:** `main` yalnızca incelenmiş Pull Request ile değişir; doğrudan commit yoktur.

Ayrıntılı güvenlik ve gizlilik notları: [proje-bilgileri/06-security-and-privacy.md](proje-bilgileri/06-security-and-privacy.md). Mimari korumalar: [proje-bilgileri/11-kod-mimarisi-ve-korumalar.md](proje-bilgileri/11-kod-mimarisi-ve-korumalar.md).

## İletişim

Proje ekibi, roller ve GitHub hesapları: [README — Ekip ve çalışma düzeni](README.md).
