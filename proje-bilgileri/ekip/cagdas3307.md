---
title: Çağdaş Kemal Ağca - Kişisel Plan
durum: Taslak
son-guncelleme: 2026-10-12
---

# Çağdaş Kemal Ağca (@Cagdas3307) - Kişisel Plan

**Rol:** Backend API / Sunucu Geliştirici
**Ana Sorumluluk:** `campus_server` - Shelf router, endpoint'ler, kimlik doğrulama, hata eşleme, middleware

## Haftalık Hedefler

### Hafta 3 (28 Eyl - 4 Eki): Sunucu İskeleti
- [ ] `campus_server` paketi: `pubspec.yaml` (shelf, shelf_router, jwt, bcrypt, campus_contracts, campus_application)
- [ ] Shelf router kurulumu: `Router`, `Pipeline`, middleware zinciri
- [ ] Health check: `GET /health` → 200 OK
- [ ] CORS middleware (Flutter Web için)
- [ ] Request logging middleware (structured JSON)
- [ ] PR: Sunucu ayağa kalkıyor, `/health` yanıtı veriyor

### Hafta 4 (5 - 11 Eki): Kimlik Doğrulama
- [ ] `POST /auth/login`: Email/şifre → JWT access + refresh token
- [ ] `POST /auth/refresh`: Refresh token → yeni access token
- [ ] Şifre hash: `bcrypt` (cost 12)
- [ ] JWT: HS256, access 15dk, refresh 7 gün, secret config'den
- [ ] Auth middleware: `Authorization: Bearer` → `request.context['user'] = User`
- [ ] Role guard: `@requireRole('Staff')` middleware
- [ ] PR: Auth endpoints + middleware testleri

### Hafta 5 (12 - 18 Eki): Bildirim Endpoint'leri - Öğrenci
- [ ] `POST /reports`: Bildirim oluşturma (multipart/form-data: photo, location, category, description, buildingId?)
- [ ] Request validation: Contract DTO → Domain/Application'e geçiş
- [ ] `GET /reports`: Listeleme (query: status, category, page, limit) - Student: sadece kendi
- [ ] `GET /reports/:id`: Detay (foto URL, konum, durum geçmişi)
- [ ] Hata eşleme: Domain/Application hataları → HTTP 400/404/409/422
- [ ] PR: Her endpoint ayrı PR, contract testleri ile

### Hafta 6 (19 - 25 Eki): Bildirim Endpoint'leri - Görevli
- [ ] `POST /reports/:id/assign`: Üstlenme (Rule 02: 409 eğer dolu)
- [ ] `POST /reports/:id/resolve`: Çözme (multipart: resolutionPhoto, resolutionNote?)
- [ ] Rule 03: Sadece assignee çözebilir → 403
- [ ] Rule 04: Resolution photo zorunlu → 422
- [ ] Transaction: Resolve + Notification + StatusHistory (Application katmanında)
- [ ] `GET /reports?assignee=me`: Görevlinin üstlendiği bildirimler
- [ ] PR: Görevli endpoint'leri + yetki testleri

### Hafta 7 (26 Eki - 1 Kas): Bildirim ve Bina Endpoint'leri
- [ ] `GET /notifications`: Öğrenci bildirimleri (query: unreadOnly, page)
- [ ] `POST /notifications/:id/read`: Okundu işaretle
- [ ] `GET /buildings`: Bina listesi (konum izni yoksa fallback)
- [ ] `GET /buildings/:id`: Bina detayı (koordinat, ad)
- [ ] Rate limiting middleware: IP/bazlı, 100 req/dk (configurable)
- [ ] PR: Bildirim + Bina endpoint'leri

### Hafta 8 (2 - 8 Kas): Güvenlik ve Validasyon
- [ ] Input sanitization: XSS önleme, SQL injection (parametreli query zaten var)
- [ ] Security headers: `Helmet` equivalent (CSP, HSTS, X-Frame-Options)
- [ ] File upload validation: Magic bytes, size limit (stream), EXIF strip (infrastructure'a delegasyon)
- [ ] Audit log: Her mutating request log (userId, endpoint, timestamp, result)
- [ ] PR: Güvenlik middleware + testleri

### Hafta 9 (9 - 15 Kas): 1. Sunum ve API Dokümantasyonu
- [ ] **1. Sunum** (varsayım): API demo
- [ ] OpenAPI/Swagger spec: `package:shelf_openapi` veya manuel YAML
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
- [ ] `GET /users/me`: Profil bilgisi
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
- [ ] Shelf middleware zinciri (Pipeline, addMiddleware)
- [ ] JWT implementation Dart'ta (package:jwt_decoder, dart_jsonwebtoken)
- [ ] Multipart form-data parsing (shelf_multipart)
- [ ] OpenAPI spec generation from code

## Bağımlılıklar
- **Hüseyin Emre**: Application UseCase'ler, Contracts DTO'lar, Hata türleri
- **Ertuğrul**: Repository implementasyonları hazır olmalı
- **Yusuf/Fatma**: API contract uyumu, hata mesajları UI'da nasıl gösterilecek