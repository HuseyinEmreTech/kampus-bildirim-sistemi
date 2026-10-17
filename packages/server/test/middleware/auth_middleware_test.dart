import 'dart:convert';

import 'package:campus_server/src/middleware/auth_middleware.dart';
import 'package:campus_server/src/middleware/role_guard_middleware.dart';
import 'package:campus_server/src/service/token_service.dart';
import 'package:shelf/shelf.dart';
import 'package:test/test.dart';

import '../support/test_values.dart';

final tokens = TokenService(testJwtConfig);

void main() {
  group('authMiddleware', () {
    test('middleware_validToken_setsUserContext', () async {
      UserContext? seen;
      final handler = const Pipeline()
          .addMiddleware(authMiddleware(tokens))
          .addHandler((request) {
            seen = currentUser(request);
            return Response.ok('');
          });
      final res = await handler(
        _request('Bearer ${tokens.createAccessToken(staffId, 'Staff')}'),
      );
      expect(res.statusCode, 200);
      expect(seen, (userId: staffId, role: 'Staff'));
    });

    test('middleware_expiredToken_returns401', () async {
      final expired = TokenService(expiredJwtConfig)
          .createAccessToken(staffId, 'Staff');
      final res = await _protected()(_request('Bearer $expired'));
      expect(res.statusCode, 401);
      expect(await _errorCode(res), 'UNAUTHORIZED');
    });

    test('middleware_missingHeader_returns401', () async {
      final res = await _protected()(_request(null));
      expect(res.statusCode, 401);
    });

    test('middleware_notBearer_returns401', () async {
      final res = await _protected()(_request('Basic abc'));
      expect(res.statusCode, 401);
    });

    test('middleware_tokenFromOtherSecret_returns401', () async {
      final forged = TokenService(otherJwtConfig)
          .createAccessToken(staffId, 'Staff');
      final res = await _protected()(_request('Bearer $forged'));
      expect(res.statusCode, 401);
    });
  });

  group('requireRole', () {
    test('roleGuard_staffRequiredStudentToken_returns403', () async {
      final token = tokens.createAccessToken(studentId, 'Student');
      final res = await _staffOnly()(_request('Bearer $token'));
      expect(res.statusCode, 403);
      expect(await _errorCode(res), 'FORBIDDEN');
    });

    test('roleGuard_staffRequiredStaffToken_returns200', () async {
      final token = tokens.createAccessToken(staffId, 'Staff');
      final res = await _staffOnly()(_request('Bearer $token'));
      expect(res.statusCode, 200);
    });

    test('roleGuard_withoutAuthMiddleware_returns401', () async {
      final handler = const Pipeline()
          .addMiddleware(requireRole('Staff'))
          .addHandler((_) => Response.ok(''));
      final res = await handler(_request(null));
      expect(res.statusCode, 401);
    });
  });
}

Request _request(String? authorization) => Request(
  'GET',
  Uri.parse('http://localhost/korumali'),
  headers: {'authorization': ?authorization},
);

Handler _protected() => const Pipeline()
    .addMiddleware(authMiddleware(tokens))
    .addHandler((_) => Response.ok(''));

Handler _staffOnly() => const Pipeline()
    .addMiddleware(authMiddleware(tokens))
    .addMiddleware(requireRole('Staff'))
    .addHandler((_) => Response.ok(''));

Future<String?> _errorCode(Response res) async {
  final body = jsonDecode(await res.readAsString()) as Map<String, Object?>;
  final error = body['error']! as Map<String, Object?>;
  return error['code'] as String?;
}
