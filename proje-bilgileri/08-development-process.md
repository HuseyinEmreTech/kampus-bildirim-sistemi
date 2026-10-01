---
title: Geliştirme Süreci
durum: Taslak
son-guncelleme: 2026-09-30
---

# Geliştirme Süreci

← [İndeks](00-index.md)

## Yöntem

**Önce spec, sonra küçük iterasyonlar.**

- Kod yazılmadan önce kapsam, mimari ve domain dokümanları hazırlanır ([İndeks](00-index.md)).
- Sonrası haftalık küçük parçalardır: katman katman kod, her parçada test, statik analiz ve Pull Request incelemesi.
- Tek seferde büyük üretim yapılmaz; yapay zekanın ürettiği çıktıyı okuyup doğrulamak süre alır, parçalar küçük tutulur.
- Waterfall değil: "her şey bitince test" adımı, her commit sonrası tarama ve PR akışıyla çelişir.

## Git akışı

**Proje feature branch mantığıyla geliştirilir:** her özellik, düzeltme veya doküman işi kendi branch'inde yapılır, küçük bir Pull Request ile `main`'e birleşir.

- `main` doğrudan değiştirilmez; korumalıdır ve her zaman incelenmiş, çalışır durumdadır.
- Branch adları: `feature/<konu>`, `fix/<konu>`, `docs/<konu>`, `test/<konu>`.
- Bir branch tek konuyu ele alır; bittiğinde PR açılır, incelenir, birleştirilir ve silinir.
- Her PR açıklaması şablonla doldurulur ve kayıt sayılır ([kayıt sistemi](10-ekip-ve-yol-haritasi.md#6-kayıt-sistemi)); GitHub kullanımı ve koruma kuralları: [ekip ve yol haritası](10-ekip-ve-yol-haritasi.md#4-githubda-ne-kullanıyoruz), [kod mimarisi ve korumalar](11-kod-mimarisi-ve-korumalar.md).
- Commit mesajları açıklayıcıdır ve önek taşır: `feat:`, `fix:`, `docs:`, `test:`, `refactor:`.
- Haftalık düzenli commit; toplu son gece push'u yoktur.
- Her Pull Request incelenir; PR açıklaması "ne yaptım, hangi varsayımı yaptım, neyi bilmiyorum" özetini ve doküman güncelleme onayını içerir.

## Kalite

| Konu | Uygulama |
| --- | --- |
| Statik analiz | Her kod commit'inden sonra `dart analyze` ve `flutter analyze`; Dart taraması için SonarQube Cloud (ücretsiz plan) önerilir; yerel Community Dart'ı taramaz ([araştırma](kayitlar/sonarqube-puanlari.md#dart-desteği-araştırması-2026-09-30)) |
| Bulgular | Toplu değil tek tek çözülür; her bulgu için hangi yolun seçildiği kaydedilir |
| 0 referanslı metot | Bırakılmaz; beklenmedik yerde çalışan kod olmaz |
| Karmaşıklık | Bir metot bir görev; iç içe koşul yerine erken çıkış |
| Sabitler | Sihirli sayı yok; limitler sabit veya yapılandırma |
| Pull Request | Başkası okur; PR küçük tutulur |

Tarama puanları ve çözülen bulgular [SonarQube puanları](kayitlar/sonarqube-puanlari.md) dosyasında ve PR açıklamalarında tutulur.

## Test

- **Birim testleri:** domain ve servisler, her kural için.
- **Entegrasyon testi:** gerçek PostgreSQL konteyneriyle, en az bir uçtan uca akış.
- **Yarış durumu testi:** iki görevli aynı anda üstlenmeye çalışır ([Rule 02](03-domain-design.md#kurallar-rules)).
- **Sıfır veri testi:** sistem boşken listeler boş döner ve ekranlar boş durumu gösterir.
- **Adlandırma:** `Metot_Senaryo_BeklenenSonuc`; gövde Arrange, Act, Assert.
- **Geliştirme döngüsü:** Red, Green, Refactor.

## Tamamlanma ölçütü (her PR için)

- [ ] Testler yazıldı ve geçiyor
- [ ] Statik analiz çıktısı eklendi, bulgular çözüldü ya da gerekçelendirildi
- [ ] İlgili doküman güncellendi (ya da gerekmediği yazıldı)
- [ ] Yapay zeka kullanıldıysa [kayıt](09-ai-usage.md) eklendi
- [ ] Gizli bilgi yok

## Kararlar ve borç

- Geri dönülmesi zor kararlar ADR olarak yazılır ([ADR şablonu](adr/00-adr-template.md), [ADR-01](adr/01-dart-backend-postgresql.md)); yapay zekanın yazdığı ADR taslaktır, doğrulanır.
- Bilinen eksikler ve teknik borç, [haftalık kayıtlarda](haftalik/00-haftalik-index.md) açıkça listelenir.
