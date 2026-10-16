import '../database/database.dart';
import '../database/uuid_format.dart';

/// Kullanıcı satırı. Domain'deki `User` (#15) gelince onunla değişecek.
/// [passwordHash] yalnızca girişte parola kontrolü içindir; istemciye gönderilmez.
typedef UserRecord = ({
  String userId,
  String fullName,
  String email,
  String passwordHash,
  String role,
});

/// Kullanıcıların PostgreSQL tarafı. `UserRepository` arayüzü (#15) gelince onu uygular.
class UserRepositoryImpl {
  UserRepositoryImpl(this._db);

  final Database _db;

  static const _columns =
      'user_id::text, full_name, email, password_hash, role';

  // E-posta büyük/küçük harf fark etmeden eşleşir; V3'teki tekil index de lower(email).
  // Boşluk temizleme gibi biçim düzeltmeleri domain'deki e-posta kuralının işi.
  static const _byEmailSql =
      'SELECT $_columns FROM users WHERE lower(email) = lower(\$1)';

  static const _byIdSql = 'SELECT $_columns FROM users WHERE user_id = \$1';

  /// Girişte kullanılır; kullanıcı yoksa `null`.
  Future<UserRecord?> findByEmail(String email) async =>
      _single(await _db.execute(_byEmailSql, [email]));

  /// [userId] UUID değilse ya da kullanıcı yoksa `null`.
  Future<UserRecord?> findById(String userId) async {
    if (!isUuid(userId)) return null;
    return _single(await _db.execute(_byIdSql, [userId]));
  }

  UserRecord? _single(List<List<Object?>> rows) {
    if (rows.isEmpty) return null;
    final [id, fullName, email, passwordHash, role] = rows.single;
    return (
      userId: id! as String,
      fullName: fullName! as String,
      email: email! as String,
      passwordHash: passwordHash! as String,
      role: role! as String,
    );
  }
}
