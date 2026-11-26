import 'package:campus_domain/campus_domain.dart';

import '../core/app_error.dart';
import '../core/error_mapper.dart';
import '../dto/report_detail_view.dart';
import '../repository/report_repository.dart';

/// Bildirim detayı (#159). Rule 01: öğrenci yalnızca kendi bildirimini görür,
/// görevli hepsini.
final class GetReportUseCase {
  GetReportUseCase(this._repository);

  final ReportRepository _repository;

  /// Geçersiz kimlik, olmayan bildirim ve öğrencinin başkasına ait bildirimi
  /// aynı [NotFoundError]'ı döner: öğrenci başkasının bildiriminin var olup
  /// olmadığını bu uçtan öğrenemez.
  Future<Result<ReportDetailView, AppError>> execute({
    required String reportId,
    required String currentUserId,
    required String role,
  }) async {
    final Role parsedRole;
    switch (parseRole(role)) {
      case Success(:final value):
        parsedRole = value;
      case Failure(:final error):
        return Failure(mapDomainError(error));
    }

    final ReportId id;
    switch (ReportId.create(reportId)) {
      case Success(:final value):
        id = value;
      case Failure():
        return const Failure(NotFoundError());
    }

    final ReportDetailView? detail;
    switch (await _repository.findDetail(id)) {
      case Success(:final value):
        detail = value;
      case Failure(:final error):
        return Failure(error);
    }

    if (detail == null) return const Failure(NotFoundError());
    if (parsedRole == Role.student &&
        detail.report.reporterId.value != currentUserId) {
      return const Failure(NotFoundError());
    }
    return Success(detail);
  }
}
