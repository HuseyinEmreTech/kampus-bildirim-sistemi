import 'package:campus_application/campus_application.dart';
import 'package:campus_domain/campus_domain.dart';
import 'package:test/test.dart';

import '../support/fake_report_repository.dart';
import '../support/report_test_data.dart';

void main() {
  late FakeReportRepository repository;
  late ReportResolveUseCase useCase;

  setUp(() {
    repository = FakeReportRepository();
    useCase = ReportResolveUseCase(repository);
  });

  test('execute_withPhoto_resolvesAndCreatesNotification', () async {
    final report = await assignedReport(repository);

    final result = await useCase.execute(
      ResolveReportCommand(
        reportId: report.id.value,
        assigneeId: staffId,
        role: 'Staff',
        resolutionPhotoUrl: '/files/sonuc.jpg',
        resolutionPhotoContentType: 'image/jpeg',
        resolutionPhotoSizeBytes: 500000,
        note: 'Lamba değiştirildi',
      ),
    );

    expect(result, isA<Success<Unit, AppError>>());
    expect(repository.notifications, hasLength(1));
    expect(
      repository.historyFor(report.id.value).map((h) => h.toStatus),
      contains(ReportStatus.cozuldu.name),
    );
  });

  test('execute_withoutPhoto_returnsMissingResolutionPhoto', () async {
    final report = await assignedReport(repository);

    final result = await useCase.execute(
      ResolveReportCommand(
        reportId: report.id.value,
        assigneeId: staffId,
        role: 'Staff',
      ),
    );

    expect(result, isA<Failure<Unit, AppError>>());
    final error = (result as Failure<Unit, AppError>).error;
    expect(error, isA<MissingResolutionPhotoError>());
  });

  test('execute_resolveNewReport_returnsInvalidTransition', () async {
    final report = newReport();
    repository.seed(report);

    final result = await useCase.execute(
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

  test('execute_otherAssignee_returnsForbidden', () async {
    final report = await assignedReport(repository, assigneeId: staffId);

    final result = await useCase.execute(
      ResolveReportCommand(
        reportId: report.id.value,
        assigneeId: otherStaffId,
        role: 'Staff',
        resolutionPhotoUrl: '/files/sonuc.jpg',
        resolutionPhotoContentType: 'image/jpeg',
        resolutionPhotoSizeBytes: 500000,
      ),
    );

    expect(result, isA<Failure<Unit, AppError>>());
    expect((result as Failure<Unit, AppError>).error, isA<ForbiddenError>());
  });
}
