// Gerçek PostgreSQL ister: DATABASE_URL ortam değişkeni (README §10, .env.example).
@Tags(['db'])
library;

import 'dart:io';

import 'package:campus_infrastructure/campus_infrastructure.dart';
import 'package:test/test.dart';

// Seed verisiyle çakışmayan sabit kimlikler; her testten önce kurulur, sonra silinir.
const _blockA = 'b0000000-0000-4000-8000-0000000000e1';
const _blockB = 'b0000000-0000-4000-8000-0000000000e2';
const _blockC = 'b0000000-0000-4000-8000-0000000000e3';
const _missing = 'b0000000-0000-4000-8000-0000000000ee';

const _insertBuilding = r'''
INSERT INTO buildings (building_id, name, latitude, longitude) VALUES ($1, $2, $3, $4)
''';

Future<void> _deleteFixtures(Database db) => db.execute(
  r'DELETE FROM buildings WHERE building_id IN ($1, $2, $3)',
  [_blockA, _blockB, _blockC],
);

void main() {
  final url = Platform.environment['DATABASE_URL'];

  group('BuildingRepositoryImpl', () {
    late Database db;
    late BuildingRepositoryImpl repository;

    setUpAll(() {
      db = Database.fromUrl(url!);
      repository = BuildingRepositoryImpl(db);
    });
    tearDownAll(() => db.close());

    setUp(() async {
      await _deleteFixtures(db);
      // Türkçe sıralamayı görmek için karışık sırayla eklenir: Ç, C ile D arasındadır.
      await db.execute(_insertBuilding, [_blockC, 'Test Dekanlık', 36.7, 36.3]);
      await db.execute(_insertBuilding, [_blockB, 'Test Çarşı', 36.6, 36.2]);
      await db.execute(_insertBuilding, [_blockA, 'Test Cami', 36.5, 36.1]);
    });
    tearDown(() => _deleteFixtures(db));

    test('list_returnsBuildingsInTurkishOrder', () async {
      final buildings = await repository.list();

      final testOnes = buildings.where((b) => b.name.startsWith('Test '));
      expect(testOnes.toList(), [
        (
          buildingId: _blockA,
          name: 'Test Cami',
          latitude: 36.5,
          longitude: 36.1,
        ),
        (
          buildingId: _blockB,
          name: 'Test Çarşı',
          latitude: 36.6,
          longitude: 36.2,
        ),
        (
          buildingId: _blockC,
          name: 'Test Dekanlık',
          latitude: 36.7,
          longitude: 36.3,
        ),
      ]);
    });

    test('findById_existing_returnsBuilding', () async {
      final building = await repository.findById(_blockA);

      expect(building?.name, 'Test Cami');
    });

    test('findById_unknown_returnsNull', () async {
      expect(await repository.findById(_missing), isNull);
    });

    test('findById_notUuid_returnsNull', () async {
      expect(await repository.findById('../bina'), isNull);
    });
  }, skip: url == null ? 'DATABASE_URL tanımlı değil' : false);
}
