import 'package:campus_application/campus_application.dart';
import 'package:campus_domain/campus_domain.dart';
import 'package:test/test.dart';

import '../support/fake_report_repository.dart';
import '../support/report_test_data.dart';

void main() {
  late FakeReportRepository repository;
  late ReportResolveUseCase resolveUseCase;
  late ReportAssignUseCase assignUseCase;

  setUp(() {
    repository = FakeReportRepository();
    resolveUseCase = ReportResolveUseCase(repository);
    assignUseCase = ReportAssignUseCase(repository);
  });

  test('execute_resolveOnYeniReport_returnsInvalidTransition', () async {
    final report = newReport();
    repository.seed(report);

    final result = await resolveUseCase.execute(
      ResolveReportCommand(
        reportId: report.id.value,
        assigneeId: staffId,
        role: 'Staff',
        resolutionPhotoUrl: '/files/sonuc.jpg',
        resolutionPhotoContentType: 'image/jpeg',
        resolutionPhotoSizeBytes: 500000,
      ),
    );

    expect(result, isA<Failure<Unit, AppError>>());
    expect(
      (result as Failure<Unit, AppError>).error,
      isA<InvalidTransitionError>(),
    );
  });

  test('execute_assignOnAlreadyAssignedReport_returnsConflict', () async {
    final report = await assignedReport(repository);

    final result = await assignUseCase.execute(
      AssignReportCommand(
        reportId: report.id.value,
        assigneeId: otherStaffId,
        role: 'Staff',
      ),
    );

    expect(result, isA<Failure<Unit, AppError>>());
    expect((result as Failure<Unit, AppError>).error, isA<ConflictError>());
  });
}
