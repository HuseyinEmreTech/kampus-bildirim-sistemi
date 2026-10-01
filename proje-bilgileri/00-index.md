---
title: Campus Report - Proje Dokümantasyonu
durum: Taslak
son-guncelleme: 2026-09-30
---

# Campus Report: Proje Dokümantasyonu

Kampüs sorun bildirim sistemi. Öğrenci kampüste gördüğü sorunu fotoğraf ve konumla bildirir, görevli üstlenir ve çözer, çözülünce öğrenciye sistemde haber gider.

> **Durum (2 Ekim 2026):** Proje onaylandı, dört kişilik ekip kuruldu. Kod henüz yok; ilk iş [repo iskeleti](planlar/2026-10-02-repo-iskeleti.md).

## Buradan başla

0. Vault nasıl incelenir, kim nereden başlar: [Vault rehberi](README.md)
1. Proje ne ve neden: [Proje kapsamı ve amacı](01-project-scope.md)
2. Bu hafta ne oldu: [Haftalık kayıtlar](haftalik/00-haftalik-index.md)
3. Ekibe yeni katıldıysan: [Başlangıç rehberi](ekip/00-baslangic-rehberi.md)
4. Kim ne yapıyor: [Ekip ve yol haritası](10-ekip-ve-yol-haritasi.md)

## Tasarım dokümanları

| # | Doküman | Ne anlatır | Durum |
| --- | --- | --- | --- |
| 01 | [Proje kapsamı ve amacı](01-project-scope.md) | Problem, amaç, kullanıcılar, akış, kapsam, riskler | Taslak |
| 02 | [Mimari genel bakış](02-architecture-overview.md) | Teknolojiler, katmanlar, ilkeler | Taslak |
| 03 | [Domain tasarımı](03-domain-design.md) | Varlıklar, kurallar, durum akışı | Taslak |
| 04 | [Kullanıcı hikayeleri](04-user-stories.md) | USR 01-07 ve kabul ölçütleri | Taslak |
| 05 | [API tasarımı](05-api-design.md) | Endpoint'ler, örnek istek ve yanıtlar | Taslak |
| 06 | [Güvenlik ve gizlilik](06-security-and-privacy.md) | Riskler ve kararlar | Taslak |
| 07 | [Geliştirme ortamı](07-development-environment.md) | Makine, araçlar, kurulum | Güncel |
| 08 | [Geliştirme süreci](08-development-process.md) | Yöntem, feature branch akışı, kalite, test | Taslak |
| 09 | [Yapay zeka kullanımı](09-ai-usage.md) | Çalışma ilkeleri, review süresi, prompt'lar | Güncel |
| 10 | [Ekip ve yol haritası](10-ekip-ve-yol-haritasi.md) | Ekip, roller, GitHub kullanımı, 15 haftalık plan | Onaylandı |
| 11 | [Kod mimarisi ve korumalar](11-kod-mimarisi-ve-korumalar.md) | Paketler, izinli bağımlılıklar, hatayı önleyen korumalar | Onaylandı |
| - | [Uygulama planı: repo iskeleti](planlar/2026-10-02-repo-iskeleti.md) | Hafta 4'ün ilk işi, adım adım | Onay bekliyor |
| - | [ADR-01: Dart backend ve PostgreSQL](adr/01-dart-backend-postgresql.md) | Geri dönülmesi zor karar | Önerildi |
| - | [ADR-02: Kod kalitesi aracı](adr/02-kalite-araci-sonarqube-cloud.md) | SonarQube Cloud ve yerel analiz kararı, karşılaştırma matrisi | Önerildi |
| - | [ADR şablonu](adr/00-adr-template.md) | ADR yazma kuralı | Şablon |

## İzleme kayıtları

Projede olan biten her şey bu kayıtlarda tutulur.

| Kayıt | Ne tutulur |
| --- | --- |
| [Haftalık kayıtlar](haftalik/00-haftalik-index.md) | Haftanın proje kararları, teknoloji yığını değişiklikleri, gün gün yapılanlar |
| Günlük raporlar ([Hüseyin](ekip/huseyin-emre.md#raporlar), [Ertuğrul](ekip/ertugrul-pekdemir.md#raporlar), [Murat](ekip/murat-yaman.md#raporlar), [Yusuf](ekip/yusuf-ekenel.md#raporlar)) | Her üyenin çalıştığı her gün: ne yaptı, ne yapamadı, ne değişti, neyi neden seçti; katkı raporunun kaynağı |
| [Teknoloji değişiklikleri](kayitlar/teknoloji-degisiklikleri.md) | Yığına giren, değişen ve elenen her şey |
| [Hata kayıtları](kayitlar/hata-kayitlari.md) | Yapay zekanın ve bizim yaptığımız hatalar, düzeltmeler, dersler |
| [SonarQube puanları](kayitlar/sonarqube-puanlari.md) | Tarama puanları ve bulgu çözüm günlüğü |
| [Skill kataloğu](kayitlar/skill-katalogu.md) | Her Skill: ne, neden var, projede neden, durum |
| [Skill, Plugin ve araç kullanım günlüğü](kayitlar/skill-ve-arac-kullanimi.md) | Haftalık: hangi Skill, nerede, neden, sonuç |

## Dokümantasyon kuralları

Bu dokümanların güncel kalması projenin bir parçasıdır.

1. **Aynı PR'da güncelle.** Davranış değişen her PR ilgili dokümanı da değiştirir.
2. **Önce spec, sonra kod.** Kural veya hikaye değişecekse önce doküman güncellenir.
3. **Her PR bir kayıt.** PR şablonu doldurulur: ne yapıldı, test, yapay zeka kullanımı, doküman.
4. **Haftalık dosya güncel tutulur.** Kararlar ve teknoloji değişiklikleri o hafta içinde yazılır.
5. **ADR'lar silinmez.** Karar değişirse eski kaydın durumu "Yerini ADR-NN aldı" olur.
6. **Her dokümanın başında** `durum` ve `son-guncelleme` alanı bulunur.
7. **Dosya adları:** sıra numarası veya tarih + kebab-case, Türkçe karakter yok. İçerik Türkçedir.
8. **Bağlantılar** standart Markdown biçimindedir; GitHub'da ve Obsidian'da aynı çalışır.
9. **Kontrol:** doküman eklendikten sonra Obsidian CLI ile çözülemeyen bağlantılar ve yetim dosyalar taranır.

## Terimler

| Terim | Anlam |
| --- | --- |
| **Report** | Öğrencinin açtığı sorun kaydı |
| **Notification** | Öğrenciye sistemde gösterilen "çözüldü" haberi |
| **Staff** | Bildirimi üstlenip çözebilen görevli |
| **Student** | Sorun bildiren öğrenci |

## Açık kararlar

| Karar | Öneri | Durum |
| --- | --- | --- |
| Backend dili ve veritabanı | Dart (Shelf) ve PostgreSQL | Kabul ([ADR-01](adr/01-dart-backend-postgresql.md)) |
| Takım büyüklüğü ve süre | 4 kişi, 15 ders haftası | Kabul ([ekip](10-ekip-ve-yol-haritasi.md)) |
| Konum alma | GPS; izin yoksa bina listesi | Kabul ([mimari](11-kod-mimarisi-ve-korumalar.md#5-konum)) |
| Çözümde sonuç fotoğrafı | Zorunlu | Kabul |
| Sunum ve teslim tarihleri | Hafta 9 ve 15 varsayımı | Hoca'ya sorulacak |
| Kampüs sınırı koordinatları | Yapılandırma dosyasında dikdörtgen | Açık |
| `OUTSIDE_CAMPUS` HTTP durumu | `422` | Öneri |
| Görevlinin üstlendikleri listesi | `assignee=me` filtresi | Öneri |
| Fotoğraf saklama | Sunucu diski, veritabanında yol | Öneri |
| Hesap oluşturma | İlk sürümde seed veri, kayıt ekranı yok | Öneri |
| Dart için kalite aracı | SonarQube Cloud Free ve yerel `dart analyze` ([ADR-02](adr/02-kalite-araci-sonarqube-cloud.md)) | Hoca görüşü bekleniyor |
| Bilgi grafiği aracı (Graphify) | Kod oluşunca ayrı branch'te denenecek | Değerlendiriliyor |
