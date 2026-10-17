import 'package:campus_infrastructure/campus_infrastructure.dart';

// Veritabanı olmadan test için repository'lerin bellek içi sahteleri.
// Davranışları gerçek SQL ile aynıdır (bkz. infrastructure testleri).

class FakeUsers implements UserRepositoryImpl {
  final users = <UserRecord>[];

  @override
  Future<UserRecord?> findByEmail(String email) async =>
      users.where((u) => u.email == email.toLowerCase()).firstOrNull;

  @override
  Future<UserRecord?> findById(String userId) async =>
      users.where((u) => u.userId == userId).firstOrNull;
}

class FakeSessions implements SessionRepositoryImpl {
  /// Belirteç özeti -> oturum. İptal edilen oturum `revoked: true` olur.
  final sessions = <String, ({String userId, bool revoked})>{};

  @override
  Future<String> create(
    String userId,
    String refreshTokenHash,
    DateTime expiresAt,
  ) async {
    sessions[refreshTokenHash] = (userId: userId, revoked: false);
    return 'session-${sessions.length}';
  }

  @override
  Future<({String sessionId, String userId})?> rotate(
    String oldTokenHash,
    String newTokenHash,
    DateTime newExpiresAt,
  ) async {
    final old = sessions[oldTokenHash];
    if (old == null || old.revoked) return null;
    sessions[oldTokenHash] = (userId: old.userId, revoked: true);
    final id = await create(old.userId, newTokenHash, newExpiresAt);
    return (sessionId: id, userId: old.userId);
  }
}
