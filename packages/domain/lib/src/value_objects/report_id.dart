import '../core/domain_error.dart';
import '../core/id_generator.dart';
import '../core/result.dart';

final class ReportId {
  const ReportId._(this.value);

  final String value;

  static final _uuidRegExp = RegExp(
    r'^[0-9a-fA-F]{8}-'
    r'[0-9a-fA-F]{4}-'
    r'[0-9a-fA-F]{4}-'
    r'[0-9a-fA-F]{4}-'
    r'[0-9a-fA-F]{12}$',
  );

  /// Yeni bir UUID v4 kimliği üretir. Üretilen değer her zaman geçerlidir.
  static ReportId generate() => ReportId._(generateUuidV4());

  static Result<ReportId, DomainError> create(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return const Failure(InvalidId('reportId boş olamaz'));
    }
    if (!_uuidRegExp.hasMatch(trimmed)) {
      return const Failure(InvalidId('reportId geçerli bir UUID olmalı'));
    }
    return Success(ReportId._(trimmed));
  }
}
