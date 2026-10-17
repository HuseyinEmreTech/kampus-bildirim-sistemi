import 'package:campus_application/campus_application.dart';
import 'package:campus_domain/campus_domain.dart';
import 'package:test/test.dart';

import '../support/fake_report_repository.dart';

void main() {
  late FakeReportRepository repository;
  late ReportResolveUseCase useCase;
  final staffId = '6a98741b-64c8-49de-9e68-3d7a2f44802b';
  final reporterId = '5c98741b-64c8-49de-9e68-3d7a2f44802b';

  Future<Report> createAssignedReport() async {
    final createResult = Report.create(
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
    final report = (createResult as Success<Report, DomainError>).value;
    repository.seed(report);
    final assignResult = await ReportAssignUseCase(repository).execute(
      AssignReportCommand(
        reportId: report.id.value,
        assigneeId: staffId,
        role: 'Staff',
      ),
    );
    expect(assignResult, isA<Success<Unit, AppError>>());
    return report;
  }

  setUp(() {
    repository = FakeReportRepository();
    useCase = ReportResolveUseCase(repository);
  });

  test('execute_withPhoto_resolvesAndCreatesNotification', () async {
    final report = await createAssignedReport();

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
    final report = await createAssignedReport();

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
    final createResult = Report.create(
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
    final report = (createResult as Success<Report, DomainError>).value;
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
}
