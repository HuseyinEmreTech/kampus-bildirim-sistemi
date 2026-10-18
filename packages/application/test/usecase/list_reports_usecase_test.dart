import 'package:campus_application/campus_application.dart';
import 'package:campus_domain/campus_domain.dart';
import 'package:test/test.dart';

import '../support/fake_report_repository.dart';
import '../support/report_test_data.dart';

void main() {
  late FakeReportRepository repository;
  late ListReportsUseCase useCase;
  final otherStudentId = '5c98741b-64c8-49de-9e68-3d7a2f44802c';

  setUp(() {
    repository = FakeReportRepository();
    useCase = ListReportsUseCase(repository);
  });

  test('execute_studentSeesOnlyOwnReports', () async {
    repository.seed(newReport());
    repository.seed(
      newReport(reporterId: otherStudentId, category: 'Temizlik'),
    );

    final result = await useCase.execute(
      ListReportsQuery(currentUserId: studentId, role: 'Student'),
    );

    expect(result, isA<Success<Paginated<ReportSummary>, AppError>>());
    final page = (result as Success<Paginated<ReportSummary>, AppError>).value;
    expect(page.items, hasLength(1));
    expect(page.items.first.category, 'ariza');
  });

  test('execute_staffSeesAllReports', () async {
    repository.seed(newReport());
    repository.seed(
      newReport(reporterId: otherStudentId, category: 'Temizlik'),
    );

    final result = await useCase.execute(
      ListReportsQuery(currentUserId: staffId, role: 'Staff'),
    );

    expect(result, isA<Success<Paginated<ReportSummary>, AppError>>());
    final page = (result as Success<Paginated<ReportSummary>, AppError>).value;
    expect(page.items, hasLength(2));
  });

  test('execute_invalidPage_returnsValidationError', () async {
    final result = await useCase.execute(
      ListReportsQuery(currentUserId: studentId, role: 'Student', page: 0),
    );

    expect(result, isA<Failure<Paginated<ReportSummary>, AppError>>());
    expect(
      (result as Failure<Paginated<ReportSummary>, AppError>).error,
      isA<ValidationError>(),
    );
  });
}
