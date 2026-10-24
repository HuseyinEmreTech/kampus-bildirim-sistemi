---
title: Hüseyin Emre - Kişisel Plan
durum: Taslak
son-guncelleme: 2026-10-24
---

# Hüseyin Emre (@HuseyinEmreTech) - Kişisel Plan

**Rol:** Teknik Lider / Domain & Application Owner
**Ana Sorumluluk:** `campus_domain`, `campus_application`, `campus_contracts`, CI/CD, kabul testleri, PR incelemesi, mimari kararlar

## Haftalık Hedefler

### Hafta 3 (28 Eyl - 4 Eki): Kurulum ve Temel
- [ ] Monorepo iskeleti (packages/domain, application, contracts, infrastructure, server, app)
- [ ] GitHub Actions CI: `dart format`, `dart analyze --fatal-infos`, testler, mimari test
- [ ] AGENTS.md, CODEOWNERS, PR template, Issue template
- [ ] `campus_domain`: User entity, Role enum, Guid value object
- [ ] İlk PR: Repo iskeleti + CI çalışıyor

### Hafta 4 (5 - 11 Eki): Domain Çekirdeği
- [ ] `campus_domain`: Report aggregate (Entity), Photo, Location value objects
- [ ] `campus_domain`: Category, ReportStatus, NotificationType enum'lar
- [ ] `campus_domain`: Rule 00-07 implementasyonu (domain seviyesinde doğrulamalar)
- [ ] `campus_application`: ReportService arayüzü, UseCase'ler (Create, Assign, Resolve, List)
- [ ] `campus_contracts`: Request/Response DTO'ları, JSON serileştirme
- [ ] Domain testleri: Rule 00-07 her biri için en az 1 test
- [ ] PR'lar: Her entity/use case ayrı PR (küçük tut)

### Hafta 5 (12 - 18 Eki): Application Katmanı ve Kabul Testleri
- [ ] `campus_application`: ReportCreateUseCase, ReportAssignUseCase, ReportResolveUseCase
- [ ] `campus_application`: ListReportsUseCase (filtreleme, sayfalama)
- [ ] **Kabul testleri yazımı** (Rule 02 yarış durumu, Rule 04 transaction, Rule 05 geçişler)
- [ ] `@Tags(['bekliyor'])` ile işaretli testler → implementation bekler
- [ ] PR incelemesi: Ertuğrul (infrastructure), Çağdaş (server) PR'ları

### Hafta 6 (19 - 25 Eki): Entegrasyon ve Test
- [ ] Infrastructure ile entegrasyon: Repository arayüzleri bağlama
- [ ] Server ile entegrasyon: Endpoint'ler UseCase çağırıyor mu?
- [ ] Hata eşleme: Domain/Application hataları → HTTP status kodları
- [ ] Rule 01, 03, 06, 07 kabul testleri yazımı
- [ ] Kod kalitesi: `dart analyze` sıfır uyarı, test coverage %80+

### Hafta 7 (26 Eki - 1 Kas): Kalite ve Güvenlik
- [ ] SonarQube Cloud kurulumu, Dart taraması
- [ ] Rate limiting, güvenlik başlıkları (server tarafında Çağdaş ile)
- [ ] ADR yazımı: Fotoğraf depolama, Auth stratejisi, Hata eşleme
- [ ] PR review süreleri ölçümü, AI çıktı review süresi
- [ ] 1. Sunum hazırlığı (Hafta 9 varsayım)

### Hafta 8 (2 - 8 Kas): Gerçek API Bağlantısı
- [ ] Flutter app (Yusuf/Fatma) ile API contract testi
- [ ] Yetki testleri: Student/Staff roller için endpoint erişimleri
- [ ] Boş veri, hata durumu, edge case testleri
- [ ] Migration'lar production-ready hale getirme

### Hafta 9 (9 - 15 Kas): 1. Sunum ve SonarQube
- [ ] **1. Sunum** (varsayım): Mimari, domain, test stratejisi
- [ ] SonarQube Cloud ilk tam tarama, quality gate
- [ ] Teknik borç listesi, refactor planı
- [ ] Katkı raporu taslağı (haftalık kayıtlardan)

### Hafta 10 (16 - 22 Kas): Çözüm Fotoğrafı ve Detaylar
- [ ] Resolution photo akışı: Domain rule + Application + Contracts
- [ ] Sayfalama, filtreleme (kategori, durum, tarih aralığı)
- [ ] EXIF temizleme doğrulama (infrastructure test)
- [ ] Performance: N+1 sorgu kontrolü, index kullanımı

### Hafta 11 (23 - 29 Kas): Dağıtım Kararı ve Kalan İşler
- [ ] VPS var mı? → Yoksa yerel demo planı B (README'e yaz)
- [ ] Rate limit fine-tuning, loglama yapılandırması
- [ ] ADR'lar finalize, mimari kararlar dokümante
- [ ] Özellik dondurma hazırlığı (Hafta 12 Pazar)

### Hafta 12 (30 Kas - 6 Ara): Özellik Dondurma
- [ ] **Özellik dondurma** (Pazar 6 Ara) - Yeni feature yok, sadece hata
- [ ] APK build (Android), IPA build (iOS), Web build
- [ ] Deploy denemesi (VPS varsa) / Yerel demo kaydı
- [ ] Release notları, CHANGELOG

### Hafta 13 (7 - 13 Ara): Dokümantasyon ve 2. Sunum
- [ ] README.md final: Kurulum, çalıştırma, mimari, API, deploy
- [ ] ADR'lar tamamlandı, indekslendi
- [ ] **2. Sunum slaytları** (varsayım): Demo, kalite, öğrenilenler
- [ ] Katkı raporları final (herkesin günlük raporlarından)

### Hafta 14 (14 - 20 Ara): Test Haftası - Sadece Hata
- [ ] Sadece hata düzeltme PR'ları
- [ ] Regression testleri çalıştırma
- [ ] Demo senaryoları end-to-end test

### Hafta 15 (21 - 27 Ara): Teslim
- [ ] **Teslim ve 2. Sunum**
- [ ] GitHub Releases: APK, Web URL, Kaynak kod
- [ ] Hoca değerlendirmesi için hazırlık

---

## Kişisel Başarı Kriterleri
- [ ] Tüm domain kuralları test altında (%100 Rule coverage)
- [ ] CI her PR'da yeşil (format, analyze, test, arch test)
- [ ] PR review süresi ortalama < 2 saat
- [ ] Her hafta en az 1 birleşmiş PR (kendi + review ettiği)
- [ ] Kendi yazdığı her kodu anlatabilme (hoca sorduğunda)

## Riskler
- AI review süresi uzarsa → Küçük PR'lar, önbellekli prompt'lar
- Backend darboğazı → Domain/App tek owner, Infrastructure/Server ayrı owner
- VPS yok → Hafta 11'de erken karar, yerel demo kaydı hazırla

---

## 12 Ekim 2026 — SonarQube Cloud entegrasyonu (yapıldı, Hafta 7 işi erken tamamlandı)

Bu, [ADR-02](../adr/02-kalite-araci-sonarqube-cloud.md) kararının (Dart taraması SonarQube Cloud Free'de) uygulanmasıdır. Yerel SonarQube Community Dart'ı taramıyor; bu yüzden CI'da bulut taraması kuruldu.

### Neden
- Dersin beklediği "her commit sonrası kod kalitesi taraması ve bulguların tek tek çözülmesi" alışkanlığını otomatikleştirmek.
- Her push ve PR'da Quality Gate + bulgu raporu; sonuçlar GitHub'da PR check'i olarak görünsün.
- Bulgular [SonarQube puanları](../kayitlar/sonarqube-puanlari.md) dosyasında tutulacak.

### Adım adım ne yapıldı
1. **Proje açılışı:** `sonarcloud.io` → GitHub hesabıyla giriş → repo import (Free plan). Oluşan değerler: organization `huseyinemretech`, project key `HuseyinEmreTech_Yapay-Zeka-Destekli-Yazilim-Gelistirme` (bu ikisi onboarding ekranının verdiği gerçek değerler; tahmin değil).
2. **Token:** Analiz için `SONAR_TOKEN` üretildi ve GitHub repo → Settings → Secrets and variables → Actions → **Repository secrets** alanına eklendi. Token yalnızca burada durur; dosyaya/commit'e girmez.
3. **`sonar-project.properties`** eklendi: projectKey, organization, `sonar.sources` (packages/*/lib), `sonar.tests` (yalnızca gerçekten var olan `test` ve `packages/app/test`), dışlamalar (`*.g.dart`, `*.freezed.dart`, `.dart_tool`, `build`, platform klasörleri).
4. **`.github/workflows/sonar.yml`** eklendi: `actions/checkout` (fetch-depth: 0) → `subosito/flutter-action` (3.47.0) → `flutter pub get` → `SonarSource/sonarqube-scan-action@v8` (`SONAR_TOKEN` ile). Mevcut `ci.yml`'e dokunulmadı.
5. **PR:** Branch `feature/sonarcloud-entegrasyon`, 3 commit (`bdfcddf`, `5b5e1bd`, `7c56af3`) → PR #24.
6. **İlk tarama hatası ve düzeltmesi:** `sonar.tests` içinde repoda **bulunmayan boş klasörler** vardı (`packages/application/test` vb.) → "folder does not exist" hatası. Boş klasörler git'te tutulmadığı için yalnızca var olan test klasörleri bırakıldı. (Ayrıca action `v7 → v8` ve projectKey onboarding değeriyle düzeltildi.)
7. **Yeşil sonuç:** PR #24'te `kontrol`, `sonar` ve `SonarCloud Code Analysis` (Quality Gate Passed, 0 yeni bulgu) başarılı. `main`'e squash ile birleştirildi (birleşme commit'i `89c3659`); `main`'de analiz tekrar çalışıp yeşil oldu.

### Kararlar ve nerede verildi
- **CI tabanlı analiz** (SonarCloud'un otomatik analizi değil): Dart/Flutter analizi `pub get` ve derlemeye ihtiyaç duyar; otomatik analiz bunu yapamaz.
- **SonarQube Cloud Free:** [ADR-02](../adr/02-kalite-araci-sonarqube-cloud.md).
- **`sonarqube-scan-action@v8`:** v3 ve altı Docker tabanlıydı ve `flutter pub get` ile inen bağımlılıklara erişemiyordu; v5+ composite olduğu için tarayıcı, bağımlılıkların olduğu ortamda çalışır.
- **projectKey/organization:** onboarding'in verdiği değerler; elle uydurma yok.
- **test yolları:** yalnızca repoda gerçekten bulunan klasörler.

### Dersler
- **Sır yönetimi:** Token bir kez sohbete düz metin yapıştırıldı; sızmış sayılıp revoke edilip yenisi üretilmeli ve yalnızca GitHub Secrets + SonarCloud tarafında tutulmalı. Repo'ya sır girmiyor ([AGENTS.md](../../AGENTS.md) kuralı).
- **Boş klasör tuzağı:** Git boş klasörleri tutmaz; yol listelerini (`sources`/`tests`) dosya bazlı doğrula.
- **Branch koruması:** `main` en az 1 onay + doğrusal geçmiş istiyor; bu yüzden merge `--squash` ile ve owner bypass'ıyla yapıldı.

### Açık kalanlar
- Coverage (`flutter test --coverage` + `sonar.dart.lcov.reportPaths`), README'ye Quality Gate badge ve branch protection'da `SonarCloud Code Analysis` zorunlu check — planlı, henüz yapılmadı.
- Ekip erişimi: SonarCloud → organization → Members üzerinden üyelerin eklenmesi.
- `analysis_options.yaml`'de commit'lenmemiş yerel değişiklik var (bu işin kapsamı dışında).

## Raporlar

- [2026-10-02](raporlar/huseyin-emre/2026-10-02.md): Ekip kurulumu, `main` koruması, doküman iskeleti
- [2026-10-21](raporlar/huseyin-emre/2026-10-21.md): PR inceleme ve birleştirme, issue güncelleme, doküman/ADR, token kaydı
- [2026-10-24](raporlar/huseyin-emre/2026-10-24.md): PR denetimi (#97-#99), Sonar kapsam düzeltmesi (#100, #102), JS bug düzeltmesi (#103), şablon ve kayıtlar (#101, #104, #107), yerel–bulut karşılaştırması (#108)
