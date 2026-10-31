import 'dart:convert';

import 'package:campus_server/src/middleware/request_log_middleware.dart';
import 'package:shelf/shelf.dart';
import 'package:test/test.dart';

void main() {
  late List<String> lines;
  late DateTime time;

  setUp(() {
    lines = [];
    time = DateTime.utc(2026, 10, 17, 12);
  });

  Handler app(Handler inner) => const Pipeline()
      .addMiddleware(requestLog(write: lines.add, now: () => time))
      .addHandler(inner);

  Request req() => Request(
    'POST',
    Uri.parse('http://localhost/api/auth/login?x=gizli'),
    headers: {'authorization': 'Bearer gizli-belirtec'},
    body: '{"password":"gizli-parola"}',
  );

  Map<String, Object?> entry() =>
      jsonDecode(lines.single) as Map<String, Object?>;

  test('requestLog_success_writesOneJsonLine', () async {
    final res = await app((_) {
      time = time.add(const Duration(milliseconds: 42));
      return Response.ok('ok');
    })(req());

    expect(res.statusCode, 200);
    final log = entry();
    expect(log['level'], 'info');
    expect(log['method'], 'POST');
    expect(log['path'], '/api/auth/login');
    expect(log['status'], 200);
    expect(log['durationMs'], 42);
    // Satır istek bitince yazılır; zaman o anı gösterir.
    expect(log['time'], '2026-10-17T12:00:00.042Z');
    expect(log['requestId'], res.headers[requestIdHeader]);
    expect(res.headers[requestIdHeader], hasLength(16));
  });

  test('requestLog_neverWritesSecrets', () async {
    await app((_) => Response.ok('ok'))(req());
    expect(lines.single, isNot(contains('gizli')));
  });

  test('requestLog_serverError_levelError', () async {
    await app((_) => Response.internalServerError())(req());
    expect(entry()['level'], 'error');
    expect(entry()['status'], 500);
  });

  test('requestLog_clientError_levelInfo', () async {
    await app((_) => Response.notFound('yok'))(req());
    expect(entry()['level'], 'info');
    expect(entry()['status'], 404);
  });

  test('requestLog_handlerThrows_logsAndRethrows', () async {
    final handler = app((_) => throw StateError('beklenmeyen'));
    await expectLater(handler(req()), throwsStateError);
    expect(entry()['level'], 'error');
    expect(entry()['error'], 'StateError');
  });

  test('requestLog_eachRequestGetsNewId', () async {
    final handler = app((_) => Response.ok('ok'));
    final a = await handler(req());
    final b = await handler(req());
    expect(a.headers[requestIdHeader], isNot(b.headers[requestIdHeader]));
  });
}
