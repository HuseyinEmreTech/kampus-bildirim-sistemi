/// Şifrenin en az karakter sayısı; yalnızca kullanıcıya erken uyarı içindir.
const passwordMinLength = 6;

/// Kullanıcının rolü (03-domain-design: Role) ve API'deki yazılışı.
enum UserRole {
  student('Student'),
  staff('Staff');

  const UserRole(this.jsonValue);

  final String jsonValue;
}

/// Girişten sonra uygulamanın tuttuğu oturum bilgisi (05-api-design, #82:
/// `POST /api/auth/login` yanıtı). Erişim belirteci isteklerde gönderilir
/// (15 dk); süresi dolunca yenileme belirteciyle (7 gün) yenisi alınır.
class Session {
  const Session({
    required this.accessToken,
    required this.refreshToken,
    required this.userId,
    required this.fullName,
    required this.role,
  });

  final String accessToken;
  final String refreshToken;
  final String userId;
  final String fullName;
  final UserRole role;

  /// Giriş yanıtını okur; biçim beklenenden farklıysa `null` döner.
  static Session? fromJson(Map<String, Object?> json) {
    if (json case {
      'accessToken': final String accessToken,
      'refreshToken': final String refreshToken,
      'user': {
        'userId': final String userId,
        'fullName': final String fullName,
        'role': final String roleValue,
      },
    }) {
      final role = UserRole.values
          .where((value) => value.jsonValue == roleValue)
          .firstOrNull;
      if (role == null) return null;
      return Session(
        accessToken: accessToken,
        refreshToken: refreshToken,
        userId: userId,
        fullName: fullName,
        role: role,
      );
    }
    return null;
  }

  Map<String, Object?> toJson() => {
    'accessToken': accessToken,
    'refreshToken': refreshToken,
    'user': {'userId': userId, 'fullName': fullName, 'role': role.jsonValue},
  };
}
