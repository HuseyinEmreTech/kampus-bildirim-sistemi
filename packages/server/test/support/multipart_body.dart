import 'dart:convert';

import 'package:shelf/shelf.dart';

// Testler için elle kurulan `multipart/form-data` gövdesi.

const testBoundary = 'test-sinir-123';

typedef TestPart = ({String headers, List<int> body});

TestPart textPart(String name, String value) => (
  headers: 'Content-Disposition: form-data; name="$name"',
  body: utf8.encode(value),
);

TestPart filePart(String name, String contentType, List<int> bytes) => (
  headers:
      'Content-Disposition: form-data; name="$name"; filename="dosya"\r\n'
      'Content-Type: $contentType',
  body: bytes,
);

Request multipartRequest(
  String method,
  String path,
  List<TestPart> parts, {
  String? token,
}) {
  final body = <int>[];
  for (final part in parts) {
    body
      ..addAll(utf8.encode('--$testBoundary\r\n${part.headers}\r\n\r\n'))
      ..addAll(part.body)
      ..addAll(utf8.encode('\r\n'));
  }
  body.addAll(utf8.encode('--$testBoundary--\r\n'));
  return Request(
    method,
    Uri.parse('http://localhost$path'),
    body: body,
    headers: {
      'content-type': 'multipart/form-data; boundary=$testBoundary',
      if (token != null) 'authorization': 'Bearer $token',
    },
  );
}
