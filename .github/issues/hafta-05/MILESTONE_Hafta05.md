# Milestone: Hafta 05 (12 - 18 Ekim 2026)

**Sprint:** Pazartesi 12 Ekim - Pazar 18 Ekim 2026
**Kapanış:** Pazar 18 Ekim 23:59
**Ders:** Cuma 16 Ekim (1 dk/kişi demo)

## Ortak Hedef
> **"Üstlen" (USR 05) uçtan uca çalışıyor + İlk ekran hazır**

| Paket | Teslim Edilecek |
|-------|-----------------|
| `campus_application` | ReportCreateUseCase, ReportAssignUseCase, ReportResolveUseCase, ListReportsUseCase |
| `campus_infrastructure` | ReportRepositoryImpl (CRUD + Rule 02 SQL), FileStorage (foto kaydet, EXIF temizle) |
| `campus_server` | POST /auth/login, POST /auth/refresh, POST /reports, GET /reports, GET /reports/:id, POST /reports/:id/assign |
| `campus_app` (Mobile) | Giriş ekranı, Bildirim listesi (Student), Bildirim oluşturma (foto, konum, kategori) |
| `campus_app` (Web) | Responsive bildirim listesi (yan panel + detay), widget testleri |
| `test` | Rule 02, 04, 05 kabul testleri yeşil |

---

## Issue'lar (Her kişi en az 1 PR birleştirir)

| # | Başlık | Atanan | Etiketler | Öncelik |
|---|--------|--------|-----------|---------|
| 1 | Application UseCase'ler: Create, Assign, Resolve, List | @HuseyinEmreTech | `application`, `feat`, `sart` | 🔴 Şart |
| 2 | Kabul testleri: Rule 02 (yarış), Rule 04 (foto zorunlu), Rule 05 (geçiş) | @HuseyinEmreTech | `test`, `feat`, `sart` | 🔴 Şart |
| 3 | ReportRepositoryImpl: CRUD + Rule 02 koşullu UPDATE | @ertrlpkdmr | `infrastructure`, `feat`, `sart` | 🔴 Şart |
| 4 | FileStorage: Foto kaydet, 5MB limit, EXIF temizle, magic bytes | @ertrlpkdmr | `infrastructure`, `feat`, `sart` | 🔴 Şart |
| 5 | Auth endpoints: login, refresh, JWT middleware, role guard | @Cagdas3307 | `server`, `feat`, `sart` | 🔴 Şart |
| 6 | Bildirim endpoints: create, list, get, assign | @Cagdas3307 | `server`, `feat`, `sart` | 🔴 Şart |
| 7 | Mobil: Giriş ekranı + Auth state (token storage) | @yusufekenel | `app:mobile`, `feat`, `sart` | 🔴 Şart |
| 8 | Mobil: Bildirim listesi (Student) + oluşturma ekranı | @yusufekenel | `app:mobile`, `feat`, `sart` | 🔴 Şart |
| 9 | Web: Responsive bildirim listesi (yan panel) + widget test | @muberrayener | `app:web`, `feat`, `test`, `sart` | 🔴 Şart |
| 10 | Test: Rule 02/04/05 kabul testlerini yeşile çevir | @KeremC23 | `test`, `feat`, `sart` | 🔴 Şart |

---

## Branch İsimlendirme
```
feature/hafta05-<kisa-ad>   → feat issue'lar
test/hafta05-<kisa-ad>      → test issue'lar
```

## Definition of Done (Her PR için)
- [ ] Testler yazıldı ve geçiyor (kabul testleri `@Tags(['bekliyor'])` etiketsiz yeşil)
- [ ] `dart analyze --fatal-infos` sıfır uyarı
- [ ] `dart format .` uygulandı
- [ ] İlgili doküman güncellendi (domain design, API design, vs.)
- [ ] PR şablonu dolu: ne yaptım, AI ne kullanıldı, hangi satırı anlatamıyorum
- [ ] CODEOWNER onayı alındı
- [ ] Squash merge

---

## Bağımlılık Sırası (Bloklama önlemek için)

```
1. HuseyinEmreTech: domain entity'ler hazır → Application interface'ler
2. ertrlpkdmr: Repository interface hazır → Implementation
3. Cagdas3307: Application UseCase hazır → Endpoint çağırır
4. yusufekenel/muberrayener: Contracts DTO hazır → API entegrasyonu
5. KeremC23: Kabul testleri Application/Infrastructure hazır → Yeşile çevirir
```

**Önemli:** Hüseyin Emre önce `campus_application` UseCase arayüzlerini ve DTO'ları push etsin (Pazartesi-Salı), diğerleri beklemesin.