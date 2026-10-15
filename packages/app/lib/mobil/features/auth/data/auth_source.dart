import 'session.dart';

/// Giriş isteğinin sonucu: oturum açıldı, bilgiler reddedildi ya da sonuçlanmadı.
sealed class LoginResult {
  const LoginResult();
}

final class LoginSucceeded extends LoginResult {
  const LoginSucceeded(this.session);

  final Session session;
}

/// Sunucu e-posta veya şifreyi kabul etmedi (401).
final class LoginRejected extends LoginResult {
  const LoginRejected();
}

/// Sunucu hatası veya bağlantı sorunu.
final class LoginFailed extends LoginResult {
  const LoginFailed();
}

/// Girişi sunucuya soran kaynak.
///
/// Gerçek hali sunucu ve `campus_contracts` hazır olunca yazılacak;
/// testlerde sahte bir kaynak kullanılır.
abstract interface class AuthSource {
  Future<LoginResult> login({required String email, required String password});
}
