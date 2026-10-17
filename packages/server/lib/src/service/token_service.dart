import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

import '../config/jwt_config.dart';

/// Belirteçten okunan kullanıcı bilgisi. İçinde şifre ya da e-posta yoktur.
typedef UserContext = ({String userId, String role});

/// JWT üretir ve doğrular. Algoritma HS256 (tek sır ile imza).
class TokenService {
  TokenService(this._config, {Random? random})
    : _random = random ?? Random.secure();

  final JwtConfig _config;
  final Random _random;

  static const _roleClaim = 'role';

  /// Her yenileme belirtecini benzersiz yapan rastgele kimliğin bayt sayısı.
  static const _tokenIdBytes = 16;

  /// Erişim belirteci üretir (15 dk). İçinde: `sub`, `role`, `iat`, `exp`, `iss`.
  String createAccessToken(String userId, String role) {
    final jwt = JWT(
      <String, Object?>{_roleClaim: role},
      subject: userId,
      issuer: JwtConfig.issuer,
    );
    return jwt.sign(
      SecretKey(_config.accessSecret),
      algorithm: JWTAlgorithm.HS256,
      expiresIn: _config.accessLifetime,
    );
  }

  /// Yenileme belirteci üretir (7 gün). Ayrı sır ile imzalanır; `jti`
  /// rastgele olduğu için aynı saniyede üretilen iki belirteç bile farklıdır.
  String createRefreshToken(String userId) {
    final jwt = JWT(
      <String, Object?>{},
      subject: userId,
      issuer: JwtConfig.issuer,
      jwtId: _randomId(),
    );
    return jwt.sign(
      SecretKey(_config.refreshSecret),
      algorithm: JWTAlgorithm.HS256,
      expiresIn: _config.refreshLifetime,
    );
  }

  /// Erişim belirteci geçerliyse kullanıcı bilgisini, değilse `null` döner.
  /// İmza, süre ve `iss` kontrol edilir.
  UserContext? verifyAccessToken(String token) {
    final jwt = JWT.tryVerify(
      token,
      SecretKey(_config.accessSecret),
      issuer: JwtConfig.issuer,
    );
    if (jwt == null) return null;
    final userId = jwt.subject;
    final payload = jwt.payload;
    if (userId == null || payload is! Map) return null;
    final role = payload[_roleClaim];
    if (role is! String) return null;
    return (userId: userId, role: role);
  }

  /// Yenileme belirteci imzası ve süresi geçerliyse kullanıcı kimliğini,
  /// değilse `null` döner. İptal edilip edilmediğine veritabanı bakar.
  String? verifyRefreshToken(String token) {
    final jwt = JWT.tryVerify(
      token,
      SecretKey(_config.refreshSecret),
      issuer: JwtConfig.issuer,
    );
    return jwt?.subject;
  }

  /// Yenileme belirtecinin veritabanında saklanan özeti (SHA-256).
  /// Aramada kullanıldığı için her seferinde aynı sonucu vermelidir.
  String hashRefreshToken(String token) =>
      sha256.convert(utf8.encode(token)).toString();

  /// Bitiş zamanı: şimdi + yenileme belirteci ömrü.
  DateTime refreshExpiry() =>
      DateTime.now().toUtc().add(_config.refreshLifetime);

  String _randomId() {
    final bytes = List<int>.generate(
      _tokenIdBytes,
      (_) => _random.nextInt(256),
    );
    return base64Url.encode(bytes);
  }
}
