import 'package:campus_infrastructure/campus_infrastructure.dart';

import 'password_hasher.dart';
import 'token_service.dart';

/// Giriş başarısız olduğunda nedeni.
enum AuthFailureReason {
  /// E-posta ya da parola yanlış. Hangisinin yanlış olduğu söylenmez.
  invalidCredentials,

  /// Yenileme belirteci geçersiz, süresi dolmuş ya da daha önce kullanılmış.
  invalidRefreshToken,
}

/// Giriş/yenileme sonucu. İstisna fırlatılmaz; sonuç bu tiple döner.
sealed class AuthOutcome {
  const AuthOutcome();
}

final class AuthSuccess extends AuthOutcome {
  const AuthSuccess({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  final String accessToken;
  final String refreshToken;
  final UserRecord user;
}

final class AuthFailure extends AuthOutcome {
  const AuthFailure(this.reason);

  final AuthFailureReason reason;
}

/// Giriş ve belirteç yenileme. Kullanıcı ve oturum kayıtları
/// Ertuğrul'un repository'lerinden gelir (veritabanı işi orada).
class AuthService {
  AuthService({
    required this._users,
    required this._sessions,
    required this._tokens,
    required this._hasher,
  });

  final UserRepositoryImpl _users;
  final SessionRepositoryImpl _sessions;
  final TokenService _tokens;
  final PasswordHasher _hasher;

  /// E-posta ve parola doğruysa yeni oturum açar.
  Future<AuthOutcome> login(String email, String password) async {
    final user = await _users.findByEmail(email);
    if (user == null) {
      _hasher.verifyAgainstDummy(password);
      return const AuthFailure(AuthFailureReason.invalidCredentials);
    }
    if (!_hasher.verify(password, user.passwordHash)) {
      return const AuthFailure(AuthFailureReason.invalidCredentials);
    }

    final refreshToken = _tokens.createRefreshToken(user.userId);
    await _sessions.create(
      user.userId,
      _tokens.hashRefreshToken(refreshToken),
      _tokens.refreshExpiry(),
    );
    return _success(user, refreshToken);
  }

  /// Eski yenileme belirtecini iptal edip yenisini verir (rotation).
  /// Aynı belirteç ikinci kez gelirse başarısız olur.
  Future<AuthOutcome> refresh(String refreshToken) async {
    const failure = AuthFailure(AuthFailureReason.invalidRefreshToken);

    final userId = _tokens.verifyRefreshToken(refreshToken);
    if (userId == null) return failure;

    final newRefreshToken = _tokens.createRefreshToken(userId);
    final rotated = await _sessions.rotate(
      _tokens.hashRefreshToken(refreshToken),
      _tokens.hashRefreshToken(newRefreshToken),
      _tokens.refreshExpiry(),
    );
    if (rotated == null || rotated.userId != userId) return failure;

    final user = await _users.findById(userId);
    if (user == null) return failure;
    return _success(user, newRefreshToken);
  }

  AuthSuccess _success(UserRecord user, String refreshToken) => AuthSuccess(
    accessToken: _tokens.createAccessToken(user.userId, user.role),
    refreshToken: refreshToken,
    user: user,
  );
}
