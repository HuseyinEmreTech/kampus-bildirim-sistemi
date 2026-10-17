import 'dart:convert';

import 'package:campus_server/src/endpoint/auth_endpoints.dart';
import 'package:campus_server/src/service/auth_service.dart';
import 'package:campus_server/src/service/password_hasher.dart';
import 'package:campus_server/src/service/token_service.dart';
import 'package:shelf/shelf.dart';
import 'package:test/test.dart';

import '../support/fake_repositories.dart';
import '../support/test_values.dart';

// Test hızlı olsun diye düşük bcrypt maliyeti; üretimde 12.
final hasher = PasswordHasher(cost: 4);

late Handler app;

void main() {
  setUp(() {
    final users = FakeUsers()
      ..users.add((
        userId: studentId,
        fullName: 'Ayşe Yılmaz',
        email: 'ayse@ornek.edu',
        passwordHash: hasher.hash(testPassword),
        role: 'Student',
      ));
    final auth = AuthService(
      users: users,
      sessions: FakeSessions(),
      tokens: TokenService(testJwtConfig),
      hasher: hasher,
    );
    app = AuthEndpoints(auth).router.call;
  });

  test('login_validCredentials_returnsTokens', () async {
    final res = await _validLogin();
    expect(res.statusCode, 200);
    expect(res.headers['content-type'], startsWith('application/json'));
    final body = await _json(res);
    expect(body['accessToken'], isA<String>());
    expect(body['refreshToken'], isA<String>());
    // Parola özeti ve e-posta yanıtta yok.
    expect(body['user'], {
      'userId': studentId,
      'fullName': 'Ayşe Yılmaz',
      'role': 'Student',
    });
  });

  test('login_wrongPassword_returns401', () async {
    final res = await _post('/api/auth/login', {
      'email': 'ayse@ornek.edu',
      'password': 'yanlis',
    });
    expect(res.statusCode, 401);
    expect(await _errorCode(res), 'INVALID_CREDENTIALS');
  });

  test('login_unknownUser_returns401', () async {
    final res = await _post('/api/auth/login', {
      'email': 'yok@ornek.edu',
      'password': testPassword,
    });
    expect(res.statusCode, 401);
    expect(await _errorCode(res), 'INVALID_CREDENTIALS');
  });

  test('login_missingPassword_returns400', () async {
    final res = await _post('/api/auth/login', {'email': 'ayse@ornek.edu'});
    expect(res.statusCode, 400);
    expect(await _errorCode(res), 'VALIDATION_ERROR');
  });

  test('login_bodyNotJson_returns400', () async {
    final res = await app(
      Request(
        'POST',
        Uri.parse('http://localhost/api/auth/login'),
        body: 'json-degil',
      ),
    );
    expect(res.statusCode, 400);
  });

  test('refresh_validToken_returnsNewTokens', () async {
    final first = await _json(await _validLogin());
    final res = await _post('/api/auth/refresh', {
      'refreshToken': first['refreshToken'],
    });
    expect(res.statusCode, 200);
    expect((await _json(res))['refreshToken'], isNot(first['refreshToken']));
  });

  test('refresh_revokedToken_returns401', () async {
    final first = await _json(await _validLogin());
    final token = first['refreshToken'];
    await _post('/api/auth/refresh', {'refreshToken': token});
    final res = await _post('/api/auth/refresh', {'refreshToken': token});
    expect(res.statusCode, 401);
    expect(await _errorCode(res), 'UNAUTHORIZED');
  });

  test('refresh_expiredToken_returns401', () async {
    final expired = TokenService(expiredJwtConfig)
        .createRefreshToken(studentId);
    final res = await _post('/api/auth/refresh', {'refreshToken': expired});
    expect(res.statusCode, 401);
  });

  test('refresh_missingToken_returns400', () async {
    final res = await _post('/api/auth/refresh', {});
    expect(res.statusCode, 400);
    expect(await _errorCode(res), 'VALIDATION_ERROR');
  });
}

Future<Response> _post(String path, Map<String, Object?> body) async => app(
  Request(
    'POST',
    Uri.parse('http://localhost$path'),
    body: jsonEncode(body),
    headers: {'content-type': 'application/json'},
  ),
);

Future<Response> _validLogin() => _post('/api/auth/login', {
  'email': 'ayse@ornek.edu',
  'password': testPassword,
});

Future<Map<String, Object?>> _json(Response res) async =>
    jsonDecode(await res.readAsString()) as Map<String, Object?>;

Future<String?> _errorCode(Response res) async {
  final error = (await _json(res))['error']! as Map<String, Object?>;
  return error['code'] as String?;
}
