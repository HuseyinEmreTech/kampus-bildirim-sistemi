import 'package:campus_domain/campus_domain.dart';
import 'package:test/test.dart';

void main() {
  test('create_validUuid_returnsSuccess', () {
    final result = UserId.create('5c98741b-64c8-49de-9e68-3d7a2f44802b');
    expect(result, isA<Success<UserId, DomainError>>());
  });

  test('create_empty_returnsInvalidId', () {
    final result = UserId.create('');
    expect(result, isA<Failure<UserId, DomainError>>());
  });

  test('create_invalidFormat_returnsInvalidId', () {
    final result = UserId.create('not-a-uuid');
    expect(result, isA<Failure<UserId, DomainError>>());
  });
}
