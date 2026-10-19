import 'dart:async';
import 'dart:convert';

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
}
