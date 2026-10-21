import 'session.dart';

/// Oturumu uygulama kapanınca da saklayan depo.
///
/// Şifreli gerçek hali (`flutter_secure_storage`, onaylı) ayrı PR'da gelecek;
/// okunamayan veya bozuk kayıtta `read` `null` döner. Testlerde sahte depo kullanılır.
abstract interface class SessionStore {
  Future<Session?> read();
  Future<void> write(Session session);
  Future<void> clear();
}
