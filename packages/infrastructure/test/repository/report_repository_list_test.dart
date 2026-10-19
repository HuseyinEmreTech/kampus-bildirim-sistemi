// Gerçek PostgreSQL ister: DATABASE_URL ortam değişkeni (README §10, .env.example).
@Tags(['db'])
library;

import 'dart:io';

import 'package:campus_infrastructure/campus_infrastructure.dart';
import 'package:test/test.dart';

// Seed ve diğer test dosyalarıyla çakışmayan sabit kimlikler. Test dosyaları aynı
// anda çalışabildiği için her sorgu bu dosyanın öğrencisine ya da görevlisine süzülür.
const _student = 'a0000000-0000-4000-8000-0000000000a1';
const _staff = 'a0000000-0000-4000-8000-0000000000a2';
const _otherStudent = 'a0000000-0000-4000-8000-0000000000a3';
const _building = 'b0000000-0000-4000-8000-0000000000a1';

const _mine = (
  status: null,
  category: null,
  assigneeId: null,
  reporterId: _student,
);

NewReport _report(
  String category, {
  String? buildingId,
  String reporterId = _student,
}) => (
  reporterId: reporterId,
  category: category,
  description: 'Liste testi bildirimi',
  photo: (url: '/files/liste.jpg', contentType: 'image/jpeg', sizeBytes: 1000),
  latitude: 36.58,
  longitude: 36.17,
  place: buildingId == null ? 'Kantin önü' : null,
  locationSource: buildingId == null ? 'Gps' : 'Building',
  buildingId: buildingId,
);

const _insertUser = r'''
INSERT INTO users (user_id, full_name, email, password_hash, role)
VALUES ($1, $2, $3, 'test-hash', $4)
''';

Future<void> _deleteFixtures(Database db) async {
  await db.execute(
    r'DELETE FROM status_history WHERE report_id IN '
    r'(SELECT report_id FROM reports WHERE reporter_id IN ($1, $2))',
    [_student, _otherStudent],
  );
  await db.execute(r'DELETE FROM reports WHERE reporter_id IN ($1, $2)', [
    _student,
    _otherStudent,
  ]);
  await db.execute(r'DELETE FROM buildings WHERE building_id = $1', [
    _building,
  ]);
  await db.execute(r'DELETE FROM users WHERE user_id IN ($1, $2, $3)', [
    _student,
    _staff,
    _otherStudent,
  ]);
}

void main() {
  final url = Platform.environment['DATABASE_URL'];

  group('ReportRepositoryImpl.list', () {
    late Database db;
    late ReportRepositoryImpl repository;
    late List<String> created;

    Future<List<String>> idsOf(
      ReportFilter filter, {
      int limit = 20,
      int offset = 0,
    }) async {
      final page = await repository.list(filter, limit: limit, offset: offset);
      return [for (final item in page) item.reportId];
    }

    setUpAll(() {
      db = Database.fromUrl(url!);
      repository = ReportRepositoryImpl(db);
    });
    tearDownAll(() => db.close());

    setUp(() async {
      await _deleteFixtures(db);
      await db.execute(_insertUser, [
        _student,
        'Liste Öğrenci',
        'liste-o@test.edu',
        'Student',
      ]);
      await db.execute(_insertUser, [
        _staff,
        'Liste Görevli',
        'liste-g@test.edu',
        'Staff',
      ]);
      await db.execute(_insertUser, [
        _otherStudent,
        'Liste Başka Öğrenci',
        'liste-b@test.edu',
        'Student',
      ]);
      await db.execute(
        r'INSERT INTO buildings (building_id, name, latitude, longitude) '
        r'VALUES ($1, $2, 36.58, 36.17)',
        [_building, 'Liste Testi Binası'],
      );
      // Her `create` ayrı işlem: oluşturulma zamanları farklı, sıra belli.
      created = [
        await repository.create(_report('Ariza')),
        await repository.create(_report('Temizlik', buildingId: _building)),
        await repository.create(_report('Ariza')),
      ];
    });
    tearDown(() => _deleteFixtures(db));

    // Rule 01: öğrenci başka öğrencinin bildirimini görmez.
    test('list_byReporter_returnsOnlyTheirsNewestFirst', () async {
      await repository.create(_report('Ariza', reporterId: _otherStudent));

      expect(await idsOf(_mine), created.reversed);
    });

    test('list_withLimitAndOffset_returnsPage', () async {
      expect(await idsOf(_mine, limit: 2), [created[2], created[1]]);
      expect(await idsOf(_mine, limit: 2, offset: 2), [created[0]]);
    });

    test('list_withStatus_returnsOnlyThatStatus', () async {
      await repository.assign(created[0], _staff);

      final taken = (
        status: 'Ustlenildi',
        category: null,
        assigneeId: null,
        reporterId: _student,
      );
      expect(await idsOf(taken), [created[0]]);
    });

    test('list_withCategory_returnsOnlyThatCategory', () async {
      final cleaning = (
        status: null,
        category: 'Temizlik',
        assigneeId: null,
        reporterId: _student,
      );
      expect(await idsOf(cleaning), [created[1]]);
    });

    test('list_byAssignee_returnsOnlyTheirs', () async {
      await repository.assign(created[2], _staff);

      final theirs = (
        status: null,
        category: null,
        assigneeId: _staff,
        reporterId: null,
      );
      expect(await idsOf(theirs), [created[2]]);
    });

    // Sorgu dizesinden gelen bozuk kimlik veritabanı hatasına (500) dönmez;
    // hiçbir bildirim eşleşmez. Öğrenci için bu, "hepsini göster" de demek değildir.
    test('list_withNonUuidId_returnsEmpty', () async {
      final badAssignee = (
        status: null,
        category: null,
        assigneeId: 'abc',
        reporterId: null,
      );
      final badReporter = (
        status: null,
        category: null,
        assigneeId: null,
        reporterId: 'abc',
      );
      expect(await idsOf(badAssignee), isEmpty);
      expect(await idsOf(badReporter), isEmpty);
    });

    test('list_withInvalidPage_returnsEmpty', () async {
      expect(await idsOf(_mine, limit: 0), isEmpty);
      expect(await idsOf(_mine, limit: maxPageSize + 1), isEmpty);
      expect(await idsOf(_mine, offset: -1), isEmpty);
      expect(await idsOf(_mine, limit: maxPageSize), hasLength(3));
    });

    test('list_returnsSummaryFields', () async {
      final page = await repository.list(_mine, limit: 20, offset: 0);
      final withBuilding = page.firstWhere((r) => r.reportId == created[1]);
      final withGps = page.firstWhere((r) => r.reportId == created[0]);

      expect(withBuilding.category, 'Temizlik');
      expect(withBuilding.status, 'Yeni');
      expect(withBuilding.description, 'Liste testi bildirimi');
      expect(withBuilding.buildingName, 'Liste Testi Binası');
      expect(withBuilding.place, isNull);
      expect(withBuilding.photoUrl, '/files/liste.jpg');
      expect(withBuilding.assigneeId, isNull);
      expect(withGps.place, 'Kantin önü');
      expect(withGps.buildingName, isNull);
    });

    // API'deki `total`: sayfadan bağımsız, aynı süzgeçle bütün eşleşenler.
    test('count_matchesFilterRegardlessOfPage', () async {
      await repository.create(_report('Ariza', reporterId: _otherStudent));

      expect(await repository.count(_mine), 3);
      expect(
        await repository.count((
          status: null,
          category: 'Temizlik',
          assigneeId: null,
          reporterId: _student,
        )),
        1,
      );
    });

    test('count_withNonUuidId_returnsZero', () async {
      expect(
        await repository.count((
          status: null,
          category: null,
          assigneeId: null,
          reporterId: 'abc',
        )),
        0,
      );
    });

    // Kimliği domain üretir; depo aynı kimlikle kaydeder.
    test('create_withGivenId_keepsThatId', () async {
      const givenId = 'c0000000-0000-4000-8000-0000000000b9';

      final saved = await repository.create(
        _report('Ariza'),
        reportId: givenId,
      );

      expect(saved, givenId);
      expect(await idsOf(_mine), contains(givenId));
    });
  }, skip: url == null ? 'DATABASE_URL tanımlı değil' : false);
}
