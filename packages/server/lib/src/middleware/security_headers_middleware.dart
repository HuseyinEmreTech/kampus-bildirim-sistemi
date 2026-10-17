import 'package:shelf/shelf.dart';

/// Her yanıta eklenen güvenlik başlıkları (Helmet benzeri).
/// Sunucu yalnızca JSON döndüğü için en sıkı ayarlar seçildi.
const securityHeaderValues = {
  // Tarayıcı dosya türünü tahmin etmesin; `content-type` neyse o.
  'x-content-type-options': 'nosniff',
  // Yanıt başka bir sitede çerçeve (iframe) içinde açılamasın.
  'x-frame-options': 'DENY',
  // Yanıt hiçbir betik, resim, stil yükleyemesin; çerçevelenemesin.
  'content-security-policy': "default-src 'none'; frame-ancestors 'none'",
  // Başka siteye geçerken adres bilgisi gönderilmesin.
  'referrer-policy': 'no-referrer',
  // HTTPS ile gelindiyse bir yıl boyunca yalnızca HTTPS kullanılsın.
  // HTTP üzerinden tarayıcılar bu başlığı yok sayar.
  'strict-transport-security': 'max-age=31536000',
  // Kişisel veri içeren yanıtlar önbelleğe yazılmasın.
  'cache-control': 'no-store',
};

/// [securityHeaderValues] başlıklarını her yanıta ekler.
Middleware securityHeaders() {
  return (Handler inner) {
    return (Request request) async {
      final response = await inner(request);
      return response.change(headers: securityHeaderValues);
    };
  };
}
