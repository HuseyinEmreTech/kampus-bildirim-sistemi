---
title: Emir Kerem Çakıcı - Kişisel Plan
durum: Taslak
son-guncelleme: 2026-11-01
---

# Emir Kerem Çakıcı - Kişisel Plan

> **Güncel görevler (1 Kasım 2026):** [Kalan işler planı](../planlar/2026-11-01-kalan-isler.md) ve `gh issue list --assignee KeremC23`. Son tarih yok; sıra bağımlılığa göre. Bu dosyadaki haftalık hedefler geçmiş kayıttır.


**Rol:** Esnek Destek / Test & Kalite / Yardımcı Geliştirici
**Ana Sorumluluk:** Takıma göre esnek - Test yazımı, hata düzeltme, dokümantasyon, küçük feature'lar

> **Not:** GitHub kullanıcı adı (`KeremC23`) ve beceri seti netleşince bu plan güncellenecek. İlk 2 hafta öğrenme ve takıma entegrasyon.
> **Önemli:** Bu rol/dağıtım öneridir. **Beğenmezsen değiştiririz** - Hüseyin Emre ile konuşup eline uygun, öğrenmek istediğin alana çeviririz (mobil, backend, web, infra, tamamen test, vs.).

## Haftalık Hedefler

### Hafta 3-4 (Geçmiş): Kurulum ve Öğrenme
- [ ] Flutter/Dart kurulum, projeyi çalıştırma
- [ ] Repository klonlama, branch oluşturma, PR açma öğrenme
- [ ] AGENTS.md, proje dokümanları okuma
- [ ] Hüseyin Emre ile pair programming (1-2 saat)

### Hafta 5 (12 - 18 Eki): **Hafta 5 - Bugün Başlangıç (12 Eki Pazartesi)**
- [ ] **Görev**: Test yazımı - Domain/Application kabul testlerini yeşile çevirme
- [ ] **Öğrenme**: `campus_domain` testleri, Rule 02/04/05 test senaryoları
- [ ] **Branch**: `test/week5-rule02-race-condition`
- [ ] **Commit planı**:
  - `test(domain): rule02 assign race condition test`
  - `test(application): rule04 resolve requires photo test`

### Hafta 6 (19 - 25 Eki): Entegrasyon Testleri
- [ ] **Görev**: Infrastructure/Server entegrasyon testleri
- [ ] Testcontainers ile PostgreSQL test DB kurulumu
- [ ] RepositoryImpl testleri (Ertuğrul ile pair)
- [ ] **Branch**: `test/week6-integration-repo`
- [ ] **Commit planı**:
  - `test(infrastructure): report repository integration tests`
  - `test(server): auth endpoint integration tests`

### Hafta 7 (26 Eki - 1 Kas): E2E ve Contract Testleri
- [ ] **Görev**: API contract testleri (Schemathesis/Pact benzeri)
- [ ] Flutter integration test'leri (Yusuf/Fatma ile)
- [ ] **Branch**: `test/week7-e2e-contract`
- [ ] **Commit planı**:
  - `test(contracts): api contract validation`
  - `test(app): e2e student report flow`

### Hafta 8 (2 - 8 Kas): Performans ve Güvenlik Testleri
- [ ] **Görev**: Load test (k6/hey), güvenlik taraması (OWASP ZAP basit)
- [ ] Rate limit test, brute force test
- [ ] **Branch**: `test/week8-perf-security`
- [ ] **Commit planı**:
  - `test(perf): load test script k6`
  - `test(security): rate limit brute force tests`

### Hafta 9 (9 - 15 Kas): 1. Sunum Desteği
- [ ] **Görev**: Demo verisi hazırlığı, sunum kayıt yardımı
- [ ] Sahte veri scriptleri (seed) genişletme
- [ ] **Branch**: `chore/week9-demo-data`
- [ ] **Commit planı**:
  - `chore: extended seed data for demo`
  - `docs: demo script`

### Hafta 10 (16 - 22 Kas): Hata Takibi ve Regression
- [ ] **Görev**: Bug triage, regression test suite genişletme
- [ ] Flaky test tespiti ve düzeltme
- [ ] **Branch**: `test/week10-regression`
- [ ] **Commit planı**:
  - `test: regression suite for reported bugs`
  - `fix: flaky test stabilization`

### Hafta 11 (23 - 29 Kas): Dokümantasyon ve Yardım
- [ ] **Görev**: API dokümantasyonu yardımı (Çağdaş ile)
- [ ] Kullanım kılavuzu ekran görüntüleri
- [ ] **Branch**: `docs/week11-api-docs-help`
- [ ] **Commit planı**:
  - `docs: api endpoint examples`
  - `docs: user guide screenshots`

### Hafta 12 (30 Kas - 6 Ara): Release Hazırlığı
- [ ] **Görev**: Release notları, changelog, APK/Web linkleri toplama
- [ ] GitHub Release oluşturma yardımı
- [ ] **Branch**: `release/week12-prep`
- [ ] **Commit planı**:
  - `chore: release notes v1.0.0`
  - `ci: release workflow`

### Hafta 13 (7 - 13 Ara): Final Test ve Sunum
- [ ] **Görev**: Smoke test suite, canlı demo rehearsal
- [ ] **Branch**: `test/week13-smoke`
- [ ] **Commit planı**:
  - `test: smoke test suite`
  - `chore: demo rehearsal checklist`

### Hafta 14 (14 - 20 Ara): Test Haftası
- [ ] Sadece kritik hata düzeltmeleri
- [ ] Takımla manuel test oturumları

### Hafta 15 (21 - 27 Ara): Teslim
- [ ] Canlı demo desteği
- [ ] Katkı raporu: Yazılan testler, düzeltme sayısı, öğrenilenler

---

## Esnek Görev Havuzu (Hafta içinde alınabilecek)

| Öncelik | Görev | Sahip | Branch Örneği |
|---------|-------|-------|---------------|
| Yüksek | Kabul testi yeşile çevir | Hüseyin Emre atar | `test/rule-XX-fix` |
| Orta | Widget test ekle | Yusuf/Fatma ister | `test/widget-XXX` |
| Orta | API contract test | Çağdaş ister | `test/contract-XXX` |
| Düşük | Dokümantasyon düzeltme | Herkes | `docs/fix-XXX` |
| Düşük | Küçük UI pürüzü | Yusuf/Fatma | `fix/ui-XXX` |

## Bağımlılıklar
- **Hüseyin Emre**: Görev atama, code review, pair programming
- **Tüm takım**: Yardım istediğinde 30 dk kuralı (AGENTS.md Madde 9)