# Issue #3: ReportRepositoryImpl - CRUD + Rule 02 SQL

**Milestone:** Hafta 05 (12-18 Eki)
**Atanan:** @ertrlpkdmr
**Etiketler:** `infrastructure`, `feat`, `sart`
**Branch:** `feature/hafta05-report-repository-impl`

## Kabul Ölçütleri
- [ ] `ReportRepositoryImpl` implements `ReportRepository` (Application interface)
- [ ] `create(Report)` → INSERT + RETURNING reportId
- [ ] `findById(ReportId)` → JOIN users, buildings → `Report` aggregate
- [ ] `list(ListReportsQuery)` → Filtreli, sayfalı (keyset pagination)
- [ ] `assign(ReportId, UserId)` → **Rule 02 SQL**:
  ```sql
  UPDATE reports 
  SET assignee_id = $1, taken_at = NOW(), status = 'Ustlenildi'
  WHERE report_id = $2 AND assignee_id IS NULL AND status = 'Yeni'
  ```
  → `affectedRows == 1` ise success, `0` ise `DomainError.alreadyAssigned`
- [ ] `resolve(ReportId, ResolutionPhoto, String?)` → UPDATE status, photo, note, resolved_at
- [ ] `addStatusHistory(ReportId, from, to, changedBy, note)` → INSERT

## Dokunulacak Dosyalar
```
packages/infrastructure/lib/src/
├── repository/
│   ├── report_repository_impl.dart
│   ├── user_repository_impl.dart
│   ├── building_repository_impl.dart
│   └── notification_repository_impl.dart
├── database/
│   ├── database.dart (connection pool)
│   └── transaction.dart (helper)
└── mapper/
    └── report_mapper.dart (Row → Domain Entity)
```

## Dokunulmayacak Dosyalar
- `packages/domain/` - Entity, Repository interface
- `packages/application/` - UseCase'ler
- `packages/server/` - Endpoint'ler

## Bağlı Testler
- `packages/infrastructure/test/repository/report_repository_impl_test.dart`
  - `create_returnsReportWithId`
  - `findById_returnsAggregate`
  - `assign_whenAlreadyAssigned_returnsAlreadyAssigned` (Rule 02)
  - `assign_whenNotYeni_returnsInvalidTransition` (Rule 05)
  - `resolve_whenNotAssignee_returnsNotAssignee` (Rule 03)
  - `list_withFilters_returnsPaginated`

## Migration (Ayri PR/Commit)
```sql
-- db/migrations/V1__init.sql
CREATE TABLE reports (
  report_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  reporter_id UUID NOT NULL REFERENCES users(user_id),
  assignee_id UUID REFERENCES users(user_id),
  category VARCHAR(20) NOT NULL CHECK (category IN ('Ariza','Temizlik','Guvenlik','Diger')),
  description VARCHAR(500) NOT NULL,
  photo_url VARCHAR(500) NOT NULL,
  photo_content_type VARCHAR(50) NOT NULL,
  photo_size_bytes BIGINT NOT NULL,
  latitude DOUBLE PRECISION NOT NULL,
  longitude DOUBLE PRECISION NOT NULL,
  place VARCHAR(100),
  location_source VARCHAR(10) NOT NULL CHECK (location_source IN ('Gps','Building')),
  building_id UUID REFERENCES buildings(building_id),
  status VARCHAR(20) NOT NULL DEFAULT 'Yeni' CHECK (status IN ('Yeni','Ustlenildi','Cozuldu')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  taken_at TIMESTAMPTZ,
  resolved_at TIMESTAMPTZ,
  resolution_photo_url VARCHAR(500),
  resolution_photo_content_type VARCHAR(50),
  resolution_photo_size_bytes BIGINT,
  resolution_note VARCHAR(500)
);

CREATE INDEX idx_reports_status_created ON reports(status, created_at DESC);
CREATE INDEX idx_reports_assignee ON reports(assignee_id) WHERE assignee_id IS NOT NULL;
```

## Notlar
- Parametreli query (`$1`, `$2`) **ZORUNLU** - String interpolation YASAK
- `postgres` paketi connection pool: `maxConnections: 10`, `idleTimeout: 30s`
- Transaction helper: `db.transaction((tx) => ...)` pattern
- Mapper: Domain entity oluştururken `Report._()` private constructor kullanır
- `Clock` interface implementasyonu: `SystemClock` (prod), `FixedClock` (test)