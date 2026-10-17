import 'session.dart';

/// Oturumu uygulama kapanınca da saklayan depo.
///
/// Gerçek hali `flutter_secure_storage` onaylanınca yazılacak (şifreli saklama);
/// okunamayan veya bozuk kayıtta `read` `null` döner. Testlerde sahte depo kullanılır.
abstract interface class SessionStore {
  Future<Session?> read();
  Future<void> write(Session session);
  Future<void> clear();
}
