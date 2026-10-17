/// JWT ayarları. Sırlar ortam değişkeninden gelir, koda yazılmaz.
class JwtConfig {
  const JwtConfig({
    required this.accessSecret,
    required this.refreshSecret,
    this.accessLifetime = defaultAccessLifetime,
    this.refreshLifetime = defaultRefreshLifetime,
  });

  /// Erişim belirteci (access token) ömrü: 15 dakika.
  static const defaultAccessLifetime = Duration(minutes: 15);

  /// Yenileme belirteci (refresh token) ömrü: 7 gün.
  static const defaultRefreshLifetime = Duration(days: 7);

  /// Tahmin edilmesi zor olsun diye sırrın en az uzunluğu.
  static const minSecretLength = 32;

  /// Belirteci kimin ürettiğini gösterir; doğrulamada da kontrol edilir.
  static const issuer = 'campus-report';

  static const accessSecretKey = 'JWT_ACCESS_SECRET';
  static const refreshSecretKey = 'JWT_REFRESH_SECRET';

  final String accessSecret;
  final String refreshSecret;
  final Duration accessLifetime;
  final Duration refreshLifetime;

  /// [env] içinden sırları okur. Eksik ya da kısa sır varsa `null` döner;
  /// sunucu bu durumda açılmaz.
  static JwtConfig? fromEnvironment(Map<String, String> env) {
    final access = env[accessSecretKey] ?? '';
    final refresh = env[refreshSecretKey] ?? '';
    if (access.length < minSecretLength) return null;
    if (refresh.length < minSecretLength) return null;
    if (access == refresh) return null;
    return JwtConfig(accessSecret: access, refreshSecret: refresh);
  }
}
