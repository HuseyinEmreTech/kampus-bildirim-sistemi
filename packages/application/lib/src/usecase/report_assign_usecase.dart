import 'package:campus_domain/campus_domain.dart';

import '../core/app_error.dart';
import '../core/command_parser.dart';
import '../dto/assign_report_command.dart';
import '../repository/report_repository.dart';

final class ReportAssignUseCase {
  ReportAssignUseCase(this._repository);

  final ReportRepository _repository;

  Future<Result<Unit, AppError>> execute(AssignReportCommand command) async {
    final baseResult = CommandParser.parseBase(
      role: command.role,
      reportId: command.reportId,
      assigneeId: command.assigneeId,
    );
    final BaseCommand base;
    switch (baseResult) {
      case Success(value: final value):
        base = value;
      case Failure(error: final error):
        return Failure(error);
    }
    final role = base.role;
    final reportId = base.reportId;
    final assigneeId = base.assigneeId;

    if (role != Role.staff) {
      return const Failure(ForbiddenError());
    }

    final findResult = await _repository.findById(reportId);
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

    if (report.status != ReportStatus.yeni) {
      return const Failure(
        ConflictError('Bildirim zaten üstlenilmiş veya çözülmüş'),
      );
    }

    return _repository.assign(reportId, assigneeId);
  }
}
