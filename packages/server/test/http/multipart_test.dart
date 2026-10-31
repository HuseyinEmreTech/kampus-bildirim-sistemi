import 'dart:convert';

import 'package:campus_server/src/http/multipart.dart';
import 'package:shelf/shelf.dart';
import 'package:test/test.dart';

import '../support/multipart_body.dart';

void main() {
  test('boundary_multipartRequest_returnsBoundary', () {
    final request = multipartRequest('PUT', '/x', [textPart('note', 'a')]);
    expect(multipartBoundary(request), testBoundary);
  });

  test('boundary_jsonRequest_returnsNull', () {
    final request = Request(
      'PUT',
      Uri.parse('http://localhost/x'),
      headers: {'content-type': 'application/json'},
    );
    expect(multipartBoundary(request), isNull);
  });

  test('formParts_readsNamesTypesAndBodiesInOrder', () async {
    final request = multipartRequest('PUT', '/x', [
      textPart('note', 'Lamba değiştirildi.'),
      filePart('resolutionPhoto', 'image/jpeg', [1, 2, 3]),
    ]);

    final seen = <String>[];
    await for (final part in formParts(request, testBoundary)) {
      final bytes = await part.body.expand((c) => c).toList();
      seen.add('${part.name}|${part.contentType}|${bytes.length}');
      if (part.name == 'note') {
        expect(utf8.decode(bytes), 'Lamba değiştirildi.');
      }
    }

    expect(seen, ['note|null|21', 'resolutionPhoto|image/jpeg|3']);
  });

  test('readTextField_overLimit_returnsNull', () async {
    final text = await readTextField(Stream.value(utf8.encode('12345')), 4);
    expect(text, isNull);
  });

  test('readTextField_withinLimit_returnsText', () async {
    final text = await readTextField(Stream.value(utf8.encode('1234')), 4);
    expect(text, '1234');
  });
}
