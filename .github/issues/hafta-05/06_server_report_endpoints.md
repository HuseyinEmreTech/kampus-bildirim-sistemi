# Issue #6: Bildirim Endpoint'leri - Create, List, Get, Assign

**Milestone:** Hafta 05 (12-18 Eki)
**Atanan:** @Cagdas3307
**Etiketler:** `server`, `feat`, `sart`
**Branch:** `feature/hafta05-report-endpoints`

## Kabul Ölçütleri
- [ ] `POST /api/reports` (multipart/form-data)
  - Request: `CreateReportRequest` (contracts)
    - `photo`: File (image/jpeg|png, max 5MB)
    - `latitude`, `longitude`: Double (GPS)
    - `place`: String? (yer tarifi, max 100 char)
    - `category`: String (Ariza|Temizlik|Guvenlik|Diger)
    - `description`: String (5-500 char)
    - `buildingId`: UUID? (konum izni yoksa)
  - Response: `ReportResponse { reportId, status: "Yeni", createdAt }`
  - **Validasyon**: Contract DTO → Domain/Application command
  - **Hata eşleme**:
    - `DomainError.outsideCampus` → `422 OUTSIDE_CAMPUS`
    - `DomainError.invalidPhoto` → `422 INVALID_PHOTO`
    - `DomainError.buildingNotFound` → `422 BUILDING_NOT_FOUND`
- [ ] `GET /api/reports`
  - Query: `status`, `category`, `assigneeId`, `dateFrom`, `dateTo`, `cursor`, `limit`
  - Response: `PaginatedResponse<ReportSummary>`
  - **Yetki**: Student → `reporterId = currentUser`, Staff → tüm
- [ ] `GET /api/reports/:id`
  - Response: `ReportDetailResponse` (foto URL, konum, durum geçmişi, assignee bilgisi)
  - **Yetki**: Student → kendi bildirimi, Staff → tüm
- [ ] `POST /api/reports/:id/assign`
  - Request: boş (user context'ten alınır)
  - Response: `ReportResponse { status: "Ustlenildi", takenAt }`
  - **Hata**: `409 ALREADY_ASSIGNED` (Rule 02), `403 FORBIDDEN` (Rule 00), `404 NOT_FOUND`

## Dokunulacak Dosyalar
```
packages/server/lib/src/
├── endpoint/
│   └── report_endpoints.dart
├── mapper/
│   └── report_mapper.dart (Domain ↔ Contract DTO)
├── exception/
│   └── exception_mapper.dart (Domain/AppError → HTTP status)
└── middleware/
    └── validation_middleware.dart (request body validation)
```

## Dokunulmayacak Dosyalar
- `packages/domain/` - Entity, Rule'lar
- `packages/application/` - UseCase'ler (Issue #1)
- `packages/contracts/` - Request/Response DTO'lar (import only)
- `packages/infrastructure/` - Repository (inject edilir)

## Hata Eşleme Tablosu (Exception Mapper)
| Domain/AppError | HTTP Status | Error Code |
|-----------------|-------------|------------|
| `DomainError.onlyStaff` | 403 | FORBIDDEN |
| `DomainError.invalidTransition` | 409 | INVALID_TRANSITION |
| `DomainError.alreadyAssigned` | 409 | ALREADY_ASSIGNED |
| `DomainError.notAssignee` | 403 | NOT_ASSIGNEE |
| `DomainError.missingResolutionPhoto` | 422 | MISSING_RESOLUTION_PHOTO |
| `DomainError.outsideCampus` | 422 | OUTSIDE_CAMPUS |
| `DomainError.invalidPhoto` | 422 | INVALID_PHOTO |
| `DomainError.buildingNotFound` | 422 | BUILDING_NOT_FOUND |
| `AppError.repositoryFailure` | 500 | INTERNAL_ERROR |
| `AppError.notFound` | 404 | NOT_FOUND |

## Bağlı Testler
- `packages/server/test/report_endpoints_test.dart`
  - `create_validGps_returns201`
  - `create_buildingFallback_returns201`
  - `create_outsideCampus_returns422`
  - `create_invalidPhoto_returns422`
  - `list_studentSeesOwn_returnsPaginated`
  - `list_staffSeesAll_returnsPaginated`
  - `get_ownReport_returnsDetail`
  - `assign_yeniReport_returns200`
  - `assign_alreadyAssigned_returns409`
  - `assign_notStaff_returns403`

## Bağımlılık
- Issue #1 (Application UseCase'ler) **önce** merge
- Issue #3 (RepositoryImpl) **önce** merge
- `campus_contracts` DTO'lar hazır
- `shelf_multipart` paketi (multipart parsing)

## Notlar
- **Request validation**: Contract DTO `fromJson` + custom validator
- **File upload**: `shelf_multipart` → `FileStorage` (Infrastructure) delegate
- **Konum doğrulama**: Application/UseCase içinde (sunucuda)
- **Response**: Contract DTO `toJson` (camelCase JSON)