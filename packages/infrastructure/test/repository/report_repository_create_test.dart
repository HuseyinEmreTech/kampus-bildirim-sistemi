// Gerçek PostgreSQL ister: DATABASE_URL ortam değişkeni (README §10, .env.example).
@Tags(['db'])
library;

import 'dart:io';

import 'package:campus_infrastructure/campus_infrastructure.dart';
import 'package:test/test.dart';

// Seed ve diğer test dosyalarıyla çakışmayan sabit kimlikler.
const _student = 'a0000000-0000-4000-8000-0000000000d3';
const _staff = 'a0000000-0000-4000-8000-0000000000d2';
const _building = 'b0000000-0000-4000-8000-0000000000d1';

const _gpsReport = (
  reporterId: _student,
  category: 'Ariza',
  description: 'Koridordaki lamba yanmıyor',
  photo: (url: '/files/test.jpg', contentType: 'image/jpeg', sizeBytes: 1000),
  latitude: 36.5871,
  longitude: 36.1742,
  place: 'B blok 2. kat',
  locationSource: 'Gps',
  buildingId: null,
);

const _buildingReport = (
  reporterId: _student,
  category: 'Temizlik',
  description: 'Merdivenler çok kirli',
  photo: (url: '/files/test.png', contentType: 'image/png', sizeBytes: 2000),
  latitude: 36.58,
  longitude: 36.17,
  place: null,
  locationSource: 'Building',
  buildingId: _building,
);

const _insertUser = r'''
INSERT INTO users (user_id, full_name, email, password_hash, role)
VALUES ($1, $2, $3, 'test-hash', $4)
''';

const _savedReport = r'''
SELECT reporter_id::text, status, category, photo_url, photo_content_type,
  photo_size_bytes, place, location_source, building_id::text
FROM reports WHERE report_id = $1
''';

const _historyOf = r'''
SELECT from_status, to_status, changed_by::text FROM status_history
WHERE report_id = $1
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
  await db.execute(r'DELETE FROM buildings WHERE building_id = $1', [
    _building,
  ]);
  await db.execute(r'DELETE FROM users WHERE user_id IN ($1, $2)', [
    _student,
    _staff,
  ]);
}

void main() {
  final url = Platform.environment['DATABASE_URL'];

  group('ReportRepositoryImpl.create', () {
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
        'Oluşturma Öğrenci',
        'olusturma-o@test.edu',
        'Student',
      ]);
      await db.execute(_insertUser, [
        _staff,
        'Oluşturma Görevli',
        'olusturma-g@test.edu',
        'Staff',
      ]);
      await db.execute(
        r'INSERT INTO buildings (building_id, name, latitude, longitude) '
        r'VALUES ($1, $2, 36.58, 36.17)',
        [_building, 'Oluşturma Testi Binası'],
      );
    });
    tearDown(() => _deleteFixtures(db));

    test('create_returnsReportWithId', () async {
      final reportId = await repository.create(_gpsReport);

      final saved = await db.execute(_savedReport, [reportId]);
      expect(saved.single, [
        _student,
        'Yeni',
        'Ariza',
        '/files/test.jpg',
        'image/jpeg',
        1000,
        'B blok 2. kat',
        'Gps',
        null,
      ]);
    });

    test('create_withBuilding_savesBuilding', () async {
      final reportId = await repository.create(_buildingReport);

      final saved = await db.execute(_savedReport, [reportId]);
      expect(saved.single.sublist(6), [null, 'Building', _building]);
    });

    test('create_writesFirstStatusHistoryRow', () async {
      final reportId = await repository.create(_gpsReport);

      final history = await db.execute(_historyOf, [reportId]);
      expect(history, [
        [null, 'Yeni', _student],
      ]);
    });
  }, skip: url == null ? 'DATABASE_URL tanımlı değil' : false);
}
