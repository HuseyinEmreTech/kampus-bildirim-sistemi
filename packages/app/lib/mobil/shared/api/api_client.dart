import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

/// Sunucu bu sürede cevap vermezse "ulaşılamadı" sayılır.
const _requestTimeout = Duration(seconds: 20);

/// 401 durum kodu: giriş yok ya da oturumun süresi doldu.
const _unauthorized = 401;

/// 401'de oturumu kapatan hata kodu (05-api-design). Yanlış şifrede giriş
/// ucu `INVALID_CREDENTIALS` döner; o oturumu kapatmaz.
const _unauthorizedCode = 'UNAUTHORIZED';

/// Giriş ve yenileme uçları; buradaki 401 oturumu kapatmaz (yenileme
/// eklenince döngüye girmesin).
const _authPathPrefix = '/api/auth/';

/// Başarılı durum kodları: 200 (dahil) ile 300 (hariç) arası.
const _successStart = 200;
const _successEnd = 300;

/// Hata gövdesi okunamazsa kullanılan kod.
const unknownErrorCode = 'UNKNOWN';

/// Sunucu isteğinin sonucu (05-api-design).
sealed class ApiResponse {
  const ApiResponse();
}

/// 2xx; [body] çözülmüş JSON (gövde yoksa `null`).
final class ApiSuccess extends ApiResponse {
  const ApiSuccess(this.body);

  final Object? body;
}

/// Sunucu hata döndü: `{ "error": { "code", "message", "details" } }`.
final class ApiError extends ApiResponse {
  const ApiError({
    required this.status,
    required this.code,
    required this.message,
  });

  final int status;
  final String code;
  final String message;
}

/// Bağlantı yok, zaman aşımı ya da gövde JSON değil.
final class ApiUnreachable extends ApiResponse {
  const ApiUnreachable();
}

/// Sunucuyla konuşan ortak istemci: adres, `Authorization: Bearer` başlığı,
/// JSON ve hata gövdesi burada; kaynaklar (`*Source`) yalnızca yolu ve
/// çevrilecek modeli bilir. Ağ hataları sonuç tipine çevrilir, istisna
/// dışarı çıkmaz.
class ApiClient {
  ApiClient({
    required this._baseUrl,
    required this._token,
    http.Client? client,
    this._onUnauthorized,
  }) : _client = client ?? http.Client();

  final Uri _baseUrl;
  final String? Function() _token;
  final http.Client _client;

  /// 401 gelince çağrılır (ör. oturumu kapatıp giriş ekranına dönmek).
  final void Function()? _onUnauthorized;

  Future<ApiResponse> get(String path, {Map<String, String>? query}) =>
      _send(http.Request('GET', _url(path, query)));

  Future<ApiResponse> postJson(String path, Map<String, Object?> body) =>
      _send(_jsonRequest('POST', path, body));

  Future<ApiResponse> put(String path, {Map<String, Object?>? body}) => _send(
    body == null
        ? http.Request('PUT', _url(path, null))
        : _jsonRequest('PUT', path, body),
  );

  /// Hazır bir isteği gönderir (ör. fotoğraflı `multipart` istek).
  Future<ApiResponse> send(http.BaseRequest request) => _send(request);

  /// [path] yolunun tam adresi.
  Uri url(String path) => _url(path, null);

  Uri _url(String path, Map<String, String>? query) => _baseUrl.replace(
    path: path,
    queryParameters: query == null || query.isEmpty ? null : query,
  );

  http.Request _jsonRequest(
    String method,
    String path,
    Map<String, Object?> body,
  ) => http.Request(method, _url(path, null))
    ..headers['Content-Type'] = 'application/json; charset=utf-8'
    ..body = jsonEncode(body);

  Future<ApiResponse> _send(http.BaseRequest request) async {
    final token = _token();
    if (token != null) request.headers['Authorization'] = 'Bearer $token';
    try {
      final streamed = await _client.send(request).timeout(_requestTimeout);
      final response = await http.Response.fromStream(streamed);
      return _read(response, request.url.path);
    } on http.ClientException {
      return const ApiUnreachable();
    } on TimeoutException {
      return const ApiUnreachable();
    } on FormatException {
      return const ApiUnreachable();
    } on IOException {
      // TLS el sıkışması (HandshakeException) ya da gövde okunurken kopan
      // bağlantı (SocketException): http paketi bunları çevirmeden geçirir.
      return const ApiUnreachable();
    }
  }

  ApiResponse _read(http.Response response, String path) {
    final status = response.statusCode;
    final text = utf8.decode(response.bodyBytes);
    if (status >= _successStart && status < _successEnd) {
      return ApiSuccess(text.isEmpty ? null : jsonDecode(text));
    }
    final error = _error(status, text);
    if (_endsSession(error, path)) _onUnauthorized?.call();
    return error;
  }

  /// Oturum yalnızca giriş gerektiren bir uç `UNAUTHORIZED` dönünce biter;
  /// giriş ve yenileme uçlarının 401'i (ör. yanlış şifre) bitirmez.
  bool _endsSession(ApiError error, String path) =>
      error.status == _unauthorized &&
      error.code == _unauthorizedCode &&
      !path.startsWith(_authPathPrefix);
}

/// Hata gövdesini okur; biçim beklenenden farklıysa bilinmeyen hata.
ApiError _error(int status, String text) {
  try {
    if (jsonDecode(text) case {
      'error': {'code': final String code, 'message': final String message},
    }) {
      return ApiError(status: status, code: code, message: message);
    }
  } on FormatException {
    // Gövde JSON değil (ör. ara sunucunun HTML sayfası).
  }
  return ApiError(
    status: status,
    code: unknownErrorCode,
    message: 'Sunucu hatası ($status)',
  );
}
