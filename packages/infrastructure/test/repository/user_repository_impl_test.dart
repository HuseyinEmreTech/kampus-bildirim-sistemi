// Gerçek PostgreSQL ister: DATABASE_URL ortam değişkeni (README §10, .env.example).
@Tags(['db'])
library;

import 'dart:io';

import 'package:campus_infrastructure/campus_infrastructure.dart';
import 'package:postgres/postgres.dart' show ServerException;
import 'package:test/test.dart';

// Seed verisiyle çakışmayan sabit kimlik; her testten önce kurulur, sonra silinir.
const _user = 'a0000000-0000-4000-8000-0000000000d1';
const _missing = 'a0000000-0000-4000-8000-0000000000dd';

const _insertUser = r'''
INSERT INTO users (user_id, full_name, email, password_hash, role)
VALUES ($1, 'Test Görevli', 'kullanici.test@ornek.edu', 'test-hash', 'Staff')
''';

Future<void> _deleteFixtures(Database db) => db.execute(
  r'DELETE FROM users WHERE user_id IN ($1, $2)',
  [_user, _missing],
);

void main() {
  final url = Platform.environment['DATABASE_URL'];

  group('UserRepositoryImpl', () {
    late Database db;
    late UserRepositoryImpl repository;

    setUpAll(() {
      db = Database.fromUrl(url!);
      repository = UserRepositoryImpl(db);
    });
    tearDownAll(() => db.close());

    setUp(() async {
      await _deleteFixtures(db);
      await db.execute(_insertUser, [_user]);
    });
    tearDown(() => _deleteFixtures(db));

    test('findByEmail_existing_returnsUserWithHash', () async {
      final user = await repository.findByEmail('kullanici.test@ornek.edu');

      expect(user, (
        userId: _user,
        fullName: 'Test Görevli',
        email: 'kullanici.test@ornek.edu',
        passwordHash: 'test-hash',
        role: 'Staff',
      ));
    });

    test('findByEmail_differentCase_findsSameUser', () async {
      final user = await repository.findByEmail('Kullanici.TEST@ornek.edu');

      expect(user?.userId, _user);
    });

    test('email_sameAddressDifferentCase_cannotBeAddedTwice', () async {
      // V3 migration: aynı e-posta farklı harflerle ikinci hesap açamaz.
      await expectLater(
        db.execute(
          r'''
INSERT INTO users (user_id, full_name, email, password_hash, role)
VALUES ($1, 'İkinci Hesap', 'KULLANICI.test@ornek.edu', 'x', 'Student')
''',
          [_missing],
        ),
        throwsA(
          isA<ServerException>()
              .having((e) => e.code, 'code', '23505')
              .having(
                (e) => e.constraintName,
                'constraint',
                'users_email_lower_key',
              ),
        ),
      );
    });

    test('findByEmail_unknown_returnsNull', () async {
      expect(await repository.findByEmail('yok@ornek.edu'), isNull);
    });

    test('findById_existing_returnsUser', () async {
      final user = await repository.findById(_user);

      expect(user?.email, 'kullanici.test@ornek.edu');
    });

    test('findById_unknown_returnsNull', () async {
      expect(await repository.findById(_missing), isNull);
    });

    test('findById_notUuid_returnsNull', () async {
      expect(await repository.findById('abc'), isNull);
    });
  }, skip: url == null ? 'DATABASE_URL tanımlı değil' : false);
}
