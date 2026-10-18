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
    expect(
      (result as Failure<Unit, AppError>).error,
      isA<MissingResolutionPhotoError>(),
    );
  });

  test('execute_withPhoto_resolvesAndCreatesNotificationAndHistory', () async {
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

    final found = await repository.findById(report.id);
    final updated = (found as Success<Report?, AppError>).value;
    expect(updated, isNotNull);
    expect(updated!.status, ReportStatus.cozuldu);
  });
}
