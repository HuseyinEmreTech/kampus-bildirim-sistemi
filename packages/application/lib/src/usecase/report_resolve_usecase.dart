import 'package:campus_domain/campus_domain.dart';

import '../core/app_error.dart';
import '../core/command_parser.dart';
import '../core/error_mapper.dart';
import '../dto/resolve_report_command.dart';
import '../repository/report_repository.dart';

final class ReportResolveUseCase {
  ReportResolveUseCase(this._repository);

  final ReportRepository _repository;

  Future<Result<Unit, AppError>> execute(ResolveReportCommand command) async {
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
