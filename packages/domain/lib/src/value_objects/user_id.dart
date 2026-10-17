import '../core/domain_error.dart';
import '../core/result.dart';

final class UserId {
  const UserId._(this.value);

  final String value;

  static final _uuidRegExp = RegExp(
    r'^[0-9a-fA-F]{8}-'
    r'[0-9a-fA-F]{4}-'
    r'[0-9a-fA-F]{4}-'
    r'[0-9a-fA-F]{4}-'
    r'[0-9a-fA-F]{12}$',
  );

  static Result<UserId, DomainError> create(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return const Failure(InvalidId('userId boş olamaz'));
    }
    if (!_uuidRegExp.hasMatch(trimmed)) {
      return const Failure(InvalidId('userId geçerli bir UUID olmalı'));
    }
    return Success(UserId._(trimmed));
  }
}
