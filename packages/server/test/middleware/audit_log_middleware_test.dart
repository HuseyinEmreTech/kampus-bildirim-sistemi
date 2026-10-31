import 'dart:convert';

import 'package:campus_server/src/middleware/audit_log_middleware.dart';
import 'package:campus_server/src/middleware/auth_middleware.dart';
import 'package:campus_server/src/service/token_service.dart';
import 'package:shelf/shelf.dart';
import 'package:test/test.dart';

import '../support/test_values.dart';

final tokens = TokenService(testJwtConfig);

late List<String> lines;

void main() {
  setUp(() => lines = []);

  Handler app(Response Function() result) => const Pipeline()
      .addMiddleware(authMiddleware(tokens))
      .addMiddleware(auditLog(write: lines.add))
      .addHandler((_) => result());

  Request req(String method) => Request(
    method,
    Uri.parse('http://localhost/api/reports/r1/assignment?x=gizli'),
    headers: {
      'authorization': 'Bearer ${tokens.createAccessToken(staffId, 'Staff')}',
    },
  );

  test('audit_mutatingRequest_writesWhoWhatResult', () async {
    final res = await app(() => Response.ok('ok'))(req('PUT'));
    expect(res.statusCode, 200);
    final log = jsonDecode(lines.single) as Map<String, Object?>;
    expect(log['audit'], isTrue);
    expect(log['userId'], staffId);
    expect(log['method'], 'PUT');
    expect(log['path'], '/api/reports/r1/assignment');
    expect(log['status'], 200);
    expect(log['time'], isA<String>());
  });

  test('audit_failedRequest_recordsErrorStatus', () async {
    await app(() => Response(409))(req('POST'));
    final log = jsonDecode(lines.single) as Map<String, Object?>;
    expect(log['status'], 409);
  });

  test('audit_readOnlyGet_notRecorded', () async {
    final res = await app(() => Response.ok('ok'))(req('GET'));
    expect(res.statusCode, 200);
    expect(lines, isEmpty);
  });

  test('audit_neverWritesQueryString', () async {
    await app(() => Response.ok('ok'))(req('DELETE'));
    expect(lines.single, isNot(contains('gizli')));
  });
}
