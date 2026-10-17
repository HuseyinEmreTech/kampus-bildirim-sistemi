import '../core/domain_error.dart';
import '../core/id_generator.dart';
import '../core/result.dart';
import '../core/uuid_pattern.dart';

final class ReportId {
  const ReportId._(this.value);

  final String value;

  /// Yeni bir UUID v4 kimliği üretir. Üretilen değer her zaman geçerlidir.
  static ReportId generate() => ReportId._(generateUuidV4());

  static Result<ReportId, DomainError> create(String value) => createUuidValue(
    value,
    ReportId._,
    emptyMessage: 'reportId boş olamaz',
    invalidMessage: 'reportId geçerli bir UUID olmalı',
  );
}
