import 'package:campus_application/campus_application.dart';
import 'package:campus_domain/campus_domain.dart';
import 'package:test/test.dart';

import '../support/fake_report_repository.dart';

void main() {
  late FakeReportRepository repository;
  late ReportAssignUseCase useCase;
  final staffId = '6a98741b-64c8-49de-9e68-3d7a2f44802b';
  final reporterId = '5c98741b-64c8-49de-9e68-3d7a2f44802b';

  Report createNewReport() {
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
      createdAt: DateTime.utc(2026, 10, 12, 10, 0, 0),
    );
    return (result as Success<Report, DomainError>).value;
  }

  setUp(() {
    repository = FakeReportRepository();
    useCase = ReportAssignUseCase(repository);
  });

  test('execute_newReport_assignsToStaff', () async {
    final report = createNewReport();
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
    final report = createNewReport();
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
    final report = createNewReport();
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
        assigneeId: '7a98741b-64c8-49de-9e68-3d7a2f44802b',
        role: 'Staff',
      ),
    );

    expect(result, isA<Failure<Unit, AppError>>());
    expect((result as Failure<Unit, AppError>).error, isA<ConflictError>());
  });
}
