---
title: Bordo Takım - Görev Dağılımı ve Rol Tanımları
durum: Taslak
son-guncelleme: 2026-11-01
---

# Bordo Takım - Görev Dağılımı ve Rol Tanımları

← [İndeks](../00-index.md)

> **1 Kasım 2026:** Bu dağılım ilk plandır. Güncel görevler: [Kalan işler planı](../planlar/2026-11-01-kalan-isler.md).

Bu doküman 6 kişilik Bordo Takımı için proje rollerini, sorumlulukları ve 15 haftalık süreç içindeki görev dağılımını tanımlar.

## 1. Takım Üyeleri ve Beceriler

| Üye | GitHub | Üniversite | Bölüm | Sınıf | Beceri Seti | Ana Teknoloji |
|-----|--------|------------|-------|-------|-------------|---------------|
| **Hüseyin Emre** | `HuseyinEmreTech` | I.S.T.E | Yönetim Bilişim Sistemleri | 4 | Dart, C#, PostgreSQL, Firebase | **Tech Lead / Full Stack** |
| **Yusuf Ekenel** | `yusufekenel` | I.S.T.E | Yönetim Bilişim Sistemleri | 4 | Dart, PostgreSQL | **Flutter Mobil (Android/iOS)** |
| **Ertuğrul Pekdemir** | `ertrlpkdmr` | I.S.T.E | Yönetim Bilişim Sistemleri | 4 | Dart, PostgreSQL | **Backend / Infrastructure** |
| **Çağdaş Kemal Ağca** | `Cagdas3307` | I.S.T.E | Yönetim Bilişim Sistemleri | 4 | C#, Dart, Python, SQL, Firebase | **Backend API / Database** |
| **Fatma Müberra Yener** | `muberrayener` | I.M.U | Bilgisayar Mühendisliği | 4 | Python, C#, Java, MongoDB, PostgreSQL | **Web Arayüzü / Test & QA** |
| **Emir Kerem Çakıcı** | *(belirlenecek)* | I.M.U | Bilgisayar Mühendisliği | 4 | *(belirlenecek)* | **Destek / Esnek Rol** |

## 2. Roller ve Sorumluluk Matrisi

### 2.1 Temel Roller (Proje Mimarisine Göre)

| Paket/Katman | Sorumlu | Yedek | Açıklama |
|--------------|---------|-------|----------|
| `campus_domain` | **Hüseyin Emre** | Çağdaş | Domain entities, value objects, kurallar (Rule 00-07) |
| `campus_application` | **Hüseyin Emre** | Ertuğrul | Use case'ler, servisler, DTO'lar |
| `campus_contracts` | **Hüseyin Emre** | Yusuf | API sözleşmeleri, request/response modelleri |
| `campus_infrastructure` | **Ertuğrul** | Çağdaş | PostgreSQL repository implementasyonları, dosya depolama |
| `campus_server` | **Çağdaş** | Ertuğrul | Shelf router, endpoint'ler, auth middleware, hata eşleme |
| `campus_app` (Flutter) | **Yusuf** | Fatma | Mobil uygulama (Android, iOS, **Web**) |

### 2.2 Çapraz Kesit Sorumluluklar

| Alan | Sorumlu | Destek |
|------|---------|--------|
| **Teknik Liderlik / Mimari Kararlar** | Hüseyin Emre | Tüm takım |
| **CI/CD Pipeline & GitHub Actions** | Hüseyin Emre | Ertuğrul |
| **Veritabanı Şeması & Migration** | Ertuğrul | Çağdaş |
| **Test Stratejisi & Otomasyon** | Fatma Müberra | Yusuf |
| **SonarQube Cloud & Kalite** | Hüseyin Emre | Fatma |
| **Dokümantasyon (ADR, README, API Docs)** | Hüseyin Emre | Tüm takım (kendi PR'ları) |
| **Web Arayüzü (Flutter Web)** | Fatma Müberra | Yusuf |
| **Deploy / VPS / HTTPS** | Ertuğrul | Çağdaş |
| **Günlük Raporlar & Haftalık İlerleme** | Herkes kendi klasörüne | Hüseyin Emre (derleme) |

## 3. Haftalık Görev Dağılımı (15 Hafta)

### Sprint 0-3 (Hafta 3-4): Kurulum ve Temel Altyapı

| Hafta | Hüseyin Emre | Yusuf | Ertuğrul | Çağdaş | Fatma | Emir |
|-------|--------------|-------|----------|--------|-------|------|
| **3** | Repo iskeleti, CI, AGENTS.md, CODEOWNERS | Flutter kurulum, platform kanalları | Docker compose, PG şeması taslağı | Sunucu iskeleti, Shelf router | Web proje iskeleti (Flutter Web) | Kurulum, öğrenme |
| **4** | Domain çekirdeği (User, Report, Rule 00-07) | Tema, navigation, temel widget'lar | Repository arayüzleri, PG bağlantısı | Auth endpoint'leri (register/login) | Test stratejisi, widget test altyapısı | Sahte veri, seed scriptleri |

### Sprint 4-7 (Hafta 5-8): Çekirdek İş Mantığı ve API

| Hafta | Hüseyin Emre | Yusuf | Ertuğrul | Çağdaş | Fatma | Emir |
|-------|--------------|-------|----------|--------|-------|------|
| **5** | Application katmanı (ReportService) | Giriş ekranı, auth state | ReportRepositoryImpl, SQL | Bildirim CRUD endpoint'leri | **Web: Giriş, Liste ekranları** | Test senaryoları yazımı |
| **6** | Use case'ler: Create, Assign, Resolve | Bildirim liste ekranı (Student) | File storage (local disk) | Hata eşleme, middleware | **Web: Bildirim detay, oluşturma** | Entegrasyon testleri |
| **7** | Kabul testleri (Rule 02, 04, 05) | Bildirim oluşturma (foto, konum) | EXIF temizleme, 5MB limit | Görevli endpoint'leri (assign, resolve) | **Web: Harita/konum seçici** | E2E test altyapısı |
| **8** | Rule 01, 03, 06, 07 testleri | GPS + bina listesi fallback | Migration'lar, indexler | Rate limiting, güvenlik başlıkları | **Web: Responsive düzenler** | Performans testleri |

### Sprint 8-11 (Hafta 9-12): Entegrasyon, Web ve Kalite

| Hafta | Hüseyin Emre | Yusuf | Ertuğrul | Çağdaş | Fatma | Emir |
|-------|--------------|-------|----------|--------|-------|------|
| **9** | PR review, kod kalitesi | Mobil + API entegrasyonu | VPS hazırlığı, Docker | API dokümantasyonu (OpenAPI) | **1. Sunum hazırlığı** | Hata takibi, regression |
| **10** | SonarQube Cloud entegrasyonu | Çözüm fotoğrafı akışı | Backup/restore stratejisi | Sayfalama, filtreleme | **Web: Bildirimlerim, profil** | Load test, bottleneck |
| **11** | ADR'lar, mimari kararlar | Boş/hata durumları, offline | Dağıtım kararı (VPS/yerel) | Kalan endpoint'ler, loglama | **Web: Admin/raporlama** | Güvenlik testi (temel) |

### Sprint 12-15 (Hafta 13-15): Dondurma, Test, Teslim

| Hafta | Hüseyin Emre | Yusuf | Ertuğrul | Çağdaş | Fatma | Emir |
|-------|--------------|-------|----------|--------|-------|------|
| **12** | **Özellik dondurma**, APK build | APK/İPA/Web build, test | Deploy denemesi, HTTPS | Son performans ayarları | **Web final testleri** | Demo senaryoları |
| **13** | README, ADR final, katkı raporu | UX pürüzleri, erişilebilirlik | Monitoring, log aggregation | Güvenlik hardening | **2. Sunum slaytları** | Kullanım kılavuzu |
| **14** | Sadece hata düzeltme | Sadece hata düzeltme | Sadece hata düzeltme | Sadece hata düzeltme | **Sadece hata düzeltme** | Sadece hata düzeltme |
| **15** | **Teslim, 2. Sunum** | Demo, canlı test | Demo, canlı test | Demo, canlı test | **Demo, canlı test** | Demo, canlı test |

## 4. GitHub Repository Yapısı ve Branch Stratejisi

### 4.1 Ana Repository
```
kampus-bildirim-sistemi/           ← Monorepo (mevcut)
├── packages/
│   ├── domain/          → Hüseyin Emre (owner)
│   ├── application/     → Hüseyin Emre (owner)
│   ├── contracts/       → Hüseyin Emre (owner)
│   ├── infrastructure/  → Ertuğrul (owner)
│   ├── server/          → Çağdaş (owner)
│   └── app/             → Yusuf (owner), Fatma (web)
├── proje-bilgileri/     → Hüseyin Emre (derleme), herkes kendi PR'ı
└── .github/             → Hüseyin Emre (CI, templates)
```

### 4.2 Branch İsimlendirme
```
feature/<issue-no>-<kisa-ad>    ← Yeni özellik
fix/<issue-no>-<kisa-ad>        ← Hata düzeltme
docs/<issue-no>-<kisa-ad>       ← Dokümantasyon
test/<issue-no>-<kisa-ad>       ← Test ekleme
refactor/<issue-no>-<kisa-ad>   ← Yeniden yapılandırma
```

### 4.3 CODEOWNERS (Öneri)
```
# Domain çekirdeği - en katı koruma
/packages/domain/          @HuseyinEmreTech
/packages/application/     @HuseyinEmreTech
/packages/contracts/       @HuseyinEmreTech
/test/                     @HuseyinEmreTech

# Infrastructure - Ertuğrul
/packages/infrastructure/  @ertrlpkdmr

# Server/API - Çağdaş
/packages/server/          @Cagdas3307

# Flutter App - Yusuf (mobil), Fatma (web)
/packages/app/lib/         @yusufekenel @muberrayener
/packages/app/web/         @muberrayener

# CI/CD ve repo ayarları
/.github/                  @HuseyinEmreTech
/AGENTS.md                 @HuseyinEmreTech
```

## 5. Issue ve Milestone Şablonları

### 5.1 Issue Türleri ve Etiketler
| Etiket | Açıklama | Örnek |
|--------|----------|-------|
| `domain` | Domain katmanı | Rule 02 implementasyonu |
| `application` | Use case / servis | ReportCreateUseCase |
| `contracts` | API sözleşmesi | ReportDTO, pagination |
| `infrastructure` | DB, dosya, harici servis | ReportRepositoryImpl |
| `server` | Endpoint, auth, middleware | POST /reports |
| `app:mobile` | Flutter Android/iOS | Bildirim oluşturma ekranı |
| `app:web` | Flutter Web | Giriş sayfası responsive |
| `ci` | Pipeline, workflow | SonarQube entegrasyonu |
| `docs` | ADR, README, API doc | ADR-03: Fotoğraf depolama |
| `test` | Test ekleme/iyileştirme | Yarış durumu testi |

### 5.2 Öncelik Etiketleri
- `sart` → **Şart** (MVP için zorunlu)
- `olmali` → **Olmalı** (kalite/UX için önemli)
- `olursa` → **Olursa** (zaman kalırsa)

## 6. Kişisel GitHub Planları (Her Üye Kendi Dosyasına Yazar)

Her üye `proje-bilgileri/ekip/<github-username>.md` dosyasında haftalık planını tutar:

```
proje-bilgileri/ekip/
├── huseyinemretech.md    ← Hüseyin Emre
├── yusufekenel.md        ← Yusuf Ekenel
├── ertrlpkdmr.md         ← Ertuğrul Pekdemir
├── cagdas3307.md         ← Çağdaş Kemal Ağca
├── muberrayener.md       ← Fatma Müberra Yener
└── emirkerem.md          ← Emir Kerem Çakıcı (GitHub kullanıcı adı belirlendikten sonra)
```

## 7. İletişim ve Koordinasyon

| Toplantı | Sıklık | Katılımcılar | Süre |
|----------|--------|--------------|------|
| **Haftalık Planlama** | Pazartesi | Tüm takım | 15 dk |
| **Ders İlerleme** | Cuma | Tüm takım | 1 dk/kişi |
| **Günlük Senkron** | Günlük (async) | İlgili alt takım | GitHub Issue/PR yorumları |
| **Pair Programming** | Gerektiğinde | 2 kişi | 1-2 saat |

## 8. Riskler ve Azaltma

| Risk | Etki | Azaltma Stratejisi |
|------|------|-------------------|
| Flutter Web deneyimi az | Web gecikebilir | Fatma + Yusuf pair programming; erken prototip |
| Emir beceri seti belirsiz | Yük dağıtımı zor | İlk 2 hafta öğrenme; esnek rol (test/destek) |
| 6 kişi koordinasyonu | Çakışma, gecikme | Küçük PR'lar, CODEOWNERS, async iletişim |
| Backend (3 kişi) darboğaz | PR kuyruğu | Domain/App tek owner (Hüseyin), Infra/Server ayrı |
| VPS yoksa deploy | Sunum riski | Hafta 11'de karar; yerel demo planı B |

## 9. Onay ve Güncelleme

Bu doküman **Taslak** durumundadır. Takım onayı ve hoca görüşünden sonra **Onaylandı** yapılacaktır.

| Rol | İsim | Onay | Tarih |
|-----|------|------|-------|
| Tech Lead | Hüseyin Emre | ⬜ | |
| Mobil Lead | Yusuf Ekenel | ⬜ | |
| Backend/Infra | Ertuğrul Pekdemir | ⬜ | |
| Backend/API | Çağdaş Kemal Ağca | ⬜ | |
| Web/QA | Fatma Müberra Yener | ⬜ | |
| Destek | Emir Kerem Çakıcı | ⬜ | |

---

**Not:** Emir Kerem Çakıcı için GitHub kullanıcı adı ve beceri seti netleşince bu doküman güncellenecektir.