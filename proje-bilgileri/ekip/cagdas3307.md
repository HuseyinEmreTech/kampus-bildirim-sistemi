---
title: Çağdaş Kemal Ağca - Kişisel Plan
durum: Taslak
son-guncelleme: 2026-10-24
---

# Çağdaş Kemal Ağca (@Cagdas3307) - Kişisel Plan

**Rol:** Backend API / Sunucu Geliştirici
**Ana Sorumluluk:** `campus_server` - Shelf router, endpoint'ler, kimlik doğrulama, hata eşleme, middleware

## Haftalık Hedefler

### Hafta 3 (28 Eyl - 4 Eki): Sunucu İskeleti
- [x] `campus_server` paketi: `pubspec.yaml` (shelf, shelf_router, jwt, bcrypt, campus_contracts, campus_application) — jwt ve bcrypt #19 ile
- [x] Shelf router kurulumu: `Router`, `Pipeline`, middleware zinciri
- [x] Health check: `GET /health` → 200 OK
- [x] CORS middleware (Flutter Web için)
- [x] Request logging middleware (structured JSON) — #111
- [x] PR: Sunucu ayağa kalkıyor, `/health` yanıtı veriyor (#33)

### Hafta 4 (5 - 11 Eki): Kimlik Doğrulama
- [x] `POST /auth/login`: Email/şifre → JWT access + refresh token (#19)
- [x] `POST /auth/refresh`: Refresh token → yeni access token (rotation ile)
- [x] Şifre hash: `bcrypt` (cost 12)
- [x] JWT: HS256, access 15dk, refresh 7 gün, secret config'den
- [x] Auth middleware: `Authorization: Bearer` → `request.context['user'] = UserContext`
- [x] Role guard: `requireRole('Staff')` middleware
- [x] PR: Auth endpoints + middleware testleri — 4 PR'a bölündü: #67 (birleşti), #80, #81, #82 (review bekliyor)

### Hafta 5 (12 - 18 Eki): Bildirim Endpoint'leri - Öğrenci
> Durum (24 Eki): #20'nin uçları PR olarak açıldı (#115-#121). Bildirim uçlarını `server.dart`'a bağlamak için #17 (`ReportRepositoryImpl` arayüzü), detay için application'da use case bekleniyor.

- [x] `POST /reports`: Bildirim oluşturma (multipart/form-data: photo, location, category, description, buildingId?) — #121
- [ ] Request validation: Contract DTO → Domain/Application'e geçiş — alanlar sunucuda okunup application komutuna çevriliyor; `campus_contracts` DTO'ları (#94) gelince uyarlanacak
- [x] `GET /reports`: Listeleme (query: status, category, page, limit) - Student: sadece kendi — #116
- [ ] `GET /reports/:id`: Detay (foto URL, konum, durum geçmişi) — öğrencinin yalnızca kendi bildirimini görmesi kuralı için application'da use case gerekiyor
- [x] Hata eşleme: Domain/Application hataları → HTTP 400/404/409/422 — #115
- [x] PR: Her endpoint ayrı PR (#115-#121); contract testleri contracts gelince

### Hafta 6 (19 - 25 Eki): Bildirim Endpoint'leri - Görevli
- [x] `POST /reports/:id/assign`: Üstlenme (Rule 02: 409 eğer dolu) — API tasarımına göre `PUT /api/reports/{id}/assignment`, #117
- [x] `POST /reports/:id/resolve`: Çözme (multipart: resolutionPhoto, resolutionNote?) — `PUT /api/reports/{id}/resolution`, #118, #119
- [x] Rule 03: Sadece assignee çözebilir → 403 — #119
- [x] Rule 04: Resolution photo zorunlu → 422 — API tasarımına göre `400 VALIDATION_ERROR`, #119
- [x] Transaction: Resolve + Notification + StatusHistory (Application katmanında) — `ReportRepositoryImpl.resolve` aynı işlemde yazıyor; sunucuda iş yok
- [x] `GET /reports?assignee=me`: Görevlinin üstlendiği bildirimler — #116
- [x] PR: Görevli endpoint'leri + yetki testleri — #117, #119

### Hafta 7 (26 Eki - 1 Kas): Bildirim ve Bina Endpoint'leri
- [x] `GET /notifications`: Öğrenci bildirimleri (query: unreadOnly, page) — `GET /api/me/notifications` (page, pageSize; `unreadOnly` yok), #123
- [x] `POST /notifications/:id/read`: Okundu işaretle — `PUT /api/me/notifications/{id}/read`, #123
- [x] `GET /buildings`: Bina listesi (konum izni yoksa fallback) — #122
- [ ] `GET /buildings/:id`: Bina detayı (koordinat, ad) — API tasarımında yok; liste koordinatları da veriyor, gerekirse eklenecek
- [x] Rate limiting middleware: IP/bazlı, 100 req/dk; girişte 5/dk — #110
- [x] PR: Bildirim + Bina endpoint'leri — #122, #123

### Hafta 8 (2 - 8 Kas): Güvenlik ve Validasyon
- [x] Input sanitization: XSS önleme, SQL injection (parametreli query zaten var) — istek boyutu sınırı #124; metin kırpma/uzunluk domain'de, yanıtlar JSON + `nosniff`
- [x] Security headers: `Helmet` equivalent (CSP, HSTS, X-Frame-Options) — #110
- [x] File upload validation: Magic bytes, size limit (stream), EXIF strip (infrastructure'a delegasyon) — `LocalFileStorage` ile, #119, #121
- [x] Audit log: Her mutating request log (userId, endpoint, timestamp, result) — #113
- [x] PR: Güvenlik middleware + testleri — #110, #113, #124

### Hafta 9 (9 - 15 Kas): 1. Sunum ve API Dokümantasyonu
- [ ] **1. Sunum** (varsayım): API demo
- [x] OpenAPI/Swagger spec: `package:shelf_openapi` veya manuel YAML — manuel YAML (health, login, refresh, users/me), #114
- [ ] API dokümantasyonu: `/docs` endpoint (Scalar/Swagger UI)
- [ ] Request/Response örnekleri her endpoint için
- [ ] PR: API docs + contract testleri

### Hafta 10 (16 - 22 Kas): Sayfalama, Filtreleme, Performans
- [ ] Sayfalama: Keyset pagination (`cursor`, `limit`) - performans için
- [ ] Filtreler: `status`, `category`, `assigneeId`, `dateFrom`, `dateTo`
- [ ] Sıralama: `createdAt` desc/asc, `priority` (varsa)
- [ ] Response compression: `gzip` middleware
- [ ] PR: Gelişmiş listeleme + benchmark

### Hafta 11 (23 - 29 Kas): Kalan Endpoint'ler ve Loglama
- [x] `GET /users/me`: Profil bilgisi — #112
- [ ] `PATCH /users/me`: Profil güncelleme (ad, şifre değiştirme)
- [ ] Structured logging: `requestId` correlation, latency, DB query log (slow query)
- [ ] Error tracking: Sentry entegrasyonu (opsiyonel, ücretsiz plan)
- [ ] PR: Profil + logging

### Hafta 12 (30 Kas - 6 Ara): Özellik Dondurma ve Build
- [ ] **Özellik dondurma** - Sadece hata
- [ ] Production build: `dart compile exe` → single binary
- [ ] Dockerfile: Multi-stage, non-root, distroless/base
- [ ] Environment config: `.env` → `Platform.environment`
- [ ] PR: Production Docker image

### Hafta 13 (7 - 13 Ara): Son Kontroller ve Sunum
- [ ] End-to-end API test: Postman collection / `dart test` integration
- [ ] Load test: `hey -n 1000 -c 50` → latency, error rate
- [ ] **2. Sunum** slaytları: API mimarisi, güvenlik, performans
- [ ] README: API bölümünü yaz (endpoint listesi, auth, örnekler)

### Hafta 14 (14 - 20 Ara): Test Haftası
- [ ] Sadece hata düzeltme
- [ ] Regression: Tüm endpoint'ler contract test geçiyor mu?
- [ ] Security scan: `dart analyze`, dependency check

### Hafta 15 (21 - 27 Ara): Teslim
- [ ] Canlı demo: Sunucu çalışıyor, API yanıt veriyor
- [ ] Katkı raporu: Endpoint sayısı, test coverage, performans metrikleri

---

## Teknik Borç / Öğrenilecekler
- [x] Shelf middleware zinciri (Pipeline, addMiddleware)
- [x] JWT implementation Dart'ta (dart_jsonwebtoken)
- [ ] Multipart form-data parsing (shelf_multipart)
- [ ] OpenAPI spec generation from code

## Bağımlılıklar
- **Hüseyin Emre**: Application UseCase'ler, Contracts DTO'lar, Hata türleri
- **Ertuğrul**: Repository implementasyonları hazır olmalı
- **Yusuf/Fatma**: API contract uyumu, hata mesajları UI'da nasıl gösterilecek