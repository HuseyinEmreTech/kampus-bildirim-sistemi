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
WHERE report_id = $1 ORDER BY changed_at
''';

const _notificationsOf = r'''
SELECT user_id::text, type FROM notifications WHERE report_id = $1
''';

const _resetToNew = r'''
UPDATE reports SET status = 'Yeni', assignee_id = NULL, taken_at = NULL
WHERE report_id = $1
''';

Future<void> _deleteFixtures(Database db) async {
  await db.execute(r'DELETE FROM notifications WHERE report_id IN ($1, $2)', [
    _newReport,
    _resolvedReport,
  ]);
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

    test('assign_whenIdNotUuid_returnsNotFound', () async {
      // Adresteki kimlik bozuksa sunucu hatası değil "bulunamadı" dönmeli.
      final outcome = await repository.assign('abc', _staffA);

      expect(outcome, AssignOutcome.notFound);
    });
  }, skip: url == null ? 'DATABASE_URL tanımlı değil' : false);

  group('ReportRepositoryImpl.resolve', () {
    late Database db;
    late ReportRepositoryImpl repository;
    const photo = (
      url: '/files/sonuc.jpg',
      contentType: 'image/jpeg',
      sizeBytes: 2000,
    );

    setUpAll(() {
      db = Database.fromUrl(url!);
      repository = ReportRepositoryImpl(db);
    });
    tearDownAll(() => db.close());

    setUp(() async {
      await _deleteFixtures(db);
      await _insertFixtures(db);
      await repository.assign(_newReport, _staffA);
    });
    tearDown(() => _deleteFixtures(db));

    test('resolve_whenAssignee_resolvesWithPhoto', () async {
      final outcome = await repository.resolve(
        _newReport,
        _staffA,
        photo,
        note: 'Lamba değişti',
      );

      expect(outcome, ResolveOutcome.resolved);
      final row = await db.execute(
        r'''
SELECT status, resolved_at IS NOT NULL, resolution_photo_url,
  resolution_photo_content_type, resolution_photo_size_bytes, resolution_note
FROM reports WHERE report_id = $1
''',
        [_newReport],
      );
      expect(row.single, [
        'Cozuldu',
        true,
        '/files/sonuc.jpg',
        'image/jpeg',
        2000,
        'Lamba değişti',
      ]);
    });

    test('resolve_whenAssignee_writesHistoryAndNotifiesStudent', () async {
      await repository.resolve(_newReport, _staffA, photo);

      final history = await db.execute(_historyOf, [_newReport]);
      expect(history.map((r) => r.toList()), [
        ['Yeni', 'Ustlenildi', _staffA],
        ['Ustlenildi', 'Cozuldu', _staffA],
      ]);
      final notifications = await db.execute(_notificationsOf, [_newReport]);
      expect(notifications.single, [_student, 'ReportResolved']);
    });

    test('resolve_whenNotAssignee_returnsNotAssignee', () async {
      final outcome = await repository.resolve(_newReport, _staffB, photo);

      expect(outcome, ResolveOutcome.notAssignee);
      final row = await db.execute(
        r'SELECT status FROM reports WHERE report_id = $1',
        [_newReport],
      );
      expect(row.single.single, 'Ustlenildi');
      expect(await db.execute(_notificationsOf, [_newReport]), isEmpty);
    });

    test('resolve_whenYeni_returnsInvalidTransition', () async {
      await db.execute(r'DELETE FROM status_history WHERE report_id = $1', [
        _newReport,
      ]);
      await db.execute(_resetToNew, [_newReport]);

      final outcome = await repository.resolve(_newReport, _staffA, photo);

      expect(outcome, ResolveOutcome.invalidTransition);
    });

    test('resolve_whenAlreadyResolved_returnsInvalidTransition', () async {
      final outcome = await repository.resolve(_resolvedReport, _staffA, photo);

      expect(outcome, ResolveOutcome.invalidTransition);
      expect(await db.execute(_notificationsOf, [_resolvedReport]), isEmpty);
    });

    test('resolve_whenReportMissing_returnsNotFound', () async {
      final outcome = await repository.resolve(_missingReport, _staffA, photo);

      expect(outcome, ResolveOutcome.notFound);
    });

    test('resolve_whenIdNotUuid_returnsNotFound', () async {
      final outcome = await repository.resolve('abc', _staffA, photo);

      expect(outcome, ResolveOutcome.notFound);
    });

    test('resolve_whenNotificationFails_rollsBackEverything', () async {
      // Aynı bildirim için ikinci "çözüldü" kaydı UNIQUE kuralına takılır.
      await db.execute(
        r'''
INSERT INTO notifications (user_id, report_id, type, message)
VALUES ($1, $2, 'ReportResolved', 'önceden var')
''',
        [_student, _newReport],
      );

      await expectLater(
        repository.resolve(_newReport, _staffA, photo),
        throwsA(isA<Exception>()),
      );

      final row = await db.execute(
        r'SELECT status FROM reports WHERE report_id = $1',
        [_newReport],
      );
      expect(row.single.single, 'Ustlenildi');
      expect(await db.execute(_historyOf, [_newReport]), hasLength(1));
    });

    test('resolve_twiceAtOnce_notifiesStudentOnce', () async {
      expect(url, contains('max_connection_count'), reason: 'havuz en az 2');

      final outcomes = await Future.wait([
        repository.resolve(_newReport, _staffA, photo),
        repository.resolve(_newReport, _staffA, photo),
      ]);

      expect(
        outcomes,
        unorderedEquals([
          ResolveOutcome.resolved,
          ResolveOutcome.invalidTransition,
        ]),
      );
      expect(await db.execute(_notificationsOf, [_newReport]), hasLength(1));
    });
  }, skip: url == null ? 'DATABASE_URL tanımlı değil' : false);
}
