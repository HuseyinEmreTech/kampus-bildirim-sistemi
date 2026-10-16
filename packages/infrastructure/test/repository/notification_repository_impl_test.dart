// Gerçek PostgreSQL ister: DATABASE_URL ortam değişkeni (README §10, .env.example).
@Tags(['db'])
library;

import 'dart:io';

import 'package:campus_infrastructure/campus_infrastructure.dart';
import 'package:test/test.dart';

// Seed ve diğer test dosyalarıyla çakışmayan sabit kimlikler.
const _owner = 'a0000000-0000-4000-8000-0000000000b1';
const _other = 'a0000000-0000-4000-8000-0000000000b2';
const _firstReport = 'c0000000-0000-4000-8000-0000000000b1';
const _secondReport = 'c0000000-0000-4000-8000-0000000000b2';
const _otherReport = 'c0000000-0000-4000-8000-0000000000b3';
const _first = 'e0000000-0000-4000-8000-0000000000b1';
const _second = 'e0000000-0000-4000-8000-0000000000b2';
const _othersNotification = 'e0000000-0000-4000-8000-0000000000b3';
const _missing = 'e0000000-0000-4000-8000-0000000000bb';

const _insertUser = r'''
INSERT INTO users (user_id, full_name, email, password_hash, role)
VALUES ($1, $2, $3, 'test-hash', 'Student')
''';

const _insertReport = r'''
INSERT INTO reports (report_id, reporter_id, category, description, photo_url,
  photo_content_type, photo_size_bytes, latitude, longitude, location_source)
VALUES ($1, $2, 'Ariza', 'Bildirim testi', '/files/t.jpg', 'image/jpeg', 1,
  36.58, 36.17, 'Gps')
''';

const _insertNotification = r'''
INSERT INTO notifications (notification_id, user_id, report_id, type, message)
VALUES ($1, $2, $3, 'ReportResolved', 'Bildiriminiz çözüldü.')
''';

const _readAtOf =
    r'SELECT read_at FROM notifications WHERE notification_id = $1';

Future<void> _deleteFixtures(Database db) async {
  await db.execute(r'DELETE FROM notifications WHERE user_id IN ($1, $2)', [
    _owner,
    _other,
  ]);
  await db.execute(r'DELETE FROM reports WHERE reporter_id IN ($1, $2)', [
    _owner,
    _other,
  ]);
  await db.execute(r'DELETE FROM users WHERE user_id IN ($1, $2)', [
    _owner,
    _other,
  ]);
}

void main() {
  final url = Platform.environment['DATABASE_URL'];

  group('NotificationRepositoryImpl', () {
    late Database db;
    late NotificationRepositoryImpl repository;

    Future<Object?> readAtOf(String notificationId) async =>
        (await db.execute(_readAtOf, [notificationId])).single.single;

    setUpAll(() {
      db = Database.fromUrl(url!);
      repository = NotificationRepositoryImpl(db);
    });
    tearDownAll(() => db.close());

    setUp(() async {
      await _deleteFixtures(db);
      await db.execute(_insertUser, [_owner, 'Bildirim Sahibi', 'bs@test.edu']);
      await db.execute(_insertUser, [_other, 'Başka Öğrenci', 'bo@test.edu']);
      await db.execute(_insertReport, [_firstReport, _owner]);
      await db.execute(_insertReport, [_secondReport, _owner]);
      await db.execute(_insertReport, [_otherReport, _other]);
      await db.execute(_insertNotification, [_first, _owner, _firstReport]);
      await db.execute(_insertNotification, [_second, _owner, _secondReport]);
      await db.execute(_insertNotification, [
        _othersNotification,
        _other,
        _otherReport,
      ]);
    });
    tearDown(() => _deleteFixtures(db));

    test('markRead_whenOwner_setsReadAt', () async {
      final outcome = await repository.markRead(_first, _owner);

      expect(outcome, MarkReadOutcome.marked);
      expect(await readAtOf(_first), isA<DateTime>());
      expect(await readAtOf(_second), isNull);
    });

    test('markRead_twice_keepsFirstReadTime', () async {
      await repository.markRead(_first, _owner);
      final firstReadAt = await readAtOf(_first);

      final outcome = await repository.markRead(_first, _owner);

      expect(outcome, MarkReadOutcome.marked);
      expect(await readAtOf(_first), firstReadAt);
    });

    // Rule 01: başkasının bildirimi "yok" sayılır; var olduğu da belli edilmez.
    test('markRead_whenOtherUsersNotification_returnsNotFound', () async {
      final outcome = await repository.markRead(_othersNotification, _owner);

      expect(outcome, MarkReadOutcome.notFound);
      expect(await readAtOf(_othersNotification), isNull);
    });

    test('markRead_whenMissing_returnsNotFound', () async {
      expect(
        await repository.markRead(_missing, _owner),
        MarkReadOutcome.notFound,
      );
    });

    test('markRead_whenIdNotUuid_returnsNotFound', () async {
      expect(
        await repository.markRead('abc', _owner),
        MarkReadOutcome.notFound,
      );
    });

    Future<List<String>> idsOf(
      String userId, {
      int limit = 20,
      int offset = 0,
    }) async {
      final page = await repository.list(userId, limit: limit, offset: offset);
      return [for (final item in page) item.notificationId];
    }

    // Rule 01: öğrenci yalnızca kendi "çözüldü" bildirimlerini görür.
    test('list_returnsOnlyOwnNewestFirst', () async {
      expect(await idsOf(_owner), [_second, _first]);
      expect(await idsOf(_other), [_othersNotification]);
    });

    test('list_withLimitAndOffset_returnsPage', () async {
      expect(await idsOf(_owner, limit: 1), [_second]);
      expect(await idsOf(_owner, limit: 1, offset: 1), [_first]);
    });

    // Negatif sayı veritabanı hatasına (500), çok büyük sayı ağır sorguya dönmez.
    test('list_withInvalidPage_returnsEmpty', () async {
      expect(await idsOf(_owner, limit: 0), isEmpty);
      expect(await idsOf(_owner, limit: maxPageSize + 1), isEmpty);
      expect(await idsOf(_owner, offset: -1), isEmpty);
      expect(await idsOf(_owner, limit: maxPageSize), hasLength(2));
    });

    test('list_returnsFieldsAndReadTime', () async {
      await repository.markRead(_first, _owner);

      final [second, first] = await repository.list(
        _owner,
        limit: 20,
        offset: 0,
      );
      expect(first.reportId, _firstReport);
      expect(first.type, 'ReportResolved');
      expect(first.message, 'Bildiriminiz çözüldü.');
      expect(first.readAt, isA<DateTime>());
      expect(second.readAt, isNull);
      expect(second.createdAt.isAfter(first.createdAt), isTrue);
    });

    test('unreadCount_countsOnlyUnreadOfUser', () async {
      expect(await repository.unreadCount(_owner), 2);

      await repository.markRead(_first, _owner);

      expect(await repository.unreadCount(_owner), 1);
      expect(await repository.unreadCount(_other), 1);
    });
  }, skip: url == null ? 'DATABASE_URL tanımlı değil' : false);
}
