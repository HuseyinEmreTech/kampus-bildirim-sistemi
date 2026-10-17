import 'dart:convert';

import 'package:shelf/shelf.dart';

const _jsonHeaders = {'content-type': 'application/json; charset=utf-8'};

/// Başarılı JSON yanıtı.
Response jsonResponse(int status, Map<String, Object?> body) =>
    Response(status, body: jsonEncode(body), headers: _jsonHeaders);

/// Ortak hata biçimi (proje-bilgileri/05-api-design.md):
/// `{ "error": { "code": "...", "message": "...", "details": "..." } }`
Response errorResponse(
  int status,
  String code,
  String message, {
  String details = '',
}) => jsonResponse(status, {
  'error': {'code': code, 'message': message, 'details': details},
});

/// İstek gövdesini JSON nesnesi olarak okur. Gövde JSON değilse ya da
/// nesne değilse `null` döner.
Future<Map<String, Object?>?> readJsonObject(Request request) async {
  final text = await request.readAsString();
  try {
    final decoded = jsonDecode(text);
    if (decoded is! Map<String, Object?>) return null;
    return decoded;
  } on FormatException {
    return null;
  }
}
