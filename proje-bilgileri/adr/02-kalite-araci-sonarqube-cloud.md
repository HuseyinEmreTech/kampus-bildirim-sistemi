---
title: "ADR-02: Kod Kalitesi Aracı, SonarQube Cloud ve Yerel Analiz"
durum: Önerildi
son-guncelleme: 2026-09-30
---

# ADR-02: Kod Kalitesi Aracı, SonarQube Cloud ve Yerel Analiz

← [ADR şablonu](00-adr-template.md) · [ADR-01](01-dart-backend-postgresql.md) · [İndeks](../00-index.md)

## Durum

**Önerildi.** Hocanın "SonarQube Cloud kabul mü, yoksa yerel SonarQube mi bekleniyor?" cevabı bekleniyor.

## Bağlam

Ders, kodun SonarQube ile taranmasını ve bulguların tek tek çözülmesini bir alışkanlık olarak bekliyor. [ADR-01](01-dart-backend-postgresql.md) ile Dart seçildi; yerel **SonarQube Community'de Dart dili yok** (26.9.0.129388'de 0 Dart kuralı, [doğrulama](../kayitlar/sonarqube-puanlari.md#doğrulama-kaydı-2026-09-30)). Bu yüzden Dart kodunu hangi araçla ve nerede tarayacağımıza karar vermek gerekiyor. Bilgiler: [Dart desteği araştırması](../kayitlar/sonarqube-puanlari.md#dart-desteği-araştırması-2026-09-30) ve [öğrenci hesabı ve benzer araçlar](../kayitlar/sonarqube-puanlari.md#öğrenci-hesabı-ve-sonarqube-benzeri-araçlar).

Bağlam kısıtları: geliştirici bir öğrenci; kod GitHub'da (herkese açık); feature branch akışı, PR'lar `main`'e açılır; ölçek küçük; sunucu bakımı istemiyoruz.

## Seçenekler

| Kod | Seçenek | Kısaca |
| --- | --- | --- |
| A | SonarQube Cloud Free | Resmi Dart analizörü, bulutta; herkese açık projeler ücretsiz; yalnızca `main` ve `main`'e PR analizi |
| B | Sonar Developer Edition (deneme lisansı) | Yerelde resmi Dart desteği; süreli lisans, satış süreci |
| C | Community + topluluk eklentisi | 3 haftalık, yıldızsız bağımsız kopya; biz denemedik |
| D | Yerel Community (eklentisiz) | Dart yok; yalnızca secrets, YAML, Docker |
| E | Codacy | Dart için `dartanalyzer` sarmalı; açık kaynak ücretsiz |
| F | DeepSource | Dart için `dart-analyze` topluluk analizörü, CI'da SARIF ile |
| H | CodeScene | Kod sağlığı; Dart desteği doğrulanmadı |
| I | DCM (Dart Code Metrics) | Dart'a özel, ücretsiz sürümü kaldırıldı |
| J | `dart analyze`, `flutter analyze`, `dart test --coverage` (yerel) | Resmi Dart araçları; puan ve kalite kapısı yok |

Codecov karşılaştırmaya girmedi: yalnızca kapsam takibi yapar, tarama aracı değildir; tamamlayıcı olarak ele alındı.

## Karşılaştırma

Her ölçüt 0 ile 5 arasında puanlandı; ağırlıklar benim yargımdır. Kanıtı sağlam olmayan (doğrulanmamış) iddialar temkinli puanlandı.

| Ölçüt | Ağırlık |
| --- | --- |
| Dart analizi (resmi, güvenilir) | 5 |
| Hocanın beklentisi (SonarQube ailesi) | 4 |
| Maliyet (öğrenci için ücretsiz) | 4 |
| Dart kapsam (coverage) | 3 |
| Kurulum ve bakım yükü | 3 |
| Güven ve olgunluk | 4 |
| Feature branch ve PR akışına uyum | 3 |

| Seçenek | Dart | Hoca | Maliyet | Kapsam | Kurulum | Güven | Akış | **Toplam (100 üzerinden)** |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| **A** SonarQube Cloud Free | 5 | 5 | 5 | 5 | 4 | 5 | 3 | **93,1** |
| **J** Yerel Dart araçları | 4 | 1 | 5 | 4 | 5 | 5 | 5 | **81,5** |
| **B** Developer deneme | 5 | 5 | 2 | 5 | 2 | 4 | 4 | **78,5** |
| **E** Codacy | 3 | 1 | 4 | 1 | 4 | 4 | 3 | **57,7** |
| **C** Community + eklenti | 3 | 3 | 5 | 3 | 2 | 1 | 2 | **55,4** |
| **F** DeepSource | 3 | 1 | 4 | 1 | 3 | 4 | 3 | **55,4** |
| **D** Yerel Community | 0 | 4 | 5 | 0 | 3 | 5 | 2 | **54,6** |
| **I** DCM | 4 | 1 | 1 | 0 | 3 | 4 | 4 | **50,0** |
| **H** CodeScene | 1 | 1 | 4 | 0 | 4 | 3 | 3 | **44,6** |

### Puanların gerekçesi (önemli olanlar)

- **A, Dart 5 / Kapsam 5:** resmi Dart analizörü, Dart 3 ile 3.13 tam destekli; LCOV ile kapsam belgelenmiş. **Akış 3:** ücretsiz planda yalnızca ana dal ve hedefi ana dal olan PR analiz edilir; feature branch'in kendisi taranmaz (PR açılınca taranır).
- **J, Hoca 1:** SonarQube değil; puan ve kalite kapısı üretmez. Ama resmi araçlar, sıfır kurulum, her yerde çalışır.
- **B, Maliyet 2 / Kurulum 2:** ücretsiz değerlendirme lisansı süreli ve satış temsilcisi sürecine bağlı; dönem boyunca yetmeyebilir; sunucu ve lisans bakımı gerekir.
- **C, Güven 1:** 8 Eylül 2026'da başlamış, 0 yıldız, 0 fork, bağımsız kopya; derste "harici paketin güvenilir ve güncel olduğundan emin ol" ilkesine aykırı; biz denemedik. Özgün eklenti SonarQube 2025.1'de yüklenememiş.
- **E ve F, Kapsam 1:** Dart için kapsam desteği belgelerde doğrulanmadı. İkisi de temelde `dartanalyzer` çıktısını gösterir; yerelde `dart analyze` ile aynı bulguyu bulut arayüzünde sunar.
- **D, Dart 0:** yerelde doğrulandı.
- **I, Maliyet 1:** ücretsiz sürüm 2023'te kaldırıldı.
- **H:** Dart desteği doğrulanmadı, puan temkinli.

### Duyarlılık: ağırlıklar değişirse sıralama nasıl değişir

| Senaryo | İlk üç |
| --- | --- |
| Ana ağırlıklar | A 93,1, J 81,5, B 78,5 |
| Hoca beklentisi ağırlığı 0 | **J 92,7**, A 91,8, B 74,5 |
| Maliyet ağırlığı iki katı | A 94,0, J 84,0, B 73,3 |
| Kurulum ve güven ağırlığı iki katı | A 92,7, J 85,5, B 75,2 |
| Tüm ağırlıklar eşit | A 91,4, J 82,9, B 77,1 |

A ve J her senaryoda ilk ikidedir; hocanın beklentisini tamamen yok sayarsak J, A'nın çok az önüne geçer. Yani **iki seçeneğin birlikte kullanılması** her durumda mantıklıdır.

## Karar (öneri)

**A ve J birlikte:**

1. **Yerelde (her commit):** `dart analyze`, `flutter analyze`, `dart test --coverage`. Hızlı geri bildirim, kurulum yok.
2. **PR'da:** SonarQube Cloud Free ile Dart taraması, kapsam ve kalite kapısı; puanlar [SonarQube puanları](../kayitlar/sonarqube-puanlari.md) dosyasına yazılır.
3. **Yerel SonarQube sunucusu kurulmaz.** Community Dart'ı taramıyor; secrets taraması Cloud'da mevcut. Sunucu bakımı gereksiz karmaşıklıktır (proje bağlamı: ölçek küçük).
4. **Codecov** kapsam rozeti için isteğe bağlı bir ekstradır (GitHub Student Developer Pack); kararı kapsam raporu oluşunca verilir.
5. **Yedek plan:** Cloud'un ücretsiz plan koşulları değişir ya da uygun olmazsa J ile devam edilir ve Developer deneme lisansı (B) değerlendirilir.

## Sonuçlar

### Avantajlar

- Hocanın beklediği araç ailesi (SonarQube) ve resmi Dart analizi.
- Sunucu, lisans ve eklenti bakımı yok.
- Yerel analiz her yerde çalışır ve Cloud'a bağımlılığı azaltır.
- Feature branch akışıyla uyumlu: PR'lar `main`'e açılıyor, Cloud'da PR analizi çalışır.

### Değiş tokuşlar

- Kod Sonar'ın bulut hizmetine gider (kod zaten herkese açık; kod reposu özel olursa 50.000 satır sınırı var).
- Ücretsiz planda feature branch'in kendisi taranmaz; yalnızca `main` ve `main`'e PR. Branch içi erken geri bildirim yerel analizle sağlanır.
- Ücretsiz plan koşulları değişebilir (ücretsiz katman duyurusu Aralık 2024 tarihli).
- Yerel SonarQube ile "kendi sunucumda çalıştırdım" hikayesi kaybolur; ama ders SonarQube'un kullanımını, alışkanlığını ve bulguların çözümünü ölçüyor.

## Doğrulanmayanlar

- Cloud'un ücretsiz planı bu repo için kurulup Dart taramasının çalıştığı (kod olmadığı için denenemedi).
- Codecov, CodeScene ve Codacy'nin Dart kapsam desteği.
- `.edu` e-postasının GitHub Student Developer Pack doğrulamasını geçeceği.

## Açık sorular

- Hoca: SonarQube Cloud (ücretsiz plan) kabul mü, yoksa yerel SonarQube mi bekleniyor?

## Değişiklik geçmişi

| Tarih | Değişiklik |
| --- | --- |
| 2026-09-30 | İlk taslak, durum: Önerildi |
