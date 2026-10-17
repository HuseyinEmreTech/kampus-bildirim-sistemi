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

  test('execute_twoStaffAssignSameReport_onlyOneSucceeds', () async {
    final report = newReport();
    repository.seed(report);

    final first = await useCase.execute(
      AssignReportCommand(
        reportId: report.id.value,
        assigneeId: staffId,
        role: 'Staff',
      ),
    );
    final second = await useCase.execute(
      AssignReportCommand(
        reportId: report.id.value,
        assigneeId: otherStaffId,
        role: 'Staff',
      ),
    );

    expect(first, isA<Success<Unit, AppError>>());
    expect(second, isA<Failure<Unit, AppError>>());
    expect((second as Failure<Unit, AppError>).error, isA<ConflictError>());
  });
}
