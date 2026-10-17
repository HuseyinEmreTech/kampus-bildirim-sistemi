import '../core/domain_error.dart';
import '../core/result.dart';
import '../core/uuid_pattern.dart';

final class UserId {
  const UserId._(this.value);

  final String value;

  static Result<UserId, DomainError> create(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return const Failure(InvalidId('userId boş olamaz'));
    }
    if (!uuidV4RegExp.hasMatch(trimmed)) {
      return const Failure(InvalidId('userId geçerli bir UUID olmalı'));
    }
    return Success(UserId._(trimmed));
  }
}
