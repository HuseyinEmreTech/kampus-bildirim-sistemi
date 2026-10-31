import 'dart:convert';

import 'package:campus_server/src/middleware/body_limit_middleware.dart';
import 'package:shelf/shelf.dart';
import 'package:test/test.dart';

const limit = 10;

var innerCalls = 0;

/// Gövdeyi sonuna kadar okuyup uzunluğunu dönen sahte uç.
Future<Response> _readAll(Request request) async {
  innerCalls++;
  final body = await request.readAsString();
  return Response.ok('okundu:${body.length}');
}

final app = const Pipeline()
    .addMiddleware(bodyLimit(maxBytes: limit))
    .addHandler(_readAll);

void main() {
  setUp(() => innerCalls = 0);

  test('smallBody_passesThroughUnchanged', () async {
    final res = await app(_post(utf8.encode('12345')));

    expect(res.statusCode, 200);
    expect(await res.readAsString(), 'okundu:5');
  });

  test('contentLengthOverLimit_returns413WithoutReading', () async {
    final res = await app(_post(List.filled(limit + 1, 0)));

    expect(res.statusCode, 413);
    expect(await res.readAsString(), contains('PAYLOAD_TOO_LARGE'));
    expect(innerCalls, 0);
  });

  test('chunkedOverLimit_returns413WhileReading', () async {
    // Content-Length yok: gövde parça parça geliyor.
    final chunks = Stream.fromIterable([List.filled(6, 0), List.filled(6, 0)]);
    final res = await app(
      Request('POST', Uri.parse('http://localhost/x'), body: chunks),
    );

    expect(res.statusCode, 413);
    expect(innerCalls, 1);
  });

  test('chunkedWithinLimit_passesThrough', () async {
    final chunks = Stream.fromIterable([
      List.filled(4, 65),
      List.filled(4, 65),
    ]);
    final res = await app(
      Request('POST', Uri.parse('http://localhost/x'), body: chunks),
    );

    expect(res.statusCode, 200);
    expect(await res.readAsString(), 'okundu:8');
  });
}

Request _post(List<int> body) =>
    Request('POST', Uri.parse('http://localhost/x'), body: body);
