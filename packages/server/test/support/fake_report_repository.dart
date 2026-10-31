import 'package:campus_application/campus_application.dart';
import 'package:campus_domain/campus_domain.dart';

/// Listeleme testleri için bellek içi sahte. Gelen filtreyi saklar ve
/// [nextList] sonucunu döner. Diğer metotlar bu testlerde kullanılmaz.
class FakeReportRepository implements ReportRepository {
  ReportListFilter? lastFilter;
  int? lastLimit;
  int? lastOffset;

  Result<Paginated<ReportSummary>, AppError> nextList = const Success(
    Paginated(items: [], total: 0, page: 1, pageSize: 20),
  );

  @override
  Future<Result<Paginated<ReportSummary>, AppError>> list({
    required ReportListFilter filter,
    required int limit,
    required int offset,
  }) async {
    lastFilter = filter;
    lastLimit = limit;
    lastOffset = offset;
    return nextList;
  }

  @override
  Future<Result<ReportId, AppError>> create(Report report) =>
      throw UnimplementedError();

  @override
  Future<Result<Unit, AppError>> assign(ReportId reportId, UserId assigneeId) =>
      throw UnimplementedError();

  @override
  Future<Result<Unit, AppError>> resolve(
    ReportId reportId,
    UserId assigneeId,
    Photo resolutionPhoto, {
    String? note,
  }) => throw UnimplementedError();

  @override
  Future<Result<Report?, AppError>> findById(ReportId reportId) =>
      throw UnimplementedError();
}
