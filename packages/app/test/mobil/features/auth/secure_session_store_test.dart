import 'package:campus_app/mobil/features/auth/data/secure_session_store.dart';
import 'package:campus_app/mobil/features/auth/data/session.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

const session = Session(
  accessToken: 'sahte-erisim',
  refreshToken: 'sahte-yenileme',
  userId: 'u1',
  fullName: 'Demo Öğrenci',
  role: UserRole.student,
);

/// Bellekte anahtar-değer tutan sahte şifreli depo; istenirse her çağrıda
/// platform hatası verir.
class FakeStorage implements KeyValueStorage {
  FakeStorage({this.fails = false});

  final bool fails;
  final values = <String, String>{};

  void _maybeFail() {
    if (fails) throw PlatformException(code: 'keystore');
  }

  @override
  Future<String?> read(String key) async {
    _maybeFail();
    return values[key];
  }

  @override
  Future<void> write(String key, String value) async {
    _maybeFail();
    values[key] = value;
  }

  @override
  Future<void> delete(String key) async {
    _maybeFail();
    values.remove(key);
  }
}

void main() {
  test('write_thenRead_returnsSameSession', () async {
    final store = SecureSessionStore(storage: FakeStorage());

    await store.write(session);
    final read = await store.read();

    expect(read?.accessToken, session.accessToken);
    expect(read?.refreshToken, session.refreshToken);
    expect(read?.fullName, session.fullName);
    expect(read?.role, UserRole.student);
  });

  test('read_returnsNull_whenNothingSaved', () async {
    expect(await SecureSessionStore(storage: FakeStorage()).read(), isNull);
  });

  test('read_returnsNull_whenRecordCorrupt', () async {
    // Sonuncusu #82 öncesi eski biçim (tek `token`): oturum yok sayılır.
    const oldFormat =
        '{"token": "x", "user": {"userId": "u1", "fullName": "A", "role": "Student"}}';
    for (final bad in ['{bozuk', '[]', '{"accessToken": 1}', oldFormat]) {
      final storage = FakeStorage();
      final store = SecureSessionStore(storage: storage);
      await store.write(session);
      storage.values.updateAll((_, _) => bad);

      expect(await store.read(), isNull, reason: bad);
    }
  });

  test('clear_removesSession', () async {
    final store = SecureSessionStore(storage: FakeStorage());
    await store.write(session);

    await store.clear();

    expect(await store.read(), isNull);
  });

  test('defaultStorage_writeReadClear_usesFlutterSecureStorage', () async {
    // Paketin kendi test deposu: gerçek Keystore yerine bellekte tutar.
    FlutterSecureStorage.setMockInitialValues({});
    final store = SecureSessionStore();

    await store.write(session);
    final read = await store.read();
    await store.clear();

    expect(read?.accessToken, session.accessToken);
    expect(await store.read(), isNull);
  });

  test('storageFailure_isNotThrown_andReadsAsLoggedOut', () async {
    final store = SecureSessionStore(storage: FakeStorage(fails: true));

    await store.write(session);
    await store.clear();

    expect(await store.read(), isNull);
  });
}
