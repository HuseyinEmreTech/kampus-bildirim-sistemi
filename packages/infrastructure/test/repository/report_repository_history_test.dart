// Gerçek PostgreSQL ister: DATABASE_URL ortam değişkeni (README §10, .env.example).
@Tags(['db'])
library;

import 'dart:io';

import 'package:campus_infrastructure/campus_infrastructure.dart';
import 'package:test/test.dart';

// Seed ve diğer test dosyalarıyla çakışmayan sabit kimlikler.
const _student = 'a0000000-0000-4000-8000-0000000000c1';
const _staff = 'a0000000-0000-4000-8000-0000000000c2';
const _missing = 'c0000000-0000-4000-8000-0000000000cc';

const _report = (
  reporterId: _student,
  category: 'Ariza',
  description: 'Musluk damlatıyor',
  photo: (url: '/files/gecmis.jpg', contentType: 'image/jpeg', sizeBytes: 1000),
  latitude: 36.5871,
  longitude: 36.1742,
  place: 'A blok giriş',
  locationSource: 'Gps',
  buildingId: null,
);

const _resolution = (
  url: '/files/gecmis-sonuc.jpg',
  contentType: 'image/jpeg',
  sizeBytes: 500,
);

const _insertUser = r'''
INSERT INTO users (user_id, full_name, email, password_hash, role)
VALUES ($1, $2, $3, 'test-hash', $4)
''';

Future<void> _deleteFixtures(Database db) async {
  await db.execute(
    r'DELETE FROM notifications WHERE report_id IN '
    r'(SELECT report_id FROM reports WHERE reporter_id = $1)',
    [_student],
  );
  await db.execute(
    r'DELETE FROM status_history WHERE report_id IN '
    r'(SELECT report_id FROM reports WHERE reporter_id = $1)',
    [_student],
  );
  await db.execute(r'DELETE FROM reports WHERE reporter_id = $1', [_student]);
  await db.execute(r'DELETE FROM users WHERE user_id IN ($1, $2)', [
    _student,
    _staff,
  ]);
}

void main() {
  final url = Platform.environment['DATABASE_URL'];

  group('ReportRepositoryImpl.findHistory', () {
    late Database db;
    late ReportRepositoryImpl repository;

    setUpAll(() {
      db = Database.fromUrl(url!);
      repository = ReportRepositoryImpl(db);
    });
    tearDownAll(() => db.close());

    setUp(() async {
      await _deleteFixtures(db);
      await db.execute(_insertUser, [
        _student,
        'Geçmiş Öğrenci',
        'gecmis-o@test.edu',
        'Student',
      ]);
      await db.execute(_insertUser, [
        _staff,
        'Geçmiş Görevli',
        'gecmis-g@test.edu',
        'Staff',
      ]);
    });
    tearDown(() => _deleteFixtures(db));

    test('findHistory_afterResolve_returnsChangesInOrder', () async {
      final reportId = await repository.create(_report);
      await repository.assign(reportId, _staff);
      await repository.resolve(
        reportId,
        _staff,
        _resolution,
        note: 'Contası değişti',
      );

      final history = await repository.findHistory(reportId);
      expect(
        history.map((c) => (c.fromStatus, c.toStatus, c.changedByName, c.note)),
        [
          (null, 'Yeni', 'Geçmiş Öğrenci', null),
          ('Yeni', 'Ustlenildi', 'Geçmiş Görevli', null),
          ('Ustlenildi', 'Cozuldu', 'Geçmiş Görevli', 'Contası değişti'),
        ],
      );
      expect(history.last.changedById, _staff);
      expect(history.first.changedAt.isBefore(history.last.changedAt), isTrue);
    });

    test('findHistory_whenMissing_returnsEmpty', () async {
      expect(await repository.findHistory(_missing), isEmpty);
    });

    test('findHistory_whenIdNotUuid_returnsEmpty', () async {
      expect(await repository.findHistory('abc'), isEmpty);
    });
  }, skip: url == null ? 'DATABASE_URL tanımlı değil' : false);
}
