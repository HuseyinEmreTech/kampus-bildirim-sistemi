# Issue #10: Test - Rule 02, 04, 05 Kabul Testlerini Yeşile Çevir

**Milestone:** Hafta 05 (12-18 Eki)
**Atanan:** @KeremC23
**Etiketler:** `test`, `feat`, `sart`
**Branch:** `test/hafta05-kabul-rule02-04-05`

## Kabul Ölçütleri
Tüm testler **zaten yazılmış** `@Tags(['bekliyor'])` ile. Görev: **Implementation yapıp testleri yeşile çevirip etiketi kaldırmak**.

> **Önemli:** Bu issue **öğrenme amaçlıdır**. Takılma, soru sorma, pair programming yapma serbesttir. 30 dakika kuralı uygulanır.

### Test Dosyaları (Hazır - `packages/application/test/kabul/` ve `packages/infrastructure/test/kabul/`)

| Test Dosyası | Kural | Ne Test Ediyor | Beklenen Sonuç |
|-------------|-------|----------------|----------------|
| `report_assign_race_condition_test.dart` | Rule 02 | İki paralel assign → biri success, diğeri `alreadyAssigned` | Yeşil |
| `report_resolve_requires_photo_test.dart` | Rule 04 | ResolutionPhoto olmadan resolve → `missingResolutionPhoto` | Yeşil |
| `report_resolve_requires_photo_test.dart` | Rule 04 | ResolutionPhoto ile resolve → success + Notification + StatusHistory | Yeşil |
| `report_invalid_transitions_test.dart` | Rule 05 | Yeni→Cozuldu, Ustlenildi→Yeni → `invalidTransition` | Yeşil |

## Yapılacaklar (Adım Adım)

### 1. Testleri Çalıştır ve Kırmızı Görevin Anla
```bash
cd packages/application
dart test test/kabul/report_assign_race_condition_test.dart --tags=bekliyor
dart test test/kabul/report_resolve_requires_photo_test.dart --tags=bekliyor
dart test test/kabul/report_invalid_transitions_test.dart --tags=bekliyor
```

### 2. Hangi Implementation Eksik? (Hüseyin Emre / Ertuğrul ile Konuş)
- **Application**: UseCase'ler (Issue #1) - `ReportAssignUseCase`, `ReportResolveUseCase`
- **Infrastructure**: RepositoryImpl (Issue #3) - `assign()`, `resolve()` SQL
- **Domain**: `Report.assign()`, `Report.resolve()` metotları

### 3. Eksik Kodu Yaz (Pair Programming İste)
- Hüseyin Emre ile: Application UseCase implementation
- Ertuğrul ile: RepositoryImpl SQL (Rule 02 koşullu UPDATE)

### 4. Testleri Yeşile Çevir
```bash
# Etiketi kaldır
# @Tags(['bekliyor']) → satırı sil veya comment out

# Tekrar çalıştır (etiketsiz)
dart test test/kabul/report_assign_race_condition_test.dart
# ... diğerleri
```

### 5. CI Kontrolü
- Local: `dart analyze --fatal-infos`, `dart test`
- PR aç: CI yeşil mi?

## Dokunulacak Dosyalar (Sadece Okuma + Anlama)
```
packages/application/test/kabul/
├── report_assign_race_condition_test.dart
├── report_resolve_requires_photo_test.dart
└── report_invalid_transitions_test.dart

packages/infrastructure/test/kabul/
└── report_repository_race_condition_test.dart (DB seviyesi Rule 02)
```

## Dokunulmayacak Dosyalar
- **Test dosyaları DEĞİŞTİRİLMEZ** (sadece `@Tags(['bekliyor'])` etiketi kaldırılır)
- `packages/domain/` - Domain logic (Hüseyin Emre)
- `packages/application/lib/` - UseCase impl (Hüseyin Emre)
- `packages/infrastructure/lib/` - Repository impl (Ertuğrul)

## Öğrenme Hedefleri (Bu Hafta)
- [ ] `Result` pattern (Success/Failure) anlama
- [ ] `sealed class AppError` ve `switch` eşleme
- [ ] Rule 02: DB seviyesi yarış durumu nasıl önlenir (`WHERE assignee_id IS NULL`)
- [ ] Rule 04: Transaction (Resolve + Notification + StatusHistory)
- [ ] Rule 05: State machine geçiş kontrolü
- [ ] Fake/InMemory repository vs Real PostgreSQL test
- [ ] `dart test` komutları, tag filtreleme

## Bağımlılık
- Issue #1 (Application UseCase'ler) **merge edilmeli**
- Issue #3 (RepositoryImpl) **merge edilmeli**
- Issue #2 (Kabul testleri yazımı) **hazır olmalı**

## Yardım / Pair Programming
| Konu | Kime Danış |
|------|------------|
| Test nasıl çalışır, ne test ediyor? | Hüseyin Emre |
| UseCase implementation nasıl yazılır? | Hüseyin Emre |
| Repository SQL nasıl yazılır? | Ertuğrul |
| `Result` pattern, sealed class? | Hüseyin Emre |
| Git/PR nasıl açılır? | Herkes |

## Notlar
- **Test değiştirme yasaktır** - Sadece implementation yaz, etiketi kaldır
- Değiştirilmesi gereken bir test varsa → Issue'a yorum yaz, Hüseyin Emre ile konuş
- PR açıklamasında: "Ne yaptım, Ne anladım, Neyi anlayamadım" bölümlerini doldur
- İnceleyen (Hüseyin Emre) en az bir "bu satır neden böyle?" sorusu soracak