# Hafta 05 (12-18 Ekim 2026) - Sprint Özeti

## Milestone: Hafta 05
**Ortak Hedef:** "Üstlen" (USR 05) uçtan uca çalışıyor + İlk ekran hazır

---

## Issue Dağılımı

| # | Issue | Atanan | Branch | Paket | Öncelik |
|---|-------|--------|--------|-------|---------|
| 1 | Application UseCase'ler: Create, Assign, Resolve, List | @HuseyinEmreTech | `feature/hafta05-application-usecases` | `application` | 🔴 Şart |
| 2 | Kabul Testleri: Rule 02, 04, 05 yazımı | @HuseyinEmreTech | `test/hafta05-kabul-rule02-04-05` | `test` | 🔴 Şart |
| 3 | ReportRepositoryImpl: CRUD + Rule 02 SQL | @ertrlpkdmr | `feature/hafta05-report-repository-impl` | `infrastructure` | 🔴 Şart |
| 4 | FileStorage: Foto kaydet, 5MB, EXIF, magic bytes | @ertrlpkdmr | `feature/hafta05-file-storage` | `infrastructure` | 🔴 Şart |
| 5 | Auth Endpoints: login, refresh, JWT, role guard | @Cagdas3307 | `feature/hafta05-auth-endpoints` | `server` | 🔴 Şart |
| 6 | Bildirim Endpoint'leri: create, list, get, assign | @Cagdas3307 | `feature/hafta05-report-endpoints` | `server` | 🔴 Şart |
| 7 | Mobil: Giriş ekranı + Auth state (token storage) | @yusufekenel | `feature/hafta05-mobile-auth` | `app:mobile` | 🔴 Şart |
| 8 | Mobil: Bildirim listesi + oluşturma (foto, konum, kategori) | @yusufekenel | `feature/hafta05-mobile-reports` | `app:mobile` | 🔴 Şart |
| 9 | Web: Responsive bildirim listesi (yan panel) + widget test | @muberrayener | `feature/hafta05-web-report-list` | `app:web`, `test` | 🔴 Şart |
| 10 | Test: Rule 02/04/05 kabul testlerini yeşile çevir | @KeremC23 | `test/hafta05-kabul-rule02-04-05` | `test` | 🔴 Şart |

---

## Bağımlılık Sırası (Kritik)

```
PAZARTESİ-SALI (12-13 Eki):
├── #1 HuseyinEmreTech: Application UseCase interface + DTO'lar → PUSH
├── #2 HuseyinEmreTech: Kabul testleri yaz → PUSH (@Tags['bekliyor'])
├── #3 ertrlpkdmr: Repository interface kontrol → Implementation başla
└── #5 Cagdas3307: Auth service + middleware başla

ÇARŞAMBA-PERŞEMBE (14-15 Eki):
├── #1, #3, #5 MERGE (CI yeşil)
├── #6 Cagdas3307: Report endpoints (UseCase + Repository inject)
├── #4 ertrlpkdmr: FileStorage implementation
├── #7 yusufekenel: Mobil auth (mock API ile başla)
├── #9 muberrayener: Web responsive layout (paylaşılan widget'larla)
└── #8 yusufekenel: Mobil reports (API entegrasyonu)

CUMA (16 Eki) - DERS:
├── Herkes 1 dk demo: Ne merge edildi, ne bloklandı?
├── #10 KeremC23: Kabul testleri yeşile çevir (pair programming)
└── Bloklar çözülmedi ise: Issue'a yaz, Pazar'a kadar çöz

CUMARTESİ-PAZAR (17-18 Eki):
├── Kalan PR'lar merge
├── Integration test: Mobil + Server + DB uçtan uca
└── Pazar 23:59: Milestone kapanır
```

---

## Definition of Ready (Her Issue Başlamadan Önce)
- [ ] Issue açıklaması dolu (kabul ölçütü, dosyalar, testler)
- [ ] Bağımlılık issue'ları **merge edilmiş** veya **mock ile başlanabilir**
- [ ] Branch açılmış (`feature/hafta05-...` veya `test/hafta05-...`)

## Definition of Done (Her PR için)
- [ ] Testler yazıldı/yeşil (kabul testleri etiketsiz)
- [ ] `dart analyze --fatal-infos` sıfır uyarı
- [ ] `dart format .` uygulandı
- [ ] İlgili doküman güncellendi (domain-design, api-design, vb.)
- [ ] PR şablonu dolu: ne yaptım, AI kullanımı, anlatamadığım satır
- [ ] CODEOWNER onayı (@HuseyinEmreTech domain/app/contracts, @ertrlpkdmr infra, @Cagdas3307 server, @yusufekenel/@muberrayener app)
- [ ] Squash merge

---

## Günlük Standup (Async - GitHub Issue Yorumunda)
Her gün akşam Issue'a yorum olarak:
```
**Gün:** 13 Ekim 2026
**Yaptım:** UseCase interface'ler push edildi, Test yazıldı
**Yapamadım:** RepositoryImpl henüz başlayamadım (UseCase bekliyordum)
**Blok:** Yok
**Yarın:** RepositoryImpl başla, FileStorage araştır
**AI Kullanımı:** UseCase template için Claude kullandım, manuel doğruladım
```

---

## Riskler ve Mitigasyon
| Risk | Etki | Mitigasyon |
|------|------|------------|
| Application UseCase gecikirse herkes bloke olur | Yüksek | Hüseyin Emre **Pazartesi-Salı** push zorunlu |
| Repository SQL (Rule 02) yanlış yazılır | Yüksek | Ertuğrul + Hüseyin Emre pair programming |
| Auth token refresh loop | Orta | Çağdaş test yaz, Yusuf manuel test et |
| Web/Mobil widget paylaşımı çakışır | Orta | Yusuf + Fatma **Salı** senkron toplantısı (15 dk) |
| Emir testleri anlayamaz | Düşük | 30 dk kuralı, Hüseyin Emre pair programming |

---

## Hafta Sonu Çıktısı (Pazar 18 Eki 23:59)
- [ ] "Üstlen" butonu: Mobil (Student listesi) → API → DB → Yanıt → UI güncelleme **uçtan uca çalışıyor**
- [ ] Giriş ekranı (Mobil + Web) çalışıyor
- [ ] Bildirim oluşturma (Mobil) çalışıyor (mock/server)
- [ ] Web responsive liste (Desktop yan panel) çalışıyor
- [ ] Rule 02, 04, 05 testleri **yeşil** (etiketsiz)
- [ ] CI her PR'da yeşil
- [ ] En az 6 birleşmiş PR (herkes en az 1)