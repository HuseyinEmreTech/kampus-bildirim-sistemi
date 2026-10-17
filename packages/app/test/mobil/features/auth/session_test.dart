import 'package:campus_app/mobil/features/auth/data/session.dart';
import 'package:flutter_test/flutter_test.dart';

/// 05-api-design: `POST /api/auth/login` yanıtı (sahte veri).
Map<String, Object?> loginResponse({String role = 'Staff'}) => {
  'token': 'sahte-belirtec',
  'user': {
    'userId': '5c98741b-64c8-49de-9e68-3d7a2f44802b',
    'fullName': 'Ayşe Yılmaz',
    'role': role,
  },
};

void main() {
  test('fromJson_readsLoginResponse', () {
    final session = Session.fromJson(loginResponse());

    expect(session?.token, 'sahte-belirtec');
    expect(session?.userId, '5c98741b-64c8-49de-9e68-3d7a2f44802b');
    expect(session?.fullName, 'Ayşe Yılmaz');
    expect(session?.role, UserRole.staff);
  });

  test('fromJson_returnsNull_whenRoleUnknown', () {
    expect(Session.fromJson(loginResponse(role: 'Admin')), isNull);
  });

  test('toJson_fromJson_roundTrip', () {
    final json = loginResponse(role: 'Student');

    expect(Session.fromJson(json)?.toJson(), json);
  });
}
