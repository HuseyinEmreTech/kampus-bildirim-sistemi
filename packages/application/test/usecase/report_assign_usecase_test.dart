import 'package:campus_application/campus_application.dart';
import 'package:campus_domain/campus_domain.dart';
import 'package:test/test.dart';

import '../support/fake_report_repository.dart';
import '../support/report_test_data.dart';

void main() {
  late FakeReportRepository repository;
  late ReportAssignUseCase useCase;

  setUp(() {
    repository = FakeReportRepository();
    useCase = ReportAssignUseCase(repository);
  });

  test('execute_newReport_assignsToStaff', () async {
    final report = newReport();
    repository.seed(report);

    final result = await useCase.execute(
      AssignReportCommand(
        reportId: report.id.value,
        assigneeId: staffId,
        role: 'Staff',
      ),
    );

    expect(result, isA<Success<Unit, AppError>>());
  });

  test('execute_studentRole_returnsForbidden', () async {
    final report = newReport();
    repository.seed(report);

    final result = await useCase.execute(
      AssignReportCommand(
        reportId: report.id.value,
        assigneeId: staffId,
        role: 'Student',
      ),
    );

    expect(result, isA<Failure<Unit, AppError>>());
    expect((result as Failure<Unit, AppError>).error, isA<ForbiddenError>());
  });

  test('execute_alreadyAssigned_returnsConflict', () async {
    final report = newReport();
    repository.seed(report);
    await useCase.execute(
      AssignReportCommand(
        reportId: report.id.value,
        assigneeId: staffId,
        role: 'Staff',
      ),
    );

    final result = await useCase.execute(
      AssignReportCommand(
        reportId: report.id.value,
        assigneeId: otherStaffId,
        role: 'Staff',
      ),
    );

    expect(result, isA<Failure<Unit, AppError>>());
    expect((result as Failure<Unit, AppError>).error, isA<ConflictError>());
  });

  test('execute_reportNotFound_returnsNotFound', () async {
    final result = await useCase.execute(
      AssignReportCommand(
        reportId: '5c98741b-64c8-49de-9e68-3d7a2f44802b',
        assigneeId: staffId,
        role: 'Staff',
      ),
    );

    expect(result, isA<Failure<Unit, AppError>>());
    expect((result as Failure<Unit, AppError>).error, isA<NotFoundError>());
  });

  test('execute_invalidRoleString_returnsValidationError', () async {
    final report = newReport();
    repository.seed(report);

    final result = await useCase.execute(
      AssignReportCommand(
        reportId: report.id.value,
        assigneeId: staffId,
        role: 'Admin',
      ),
    );

    expect(result, isA<Failure<Unit, AppError>>());
    expect((result as Failure<Unit, AppError>).error, isA<ForbiddenError>());
  });
}
