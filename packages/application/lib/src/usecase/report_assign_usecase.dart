import 'package:campus_domain/campus_domain.dart';

import '../core/app_error.dart';
import '../core/report_mutation.dart';
import '../dto/assign_report_command.dart';
import '../repository/report_repository.dart';

final class ReportAssignUseCase {
  ReportAssignUseCase(this._repository);

  final ReportRepository _repository;

  Future<Result<Unit, AppError>> execute(AssignReportCommand command) async {
    final mutationResult = await loadStaffMutation(
      repository: _repository,
      role: command.role,
      reportId: command.reportId,
      assigneeId: command.assigneeId,
      requiredStatus: ReportStatus.yeni,
      statusError: const ConflictError(
        'Bildirim zaten üstlenilmiş veya çözülmüş',
      ),
    );
    final ReportMutation mutation;
    switch (mutationResult) {
      case Success(value: final value):
        mutation = value;
      case Failure(error: final error):
        return Failure(error);
    }

    return _repository.assign(mutation.reportId, mutation.assigneeId);
  }
}
