import 'package:campus_server/src/config/jwt_config.dart';
import 'package:campus_server/src/service/token_service.dart';
import 'package:test/test.dart';

import '../support/test_values.dart';

void main() {
  final tokens = TokenService(testJwtConfig);

  group('JwtConfig', () {
    test('config_validSecrets_usesDefaultLifetimes', () {
      final config = JwtConfig.fromEnvironment({
        JwtConfig.accessSecretKey: testAccessSecret,
        JwtConfig.refreshSecretKey: testRefreshSecret,
      });
      expect(config?.accessLifetime, const Duration(minutes: 15));
      expect(config?.refreshLifetime, const Duration(days: 7));
    });

    test('config_missingOrShortSecret_returnsNull', () {
      expect(JwtConfig.fromEnvironment({}), isNull);
      expect(
        JwtConfig.fromEnvironment({
          JwtConfig.accessSecretKey: 'kisa',
          JwtConfig.refreshSecretKey: testRefreshSecret,
        }),
        isNull,
      );
    });

    test('config_sameSecretForBoth_returnsNull', () {
      expect(
        JwtConfig.fromEnvironment({
          JwtConfig.accessSecretKey: testAccessSecret,
          JwtConfig.refreshSecretKey: testAccessSecret,
        }),
        isNull,
      );
    });
  });

  group('access token', () {
    test('accessToken_valid_returnsUserAndRole', () {
      final token = tokens.createAccessToken(staffId, 'Staff');
      expect(tokens.verifyAccessToken(token), (userId: staffId, role: 'Staff'));
    });

    test('accessToken_expired_returnsNull', () {
      final token = TokenService(expiredJwtConfig)
          .createAccessToken(staffId, 'Staff');
      expect(tokens.verifyAccessToken(token), isNull);
    });

    test('accessToken_otherSecret_returnsNull', () {
      final token = TokenService(otherJwtConfig)
          .createAccessToken(staffId, 'Staff');
      expect(tokens.verifyAccessToken(token), isNull);
    });

    test('accessToken_garbage_returnsNull', () {
      expect(tokens.verifyAccessToken('bu-bir-jwt-degil'), isNull);
    });

    test('accessToken_refreshTokenGiven_returnsNull', () {
      final refresh = tokens.createRefreshToken(studentId);
      expect(tokens.verifyAccessToken(refresh), isNull);
    });
  });

  group('refresh token', () {
    test('refreshToken_valid_returnsUserId', () {
      final token = tokens.createRefreshToken(studentId);
      expect(tokens.verifyRefreshToken(token), studentId);
    });

    test('refreshToken_twoTokens_areDifferent', () {
      expect(
        tokens.createRefreshToken(studentId),
        isNot(tokens.createRefreshToken(studentId)),
      );
    });

    test('refreshToken_expired_returnsNull', () {
      final token = TokenService(expiredJwtConfig)
          .createRefreshToken(studentId);
      expect(tokens.verifyRefreshToken(token), isNull);
    });

    test('refreshToken_accessTokenGiven_returnsNull', () {
      final access = tokens.createAccessToken(studentId, 'Student');
      expect(tokens.verifyRefreshToken(access), isNull);
    });

    test('hashRefreshToken_sameInput_sameHash', () {
      final token = tokens.createRefreshToken(studentId);
      expect(tokens.hashRefreshToken(token), tokens.hashRefreshToken(token));
      expect(tokens.hashRefreshToken(token), isNot(token));
    });

    test('refreshExpiry_isAboutSevenDaysLater', () {
      final expiry = tokens.refreshExpiry();
      final expected = DateTime.now().toUtc().add(const Duration(days: 7));
      expect(expiry.difference(expected).inSeconds.abs(), lessThan(5));
    });
  });
}
