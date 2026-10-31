import 'dart:convert';

import 'package:campus_application/campus_application.dart';
import 'package:campus_server/src/exception/exception_mapper.dart';
import 'package:shelf/shelf.dart';
import 'package:test/test.dart';

void main() {
  final cases = <AppError, (int, String)>{
    const ValidationError('description', 'kısa'): (400, 'VALIDATION_ERROR'),
    const UnauthorizedError(): (401, 'UNAUTHORIZED'),
    const ForbiddenError(): (403, 'FORBIDDEN'),
    const NotFoundError(): (404, 'NOT_FOUND'),
    const ConflictError('zaten üstlenilmiş'): (409, 'CONFLICT'),
    const InvalidTransitionError(): (409, 'INVALID_TRANSITION'),
    const MissingResolutionPhotoError(): (400, 'VALIDATION_ERROR'),
  };

  cases.forEach((error, expected) {
    test('${error.runtimeType}_maps_${expected.$1}_${expected.$2}', () async {
      final res = appErrorResponse(error);
      expect(res.statusCode, expected.$1);
      expect((await _errorOf(res))['code'], expected.$2);
    });
  });

  test('validationError_fieldInDetails', () async {
    final res = appErrorResponse(const ValidationError('description', 'kısa'));
    expect(await _errorOf(res), {
      'code': 'VALIDATION_ERROR',
      'message': 'kısa',
      'details': 'description',
    });
  });

  test('unknownError_logsMessageButHidesItFromClient', () async {
    final lines = <String>[];
    final res = appErrorResponse(
      const UnknownError('SQL hatası: users tablosu'),
      write: lines.add,
    );

    expect(res.statusCode, 500);
    final body = await res.readAsString();
    expect(body, contains('INTERNAL_ERROR'));
    expect(body, isNot(contains('SQL')));
    expect(lines.single, contains('SQL hatası: users tablosu'));
    expect(jsonDecode(lines.single), containsPair('level', 'error'));
  });
}

Future<Map<String, Object?>> _errorOf(Response res) async {
  final body = jsonDecode(await res.readAsString()) as Map<String, Object?>;
  return body['error']! as Map<String, Object?>;
}
