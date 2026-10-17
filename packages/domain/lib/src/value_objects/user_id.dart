import '../core/domain_error.dart';
import '../core/result.dart';
import '../core/uuid_pattern.dart';

final class UserId {
  const UserId._(this.value);

  final String value;

  static Result<UserId, DomainError> create(String value) {
    return switch (validateUuid(
      value,
      emptyMessage: 'userId boş olamaz',
      invalidMessage: 'userId geçerli bir UUID olmalı',
    )) {
      Success(value: final id) => Success(UserId._(id)),
      Failure(error: final error) => Failure(error),
    };
  }
}
