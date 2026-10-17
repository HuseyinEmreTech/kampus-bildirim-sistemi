import 'domain_error.dart';
import 'result.dart';

const String _hex8 = r'[0-9a-fA-F]{8}';
const String _hex4 = r'[0-9a-fA-F]{4}';

/// RFC 4122 UUID v4 biçimini tanımlayan düzenli ifade.
final RegExp uuidV4RegExp = RegExp(
  '^$_hex8-$_hex4-$_hex4-$_hex4-$_hex4$_hex8'
  r'$',
);

/// [value]’nin geçerli bir UUID olup olmadığını denetler.
Result<String, DomainError> validateUuid(
  String value, {
  required String emptyMessage,
  required String invalidMessage,
}) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) {
    return Failure(InvalidId(emptyMessage));
  }
  if (!uuidV4RegExp.hasMatch(trimmed)) {
    return Failure(InvalidId(invalidMessage));
  }
  return Success(trimmed);
}

/// UUID değer nesneleri için ortak oluşturma yardımcısı.
Result<T, DomainError> createUuidValue<T>(
  String value,
  T Function(String) factory, {
  required String emptyMessage,
  required String invalidMessage,
}) {
  return switch (validateUuid(
    value,
    emptyMessage: emptyMessage,
    invalidMessage: invalidMessage,
  )) {
    Success(value: final id) => Success(factory(id)),
    Failure(error: final error) => Failure(error),
  };
}
