import 'package:campus_server/src/service/auth_service.dart';
import 'package:campus_server/src/service/password_hasher.dart';
import 'package:campus_server/src/service/token_service.dart';
import 'package:test/test.dart';

import '../support/fake_repositories.dart';
import '../support/test_values.dart';

// Test hızlı olsun diye düşük bcrypt maliyeti; üretimde 12.
final hasher = PasswordHasher(cost: 4);
final tokens = TokenService(testJwtConfig);

late FakeUsers users;
late FakeSessions sessions;
late AuthService auth;

void main() {
  setUp(() {
    users = FakeUsers()
      ..users.add((
        userId: studentId,
        fullName: 'Ayşe Yılmaz',
        email: 'ayse@ornek.edu',
        passwordHash: hasher.hash(testPassword),
        role: 'Student',
      ));
    sessions = FakeSessions();
    auth = AuthService(
      users: users,
      sessions: sessions,
      tokens: tokens,
      hasher: hasher,
    );
  });

  group('login', () {
    test('login_validCredentials_returnsTokensAndSavesHash', () async {
      final result = await auth.login('ayse@ornek.edu', testPassword);
      final success = result as AuthSuccess;
      expect(tokens.verifyAccessToken(success.accessToken), (
        userId: studentId,
        role: 'Student',
      ));
      expect(success.user.userId, studentId);
      // Belirtecin kendisi değil, yalnızca özeti saklanır.
      expect(sessions.sessions.keys, [
        tokens.hashRefreshToken(success.refreshToken),
      ]);
    });

    test('login_wrongPassword_invalidCredentials', () async {
      final result = await auth.login('ayse@ornek.edu', 'yanlis');
      expect(_reason(result), AuthFailureReason.invalidCredentials);
      expect(sessions.sessions, isEmpty);
    });

    test('login_unknownUser_sameFailureAsWrongPassword', () async {
      final result = await auth.login('yok@ornek.edu', testPassword);
      expect(_reason(result), AuthFailureReason.invalidCredentials);
    });
  });

  group('refresh', () {
    test('refresh_validToken_rotatesAndReturnsNewTokens', () async {
      final first = await _login();
      final result = await auth.refresh(first.refreshToken);
      final success = result as AuthSuccess;
      expect(success.refreshToken, isNot(first.refreshToken));
      final old =
          sessions.sessions[tokens.hashRefreshToken(first.refreshToken)];
      expect(old?.revoked, isTrue);
    });

    test('refresh_sameTokenTwice_secondFails', () async {
      final first = await _login();
      await auth.refresh(first.refreshToken);
      final again = await auth.refresh(first.refreshToken);
      expect(_reason(again), AuthFailureReason.invalidRefreshToken);
    });

    test('refresh_expiredToken_fails', () async {
      final expired = TokenService(expiredJwtConfig)
          .createRefreshToken(studentId);
      final result = await auth.refresh(expired);
      expect(_reason(result), AuthFailureReason.invalidRefreshToken);
    });

    test('refresh_validSignatureButNoSession_fails', () async {
      final result = await auth.refresh(tokens.createRefreshToken(studentId));
      expect(_reason(result), AuthFailureReason.invalidRefreshToken);
    });

    test('refresh_userDeletedAfterLogin_fails', () async {
      final first = await _login();
      users.users.clear();
      final result = await auth.refresh(first.refreshToken);
      expect(_reason(result), AuthFailureReason.invalidRefreshToken);
    });
  });
}

Future<AuthSuccess> _login() async =>
    await auth.login('ayse@ornek.edu', testPassword) as AuthSuccess;

AuthFailureReason? _reason(AuthOutcome outcome) => switch (outcome) {
  AuthSuccess() => null,
  AuthFailure(:final reason) => reason,
};
