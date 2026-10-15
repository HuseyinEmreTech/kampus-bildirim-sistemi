/// Şifrenin en az karakter sayısı; yalnızca kullanıcıya erken uyarı içindir.
const passwordMinLength = 6;

/// Kullanıcının rolü (03-domain-design: Role) ve API'deki yazılışı.
enum UserRole {
  student('Student'),
  staff('Staff');

  const UserRole(this.jsonValue);

  final String jsonValue;
}

/// Girişten sonra uygulamanın bellekte tuttuğu oturum bilgisi
/// (05-api-design: `POST /api/auth/login` yanıtı).
class Session {
  const Session({
    required this.token,
    required this.userId,
    required this.fullName,
    required this.role,
  });

  final String token;
  final String userId;
  final String fullName;
  final UserRole role;

  /// Giriş yanıtını okur; biçim beklenenden farklıysa `null` döner.
  static Session? fromJson(Map<String, Object?> json) {
    if (json case {
      'token': final String token,
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
        token: token,
        userId: userId,
        fullName: fullName,
        role: role,
      );
    }
    return null;
  }

  Map<String, Object?> toJson() => {
    'token': token,
    'user': {'userId': userId, 'fullName': fullName, 'role': role.jsonValue},
  };
}
