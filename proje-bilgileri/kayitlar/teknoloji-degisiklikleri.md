---
title: Teknoloji Değişiklikleri
durum: Güncel
son-guncelleme: 2026-10-02
---

# Teknoloji Değişiklikleri

← [İndeks](../00-index.md)

Projede teknoloji yığınına eklenen, değiştirilen veya elenen her şey burada tarihiyle tutulur. Geri dönülmesi zor olanlar ayrıca [ADR](../adr/00-adr-template.md) olur.

## Güncel yığın

| Konu | Seçim | Durum |
| --- | --- | --- |
| İstemci | Flutter (Dart 3.13.0, Flutter 3.47.0) | Kabul |
| Sunucu | Dart (Shelf) | Kabul ([ADR-01](../adr/01-dart-backend-postgresql.md)) |
| Veritabanı | PostgreSQL 16 | Kabul |
| Repo düzeni | Dart pub workspace, 6 paket, mimari test | Kabul ([korumalar](../11-kod-mimarisi-ve-korumalar.md)) |
| CI | GitHub Actions | Kabul, kurulmadı ([plan](../planlar/2026-10-02-repo-iskeleti.md)) |
| Konum | GPS; izin yoksa bina listesi (Flutter paketi seçilmedi) | Kabul |
| Konteyner | Podman, podman-compose | Kabul |
| Kod kalitesi | Yerelde `dart analyze`, `flutter analyze`, `dart test --coverage`; PR'da SonarQube Cloud Free | Öneri ([ADR-02](../adr/02-kalite-araci-sonarqube-cloud.md)); Cloud denenmedi |
| Dokümantasyon | Markdown, Obsidian vault (`proje-bilgileri`) | Kabul |
| Bilgi grafiği | Graphify | Değerlendiriliyor, kurulmadı |

## Değişiklik günlüğü

| Tarih | Konu | Önce | Sonra | Neden |
| --- | --- | --- | --- | --- |
| 2026-09-25 | Proje türü | Aday havuzu (ders README'sindeki klon proje önerileri, RAG tabanlı bilgi tabanı) | Kampüs sorun bildirim sistemi | Küçük kapsam, çok backend malzemesi (rol yetkisi, durum akışı, dosya yükleme, sayfalama, test) |
| 2026-09-25 | İstemci | Belirsiz | Flutter (Dart) | Hâkim olunan dil ve framework |
| 2026-09-25 | Konteyner | Docker | Podman | Docker kurulu değil; Podman komutları büyük ölçüde aynı, derste izin verildi |
| 2026-09-25 | Veritabanı | Belirsiz | PostgreSQL 16 (öneri) | İlişkisel model ve işlem (transaction) desteği |
| 2026-09-30 | Sunucu | Belirsiz | Dart (Shelf) önerisi | Tek dil; [ADR-01](../adr/01-dart-backend-postgresql.md) |
| 2026-09-30 | Alternatif | - | Firebase değerlendirildi, önerilmedi | Backend mimarisini gizler; Rule 02 ve Rule 04 için güvenlik kuralları ve işlemler gerekir |
| 2026-09-30 | Alternatif | - | Serverpod değerlendirildi, önerilmedi | Çok şeyi gizler; akışı anlamak önceliğimiz |
| 2026-09-30 | Dokümantasyon | Tek tek notlar | Haftalık, commit, hata, SonarQube ve araç kayıtları | Süreci ve kararları izlenebilir tutmak |
| 2026-09-30 | Kod kalitesi aracı | SonarQube (Dart taraması varsayımı) | Dart için `dart analyze`, `flutter analyze` ve kapsam; SonarQube repo düzeyinde | SonarQube Community 26.9.0.129388'de Dart dili yok (0 kural), API ile doğrulandı |
| 2026-09-30 | Kod kalitesi aracı | Yerel SonarQube Community (Dart taraması varsayımı) | Dart taraması için SonarQube Cloud Free önerisi | Araştırma: Dart yalnızca Developer Edition ve Cloud'da; ücretsiz Cloud planı herkese açık projeler için sınırsız ([araştırma](sonarqube-puanlari.md#dart-desteği-araştırması-2026-09-30)) |
| 2026-09-30 | Alternatif kalite araçları | - | Codacy, DeepSource, Codecov, CodeScene, DCM değerlendirildi | Öğrenci e-postası ve SonarQube benzeri araç sorusu; ayrıntı: [araştırma](sonarqube-puanlari.md#öğrenci-hesabı-ve-sonarqube-benzeri-araçlar) |
| 2026-09-30 | Kod kalitesi aracı | Alternatifler ayrı ayrı | Karşılaştırma matrisiyle karar önerisi: SonarQube Cloud Free ve yerel analiz; yerel SonarQube sunucusu kurulmayacak | [ADR-02](../adr/02-kalite-araci-sonarqube-cloud.md) |
| 2026-09-30 | Bilgi grafiği | Yok | Graphify değerlendirmeye alındı | LLM'lerin projeyi daha iyi anlaması; kod oluşunca denenecek |
| 2026-10-02 | Repo düzeni | Tek klasör varsayımı | Dart pub workspace, katman başına paket; Flutter 3.47.0 ile yerelde denendi | Katman ihlalini derleme ve mimari testle engellemek ([korumalar](../11-kod-mimarisi-ve-korumalar.md)) |
| 2026-10-02 | Konum | Yalnızca GPS | GPS; izin yoksa bina listesi | Kullanıcı izin vermezse de bildirim açılabilsin |
| 2026-10-02 | Kayıt sistemi | Commit başına kayıt dosyası ve betik | PR açıklaması kayıt; kişi başına günlük rapor (`ekip/raporlar/`) | 4 kişide ortak indeks dosyası merge çakışması üretir |

## Elenenler

| Seçenek | Neden elendi |
| --- | --- |
| .NET / C# | Kurulu değil; hâkim olunan dil değil |
| Mikroservis, mesaj kuyruğu, önbellek | Ölçek küçük; gereksiz karmaşıklık borcu |
| Firebase, Serverpod | Yukarıda |
