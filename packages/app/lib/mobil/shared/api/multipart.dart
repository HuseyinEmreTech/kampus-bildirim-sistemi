import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;

/// Sınırın rastgele kısmının uzunluğu.
const _boundaryLength = 24;

const _boundaryChars = 'abcdefghijklmnopqrstuvwxyz0123456789';

final _random = Random();

/// Bir fotoğraf ve metin alanlarından oluşan `multipart/form-data` istek.
///
/// `http` paketinin `MultipartFile`'ı dosya türü için ek bir paket
/// (`http_parser`) istediğinden gövde burada elle kurulur. Sunucu dosyanın
/// türünü ilk baytlarına bakıp [fileContentType] ile karşılaştırdığı için
/// türün doğru gönderilmesi gerekir.
http.Request multipartRequest(
  String method,
  Uri url, {
  required Map<String, String> fields,
  required String fileField,
  required List<int> fileBytes,
  required String fileContentType,
  required String fileName,
}) {
  final boundary = _newBoundary();
  final body = <int>[];
  void write(String text) => body.addAll(utf8.encode(text));

  for (final MapEntry(:key, :value) in fields.entries) {
    write('--$boundary\r\n');
    write('Content-Disposition: form-data; name="$key"\r\n\r\n');
    write('$value\r\n');
  }
  write('--$boundary\r\n');
  write(
    'Content-Disposition: form-data; name="$fileField"; '
    'filename="$fileName"\r\n',
  );
  write('Content-Type: $fileContentType\r\n\r\n');
  body.addAll(fileBytes);
  write('\r\n--$boundary--\r\n');

  return http.Request(method, url)
    ..headers['Content-Type'] = 'multipart/form-data; boundary=$boundary'
    ..bodyBytes = body;
}

String _newBoundary() => [
  'kampus-',
  for (var i = 0; i < _boundaryLength; i++)
    _boundaryChars[_random.nextInt(_boundaryChars.length)],
].join();

/// Fotoğraf türüne göre dosya adı uzantısı.
String photoFileName(String contentType) =>
    contentType == 'image/png' ? 'foto.png' : 'foto.jpg';
