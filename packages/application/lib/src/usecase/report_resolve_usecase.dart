import 'package:campus_domain/campus_domain.dart';

import '../core/app_error.dart';
import '../core/error_mapper.dart';
import '../dto/resolve_report_command.dart';
import '../repository/report_repository.dart';

final class ReportResolveUseCase {
  ReportResolveUseCase(this._repository);

  final ReportRepository _repository;

  Future<Result<Unit, AppError>> execute(ResolveReportCommand command) async {
    final roleResult = parseRole(command.role);
    final reportIdResult = ReportId.create(command.reportId);
    final assigneeIdResult = UserId.create(command.assigneeId);

    final Role role;
    switch (roleResult) {
      case Success(value: final value):
        role = value;
      case Failure(error: final error):
        return Failure(mapDomainError(error));
    }

    final ReportId reportId;
    switch (reportIdResult) {
      case Success(value: final value):
        reportId = value;
      case Failure(error: final error):
        return Failure(mapDomainError(error));
    }

    final UserId assigneeId;
    switch (assigneeIdResult) {
      case Success(value: final value):
        assigneeId = value;
      case Failure(error: final error):
        return Failure(mapDomainError(error));
    }

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

    if (report.status != ReportStatus.ustlenildi) {
      return const Failure(InvalidTransitionError());
    }

    if (report.assigneeId?.value != assigneeId.value) {
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

    return _repository.resolve(reportId, assigneeId, photo, note: command.note);
  }
}
