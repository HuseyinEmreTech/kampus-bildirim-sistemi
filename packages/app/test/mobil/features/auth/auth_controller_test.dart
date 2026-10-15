import 'package:campus_app/mobil/features/auth/data/session.dart';
import 'package:campus_app/mobil/features/auth/data/session_store.dart';
import 'package:campus_app/mobil/features/auth/state/auth_controller.dart';
import 'package:flutter_test/flutter_test.dart';

/// Oturumu bellekte tutan sahte depo.
class FakeSessionStore implements SessionStore {
  FakeSessionStore([this.stored]);

  Session? stored;

  @override
  Future<Session?> read() async => stored;

  @override
  Future<void> write(Session session) async => stored = session;

  @override
  Future<void> clear() async => stored = null;
}

const session = Session(
  token: 'sahte-belirtec',
  userId: '5c98741b-64c8-49de-9e68-3d7a2f44802b',
  fullName: 'Ayşe Yılmaz',
  role: UserRole.student,
);

void main() {
  test('restore_setsSession_whenSessionStored', () async {
    final controller = AuthController(FakeSessionStore(session));

    await controller.restore();

    expect(controller.isLoggedIn, isTrue);
    expect(controller.session?.fullName, 'Ayşe Yılmaz');
  });

  test('restore_staysLoggedOut_whenNothingStored', () async {
    final controller = AuthController(FakeSessionStore());

    await controller.restore();

    expect(controller.isLoggedIn, isFalse);
  });

  test('signIn_savesSessionAndNotifies', () async {
    final store = FakeSessionStore();
    final controller = AuthController(store);
    var notified = 0;
    controller.addListener(() => notified++);

    await controller.signIn(session);

    expect(store.stored, session);
    expect(controller.session, session);
    expect(notified, 1);
  });

  test('signOut_clearsStoreAndNotifies', () async {
    final store = FakeSessionStore(session);
    final controller = AuthController(store);
    await controller.restore();
    var notified = 0;
    controller.addListener(() => notified++);

    await controller.signOut();

    expect(store.stored, isNull);
    expect(controller.isLoggedIn, isFalse);
    expect(notified, 1);
  });
}
