import 'package:shelf/shelf.dart';

import '../http/json_http.dart';

/// İstek gövdesinin en büyük boyutu: 5 MB fotoğraf (Rule 07) ve form alanları
/// için pay. Daha büyük istek sunucunun belleğini doldurmasın diye okunmaz.
const maxRequestBytes = 6 * 1024 * 1024;

/// Gövde sınırı aşılınca akışın içinden fırlatılır; [bodyLimit] yakalayıp
/// `413` döner. Uç kodlarına ulaşmaz.
final class BodyTooLarge implements Exception {
  const BodyTooLarge();
}

/// Gövdesi [maxBytes]'ı aşan isteği `413 PAYLOAD_TOO_LARGE` ile reddeder.
/// `Content-Length` büyükse hiç okunmadan; başlık yoksa (parça parça
/// gönderim) okurken sınır aşıldığı anda.
Middleware bodyLimit({int maxBytes = maxRequestBytes}) {
  return (Handler inner) {
    return (Request request) async {
      final length = request.contentLength;
      if (length != null && length > maxBytes) return _tooLarge(maxBytes);
      try {
        return await inner(
          request.change(body: _limited(request.read(), maxBytes)),
        );
      } on BodyTooLarge {
        return _tooLarge(maxBytes);
      }
    };
  };
}

Stream<List<int>> _limited(Stream<List<int>> body, int maxBytes) async* {
  var total = 0;
  await for (final chunk in body) {
    total += chunk.length;
    if (total > maxBytes) throw const BodyTooLarge();
    yield chunk;
  }
}

Response _tooLarge(int maxBytes) => errorResponse(
  413,
  'PAYLOAD_TOO_LARGE',
  'İstek en fazla ${maxBytes ~/ (1024 * 1024)} MB olabilir.',
);
