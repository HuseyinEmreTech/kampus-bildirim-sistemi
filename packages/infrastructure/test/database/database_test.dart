// Gerçek PostgreSQL ister: DATABASE_URL ortam değişkeni (README §10, .env.example).
@Tags(['db'])
library;

import 'dart:io';

import 'package:campus_infrastructure/campus_infrastructure.dart';
import 'package:test/test.dart';

const _testBuildingId = 'b0000000-0000-4000-8000-0000000000ff';

const _insertTestBuilding = r'''
INSERT INTO buildings (building_id, name, latitude, longitude)
VALUES ($1, 'Test Blok', 36.5871, 36.1742)
''';

void main() {
  final url = Platform.environment['DATABASE_URL'];

  group('Database', () {
    late Database db;

    setUpAll(() => db = Database.fromUrl(url!));
    tearDownAll(() => db.close());

    test('execute_selectOne_returnsRow', () async {
      final result = await db.execute('SELECT 1');

      expect(result.single.single, 1);
    });

    test('execute_withParameters_bindsDollarPlaceholders', () async {
      final result = await db.execute(r'SELECT $1::int + $2::int', [2, 3]);

      expect(result.single.single, 5);
    });

    test('transaction_conditionalUpdate_secondTimeAffectsNoRows', () async {
      await db.transaction((tx) async {
        await tx.execute(_insertTestBuilding, parameters: [_testBuildingId]);
        const claim = r'''
UPDATE buildings SET name = 'Sahipli Blok'
WHERE building_id = $1 AND name = 'Test Blok'
''';

        final first = await tx.execute(claim, parameters: [_testBuildingId]);
        final second = await tx.execute(claim, parameters: [_testBuildingId]);

        expect(first.affectedRows, 1);
        expect(second.affectedRows, 0);
        await tx.rollback();
      });
    });

    test('transaction_whenActionThrows_rollsBack', () async {
      final action = db.transaction((tx) async {
        await tx.execute(_insertTestBuilding, parameters: [_testBuildingId]);
        throw StateError('işlem yarıda kaldı');
      });

      await expectLater(action, throwsStateError);
      final left = await db.execute(
        r'SELECT count(*) FROM buildings WHERE building_id = $1',
        [_testBuildingId],
      );
      expect(left.single.single, 0);
    });
  }, skip: url == null ? 'DATABASE_URL tanımlı değil' : false);
}
