# Issue #1: Application UseCase'ler - Create, Assign, Resolve, List

**Milestone:** Hafta 05 (12-18 Eki)
**Atanan:** @HuseyinEmreTech
**Etiketler:** `application`, `feat`, `sart`
**Branch:** `feature/hafta05-application-usecases`

## Kabul Ölçütleri
- [ ] `ReportCreateUseCase.execute(CreateReportCommand)` → `Result<ReportId, AppError>`
  - Fotoğraf, konum, kategori, açıklama valide edilir
  - ReporterId current user'dan alınır
  - Domain `Report.create()` çağrılır, repository kaydeder
- [ ] `ReportAssignUseCase.execute(AssignReportCommand)` → `Result<Unit, AppError>`
  - Sadece Staff çalıştırabilir (Rule 00)
  - Status `Yeni` olmalı (Rule 05)
  - Repository `assign()` çağrılır (Rule 02: DB seviyesinde)
  - Başarılı olursa `StatusHistory` kaydedilir
- [ ] `ReportResolveUseCase.execute(ResolveReportCommand)` → `Result<Unit, AppError>`
  - Sadece assignee çalıştırabilir (Rule 03)
  - Status `Ustlenildi` olmalı (Rule 05)
  - **ResolutionPhoto zorunlu** (Rule 04)
  - Transaction: Report resolve + Notification create + StatusHistory
- [ ] `ListReportsUseCase.execute(ListReportsQuery)` → `Result<Paginated<ReportSummary>, AppError>`
  - Filtre: status, category, assigneeId, dateRange
  - Sayfalama: cursor-based (keyset)
  - Student: sadece `reporterId = currentUser`
  - Staff: tümünü görebilir, `assignee=me` filtresi opsiyonel

## Dokunulacak Dosyalar
```
packages/application/lib/src/
├── usecase/
│   ├── report_create_usecase.dart
│   ├── report_assign_usecase.dart
│   ├── report_resolve_usecase.dart
│   └── list_reports_usecase.dart
├── dto/
│   ├── create_report_command.dart
│   ├── assign_report_command.dart
│   ├── resolve_report_command.dart
│   └── list_reports_query.dart
└── service/
    └── report_service.dart (interface)
```

## Dokunulmayacak Dosyalar
- `packages/domain/` - Domain zaten hazır olmalı
- `packages/contracts/` - DTO'lar ayrı pakette
- `packages/infrastructure/` - Repository impl ayrı issue

## Bağlı Testler (Kabul Testleri - @Tags(['bekliyor']))
- `test/kabul/report_create_usecase_test.dart`
- `test/kabul/report_assign_usecase_test.dart` (Rule 02 yarış)
- `test/kabul/report_resolve_usecase_test.dart` (Rule 04 foto zorunlu, Rule 05 geçiş)
- `test/kabul/list_reports_usecase_test.dart`

## Notlar
- UseCase'ler **sadece** `campus_domain` ve `campus_application` bağımlılığına sahip olmalı
- `dart:io`, `postgres`, `shelf` import **YASAK**
- Hata tipleri `AppError` sealed class altındadır
- Zaman `Clock` arayüzü ile alınır (testlerde sabitlenir)