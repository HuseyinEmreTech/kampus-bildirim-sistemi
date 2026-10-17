import '../features/auth/data/session.dart';
import '../features/auth/data/session_store.dart';

/// Oturumu yalnızca bellekte tutan depo; uygulama kapanınca oturum düşer.
/// `flutter_secure_storage` onaylanınca şifreli gerçek hali bunun yerine geçer.
class MemorySessionStore implements SessionStore {
  Session? _session;

  @override
  Future<Session?> read() async => _session;

  @override
  Future<void> write(Session session) async => _session = session;

  @override
  Future<void> clear() async => _session = null;
}
