import '../core/domain_error.dart';
import '../core/result.dart';
import '../core/uuid_pattern.dart';

final class UserId {
  const UserId._(this.value);

  final String value;

  static Result<UserId, DomainError> create(String value) => createUuidValue(
    value,
    UserId._,
    emptyMessage: 'userId boş olamaz',
    invalidMessage: 'userId geçerli bir UUID olmalı',
  );
}
