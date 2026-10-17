/// `POST /api/auth/refresh` gövdesi: `{ "refreshToken": "..." }`.
class RefreshRequest {
  const RefreshRequest({required this.refreshToken});

  final String refreshToken;

  /// Alan eksik, boş ya da metin değilse `null` döner (400 olur).
  static RefreshRequest? fromJson(Map<String, Object?> json) {
    final token = json['refreshToken'];
    if (token is! String || token.isEmpty) return null;
    return RefreshRequest(refreshToken: token);
  }
}
