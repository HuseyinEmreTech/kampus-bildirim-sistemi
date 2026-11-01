// Gerçek PostgreSQL ister: DATABASE_URL ortam değişkeni (README §10, .env.example).
// Application'daki `ReportRepository` arayüzünün PostgreSQL karşılığı: domain
// nesneleri ve `AppError` ile çalışır.
@Tags(['db'])
library;

import 'dart:io';

import 'package:campus_application/campus_application.dart';
import 'package:campus_domain/campus_domain.dart';
import 'package:campus_infrastructure/campus_infrastructure.dart';
import 'package:test/test.dart';

// Diğer test dosyalarıyla çakışmayan sabit kimlikler.
const _student = 'a0000000-0000-4000-8000-000000000091';
const _staffA = 'a0000000-0000-4000-8000-000000000092';
const _staffB = 'a0000000-0000-4000-8000-000000000093';
const _missingReport = 'c0000000-0000-4000-8000-000000000099';

const _insertUser = r'''
INSERT INTO users (user_id, full_name, email, password_hash, role)
VALUES ($1, $2, $3, 'test-hash', $4)
''';

const _reportRow = r'''
SELECT category, status, location_source, created_at FROM reports
WHERE report_id = $1
''';

const _historyCount =
    r'SELECT count(*) FROM status_history WHERE report_id = $1';

const _notificationCount =
    r'SELECT count(*) FROM notifications WHERE report_id = $1';

Future<void> _deleteFixtures(Database db) async {
  const ofStudent = 'SELECT report_id FROM reports WHERE reporter_id = \$1';
  await db.execute(
    'DELETE FROM notifications WHERE report_id IN ($ofStudent)',
    [_student],
  );
  await db.execute(
    'DELETE FROM status_history WHERE report_id IN ($ofStudent)',
    [_student],
  );
  await db.execute(r'DELETE FROM reports WHERE reporter_id = $1', [_student]);
  await db.execute(r'DELETE FROM users WHERE user_id IN ($1, $2, $3)', [
    _student,
    _staffA,
    _staffB,
  ]);
}

Report _newReport({String description = 'Arayüz testi bildirimi'}) {
  final result = Report.create(
    reporterId: _student,
    category: 'ariza',
    description: description,
    photoUrl: '/files/arayuz.jpg',
    photoContentType: 'image/jpeg',
    photoSizeBytes: 1000,
    latitude: 36.5871,
    longitude: 36.1742,
    locationSource: 'gps',
    createdAt: DateTime.now(),
  );
  return (result as Success<Report, DomainError>).value;
}

UserId _userId(String value) =>
    (UserId.create(value) as Success<UserId, DomainError>).value;

ReportId _reportId(String value) =>
    (ReportId.create(value) as Success<ReportId, DomainError>).value;

Photo _resolutionPhoto() => (Photo.create(
  url: '/files/sonuc.jpg',
  contentType: 'image/jpeg',
  sizeBytes: 2000,
) as Success<Photo, DomainError>).value;

void main() {
  final url = Platform.environment['DATABASE_URL'];

  group('PostgresReportRepository', () {
    late Database db;
    late PostgresReportRepository repository;

    setUpAll(() {
      db = Database.fromUrl(url!);
      repository = PostgresReportRepository(db);
    });
    tearDownAll(() => db.close());

    setUp(() async {
      await _deleteFixtures(db);
      await db.execute(_insertUser, [
        _student,
        'Arayüz Öğrenci',
        'arayuz.ogr@test.edu',
        'Student',
      ]);
      await db.execute(_insertUser, [
        _staffA,
        'Arayüz Görevli A',
        'arayuz.a@test.edu',
        'Staff',
      ]);
      await db.execute(_insertUser, [
        _staffB,
        'Arayüz Görevli B',
        'arayuz.b@test.edu',
        'Staff',
      ]);
    });
    tearDown(() => _deleteFixtures(db));

    Future<ReportId> createReport({String? description}) async {
      final report = description == null
          ? _newReport()
          : _newReport(description: description);
      final result = await repository.create(report);
      return (result as Success<ReportId, AppError>).value;
    }

    test('create_savesWithDomainIdAndDatabaseSpelling', () async {
      final report = _newReport();

      final result = await repository.create(report);

      expect(result, isA<Success<ReportId, AppError>>());
      final id = (result as Success<ReportId, AppError>).value;
      expect(id.value, report.id.value);
      final [[category, status, source, _]] = await db.execute(_reportRow, [
        id.value,
      ]);
      expect([category, status, source], ['Ariza', 'Yeni', 'Gps']);
      expect((await db.execute(_historyCount, [id.value])).single.single, 1);
    });

    test('assign_newReport_succeeds', () async {
      final id = await createReport();

      final result = await repository.assign(id, _userId(_staffA));

      expect(result, isA<Success<Unit, AppError>>());
      final [[_, status, _, _]] = await db.execute(_reportRow, [id.value]);
      expect(status, 'Ustlenildi');
    });

    // Rule 02: ikinci görevli kaybeder; durum ve görevli değişmez.
    test('assign_alreadyAssigned_returnsConflict', () async {
      final id = await createReport();
      await repository.assign(id, _userId(_staffA));

      final result = await repository.assign(id, _userId(_staffB));

      expect((result as Failure<Unit, AppError>).error, isA<ConflictError>());
    });

    test('assign_missingReport_returnsNotFound', () async {
      final result = await repository.assign(
        _reportId(_missingReport),
        _userId(_staffA),
      );

      expect((result as Failure<Unit, AppError>).error, isA<NotFoundError>());
    });

    // Rule 04: çözülünce öğrenciye bildirim de yazılır.
    test('resolve_byAssignee_succeedsAndNotifies', () async {
      final id = await createReport();
      await repository.assign(id, _userId(_staffA));

      final result = await repository.resolve(
        id,
        _userId(_staffA),
        _resolutionPhoto(),
        note: 'Değiştirildi',
      );

      expect(result, isA<Success<Unit, AppError>>());
      expect(
        (await db.execute(_notificationCount, [id.value])).single.single,
        1,
      );
      // Rule 04: durumla birlikte geçmiş satırı da yazılır (oluşturma, üstlenme, çözme).
      expect((await db.execute(_historyCount, [id.value])).single.single, 3);
    });

    // Rule 03: yalnızca üstlenen görevli çözebilir.
    test('resolve_byOtherStaff_returnsForbidden', () async {
      final id = await createReport();
      await repository.assign(id, _userId(_staffA));

      final result = await repository.resolve(
        id,
        _userId(_staffB),
        _resolutionPhoto(),
      );

      expect((result as Failure<Unit, AppError>).error, isA<ForbiddenError>());
    });

    test('resolve_notAssigned_returnsInvalidTransition', () async {
      final id = await createReport();

      final result = await repository.resolve(
        id,
        _userId(_staffA),
        _resolutionPhoto(),
      );

      expect(
        (result as Failure<Unit, AppError>).error,
        isA<InvalidTransitionError>(),
      );
    });

    test('list_returnsPageWithTotal', () async {
      for (var i = 1; i <= 3; i++) {
        await createReport(description: 'Arayüz liste $i');
      }
      final filter = ReportListFilter(reporterId: _userId(_student));

      final first = await repository.list(filter: filter, limit: 2, offset: 0);
      final second = await repository.list(filter: filter, limit: 2, offset: 2);

      final firstPage =
          (first as Success<Paginated<ReportSummary>, AppError>).value;
      expect(firstPage.items, hasLength(2));
      expect(firstPage.total, 3);
      expect(firstPage.page, 1);
      expect(firstPage.pageSize, 2);
      // API'deki yazım (05-api-design): `Yeni`, `Ariza`.
      expect(firstPage.items.first.status, 'Yeni');
      expect(firstPage.items.first.category, 'Ariza');
      final secondPage =
          (second as Success<Paginated<ReportSummary>, AppError>).value;
      expect(secondPage.items, hasLength(1));
      expect(secondPage.page, 2);
    });

    // Yorumdaki söz: geçersiz sayfada depo boş sayfa döner, toplam da 0 olur.
    test('list_invalidPage_returnsEmptyPageWithZeroTotal', () async {
      await createReport(description: 'Arayüz geçersiz sayfa');
      final filter = ReportListFilter(reporterId: _userId(_student));

      final result = await repository.list(filter: filter, limit: 0, offset: 0);

      final page =
          (result as Success<Paginated<ReportSummary>, AppError>).value;
      expect(page.items, isEmpty);
      expect(page.total, 0);
    });

    test('list_statusAndCategoryFilter_usesDatabaseSpelling', () async {
      final taken = await createReport();
      await createReport();
      await repository.assign(taken, _userId(_staffA));

      final result = await repository.list(
        filter: ReportListFilter(
          status: ReportStatus.ustlenildi,
          category: Category.ariza,
          reporterId: _userId(_student),
        ),
        limit: 10,
        offset: 0,
      );

      final page =
          (result as Success<Paginated<ReportSummary>, AppError>).value;
      expect(page.items.map((r) => r.reportId), [taken.value]);
      expect(page.total, 1);
    });

    // Veritabanına ulaşılamazken istisna dışarı sızmaz; `UnknownError` döner.
    test('assign_databaseUnreachable_returnsUnknownError', () async {
      // 1 numaralı portta PostgreSQL yok; bağlantı hemen reddedilir.
      final unreachable = Database.fromUrl(
        'postgres://campus:yok@127.0.0.1:1/campus?sslmode=disable&connect_timeout=2',
      );
      addTearDown(unreachable.close);

      final result = await PostgresReportRepository(unreachable)
          .assign(_reportId(_missingReport), _userId(_staffA));

      expect((result as Failure<Unit, AppError>).error, isA<UnknownError>());
    });

    test('findById_resolvedReport_restoresAllFields', () async {
      final id = await createReport();
      await repository.assign(id, _userId(_staffA));
      await repository.resolve(
        id,
        _userId(_staffA),
        _resolutionPhoto(),
        note: 'Değiştirildi',
      );

      final result = await repository.findById(id);

      final report = (result as Success<Report?, AppError>).value!;
      expect(report.id.value, id.value);
      expect(report.reporterId.value, _student);
      expect(report.assigneeId?.value, _staffA);
      expect(report.category, Category.ariza);
      expect(report.description, 'Arayüz testi bildirimi');
      expect(report.status, ReportStatus.cozuldu);
      expect(report.photo.url, '/files/arayuz.jpg');
      expect(report.location.source, LocationSource.gps);
      expect(report.location.latitude, 36.5871);
      expect(report.takenAt, isNotNull);
      expect(report.resolvedAt, isNotNull);
      expect(report.resolutionPhoto?.url, '/files/sonuc.jpg');
      expect(report.resolutionNote, 'Değiştirildi');
    });

    test('findById_newReport_hasNoAssigneeOrResolution', () async {
      final id = await createReport();

      final result = await repository.findById(id);

      final report = (result as Success<Report?, AppError>).value!;
      expect(report.status, ReportStatus.yeni);
      expect(report.assigneeId, isNull);
      expect(report.takenAt, isNull);
      expect(report.resolutionPhoto, isNull);
    });

    test('findById_missingReport_returnsNull', () async {
      final result = await repository.findById(_reportId(_missingReport));

      expect((result as Success<Report?, AppError>).value, isNull);
    });
  }, skip: url == null ? 'DATABASE_URL tanımlı değil' : false);
}
