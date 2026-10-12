# Issue #2: Kabul Testleri - Rule 02, 04, 05

**Milestone:** Hafta 05 (12-18 Eki)
**Atanan:** @HuseyinEmreTech
**Etiketler:** `test`, `feat`, `sart`
**Branch:** `test/hafta05-kabul-rule02-04-05`

## Kabul Ölçütleri
Tüm testler **önceden yazılır**, `@Tags(['bekliyor'])` ile işaretlenir. CI bu etiketi atlar. Görev: testleri yeşile çevirip etiketi kaldırmak.

### Test Senaryoları

#### Rule 02: Yarış Durumu (Assign)
```dart
// test/kabul/report_assign_race_condition_test.dart
test('Aynı anda iki görevli üstlenmeye çalışırsa yalnızca biri başarılır', () async {
  // Arrange: Report status = Yeni, assigneeId = null
  // Act: İki paralel AssignReportCommand.execute()
  // Assert: Birinci success, ikinci failure(AppError.alreadyAssigned)
  //         DB'de affectedRows = 1 kontrolü (Infrastructure testinde)
});
```

#### Rule 04: Çözme - Sonuç Fotoğrafı Zorunlu
```dart
// test/kabul/report_resolve_requires_photo_test.dart
test('ResolutionPhoto olmadan Resolve AppError.missingResolutionPhoto döner', () async {
  // Arrange: Report status = Ustlenildi, assignee = currentUser
  // Act: ResolveReportCommand(resolutionPhoto: null, ...)
  // Assert: Failure(AppError.missingResolutionPhoto)
});

test('ResolutionPhoto ile Resolve başarıyla tamamlanır', () async {
  // Arrange: Report status = Ustlenildi, assignee = currentUser
  // Act: ResolveReportCommand(resolutionPhoto: validPhoto, ...)
  // Assert: Success, status = Cozuldu, Notification oluştu, StatusHistory yazıldı
});
```

#### Rule 05: Geçersiz Durum Geçişleri
```dart
// test/kabul/report_invalid_transitions_test.dart
test('Yeni -> Cozuldu doğrudan geçiş AppError.invalidTransition döner', () async {
  // Act: Resolve on Yeni report
  // Assert: Failure(AppError.invalidTransition)
});

test('Ustlenildi -> Yeni geri geçiş AppError.invalidTransition döner', () async {
  // Act: Assign sonrası manuel status değiştirme denemesi
  // Assert: Failure
});
```

## Dokunulacak Dosyalar
```
packages/application/test/kabul/
├── report_create_usecase_test.dart
├── report_assign_usecase_test.dart
├── report_resolve_usecase_test.dart
├── report_invalid_transitions_test.dart
└── list_reports_usecase_test.dart
```

## Dokunulmayacak Dosyalar
- `packages/domain/test/` - Domain testleri ayrı
- `packages/infrastructure/test/` - DB testleri ayrı (entegre test)
- `packages/server/test/` - HTTP testleri ayrı

## Bağımlılık
- Issue #1 (Application UseCase'ler) **önce** merge edilmeli
- `campus_application` paketi build edilebilir olmalı

## Notlar
- Test isimleri: `metot_senaryo_beklenenSonuc` (örn: `execute_whenPhotoNull_returnsMissingResolutionPhoto`)
- Arrange / Act / Assert blokları net ayrılmalı
- Fake/InMemory repository kullan (domain/test içindeki `FakeReportRepository`)
- Test değişmez; sadece implementation yapılır