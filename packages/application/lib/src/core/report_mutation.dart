import 'package:campus_domain/campus_domain.dart';

import '../repository/report_repository.dart';
import 'app_error.dart';
import 'command_parser.dart';

/// Staff rolündeki bir kullanıcının bildirim üzerinde işlem yapabilmesi
/// için gereken ortak bağlam.
typedef ReportMutation = ({
  ReportId reportId,
  UserId assigneeId,
  Report report,
});

/// Komutu ayrıştırır, rolü doğrular, bildirimi bulur ve beklenen durumda
/// olup olmadığını denetler. Tüm hatalar [AppError]’a eşlenir.
Future<Result<ReportMutation, AppError>> loadStaffMutation({
  required ReportRepository repository,
  required String role,
  required String reportId,
  required String assigneeId,
  required ReportStatus requiredStatus,
  required AppError statusError,
}) async {
  final baseResult = CommandParser.parseBase(
    role: role,
    reportId: reportId,
    assigneeId: assigneeId,
  );
  final BaseCommand base;
  switch (baseResult) {
    case Success(value: final value):
      base = value;
    case Failure(error: final error):
      return Failure(error);
  }

  if (base.role != Role.staff) {
    return const Failure(ForbiddenError());
  }

  final findResult = await repository.findById(base.reportId);
  final Report? report;
  switch (findResult) {
    case Success(value: final value):
      report = value;
    case Failure(error: final error):
      return Failure(error);
  }

  if (report == null) {
    return const Failure(NotFoundError());
  }
  if (report.status != requiredStatus) {
    return Failure(statusError);
  }

  return Success((
    reportId: base.reportId,
    assigneeId: base.assigneeId,
    report: report,
  ));
}
