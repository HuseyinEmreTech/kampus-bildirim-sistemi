import 'package:campus_application/campus_application.dart';
import 'package:campus_domain/campus_domain.dart';
import 'package:campus_server/src/endpoint/report_endpoints.dart';

/// Gerçek use case'lerle, sahte depoya bağlı uçlar.
ReportEndpoints reportEndpointsWith(FakeReportRepository reports) =>
    ReportEndpoints(
      listReports: ListReportsUseCase(reports),
      assignReport: ReportAssignUseCase(reports),
    );

/// Bellek içi sahte depo. Gelen filtreyi ve üstlenme çağrısını saklar;
/// [stored] bildirimini ve [nextList] / [nextAssign] sonuçlarını döner.
class FakeReportRepository implements ReportRepository {
  Report? stored;
  ({String reportId, String assigneeId})? lastAssign;
  Result<Unit, AppError> nextAssign = const Success(Unit.value);

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
  Future<Result<Unit, AppError>> assign(
    ReportId reportId,
    UserId assigneeId,
  ) async {
    lastAssign = (reportId: reportId.value, assigneeId: assigneeId.value);
    return nextAssign;
  }

  @override
  Future<Result<Unit, AppError>> resolve(
    ReportId reportId,
    UserId assigneeId,
    Photo resolutionPhoto, {
    String? note,
  }) => throw UnimplementedError();

  @override
  Future<Result<Report?, AppError>> findById(ReportId reportId) async =>
      Success(stored);
}

/// Kurallara uygun, `Yeni` durumunda örnek bildirim.
Report newReport(String reporterId) {
  final result = Report.create(
    reporterId: reporterId,
    category: 'Ariza',
    description: 'B blok lambası yanmıyor',
    photoUrl: '/files/lamba.jpg',
    photoContentType: 'image/jpeg',
    photoSizeBytes: 812345,
    latitude: 36.5871,
    longitude: 36.1742,
    locationSource: 'Gps',
    createdAt: DateTime.utc(2026, 10, 2, 9, 15),
  );
  return (result as Success<Report, DomainError>).value;
}
