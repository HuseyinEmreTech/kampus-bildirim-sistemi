/// Şifrenin en az karakter sayısı; yalnızca kullanıcıya erken uyarı içindir.
const passwordMinLength = 6;

/// Kullanıcının rolü (03-domain-design: Role).
enum UserRole { student, staff }

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
}
