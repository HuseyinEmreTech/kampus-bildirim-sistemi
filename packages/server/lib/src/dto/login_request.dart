/// `POST /api/auth/login` gövdesi: `{ "email": "...", "password": "..." }`.
class LoginRequest {
  const LoginRequest({required this.email, required this.password});

  final String email;
  final String password;

  /// Alanlar eksik, boş ya da metin değilse `null` döner (400 olur).
  static LoginRequest? fromJson(Map<String, Object?> json) {
    final email = json['email'];
    final password = json['password'];
    if (email is! String || email.trim().isEmpty) return null;
    if (password is! String || password.isEmpty) return null;
    return LoginRequest(email: email.trim(), password: password);
  }
}
