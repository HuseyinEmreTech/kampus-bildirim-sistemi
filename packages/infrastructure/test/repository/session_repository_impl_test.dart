// Gerçek PostgreSQL ister: DATABASE_URL ortam değişkeni (README §10, .env.example).
@Tags(['db'])
library;

import 'dart:io';

import 'package:campus_infrastructure/campus_infrastructure.dart';
import 'package:test/test.dart';

// Seed verisiyle çakışmayan sabit kimlik; her testten önce kurulur, sonra silinir.
const _user = 'a0000000-0000-4000-8000-0000000000e1';

// Gerçek uygulamada sunucu bunları rastgele belirteçten SHA-256 ile üretir.
const _hashA = 'test-hash-a';
const _hashB = 'test-hash-b';
const _hashC = 'test-hash-c';

const _insertUser = r'''
INSERT INTO users (user_id, full_name, email, password_hash, role)
VALUES ($1, 'Test Öğrenci', 'oturum@test.edu', 'test-hash', 'Student')
''';

const _insertExpiredSession = r'''
INSERT INTO sessions (user_id, refresh_token_hash, created_at, expires_at)
VALUES ($1, $2, NOW() - INTERVAL '8 days', NOW() - INTERVAL '1 day')
''';

const _selectSession = r'''
SELECT user_id::text, revoked_at IS NULL FROM sessions WHERE refresh_token_hash = $1
''';

const _expiresInAboutSevenDays = r'''
SELECT expires_at BETWEEN NOW() + INTERVAL '6 days 23 hours' AND NOW() + INTERVAL '7 days 1 hour'
FROM sessions WHERE refresh_token_hash = $1
''';

Future<void> _deleteFixtures(Database db) async {
  await db.execute(r'DELETE FROM sessions WHERE user_id = $1', [_user]);
  await db.execute(r'DELETE FROM users WHERE user_id = $1', [_user]);
}

DateTime _inSevenDays() => DateTime.now().add(const Duration(days: 7));

void main() {
  final url = Platform.environment['DATABASE_URL'];

  group('SessionRepositoryImpl', () {
    late Database db;
    late SessionRepositoryImpl repository;

    setUpAll(() {
      db = Database.fromUrl(url!);
      repository = SessionRepositoryImpl(db);
    });
    tearDownAll(() => db.close());

    setUp(() async {
      await _deleteFixtures(db);
      await db.execute(_insertUser, [_user]);
    });
    tearDown(() => _deleteFixtures(db));

    test('create_storesActiveSession', () async {
      final sessionId = await repository.create(_user, _hashA, _inSevenDays());

      expect(sessionId, isNotEmpty);
      final rows = await db.execute(_selectSession, [_hashA]);
      expect(rows.single, [_user, true]);
      final expiry = await db.execute(_expiresInAboutSevenDays, [_hashA]);
      expect(expiry.single.single, isTrue);
    });

    test('rotate_validToken_revokesOldAndCreatesNew', () async {
      await repository.create(_user, _hashA, _inSevenDays());

      final rotated = await repository.rotate(_hashA, _hashB, _inSevenDays());

      expect(rotated?.userId, _user);
      expect((await db.execute(_selectSession, [_hashA])).single, [
        _user,
        false,
      ]);
      expect((await db.execute(_selectSession, [_hashB])).single, [
        _user,
        true,
      ]);
    });

    test('rotate_sameTokenTwice_secondReturnsNull', () async {
      await repository.create(_user, _hashA, _inSevenDays());
      await repository.rotate(_hashA, _hashB, _inSevenDays());

      final reused = await repository.rotate(_hashA, _hashC, _inSevenDays());

      expect(reused, isNull);
      expect(await db.execute(_selectSession, [_hashC]), isEmpty);
    });

    test('rotate_expiredToken_returnsNull', () async {
      await db.execute(_insertExpiredSession, [_user, _hashA]);

      final rotated = await repository.rotate(_hashA, _hashB, _inSevenDays());

      expect(rotated, isNull);
      expect(await db.execute(_selectSession, [_hashB]), isEmpty);
    });

    test('rotate_unknownToken_returnsNull', () async {
      final rotated = await repository.rotate(_hashA, _hashB, _inSevenDays());

      expect(rotated, isNull);
    });

    test('rotate_sameTokenAtOnce_onlyOneWins', () async {
      // Aynı yenileme belirteci iki kez aynı anda gelirse yalnızca biri yeni oturum alır.
      for (var round = 0; round < 20; round++) {
        await _deleteFixtures(db);
        await db.execute(_insertUser, [_user]);
        await repository.create(_user, _hashA, _inSevenDays());

        final results = await Future.wait([
          repository.rotate(_hashA, _hashB, _inSevenDays()),
          repository.rotate(_hashA, _hashC, _inSevenDays()),
        ]);

        expect(
          results.where((r) => r != null),
          hasLength(1),
          reason: 'tur $round',
        );
      }
    });
  }, skip: url == null ? 'DATABASE_URL tanımlı değil' : false);
}
