import 'dart:convert';

import 'package:campus_server/src/endpoint/user_endpoints.dart';
import 'package:campus_server/src/middleware/auth_middleware.dart';
import 'package:campus_server/src/service/token_service.dart';
import 'package:shelf/shelf.dart';
import 'package:test/test.dart';

import '../support/fake_repositories.dart';
import '../support/test_values.dart';

final tokens = TokenService(testJwtConfig);

late FakeUsers users;
late Handler app;

void main() {
  setUp(() {
    users = FakeUsers()
      ..users.add((
        userId: staffId,
        fullName: 'Zeynep Demir',
        email: 'zeynep@ornek.edu',
        passwordHash: 'gizli-ozet',
        role: 'Staff',
      ));
    // Sunucudaki gibi: adres, auth middleware'in arkasında.
    app = const Pipeline()
        .addMiddleware(authMiddleware(tokens))
        .addHandler(UserEndpoints(users).router.call);
  });

  test('me_validToken_returnsOwnProfile', () async {
    final res = await app(_get(tokens.createAccessToken(staffId, 'Staff')));
    expect(res.statusCode, 200);
    expect(jsonDecode(await res.readAsString()), {
      'userId': staffId,
      'fullName': 'Zeynep Demir',
      'email': 'zeynep@ornek.edu',
      'role': 'Staff',
    });
  });

  test('me_neverReturnsPasswordHash', () async {
    final res = await app(_get(tokens.createAccessToken(staffId, 'Staff')));
    expect(await res.readAsString(), isNot(contains('gizli-ozet')));
  });

  test('me_withoutToken_returns401', () async {
    final res = await app(_get(null));
    expect(res.statusCode, 401);
  });

  test('me_userDeleted_returns404', () async {
    users.users.clear();
    final res = await app(_get(tokens.createAccessToken(staffId, 'Staff')));
    expect(res.statusCode, 404);
    final body = jsonDecode(await res.readAsString()) as Map<String, Object?>;
    expect((body['error']! as Map<String, Object?>)['code'], 'NOT_FOUND');
  });
}

Request _get(String? accessToken) => Request(
  'GET',
  Uri.parse('http://localhost/api/users/me'),
  headers: {
    'authorization': ?(accessToken == null ? null : 'Bearer $accessToken'),
  },
);
