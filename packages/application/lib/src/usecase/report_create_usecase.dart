import 'package:campus_domain/campus_domain.dart';

import '../core/app_error.dart';
import '../core/error_mapper.dart';
import '../dto/create_report_command.dart';
import '../repository/report_repository.dart';

final class ReportCreateUseCase {
  ReportCreateUseCase(this._repository, this._clock);

  final ReportRepository _repository;
  final Clock _clock;

  Future<Result<ReportId, AppError>> execute(
    CreateReportCommand command,
  ) async {
    final reportResult = Report.create(
      reporterId: command.reporterId,
      category: command.category,
      description: command.description,
      photoUrl: command.photoUrl,
      photoContentType: command.photoContentType,
      photoSizeBytes: command.photoSizeBytes,
      latitude: command.latitude,
      longitude: command.longitude,
      locationSource: command.locationSource,
      place: command.place,
      buildingId: command.buildingId,
      createdAt: _clock.now(),
    );

    return switch (reportResult) {
      Success(value: final report) => await _repository.create(report),
      Failure(error: final error) => Failure(mapDomainError(error)),
    };
  }
}
