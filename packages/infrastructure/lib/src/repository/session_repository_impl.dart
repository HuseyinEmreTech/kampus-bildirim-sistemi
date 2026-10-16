import '../database/database.dart';

/// Giriş oturumları (refresh token). Arayüz (#15) gelince onu uygular.
///
/// Belirtecin kendisi asla saklanmaz; sunucu belirtecin özetini (hash) verir.
/// Özet aramada kullanıldığı için her seferinde aynı çıkmalıdır (ör. SHA-256);
/// bcrypt gibi tuzlu özetle `WHERE refresh_token_hash = $1` araması çalışmaz.
class SessionRepositoryImpl {
  SessionRepositoryImpl(this._db);

  final Database _db;

  static const _insertSql = r'''
INSERT INTO sessions (user_id, refresh_token_hash, expires_at)
VALUES ($1, $2, $3)
RETURNING session_id::text
''';

  // Eski belirteç tek seferliktir: koşul UPDATE'in içinde olduğu için aynı belirteç
  // aynı anda iki kez gelse de yalnızca biri iptal edebilir (Rule 02 ile aynı yöntem).
  static const _revokeActiveSql = r'''
UPDATE sessions SET revoked_at = NOW()
WHERE refresh_token_hash = $1 AND revoked_at IS NULL AND expires_at > NOW()
RETURNING user_id::text
''';

  /// Girişte yeni oturum açar; oturum kimliğini döner.
  Future<String> create(
    String userId,
    String refreshTokenHash,
    DateTime expiresAt,
  ) async {
    final rows = await _db.execute(_insertSql, [
      userId,
      refreshTokenHash,
      expiresAt.toUtc(),
    ]);
    return rows.single.single! as String;
  }

  /// Eski belirteci iptal edip aynı kullanıcıya yeni oturum açar (tek işlemde).
  ///
  /// Eski belirteç yoksa, iptal edilmişse ya da süresi dolmuşsa `null` döner
  /// ve hiçbir şey yazılmaz.
  Future<({String sessionId, String userId})?> rotate(
    String oldTokenHash,
    String newTokenHash,
    DateTime newExpiresAt,
  ) {
    return _db.transaction((tx) async {
      final revoked = await tx.execute(
        _revokeActiveSql,
        parameters: [oldTokenHash],
      );
      if (revoked.isEmpty) return null;

      final userId = revoked.single.single! as String;
      final created = await tx.execute(
        _insertSql,
        parameters: [userId, newTokenHash, newExpiresAt.toUtc()],
      );
      return (sessionId: created.single.single! as String, userId: userId);
    });
  }
}
