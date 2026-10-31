import 'dart:convert';

import 'package:mime/mime.dart';
import 'package:shelf/shelf.dart';

/// `multipart/form-data` isteğinin bir parçası: alan adı, istemcinin
/// bildirdiği içerik türü (dosyada) ve gövde akışı.
typedef FormPart = ({String name, String? contentType, Stream<List<int>> body});

final _boundary = RegExp(r'boundary="?([^";]+)"?', caseSensitive: false);
final _fieldName = RegExp(r'(?:^|;)\s*name="([^"]*)"');

/// İstek `multipart/form-data` ise sınır (boundary) değerini, değilse `null`
/// döner.
String? multipartBoundary(Request request) {
  final type = request.headers['content-type'] ?? '';
  if (!type.toLowerCase().startsWith('multipart/form-data')) return null;
  return _boundary.firstMatch(type)?.group(1);
}

/// İsteğin parçalarını sırayla verir. Her parçanın gövdesi, bir sonraki
/// parçaya geçmeden okunmalı ya da [drain] ile atılmalıdır.
Stream<FormPart> formParts(Request request, String boundary) =>
    MimeMultipartTransformer(boundary)
        .bind(request.read())
        .map(
          (part) => (
            name:
                _fieldName
                    .firstMatch(part.headers['content-disposition'] ?? '')
                    ?.group(1) ??
                '',
            contentType: part.headers['content-type'],
            body: part,
          ),
        );

/// Metin alanını okur. [maxBytes]'ı aşarsa kalanı atar ve `null` döner;
/// büyük bir alan belleği doldurmasın diye aşan kısım saklanmaz.
Future<String?> readTextField(Stream<List<int>> body, int maxBytes) async {
  final bytes = <int>[];
  var tooLong = false;
  await for (final chunk in body) {
    if (tooLong) continue;
    bytes.addAll(chunk);
    tooLong = bytes.length > maxBytes;
  }
  return tooLong ? null : utf8.decode(bytes, allowMalformed: true);
}
