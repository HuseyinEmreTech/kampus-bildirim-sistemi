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

Report _newReport() {
  final result = Report.create(
    reporterId: _student,
    category: 'ariza',
    description: 'Arayüz testi bildirimi',
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

    Future<ReportId> createReport() async {
      final result = await repository.create(_newReport());
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
  }, skip: url == null ? 'DATABASE_URL tanımlı değil' : false);
}
