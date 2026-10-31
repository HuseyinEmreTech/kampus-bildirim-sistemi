---
title: Ertuğrul Pekdemir - Kişisel Plan
durum: Taslak
son-guncelleme: 2026-10-12
---

# Ertuğrul Pekdemir (@ertrlpkdmr) - Kişisel Plan

**Rol:** Backend Infrastructure / Veri ve Altyapı Uzmanı
**Ana Sorumluluk:** `campus_infrastructure` - PostgreSQL repository implementasyonları, dosya depolama, Docker, migration

## Haftalık Hedefler

### Hafta 3 (28 Eyl - 4 Eki): Altyapı Kurulumu
- [ ] Docker Compose: PostgreSQL 16, pgAdmin (geliştirme)
- [ ] Veritabanı şeması taslağı: `users`, `reports`, `buildings`, `notifications`, `status_history`
- [ ] Connection pool: `postgres` paketi, pool boyutu, timeout
- [ ] Migration stratejisi: SQL dosyaları versiyonlu (`V1__init.sql`, `V2__...`)
- [ ] PR: Docker compose up → PG hazır, migration çalışıyor

### Hafta 4 (5 - 11 Eki): Repository Arayüzleri ve Bağlantı
- [ ] `campus_domain` Repository interface'leri (Hüseyin Emre ile senkron)
- [ ] `UserRepository`, `ReportRepository`, `BuildingRepository`, `NotificationRepository`
- [ ] PostgreSQL bağlantı yönetimi: `Database` class, transaction helper
- [ ] Seed data script: Roller, örnek binalar, test kullanıcıları
- [ ] PR: Repository interface'ler + PG bağlantı testleri

### Hafta 5 (12 - 18 Eki): ReportRepositoryImpl - CRUD
- [ ] `ReportRepositoryImpl.create()`: INSERT + RETURNING reportId
- [ ] `ReportRepositoryImpl.findById()`: JOIN building, user
- [ ] `ReportRepositoryImpl.list()`: Filtreler (status, category, assignee, date range), sayfalama
- [ ] **Rule 02 Yarış durumu**: `UPDATE reports SET assigneeId=$1, takenAt=now() WHERE reportId=$2 AND assigneeId IS NULL` → affected rows kontrolü
- [ ] Unit testleri: Testcontainers veya ayrı test DB

### Hafta 6 (19 - 25 Eki): Dosya Depolama ve EXIF
- [ ] Fotoğraf kaydetme: `/files/{reportId}/{uuid}.{ext}` yapısı
- [ ] **EXIF temizleme**: `image` paketi veya `exiftool` CLI wrapper
- [ ] 5MB limit kontrolü (stream ile boyut kontrolü)
- [ ] Content-Type doğrulama (magic bytes, uzantı değil)
- [ ] Dosya silme: Çözüm fotoğrafı değiştirildiğinde eskisini sil
- [ ] PR: FileStorage service + testler

### Hafta 7 (26 Eki - 1 Kas): Building ve Notification Repository
- [ ] `BuildingRepositoryImpl`: Seed'ten yükleme, `findById`, `listAll`
- [ ] Kampüs sınırı kontrolü: Config'den dikdörtgen oku, `contains(lat, lng)`
- [ ] `NotificationRepositoryImpl`: `createReportResolved()`, `findByUser()`, `markAsRead()`
- [ ] `StatusHistoryRepositoryImpl`: Her durum değişiminde INSERT
- [ ] Transaction: Resolve + Notification + StatusHistory aynı transaction'da

### Hafta 8 (2 - 8 Kas): Migration'lar ve Indexler
- [ ] Production-ready migration'lar: `NOT NULL`, `UNIQUE`, `CHECK` constraint'ler
- [ ] Indexler: `reports(status, createdAt)`, `reports(assigneeId)`, `notifications(userId, readAt)`
- [ ] `EXPLAIN ANALYZE` ile sorgu planları kontrolü
- [ ] Backup/restore scripti: `pg_dump`, `pg_restore` test

### Hafta 9 (9 - 15 Kas): VPS Hazırlığı ve 1. Sunum
- [ ] VPS (varsa): Docker Compose production, reverse proxy (Caddy/Nginx), SSL (Let's Encrypt)
- [ ] Environment variables: `.env.production` şablonu
- [ ] Health check endpoint: `/health` (DB bağlantısı, disk alanı)
- [ ] **1. Sunum** demo verisi: Seed scripti production-like

### Hafta 10 (16 - 22 Kas): Performans ve Ölçek
- [ ] Connection pool tuning: `maxConnections`, `idleTimeout`
- [ ] Sorgu optimizasyonu: N+1 önleme (JOIN + batch load)
- [ ] Sayfalama: Keyset pagination (cursor) vs offset performansı
- [ ] Loglama: Structured JSON log (seviye, requestId, süre)

### Hafta 11 (23 - 29 Kas): Dağıtım Kararı ve Güvenlik
- [ ] **Dağıtım kararı** (Hafta 11 sonu): VPS var mı?
- [ ] Eğer VPS yok: Yerel demo için `docker-compose.prod.yml`, port forwarding
- [ ] Güvenlik: Şifre hash (bcrypt/argon2), JWT secret rotation
- [ ] Rate limit: Redis yoksa in-memory (tek instance için yeterli)

### Hafta 12 (30 Kas - 6 Ara): Deploy Denemesi
- [ ] **Özellik dondurma**
- [ ] Deploy denemesi: VPS veya yerel production-like
- [ ] HTTPS çalışıyor mu? (Caddy otomatik SSL)
- [ ] APK/Web build indirme linkleri
- [ ] Monitoring: Basit log aggregation (Loki/Promtail veya dosya tail)

### Hafta 13 (7 - 13 Ara): Hardening ve Dokümantasyon
- [ ] Security hardening: Firewall, fail2ban, non-root container user
- [ ] Fotoğraf saklama politikası: 30 gün sonra silme (cron job)
- [ ] Disaster recovery: Backup zamanlaması, restore drill
- [ ] Infrastructure README: Kurulum, migration, backup, deploy

### Hafta 14 (14 - 20 Ara): Test Haftası
- [ ] Sadece hata düzeltme (infrastructure tarafında)
- [ ] Load test: `hey` veya `k6` ile 100 concurrent user simülasyonu
- [ ] DB connection leak kontrolü

### Hafta 15 (21 - 27 Ara): Teslim
- [ ] Production deployment (veya demo ortamı) canlı
- [ ] Canlı demo sırasında infrastructure destek
- [ ] Katkı raporu: Migration'lar, performans iyileştirmeleri, deploy notları

---

## Teknik Borç / Öğrenilecekler
- [ ] PostgreSQL advisory lock (dağıtık lock olmadan yarış durumu)
- [ ] `postgres` paketi connection pool tuning
- [ ] EXIF stripping Dart'ta (pure Dart vs process run)
- [ ] Docker multi-stage build (küçük image)

## Bağımlılıklar
- **Hüseyin Emre**: Domain repository interface'leri
- **Çağdaş**: Server endpoint'leri repository'leri çağırıyor
- **Yusuf/Fatma**: File upload/download URL'leri, API contract
## Raporlar
- [2026-10-12](raporlar/ertrlpkdmr/2026-10-12.md): Hafta 05 planı, compose ve V1 migration
- [2026-10-15](raporlar/ertrlpkdmr/2026-10-15.md): Veritabanı bağlantısı, üstlen (Rule 02) ve depolar (#34, #40, #41, #43, #47, #48, #49)
- [2026-10-16](raporlar/ertrlpkdmr/2026-10-16.md): Birleşen PR'lar, çözüldü işaretleme (Rule 03, Rule 04)
- [2026-10-17](raporlar/ertrlpkdmr/2026-10-17.md): Bütün PR'lar birleşti (#52-#66); hafta 6-10 işleri yerelde hazır
- [2026-10-18](raporlar/ertrlpkdmr/2026-10-18.md): ReportRepository'nin PostgreSQL karşılığı; HTTPS, günlük sınırı ve kurtarma tatbikatı (yerel)
- [2026-10-19](raporlar/ertrlpkdmr/2026-10-19.md): #87 ve #88 açıldı; depo arayüzü parçalara bölündü, #81'e güvenlik notu
- [2026-10-24](raporlar/ertrlpkdmr/2026-10-24.md): Depo çeviri fonksiyonları ve fotoğraf işleme sınırı PR'ları; ekipteki değişiklikler (Murat, ADR-04)
- [2026-10-25](raporlar/ertrlpkdmr/2026-10-25.md): Görev taraması; depo arayüzü ikiye bölündü (test önce), fotoğraf saklama ve örnek JWT düzeltmesi (yerel)
- [2026-10-26](raporlar/ertrlpkdmr/2026-10-26.md): ReportRepository arayüzü 1. parça (oluştur, üstlen)
- [2026-10-27](raporlar/ertrlpkdmr/2026-10-27.md): Yenileme belirtecinin yeniden kullanımında bütün oturumlar kapanıyor (#81); örnek JWT sırları kısaltıldı
- [2026-10-31](raporlar/ertrlpkdmr/2026-10-31.md): Bildirim listesine okunmamış süzgeci (Çağdaş'ın isteği)
