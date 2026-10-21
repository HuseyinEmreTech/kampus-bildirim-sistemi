import 'package:flutter/foundation.dart';

import '../data/session.dart';
import '../data/session_store.dart';

/// Uygulamanın oturum durumu; ekranlar `ListenableBuilder` ile dinler.
///
/// Token'ın geçerliliğine sunucu karar verir: kayıtlı oturum varsa girişli
/// sayılır, ilk istekte 401 gelirse [signOut] çağrılır.
class AuthController extends ChangeNotifier {
  AuthController(this._store);

  final SessionStore _store;
  Session? _session;

  Session? get session => _session;
  bool get isLoggedIn => _session != null;

  /// Uygulama açılırken kayıtlı oturumu okur (otomatik giriş).
  Future<void> restore() async {
    _session = await _store.read();
    notifyListeners();
  }

  Future<void> signIn(Session session) async {
    await _store.write(session);
    _session = session;
    notifyListeners();
  }

  Future<void> signOut() async {
    await _store.clear();
    _session = null;
    notifyListeners();
  }
}
