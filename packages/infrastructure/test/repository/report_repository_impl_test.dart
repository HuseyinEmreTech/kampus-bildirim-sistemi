// Gerçek PostgreSQL ister: DATABASE_URL ortam değişkeni (README §10, .env.example).
@Tags(['db'])
library;

import 'dart:io';

import 'package:campus_infrastructure/campus_infrastructure.dart';
import 'package:test/test.dart';

// Seed verisiyle çakışmayan sabit kimlikler; her testten önce kurulur, sonra silinir.
const _student = 'a0000000-0000-4000-8000-0000000000f1';
const _staffA = 'a0000000-0000-4000-8000-0000000000f2';
const _staffB = 'a0000000-0000-4000-8000-0000000000f3';
const _newReport = 'c0000000-0000-4000-8000-0000000000f1';
const _resolvedReport = 'c0000000-0000-4000-8000-0000000000f2';
const _missingReport = 'c0000000-0000-4000-8000-0000000000ff';

const _insertUser = r'''
INSERT INTO users (user_id, full_name, email, password_hash, role)
VALUES ($1, $2, $3, 'test-hash', $4)
''';

const _insertNewReport = r'''
INSERT INTO reports (report_id, reporter_id, category, description, photo_url,
  photo_content_type, photo_size_bytes, latitude, longitude, location_source)
VALUES ($1, $2, 'Ariza', 'Test bildirimi', '/files/test.jpg', 'image/jpeg', 1000,
  36.5871, 36.1742, 'Gps')
''';

const _insertResolvedReport = r'''
INSERT INTO reports (report_id, reporter_id, assignee_id, category, description,
  photo_url, photo_content_type, photo_size_bytes, latitude, longitude,
  location_source, status, taken_at, resolved_at, resolution_photo_url,
  resolution_photo_content_type, resolution_photo_size_bytes)
VALUES ($1, $2, $3, 'Ariza', 'Çözülmüş test bildirimi', '/files/test.jpg',
  'image/jpeg', 1000, 36.5871, 36.1742, 'Gps', 'Cozuldu', NOW(), NOW(),
  '/files/sonuc.jpg', 'image/jpeg', 1000)
''';

const _historyOf = r'''
SELECT from_status, to_status, changed_by::text FROM status_history
WHERE report_id = $1
''';

const _resetToNew = r'''
UPDATE reports SET status = 'Yeni', assignee_id = NULL, taken_at = NULL
WHERE report_id = $1
''';

Future<void> _deleteFixtures(Database db) async {
  await db.execute(r'DELETE FROM status_history WHERE report_id IN ($1, $2)', [
    _newReport,
    _resolvedReport,
  ]);
  await db.execute(r'DELETE FROM reports WHERE report_id IN ($1, $2)', [
    _newReport,
    _resolvedReport,
  ]);
  await db.execute(r'DELETE FROM users WHERE user_id IN ($1, $2, $3)', [
    _student,
    _staffA,
    _staffB,
  ]);
}

Future<void> _insertFixtures(Database db) async {
  await db.execute(_insertUser, [
    _student,
    'Test Öğrenci',
    'o@test.edu',
    'Student',
  ]);
  await db.execute(_insertUser, [
    _staffA,
    'Test Görevli A',
    'a@test.edu',
    'Staff',
  ]);
  await db.execute(_insertUser, [
    _staffB,
    'Test Görevli B',
    'b@test.edu',
    'Staff',
  ]);
  await db.execute(_insertNewReport, [_newReport, _student]);
  await db.execute(_insertResolvedReport, [_resolvedReport, _student, _staffA]);
}

void main() {
  final url = Platform.environment['DATABASE_URL'];

  group('ReportRepositoryImpl.assign', () {
    late Database db;
    late ReportRepositoryImpl repository;

    setUpAll(() {
      db = Database.fromUrl(url!);
      repository = ReportRepositoryImpl(db);
    });
    tearDownAll(() => db.close());

    setUp(() async {
      await _deleteFixtures(db);
      await _insertFixtures(db);
    });
    tearDown(() => _deleteFixtures(db));

    test('assign_whenYeni_assignsToStaff', () async {
      final outcome = await repository.assign(_newReport, _staffA);

      expect(outcome, AssignOutcome.assigned);
      final row = await db.execute(
        r'SELECT status, assignee_id::text, taken_at IS NOT NULL FROM reports WHERE report_id = $1',
        [_newReport],
      );
      expect(row.single, ['Ustlenildi', _staffA, true]);
      final history = await db.execute(_historyOf, [_newReport]);
      expect(history.single, ['Yeni', 'Ustlenildi', _staffA]);
    });

    test('assign_whenAlreadyAssigned_returnsAlreadyAssigned', () async {
      await repository.assign(_newReport, _staffA);

      final outcome = await repository.assign(_newReport, _staffB);

      expect(outcome, AssignOutcome.alreadyAssigned);
      final row = await db.execute(
        r'SELECT assignee_id::text FROM reports WHERE report_id = $1',
        [_newReport],
      );
      expect(row.single.single, _staffA);
      expect(await db.execute(_historyOf, [_newReport]), hasLength(1));
    });

    test('assign_whenTwoStaffAtOnce_onlyOneWins', () async {
      // Havuzda tek bağlantı varsa istekler sıraya girer ve yarış hiç oluşmaz.
      expect(url, contains('max_connection_count'), reason: 'havuz en az 2');
      // Rule 02: aynı anda iki istek; tekrar tekrar denenir ki yarış gerçekten oluşsun.
      for (var round = 0; round < 20; round++) {
        await db.execute(r'DELETE FROM status_history WHERE report_id = $1', [
          _newReport,
        ]);
        await db.execute(_resetToNew, [_newReport]);

        final outcomes = await Future.wait([
          repository.assign(_newReport, _staffA),
          repository.assign(_newReport, _staffB),
        ]);

        expect(
          outcomes,
          unorderedEquals([
            AssignOutcome.assigned,
            AssignOutcome.alreadyAssigned,
          ]),
          reason: 'tur $round',
        );
        final history = await db.execute(_historyOf, [_newReport]);
        expect(history, hasLength(1), reason: 'tur $round');
      }
    });

    test('assign_whenResolved_returnsInvalidTransition', () async {
      final outcome = await repository.assign(_resolvedReport, _staffB);

      expect(outcome, AssignOutcome.invalidTransition);
      expect(await db.execute(_historyOf, [_resolvedReport]), isEmpty);
    });

    test('assign_whenReportMissing_returnsNotFound', () async {
      final outcome = await repository.assign(_missingReport, _staffA);

      expect(outcome, AssignOutcome.notFound);
    });
  }, skip: url == null ? 'DATABASE_URL tanımlı değil' : false);
}
