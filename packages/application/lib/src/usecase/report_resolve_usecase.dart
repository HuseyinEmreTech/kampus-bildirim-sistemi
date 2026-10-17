import 'package:campus_domain/campus_domain.dart';

import '../core/app_error.dart';
import '../core/error_mapper.dart';
import '../core/report_mutation.dart';
import '../dto/resolve_report_command.dart';
import '../repository/report_repository.dart';

final class ReportResolveUseCase {
  ReportResolveUseCase(this._repository);

  final ReportRepository _repository;

  Future<Result<Unit, AppError>> execute(ResolveReportCommand command) async {
    final mutationResult = await loadStaffMutation(
      repository: _repository,
      role: command.role,
      reportId: command.reportId,
      assigneeId: command.assigneeId,
      requiredStatus: ReportStatus.ustlenildi,
      statusError: const InvalidTransitionError(),
    );
    final ReportMutation mutation;
    switch (mutationResult) {
      case Success(value: final value):
        mutation = value;
      case Failure(error: final error):
        return Failure(error);
    }

    if (mutation.report.assigneeId?.value != mutation.assigneeId.value) {
      return const Failure(ForbiddenError());
    }

    final photoUrl = command.resolutionPhotoUrl;
    final photoType = command.resolutionPhotoContentType;
    final photoSize = command.resolutionPhotoSizeBytes;
    if (photoUrl == null || photoType == null || photoSize == null) {
      return const Failure(MissingResolutionPhotoError());
    }

    final photoResult = Photo.create(
      url: photoUrl,
      contentType: photoType,
      sizeBytes: photoSize,
    );
    final Photo photo;
    switch (photoResult) {
      case Success(value: final value):
        photo = value;
      case Failure(error: final error):
        return Failure(mapDomainError(error));
    }

    return _repository.resolve(
      mutation.reportId,
      mutation.assigneeId,
      photo,
      note: command.note,
    );
  }
}
