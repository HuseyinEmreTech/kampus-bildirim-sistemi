---
title: SonarQube Puanları ve Bulgu Çözüm Günlüğü
durum: Güncel
son-guncelleme: 2026-09-30
---

# SonarQube Puanları ve Bulgu Çözüm Günlüğü

← [İndeks](../00-index.md)

Her kod commit'inden sonra tarama yapılır; sonuçlar ve çözülen bulgular burada tutulur. **Henüz kod olmadığı için tarama yapılmadı ve tabloda değer yoktur; değerler uydurulmaz.**

## Araç durumu

| Araç | Durum |
| --- | --- |
| SonarQube (`http://localhost:9005`) | **Doğrulandı (2026-09-30):** `sonarqube:community` 26.9.0.129388 konteyneri yaklaşık 30 saniyede `UP` oldu, arayüz `200` döndü; deneme sonrası konteyner silindi |
| SonarQube'un Dart desteği | **Community'de yok** (yerelde doğrulandı). **Developer Edition ve SonarQube Cloud'da var**; ücretsiz Cloud planı önerildi (aşağıdaki araştırma) |
| `dart analyze`, `flutter analyze` | Yedek: kod oluşunca her commit'te çalıştırılır |
| Test kapsamı (coverage) | Test yazılınca ölçülür |

## Doğrulama kaydı (2026-09-30)

Yöntem: `podman run -d -p 127.0.0.1:9005:9000 -e SONAR_ES_BOOTSTRAP_CHECKS_DISABLE=true docker.io/library/sonarqube:community`; durum `/api/system/status` ile beklendi, sonra API sorgulandı.

| Kontrol | Sonuç |
| --- | --- |
| Sürüm ve durum | 26.9.0.129388, `STARTING` sonra `UP` (yaklaşık 30 saniye) |
| Arayüz | `http://127.0.0.1:9005/` → HTTP 200 |
| Dart dili (`/api/languages/list`) | Yok |
| Dart kuralları (`/api/rules/search?languages=dart`) | 0 kural |
| Kurulu eklentiler | `cayc`, `csharp`, `flex`, `go`, `iac`, `jacoco`, `java`, `javascript`, `javasymbolicexecution`, `kotlin`, `php`, `python`, `ruby`, `rust`, `sonarscala`, `text`, `vbnet`, `web`, `xml` |
| Desteklenen diller | `cs`, `css`, `docker`, `go`, `java`, `js`, `json`, `jsp`, `kotlin`, `php`, `py`, `ruby`, `rust`, `scala`, `secrets`, `terraform`, `text`, `ts`, `vbnet`, `web`, `xml`, `yaml` ve bulut şablon dilleri |
| Not | Konteyner gömülü H2 veritabanıyla çalıştı; bu yalnızca değerlendirme içindir. Kalıcı kullanım için PostgreSQL destekli compose gerekir |

### Sonuç (yerel doğrulama)

SonarQube Community yerelde çalışıyor ama **Dart dilini taramıyor**. Yerelde yalnızca `secrets`, `docker`, `yaml`, `json` ve `text` taraması yapabilir. Dart için seçenekler aşağıdaki araştırmada.

## Dart desteği araştırması (2026-09-30)

Soru: Dart/Flutter kodunu SonarQube ile nasıl tarayabiliriz? Bilgiler resmi Sonar dokümanlarından ve Sonar topluluk forumundan alındı; erişim tarihi 30 Eylül 2026.

### Bulgular

| # | Bulgu | Kaynak |
| --- | --- | --- |
| 1 | **Dart analizi Community sürümünde yok.** Sonar çalışanı 8 Kasım 2024'te: "Şimdilik Dart analizini Community Build'e getirme planımız yok" | [Sonar Community forumu](https://community.sonarsource.com/t/dart-flutter-support-availability-in-sonarqube-community-edition/130038) |
| 2 | Dart analizi **Developer Edition** ve üzeri ile **SonarQube Cloud**'da var | Aynı forum ve [Sonar duyurusu](https://www.sonarsource.com/blog/announcing-sonar-support-for-dart-elevate-your-code-quality/) |
| 3 | Dart 3 ile 3.13 arası **tam destekli**, Dart 2 destekli. Bizim sürümümüz Dart 3.13.0 | [SonarQube Cloud Dart dokümanı](https://docs.sonarsource.com/sonarqube-cloud/analyzing-source-code/languages/dart) |
| 4 | Analizden önce `flutter pub get` / `dart pub get` ve **tam başarılı bir derleme** önerilir; yoksa sonuçlar eksik olabilir. `Generated` yorumu olan dosyalar varsayılan olarak yok sayılır | Aynı doküman |
| 5 | **Kapsam:** LCOV raporu, `sonar.dart.lcov.reportPaths=coverage/lcov.info`; Flutter için `flutter test --coverage`, saf Dart için `dart pub global run coverage:test_with_coverage` | [Dart test coverage](https://docs.sonarsource.com/sonarqube-server/analyzing-source-code/test-coverage/dart-test-coverage) |
| 6 | **SonarQube Cloud ücretsiz plan:** herkese açık projeler sınırsız sayıda ve boyutta; özel projeler en fazla 50.000 satır; en fazla 5 kişi; **yalnızca ana dal analizi** ve **hedefi ana dal olan Pull Request analizi**; Dart destekleniyor | [Abonelik planları](https://docs.sonarsource.com/sonarqube-cloud/administering-sonarcloud/managing-subscription/subscription-plans), [ücretsiz katman duyurusu (Aralık 2024)](https://www.sonarsource.com/blog/the-new-sonarqube-free-tier-is-here/) |
| 7 | **Topluluk eklentisi:** özgün `insideapp-oss/sonar-flutter` SonarQube 7.9+ için yazılmış; SonarQube 2025.1'de eklentinin yüklenemediği bildirilmiş ([tartışma #248](https://github.com/insideapp-oss/sonar-flutter/discussions/248)) | GitHub |
| 8 | `lenerson/sonar-flutter`, Community Build 26.x için "modernize edilmiş" bağımsız bir kopya (`sonar-plugin-api 13.8.0.4399`, LGPL-3.0); **8 Eylül 2026'da başlatılmış, 0 yıldız, 0 fork**, orijinal geliştiricilerle ilgisi yok | [GitHub](https://github.com/lenerson/sonar-flutter) |
| 9 | Developer Edition için **ücretsiz değerlendirme lisansı** isteği var (satış temsilcisi aktive eder); öğrenci lisansı hakkında bir bilgi bulunamadı | [Sonar deneme sayfası](https://www.sonarsource.com/products/sonarqube/free-trial/) |

### Seçenekler

| Seçenek | Artı | Eksi | Güven |
| --- | --- | --- | --- |
| **A. SonarQube Cloud Free** | Resmi Dart desteği; kapsam LCOV ile; bizim repo herkese açık olduğu için ücretsiz; PR'lar `main`'e açıldığı için PR analizi uygun; hocanın istediği "SonarQube" | Bulut hizmeti (kod Sonar'a gider, kod zaten herkese açık); yalnızca `main` ve `main`'e PR analiz edilir | Yüksek (resmi dokümanlar) |
| B. Developer Edition deneme lisansı | Yerelde, Podman ile, resmi Dart desteği | Süreli; satış temsilcisi süreci; dönem boyunca yetmeyebilir | Orta |
| C. Topluluk eklentisi (`lenerson` kopyası) | Yerelde, Community ile Dart | 3 haftalık, yıldızsız bağımsız kopya; derste "harici paketin güvenilir ve güncel olduğundan emin ol" ilkesine aykırı risk; biz denemedik | Düşük |
| D. Yalnızca `dart analyze`, `flutter analyze`, `dart test --coverage` | Kurulum yok, hızlı | SonarQube puanı yok; hocanın alışkanlık beklentisi karşılanmaz | Yüksek (ama beklentiyi tam karşılamaz) |

### Öğrenci hesabı ve SonarQube benzeri araçlar

Soru: Öğrenci (edu) e-postasıyla kullanılabilecek, SonarQube'a benzer ve Dart destekleyen bir araç var mı? Bulgular (erişim: 30 Eylül 2026):

| Araç | Ne yapar | Dart | Öğrenci / ücretsiz durum | Not |
| --- | --- | --- | --- | --- |
| **SonarQube Cloud Free** | SonarQube'un bulut sürümü: kod kalitesi, güvenlik, kapsam, kalite kapısı | Var | Öğrenci hesabı gerekmez; herkese açık projeler ücretsiz ([plan](https://docs.sonarsource.com/sonarqube-cloud/administering-sonarcloud/managing-subscription/subscription-plans)) | Hocanın kullandığı araçla aynı ürün ailesi |
| **Codacy** | Kalite platformu | Var (`dartanalyzer`, `flutter_lints`, `lints` paketleri) ([dokümantasyon](https://docs.codacy.com/getting-started/supported-languages-and-tools/)) | Açık kaynak projeler için ücretsiz; öğrenciye özel indirim bulunamadı | Dart taraması `dartanalyzer` kuralları; kapsam desteği Dart için doğrulanmadı |
| **DeepSource** | Kod inceleme ve analiz | Topluluk analizörü olarak `dart-analyze` ([dokümantasyon](https://docs.deepsource.com/docs/languages/community)); CI'da çalışır, SARIF gönderir | Açık kaynak için ücretsiz; Ocak 2020'de GitHub Student Pack teklifi duyurulmuş ([duyuru](https://deepsource.com/blog/deepsource-gh-education)) ama **şu anki paket sayfasında görünmedi** | Öğrenci teklifinin sürdüğü doğrulanmadı |
| **Codecov** | Kapsam takibi ve rozeti | LCOV ile Dart kapsamı için uygun (doğrulanmadı) | **GitHub Student Developer Pack:** "herkese açık ve özel depolarda ücretsiz erişim" ([paket](https://education.github.com/pack)) | Kalite değil kapsam aracı |
| **CodeScene** | Kod sağlığı ve davranışsal analiz | Dart desteği doğrulanmadı | **GitHub Student Developer Pack:** özel GitHub depoları için ücretsiz öğrenci hesabı | Denemek için değerli ama Dart bilinmiyor |
| JetBrains (öğrenci lisansı) | IDE'ler | Kodlama aracı | **GitHub Student Developer Pack:** yıllık yenilenen ücretsiz abonelik | Qodana (kalite aracı) ve Dart desteği doğrulanmadı |
| DCM (Dart Code Metrics) | Dart'a özel kalite ve metrik aracı | Var | **Ücretsiz sürümü kaldırıldı**, yalnızca ücretli ([duyuru](https://dcm.dev/blog/2023/06/06/announcing-dcm-free-version-sunset/)) | Öğrenci indirimi bilgisi bulunamadı |

**Öğrenci e-postasının kazandırdığı:** GitHub Student Developer Pack'e (GitHub Education üzerinden doğrulanmış öğrenci durumuyla) başvurulabilir: GitHub Pro, Codecov, CodeScene, JetBrains vb. Sunulan teklifler değişebilir; başvuru sırasında kontrol edilmeli. Bir `.edu` e-postasının paketi otomatik açacağı garanti değildir, GitHub'ın doğrulaması gerekir. Sonar için öğrenci hesabına gerek yok.

**Değerlendirme:** Codacy ve DeepSource Dart için çoğunlukla `dartanalyzer` kurallarını sarar; yani yerelde `dart analyze` ile aynı şeyi bulut arayüzünde gösterirler. SonarQube'un Dart analizörü Sonar'ın kendi kural setidir ve hocanın kullandığı ürün ailesidir. Bu yüzden **SonarQube Cloud birincil, yerel `dart analyze` tamamlayıcı**; **Codecov** kapsam rozeti için isteğe bağlı bir ekstra olabilir.

### Karar (öneri)

Karşılaştırma matrisi ve gerekçeler: [ADR-02](../adr/02-kalite-araci-sonarqube-cloud.md).

**A + D birlikte (isteğe bağlı: Codecov ile kapsam rozeti):** Yerelde her commit'te `dart analyze`, `flutter analyze` ve `dart test --coverage`; kod reposu GitHub'da açılınca **SonarQube Cloud Free** ile Dart taraması ve kapsam. Yerel Community sunucusu yalnızca `secrets`, `docker`, `yaml` taraması için kalır (isteğe bağlı).

- Hocaya sorulacak: SonarQube Cloud kabul mü, yoksa yerel SonarQube mu bekleniyor?
- Doğrulanmadı: Cloud'un ücretsiz planı bu repo için gerçekten kurulup Dart taramasının çalıştığı; kod olmadığı için henüz denenemez.
- Kod reposu açılınca ilk iş: Cloud'da projeyi bağla, boş `sonar-project.properties` ile taramayı doğrula.

## Ölçülen metrikler

| Metrik | Anlam |
| --- | --- |
| Bug | Yanlış çalışmaya yol açabilecek hata |
| Vulnerability | Güvenlik açığı (ör. SQL Injection) |
| Security Hotspot | Gözden geçirilmesi gereken güvenlik riski |
| Code Smell | Bakımı zorlaştıran kötü koku (ör. sihirli sayı, uzun parametre listesi) |
| Cognitive Complexity | Kodun anlaşılma zorluğu (iç içe koşullar artırır) |
| Coverage | Testlerin çalıştırdığı kod yüzdesi |
| Duplication | Tekrarlanan kod yüzdesi |
| Teknik borç | Bulguları düzeltmek için tahmini süre |

## Tarama puanları

| Tarih | Commit | Araç | Bug | Vulnerability | Hotspot | Code Smell | Coverage | Duplication | Teknik borç | Not |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| | | | | | | | | | | Henüz tarama yok |

## Bulgu çözüm günlüğü

Bulgular toplu değil tek tek çözülür. Her bulgu için hangi yolun seçildiği kaydedilir: **kendim çözdüm**, **yapay zekaya anlattırdım ve kendim çözdüm**, **yapay zeka çözdü ve inceledim**.

| Tarih | Commit | Kural | Dosya | Yol | Süre | Ne öğrendim |
| --- | --- | --- | --- | --- | --- | --- |
| | | | | | | |

## Özet (her hafta güncellenir)

| Hafta | Yeni bulgu | Çözülen | Kalan | Coverage |
| --- | --- | --- | --- | --- |
| 3 | 0 | 0 | 0 | - |
