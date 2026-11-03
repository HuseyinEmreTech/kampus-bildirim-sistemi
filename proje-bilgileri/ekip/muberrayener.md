---
title: Fatma Müberra Yener - Kişisel Plan
durum: Taslak
son-guncelleme: 2026-11-01
---

# Fatma Müberra Yener (@muberrayener) - Kişisel Plan

> **Güncel görevler (1 Kasım 2026):** [Kalan işler planı](../planlar/2026-11-01-kalan-isler.md) ve `gh issue list --assignee muberrayener`. Son tarih yok; sıra bağımlılığa göre. Bu dosyadaki haftalık hedefler geçmiş kayıttır.


**Rol:** Web Arayüzü (Flutter Web) / Test & QA
**Ana Sorumluluk:** `campus_app` web hedefi, test stratejisi, otomasyon, SonarQube kalite

## Haftalık Hedefler

### Hafta 3 (28 Eyl - 4 Eki): Web İskeleti ve Test Altyapısı
- [ ] Flutter Web proje yapısı: `web/` entry point, PWA manifest
- [ ] Test paketi: `flutter_test`, `integration_test`, `mocktail`
- [ ] Widget test şablonları: Golden test, pumpWidget helpers
- [ ] CI: `flutter test --coverage`, `dart run coverage:format_lcov`
- [ ] PR: Web iskeleti + test altyapısı çalışıyor

### Hafta 4 (5 - 11 Eki): Giriş ve Tema (Web)
- [ ] Responsive giriş ekranı: Mobile < 600px, Tablet 600-900px, Desktop > 900px
- [ ] Paylaşılan tema: `lib/theme/` (Yusuf ile ortak)
- [ ] Form validation: Email, şifre, hata mesajları (i18n hazırlık)
- [ ] Web özel: Keyboard navigation, focus management
- [ ] PR: Web giriş ekranı responsive

### Hafta 5 (12 - 18 Eki): **Hafta 5 - Bugün Başlangıç (12 Eki Pazartesi)**
- [ ] **Web: Bildirim listesi (Student)** - Yan panel + detay layout (Desktop)
- [ ] **Widget testleri**: Liste boş/dolu/hata state'leri
- [ ] **Contract testleri**: API response ↔ DTO parsing
- [ ] **Branch**: `feature/week5-web-report-list`
- [ ] **Commit planı**: 
  - `feat(web): responsive report list with side panel`
  - `test(web): report list widget tests`
  - `test(contracts): report DTO parsing tests`

### Hafta 6 (19 - 25 Eki): Web Bildirim Oluşturma ve Detay
- [ ] **Web: Bildirim oluşturma** - Drag&drop fotoğraf, harita picker (leaflet/maplibre)
- [ ] **Web: Bildirim detayı** - Büyük görsel, harita, durum zaman çizelgesi
- [ ] **E2E test altyapısı**: `integration_test` + `web_driver` (Chrome headless)
- [ ] **Branch**: `feature/week6-web-create-detail`
- [ ] **Commit planı**:
  - `feat(web): report create with drag-drop photo`
  - `feat(web): report detail with map`
  - `test(e2e): report create flow`

### Hafta 7 (26 Eki - 1 Kas): Görevli Web Ekranları
- [ ] **Web: Görevli listesi** - Filtreler (status, category, date), tablo view
- [ ] **Web: Üstlen/Çöz aksiyonları** - Modal confirm, optimistic update
- [ ] **Responsive table**: Mobile'de card view, Desktop'ta data table
- [ ] **Branch**: `feature/week7-web-staff`
- [ ] **Commit planı**:
  - `feat(web): staff report list with filters`
  - `feat(web): assign/resolve actions`
  - `test(widget): staff actions`

### Hafta 8 (2 - 8 Kas): Gerçek API Entegrasyonu (Web)
- [ ] Mock client → Real HTTP client (dio/http)
- [ ] Auth interceptor: Token refresh, 401 handling
- [ ] Error boundary: Global hata sayfası, retry logic
- [ ] **Branch**: `feature/week8-web-api-integration`
- [ ] **Commit planı**:
  - `feat(web): real api client with auth`
  - `fix(web): error boundary and retry`

### Hafta 9 (9 - 15 Kas): 1. Sunum ve Web Özel Özellikler
- [ ] **1. Sunum** (varsayım): Web demo
- [ ] PWA: Service worker, offline fallback, install prompt
- [ ] SEO: Meta tags, sitemap, robots.txt
- [ ] **Branch**: `feature/week9-web-pwa-seo`
- [ ] **Commit planı**:
  - `feat(web): pwa support`
  - `feat(web): seo meta tags`

### Hafta 10 (16 - 22 Kas): Bildirimlerim ve Profil (Web)
- [ ] **Web: Bildirimlerim** - Öğrenci kendi bildirimleri, durum geçmişi timeline
- [ ] **Web: Profil** - Bilgi görüntüleme, şifre değiştirme
- [ ] **Branch**: `feature/week10-web-profile`
- [ ] **Commit planı**:
  - `feat(web): my reports with timeline`
  - `feat(web): profile page`

### Hafta 11 (23 - 29 Kas): Admin/Raporlama ve Performans
- [ ] **Web: Admin dashboard** - İstatistik kartlar, grafikler (fl_chart)
- [ ] Web performans: Lighthouse CI, bundle size analizi
- [ ] **Branch**: `feature/week11-web-admin-perf`
- [ ] **Commit planı**:
  - `feat(web): admin dashboard`
  - `perf(web): lighthouse ci + bundle analyze`

### Hafta 12 (30 Kas - 6 Ara): Build ve Release
- [ ] **Özellik dondurma**
- [ ] `flutter build web --release` - Output: `build/web/`
- [ ] Docker: Nginx static serve, SPA fallback
- [ ] **Branch**: `release/week12-web-build`
- [ ] **Commit planı**:
  - `build(web): production build config`
  - `ci(web): docker nginx static`

### Hafta 13 (7 - 13 Ara): Test Raporu ve 2. Sunum
- [ ] Test raporu: Coverage, mutation test (mutant), flaky test analizi
- [ ] **2. Sunum** slaytları: Test stratejisi, kalite metrikleri
- [ ] **Branch**: `docs/week13-test-report`
- [ ] **Commit planı**:
  - `docs: test strategy report`
  - `docs: 2nd presentation slides`

### Hafta 14 (14 - 20 Ara): Test Haftası
- [ ] Sadece hata düzeltme (web)
- [ ] Cross-browser: Chrome, Firefox, Safari (BrowserStack/local)
- [ ] Mobile web: iOS Safari, Chrome Android test

### Hafta 15 (21 - 27 Ara): Teslim
- [ ] Web URL canlı (VPS/Netlify/Vercel/Firebase Hosting)
- [ ] Katkı raporu: Test coverage %, bug sayısı, performans skorları

---

## Test Stratejisi (Fatma Sahipliği)

| Test Türü | Araç | Hedef | Sıklık |
|-----------|------|-------|--------|
| Unit (Domain/App) | `flutter_test` | %80+ coverage | Her PR |
| Widget | `flutter_test` | Kritik widget'lar | Her PR |
| Contract | `dart test` | API ↔ DTO | Her PR |
| Integration | `integration_test` | Uçtan uca akışlar | Haftada 1 |
| E2E Web | `web_driver` | Kritik kullanıcı yolları | Release öncesi |
| Performance | Lighthouse CI | PWA > 90, Perf > 80 | Her release |

## Bağımlılıklar
- **Yusuf**: Paylaşılan widget'lar, theme, contracts DTO'lar
- **Hüseyin Emre**: Kabul testleri (bekliyor etiketli), contract'lar
- **Çağdaş/Ertuğrul**: API endpoint'leri hazır olmalı