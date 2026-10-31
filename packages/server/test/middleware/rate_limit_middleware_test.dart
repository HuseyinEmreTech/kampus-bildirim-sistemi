import 'dart:convert';
import 'dart:io';

import 'package:campus_server/src/middleware/rate_limit_middleware.dart';
import 'package:shelf/shelf.dart';
import 'package:test/test.dart';

void main() {
  late DateTime time;
  DateTime clock() => time;

  setUp(() => time = DateTime.utc(2026, 10, 17, 12));

  const rule = RateLimitRule(limit: 3, window: Duration(minutes: 1));

  Handler app({RateLimitFilter? appliesTo}) => const Pipeline()
      .addMiddleware(
        rateLimit(
          rule,
          appliesTo: appliesTo,
          keyOf: (r) => r.headers['x-test-ip'] ?? 'yok',
          now: clock,
        ),
      )
      .addHandler((_) => Response.ok('ok'));

  Request req(String ip, {String path = 'api/reports'}) => Request(
    'GET',
    Uri.parse('http://localhost/$path'),
    headers: {'x-test-ip': ip},
  );

  test('rateLimit_underLimit_passes', () async {
    final handler = app();
    for (var i = 0; i < rule.limit; i++) {
      expect((await handler(req('1.1.1.1'))).statusCode, 200);
    }
  });

  test('rateLimit_overLimit_returns429WithRetryAfter', () async {
    final handler = app();
    for (var i = 0; i < rule.limit; i++) {
      await handler(req('1.1.1.1'));
    }
    time = time.add(const Duration(seconds: 20));
    final res = await handler(req('1.1.1.1'));
    expect(res.statusCode, 429);
    expect(res.headers['retry-after'], '40');
    final body = jsonDecode(await res.readAsString()) as Map<String, Object?>;
    expect((body['error']! as Map<String, Object?>)['code'], 'RATE_LIMITED');
  });

  test('rateLimit_otherClient_hasOwnCounter', () async {
    final handler = app();
    for (var i = 0; i < rule.limit; i++) {
      await handler(req('1.1.1.1'));
    }
    expect((await handler(req('2.2.2.2'))).statusCode, 200);
  });

  test('rateLimit_afterWindow_resets', () async {
    final handler = app();
    for (var i = 0; i < rule.limit; i++) {
      await handler(req('1.1.1.1'));
    }
    time = time.add(rule.window);
    expect((await handler(req('1.1.1.1'))).statusCode, 200);
  });

  test('rateLimit_filterFalse_notCounted', () async {
    final handler = app(appliesTo: (r) => r.url.path == 'api/auth/login');
    for (var i = 0; i < rule.limit + 2; i++) {
      expect((await handler(req('1.1.1.1'))).statusCode, 200);
    }
    for (var i = 0; i < rule.limit; i++) {
      await handler(req('1.1.1.1', path: 'api/auth/login'));
    }
    final res = await handler(req('1.1.1.1', path: 'api/auth/login'));
    expect(res.statusCode, 429);
  });

  test('rules_matchPlan', () {
    expect(RateLimitRule.general.limit, 100);
    expect(RateLimitRule.login.limit, 5);
    expect(RateLimitRule.login.window, const Duration(minutes: 1));
  });

  test('clientIp_withoutConnectionInfo_isUnknown', () {
    expect(clientIp(req('1.1.1.1')), 'unknown');
  });

  group('clientIpBehind', () {
    const proxy = '10.0.0.1';
    final keyOf = clientIpBehind({proxy});

    Request from(String ip, {String? forwardedFor}) => Request(
      'GET',
      Uri.parse('http://localhost/api/reports'),
      headers: {'x-forwarded-for': ?forwardedFor},
      context: {'shelf.io.connection_info': _Connection(ip)},
    );

    test('directClient_headerIgnored', () {
      // Proxy olmayan istemci başlığa sahte IP yazsa da kendi adresi sayılır.
      expect(keyOf(from('5.5.5.5', forwardedFor: '1.2.3.4')), '5.5.5.5');
    });

    test('trustedProxy_usesForwardedClient', () {
      expect(keyOf(from(proxy, forwardedFor: '1.2.3.4')), '1.2.3.4');
    });

    test('trustedProxy_spoofedPrefix_usesLastUntrustedHop', () {
      // İstemci "9.9.9.9" yazmış, proxy gerçek adresi (1.2.3.4) sona eklemiş.
      expect(keyOf(from(proxy, forwardedFor: '9.9.9.9, 1.2.3.4')), '1.2.3.4');
    });

    test('trustedProxy_noHeader_usesProxyAddress', () {
      expect(keyOf(from(proxy)), proxy);
    });

    test('emptyTrustList_sameAsClientIp', () {
      final plain = clientIpBehind({});
      expect(plain(from(proxy, forwardedFor: '1.2.3.4')), proxy);
    });
  });

  test('trustedProxiesFrom_parsesCommaSeparatedList', () {
    final env = {'TRUSTED_PROXIES': ' 10.0.0.1, ,10.0.0.2'};
    expect(trustedProxiesFrom(env), {'10.0.0.1', '10.0.0.2'});
    expect(trustedProxiesFrom({}), isEmpty);
  });
}

class _Connection implements HttpConnectionInfo {
  _Connection(String ip) : remoteAddress = InternetAddress(ip);

  @override
  final InternetAddress remoteAddress;

  @override
  int get remotePort => 50000;

  @override
  int get localPort => 8080;
}
