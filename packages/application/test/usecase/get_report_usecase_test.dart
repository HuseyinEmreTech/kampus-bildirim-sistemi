import 'package:campus_application/campus_application.dart';
import 'package:campus_domain/campus_domain.dart';
import 'package:test/test.dart';

import '../support/fake_report_repository.dart';
import '../support/report_test_data.dart';

void main() {
  const otherStudentId = '5c98741b-64c8-49de-9e68-3d7a2f44802c';
  const missingReportId = 'c0000000-0000-4000-8000-000000000999';

  late FakeReportRepository repository;
  late GetReportUseCase useCase;

  setUp(() {
    repository = FakeReportRepository();
    useCase = GetReportUseCase(repository);
  });

  Future<Result<ReportDetailView, AppError>> get(
    String reportId, {
    String userId = studentId,
    String role = 'Student',
  }) => useCase.execute(reportId: reportId, currentUserId: userId, role: role);

  test('student_seesOwnReport_withHistory', () async {
    final report = await assignedReport(repository);

    final result = await get(report.id.value);

    final detail = (result as Success<ReportDetailView, AppError>).value;
    expect(detail.report.id.value, report.id.value);
    expect(
      [for (final change in detail.history) change.status],
      [ReportStatus.ustlenildi],
    );
  });

  test('student_getsNotFound_forOthersReport', () async {
    final report = newReport(reporterId: otherStudentId);
    repository.seed(report);

    final result = await get(report.id.value);

    expect(_errorOf(result), isA<NotFoundError>());
  });

  test('staff_seesAnyReport', () async {
    final report = newReport(reporterId: otherStudentId);
    repository.seed(report);

    final result = await get(report.id.value, userId: staffId, role: 'Staff');

    expect(result, isA<Success<ReportDetailView, AppError>>());
  });

  test('malformedId_returnsNotFound', () async {
    final result = await get('bir-uuid-degil');

    expect(_errorOf(result), isA<NotFoundError>());
  });

  test('missing_returnsNotFound', () async {
    final result = await get(missingReportId, userId: staffId, role: 'Staff');

    expect(_errorOf(result), isA<NotFoundError>());
  });

  test('invalidRole_returnsForbidden', () async {
    final report = newReport();
    repository.seed(report);

    final result = await get(report.id.value, role: 'Admin');

    expect(_errorOf(result), isA<ForbiddenError>());
  });
}

AppError _errorOf(Result<ReportDetailView, AppError> result) =>
    (result as Failure<ReportDetailView, AppError>).error;
