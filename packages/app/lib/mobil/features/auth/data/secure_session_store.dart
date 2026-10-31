import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'session.dart';
import 'session_store.dart';

/// Oturumun şifreli depodaki anahtarı.
const _sessionKey = 'oturum';

/// Şifreli anahtar-değer deposu; gerçeği `flutter_secure_storage`, testte
/// sahtesi.
abstract interface class KeyValueStorage {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
  Future<void> delete(String key);
}

/// Oturumu telefonda şifreli saklayan depo (Android'de Keystore ile).
///
/// Depo hata verirse (ör. anahtar çözülemedi) istisna ekrana çıkmaz: okuma
/// "oturum yok" sayılır, yazma ve silme sessizce geçer; en kötü durumda
/// kullanıcı bir sonraki açılışta yeniden giriş yapar.
class SecureSessionStore implements SessionStore {
  SecureSessionStore({KeyValueStorage? storage})
    : _storage = storage ?? _FlutterSecureStorage();

  final KeyValueStorage _storage;

  @override
  Future<Session?> read() async {
    try {
      final saved = await _storage.read(_sessionKey);
      if (saved == null) return null;
      if (jsonDecode(saved) case final Map<String, Object?> json) {
        return Session.fromJson(json);
      }
      return null;
    } on FormatException {
      return null;
    } on PlatformException {
      return null;
    }
  }

  @override
  Future<void> write(Session session) async {
    try {
      await _storage.write(_sessionKey, jsonEncode(session.toJson()));
    } on PlatformException {
      // Saklanamadı: oturum yalnızca bu açılış boyunca bellekte kalır.
    }
  }

  @override
  Future<void> clear() async {
    try {
      await _storage.delete(_sessionKey);
    } on PlatformException {
      // Silinemedi: bozuk kayıt bir sonraki okumada zaten "oturum yok" olur.
    }
  }
}

class _FlutterSecureStorage implements KeyValueStorage {
  static const _storage = FlutterSecureStorage();

  @override
  Future<String?> read(String key) => _storage.read(key: key);

  @override
  Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value);

  @override
  Future<void> delete(String key) => _storage.delete(key: key);
}
