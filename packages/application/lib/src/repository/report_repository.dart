import 'package:campus_domain/campus_domain.dart';

import '../core/app_error.dart';
import '../dto/paginated.dart';
import '../dto/report_summary.dart';
import 'report_list_filter.dart';

abstract interface class ReportRepository {
  Future<Result<ReportId, AppError>> create(Report report);

  Future<Result<Unit, AppError>> assign(ReportId reportId, UserId assigneeId);

  Future<Result<Unit, AppError>> resolve(
    ReportId reportId,
    UserId assigneeId,
    Photo resolutionPhoto, {
    String? note,
  });

  Future<Result<Paginated<ReportSummary>, AppError>> list({
    required ReportListFilter filter,
    required int limit,
    required int offset,
  });

  Future<Result<Report?, AppError>> findById(ReportId reportId);
}
