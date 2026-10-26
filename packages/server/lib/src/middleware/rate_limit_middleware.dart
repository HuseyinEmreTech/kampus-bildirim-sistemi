import 'dart:io';

import 'package:shelf/shelf.dart';

import '../http/json_http.dart';

/// Bir istemcinin bir zaman penceresinde atabileceği en fazla istek.
class RateLimitRule {
  const RateLimitRule({required this.limit, required this.window});

  /// Genel sınır: IP başına dakikada 100 istek (kişisel plan, hafta 7).
  static const general = RateLimitRule(
    limit: 100,
    window: Duration(minutes: 1),
  );

  /// Giriş sınırı: IP başına dakikada 5 deneme (Issue #19 güvenlik notu).
  static const login = RateLimitRule(limit: 5, window: Duration(minutes: 1));

  final int limit;
  final Duration window;
}

/// İstemciyi tanımlayan anahtar. Varsayılan: bağlantının IP adresi.
typedef RateLimitKey = String Function(Request request);

/// Yalnızca bazı isteklere uygulamak için. `null` ise her isteğe uygulanır.
typedef RateLimitFilter = bool Function(Request request);

/// Sabit pencereli istek sınırı. Sınır aşılırsa `429 RATE_LIMITED` ve
/// `Retry-After` (saniye) döner. Sayaçlar bellekte tutulur; sunucu yeniden
/// başlarsa sıfırlanır (tek sunuculu ders projesi için yeterli).
Middleware rateLimit(
  RateLimitRule rule, {
  RateLimitFilter? appliesTo,
  RateLimitKey keyOf = clientIp,
  DateTime Function() now = DateTime.now,
}) {
  final windows = <String, ({DateTime start, int count})>{};
  var lastCleanup = now();

  return (Handler inner) {
    return (Request request) {
      if (appliesTo != null && !appliesTo(request)) return inner(request);

      final time = now();
      if (time.difference(lastCleanup) >= rule.window) {
        windows.removeWhere((_, w) => time.difference(w.start) >= rule.window);
        lastCleanup = time;
      }

      final key = keyOf(request);
      final current = windows[key];
      if (current == null || time.difference(current.start) >= rule.window) {
        windows[key] = (start: time, count: 1);
        return inner(request);
      }
      if (current.count >= rule.limit) {
        final retryAfter = rule.window - time.difference(current.start);
        return _tooManyRequests(retryAfter);
      }
      windows[key] = (start: current.start, count: current.count + 1);
      return inner(request);
    };
  };
}

/// Bağlantının IP adresi. Bilinmiyorsa (ör. testte) `unknown`.
/// Sunucu bir proxy arkasındaysa burası proxy'nin adresini görür; o durumda
/// [clientIpBehind] kullanılır.
String clientIp(Request request) {
  final info = request.context['shelf.io.connection_info'];
  if (info is HttpConnectionInfo) return info.remoteAddress.address;
  return 'unknown';
}

/// Ters proxy (Nginx, Cloudflare) arkasında gerçek istemci IP'si.
///
/// Proxy, istemcinin adresini `X-Forwarded-For` başlığına ekler. Bu başlığı
/// istemci de yazabildiği için yalnızca bağlantı [trustedProxies]'teki bir
/// adresten geliyorsa okunur; aksi hâlde herkes sahte IP yazıp sınırı
/// atlatabilirdi. Başlık sağdan sola okunur (her proxy sona ekler) ve
/// güvenilir olmayan ilk adres istemci sayılır. Liste boşsa (varsayılan)
/// başlık hiç okunmaz, [clientIp] ile aynıdır.
RateLimitKey clientIpBehind(Set<String> trustedProxies) {
  return (Request request) {
    final direct = clientIp(request);
    if (!trustedProxies.contains(direct)) return direct;
    final forwarded = request.headers['x-forwarded-for'] ?? '';
    final hops = forwarded
        .split(',')
        .map((hop) => hop.trim())
        .where((hop) => hop.isNotEmpty);
    for (final hop in hops.toList().reversed) {
      if (!trustedProxies.contains(hop)) return hop;
    }
    return direct;
  };
}

/// `TRUSTED_PROXIES` ortam değişkeni: virgülle ayrılmış proxy IP'leri.
/// Tanımlı değilse boş küme; proxy başlıklarına güvenilmez.
Set<String> trustedProxiesFrom(Map<String, String> env) =>
    (env[trustedProxiesKey] ?? '')
        .split(',')
        .map((ip) => ip.trim())
        .where((ip) => ip.isNotEmpty)
        .toSet();

const trustedProxiesKey = 'TRUSTED_PROXIES';

Response _tooManyRequests(Duration retryAfter) {
  // Yukarı yuvarlanmış saniye; en az 1.
  final rounded = (retryAfter.inMilliseconds + 999) ~/ 1000;
  final seconds = rounded < 1 ? 1 : rounded;
  return errorResponse(
    429,
    'RATE_LIMITED',
    'Çok fazla istek. Biraz sonra tekrar deneyin.',
  ).change(headers: {'retry-after': '$seconds'});
}
