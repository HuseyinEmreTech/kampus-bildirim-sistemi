import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:campus_app/mobil/shared/api/api_client.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

final baseUrl = Uri.parse('http://sunucu.test');

/// İstekleri kaydeden ve verilen yanıtı döndüren sahte sunucu.
class FakeServer {
  FakeServer(this.respond);

  final Future<http.Response> Function(http.Request request) respond;
  final requests = <http.Request>[];

  late final client = MockClient((request) {
    requests.add(request);
    return respond(request);
  });
}

http.Response jsonResponse(Object body, int status) => http.Response(
  jsonEncode(body),
  status,
  headers: {'content-type': 'application/json; charset=utf-8'},
);

ApiClient apiClient(
  FakeServer server, {
  String? token,
  void Function()? onUnauthorized,
}) => ApiClient(
  baseUrl: baseUrl,
  client: server.client,
  token: () => token,
  onUnauthorized: onUnauthorized,
);

void main() {
  test('get_sendsTokenAndQuery_andReturnsJson', () async {
    final server = FakeServer(
      (_) async => jsonResponse({
        'items': ['ç'],
      }, 200),
    );

    final response = await apiClient(
      server,
      token: 'belirtec',
    ).get('/api/me/reports', query: {'page': '2', 'pageSize': '20'});

    final request = server.requests.single;
    expect(request.method, 'GET');
    expect(request.url.path, '/api/me/reports');
    expect(request.url.queryParameters, {'page': '2', 'pageSize': '20'});
    expect(request.headers['Authorization'], 'Bearer belirtec');
    expect((response as ApiSuccess).body, {
      'items': ['ç'],
    });
  });

  test('postJson_sendsJsonBody_withoutToken_whenLoggedOut', () async {
    final server = FakeServer((_) async => jsonResponse({'ok': true}, 200));

    await apiClient(server)
        .postJson('/api/auth/login', {'email': 'a@ornek.edu'});

    final request = server.requests.single;
    expect(request.method, 'POST');
    expect(request.headers.containsKey('Authorization'), isFalse);
    expect(request.headers['Content-Type'], startsWith('application/json'));
    expect(jsonDecode(request.body), {'email': 'a@ornek.edu'});
  });

  test('put_returnsSuccessWithoutBody_whenNoContent', () async {
    final server = FakeServer((_) async => http.Response('', 204));

    final response = await apiClient(
      server,
      token: 't',
    ).put('/api/reports/r1/assignment');

    expect(server.requests.single.method, 'PUT');
    expect((response as ApiSuccess).body, isNull);
  });

  test('error_readsCodeAndMessage_fromErrorBody', () async {
    final server = FakeServer(
      (_) async => jsonResponse({
        'error': {
          'code': 'CONFLICT',
          'message': 'Bildirim zaten üstlenilmiş.',
          'details': null,
        },
      }, 409),
    );

    final response = await apiClient(
      server,
      token: 't',
    ).put('/api/reports/r1/assignment');

    final error = response as ApiError;
    expect(error.status, 409);
    expect(error.code, 'CONFLICT');
    expect(error.message, 'Bildirim zaten üstlenilmiş.');
  });

  test('error_hasUnknownCode_whenBodyIsNotErrorJson', () async {
    final server = FakeServer((_) async => http.Response('<html>', 502));

    final response = await apiClient(server).get('/api/buildings');

    final error = response as ApiError;
    expect(error.status, 502);
    expect(error.code, unknownErrorCode);
  });

  test('unauthorized_callsOnUnauthorized', () async {
    var signedOut = 0;
    final server = FakeServer(
      (_) async => jsonResponse({
        'error': {'code': 'UNAUTHORIZED', 'message': 'Giriş yok'},
      }, 401),
    );

    final response = await apiClient(
      server,
      token: 'eski',
      onUnauthorized: () => signedOut++,
    ).get('/api/me/reports');

    expect((response as ApiError).status, 401);
    expect(signedOut, 1);
  });

  test('unreachable_whenNetworkFailsOrTimesOut', () async {
    for (final failure in <Object>[
      http.ClientException('bağlantı yok'),
      TimeoutException('yanıt yok'),
    ]) {
      final server = FakeServer((_) async => throw failure);

      final response = await apiClient(server).get('/health');

      expect(response, isA<ApiUnreachable>(), reason: '$failure');
    }
  });

  test('unreachable_whenSuccessBodyIsNotJson', () async {
    final server = FakeServer((_) async => http.Response('{bozuk', 200));

    final response = await apiClient(server).get('/api/buildings');

    expect(response, isA<ApiUnreachable>());
  });

  test('addsBearerHeader', () async {
    // Arrange
    final server = FakeServer((_) async => jsonResponse({}, 200));

    // Act
    await apiClient(server, token: 'belirtec').get('/api/me/reports');

    // Assert
    expect(server.requests.single.headers['Authorization'], 'Bearer belirtec');
  });

  test('unreachable_whenTlsHandshakeFails', () async {
    // Arrange: canlıda HTTPS; sertifika sorunu HandshakeException verir.
    final server = FakeServer(
      (_) async => throw const HandshakeException('sertifika geçersiz'),
    );

    // Act
    final response = await apiClient(server).get('/health');

    // Assert
    expect(response, isA<ApiUnreachable>());
  });

  test('unreachable_whenConnectionDropsWhileReadingBody', () async {
    // Arrange: başlıklar geldi, gövde okunurken bağlantı koptu.
    final client = MockClient.streaming(
      (request, _) async => http.StreamedResponse(
        Stream<List<int>>.error(const SocketException('bağlantı koptu')),
        200,
      ),
    );
    final api = ApiClient(baseUrl: baseUrl, client: client, token: () => null);

    // Act
    final response = await api.get('/api/buildings');

    // Assert
    expect(response, isA<ApiUnreachable>());
  });

  test('unauthorized_doesNotSignOut_onWrongPassword', () async {
    // Arrange: yanlış şifrede giriş ucu 401 INVALID_CREDENTIALS döner.
    var signedOut = 0;
    final server = FakeServer(
      (_) async => jsonResponse({
        'error': {'code': 'INVALID_CREDENTIALS', 'message': 'Hatalı'},
      }, 401),
    );

    // Act
    final response = await apiClient(
      server,
      onUnauthorized: () => signedOut++,
    ).postJson('/api/auth/login', {'email': 'a@ornek.edu', 'password': 'x'});

    // Assert: hata döner ama oturum kapatılmaz.
    expect((response as ApiError).code, 'INVALID_CREDENTIALS');
    expect(signedOut, 0);
  });

  test('unauthorized_doesNotSignOut_onAuthEndpoints', () async {
    // Arrange: yenileme ucunun 401'i döngüye girmesin diye çıkış tetiklemez.
    var signedOut = 0;
    final server = FakeServer(
      (_) async => jsonResponse({
        'error': {'code': 'UNAUTHORIZED', 'message': 'Süresi doldu'},
      }, 401),
    );

    // Act
    await apiClient(
      server,
      onUnauthorized: () => signedOut++,
    ).postJson('/api/auth/refresh', {'refreshToken': 'eski'});

    // Assert
    expect(signedOut, 0);
  });
}
