import 'package:campus_infrastructure/campus_infrastructure.dart';

/// Giriş ve yenileme yanıtı. Parola özeti istemciye asla gönderilmez.
class AuthResponse {
  const AuthResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  final String accessToken;
  final String refreshToken;
  final UserRecord user;

  Map<String, Object?> toJson() => {
    'accessToken': accessToken,
    'refreshToken': refreshToken,
    'user': {
      'userId': user.userId,
      'fullName': user.fullName,
      'role': user.role,
    },
  };
}
