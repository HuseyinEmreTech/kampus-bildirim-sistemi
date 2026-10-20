---
title: 18 Ekim 2026 - PR Birleşme ve Issue Notları
durum: Güncel
son-guncelleme: 2026-10-18
---

# 18 Ekim 2026 - PR Birleşme ve Issue Notları

← [İndeks](../00-index.md)

Bu notun süreç gerekçeleri: [Yığın PR birleşme süreci](2026-10-17-yigin-pr-birlesme-sureci.md).

## Birleşen PR'lar

- **Veri katmanı zinciri:** #52 (resolve), #60 (create), #61 (findById), #62 (findHistory), #63 (list) — sırayla, üst üste base'li.
- **Depolama:** #53 (EXIF temizleme), #54 (fotoğraf okuma/silme).
- **Diğer altyapı:** #55 (bina deposu), #56 (öğrenci bildirim listesi), #57 (V4 tarih indeksi), #58 (yedek docs), #59 (sağlık kontrolü), #64 (Docker/canlı compose), #65 (bağlantı zaman aşımları), #66 (havuz sızıntı testi).
- **Sunucu:** #67 (JWT belirteç servisi), #68 (günlük rapor).
- **Uygulama:** #70 (mobil oluşturma ekranı), #72 (application use case'ler), #73 (kabul testleri), #74 (web bildirim listesi).
- **Süreç/domain:** #71 (yığın PR notları), #75 (`Report.restore`), #76 (CODEOWNERS yedek sahip).

## Kararlar

| Konu | Karar |
| --- | --- |
| Sayfalama | `page` + `pageSize` (offset); keyset gerekmiyor |
| Fotoğraf saklama süresi | 30 gün; ayrı migration ile `photos_deleted_at` |
| `contracts` DTO'ları | Lead üstleniyor (#20'nin önü) |
| Mobil paketler | `flutter_secure_storage`, `http`, `image_picker`, `geolocator` onaylı |
| CODEOWNERS | `domain`, `application`, `contracts`, `test/` için Ertuğrul ikinci sahip |
| Fotoğraf/konum | #21'in sonraki parçası |

## Issue'lar

- **Açıldı:** #77 (mobil giriş), #78 (görevli listesi + üstlen), #79 (çözüldü bildirimleri) — Yusuf'a atandı.
- **Kapandı:** #23 (Rule 02/04/05 kabul testleri; `bekliyor` etiketi kalmadı).
- **Açık:** #17 ve #18 (repository/storage arayüz adaptasyonu), #20 (sunucu endpoint'leri), #21 (mobil kalan parçalar), #45 (dil tartışması).

## Açık sorular ve sıradaki iş

- `contracts` DTO'ları → sunucu endpoint'leri (#20).
- `ReportRepository` / `FileStorage` arayüz adaptasyonu (#17, #18).
- Fotoğraf saklama işi (30 gün, `photos_deleted_at`).
