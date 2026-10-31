import 'package:campus_server/src/middleware/security_headers_middleware.dart';
import 'package:shelf/shelf.dart';
import 'package:test/test.dart';

void main() {
  Future<Response> call(Response inner) async {
    final handler = const Pipeline()
        .addMiddleware(securityHeaders())
        .addHandler((_) => inner);
    return handler(Request('GET', Uri.parse('http://localhost/')));
  }

  test('securityHeaders_addedToEveryResponse', () async {
    final res = await call(Response.ok('ok'));
    expect(res.headers['x-content-type-options'], 'nosniff');
    expect(res.headers['x-frame-options'], 'DENY');
    expect(
      res.headers['content-security-policy'],
      contains("default-src 'none'"),
    );
    expect(res.headers['referrer-policy'], 'no-referrer');
    expect(res.headers['strict-transport-security'], startsWith('max-age='));
    expect(res.headers['cache-control'], 'no-store');
  });

  test('securityHeaders_errorResponsesToo', () async {
    final res = await call(Response.notFound('yok'));
    expect(res.statusCode, 404);
    expect(res.headers['x-frame-options'], 'DENY');
  });

  test('securityHeaders_keepsExistingHeaders', () async {
    final res = await call(
      Response.ok('{}', headers: {'content-type': 'application/json'}),
    );
    expect(res.headers['content-type'], 'application/json');
  });
}
