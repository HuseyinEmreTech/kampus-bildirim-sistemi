import 'package:campus_application/campus_application.dart';
import 'package:campus_domain/campus_domain.dart';
import 'package:test/test.dart';

import '../support/fake_clock.dart';
import '../support/fake_report_repository.dart';

void main() {
  late FakeReportRepository repository;
  late FakeClock clock;
  late ReportCreateUseCase useCase;

  setUp(() {
    repository = FakeReportRepository();
    clock = FakeClock(DateTime.utc(2026, 10, 12, 10, 0, 0));
    useCase = ReportCreateUseCase(repository, clock);
  });

  test('execute_validCommand_createsReportWithYeniStatus', () async {
    final command = CreateReportCommand(
      reporterId: '5c98741b-64c8-49de-9e68-3d7a2f44802b',
      category: 'Ariza',
      description: 'B blok lambası yanmıyor',
      photoUrl: '/files/lamba.jpg',
      photoContentType: 'image/jpeg',
      photoSizeBytes: 812345,
      latitude: 36.5871,
      longitude: 36.1742,
      locationSource: 'Gps',
      place: 'B Blok 2. kat',
    );

    final result = await useCase.execute(command);

    expect(result, isA<Success<ReportId, AppError>>());
    final reportId = (result as Success<ReportId, AppError>).value;

    final found = await repository.findById(reportId);
    final report = (found as Success<Report?, AppError>).value;
    expect(report, isNotNull);
    expect(report!.status, ReportStatus.yeni);
    expect(report.reporterId.value, command.reporterId);
  });

  test('execute_descriptionTooShort_returnsValidationError', () async {
    final command = CreateReportCommand(
      reporterId: '5c98741b-64c8-49de-9e68-3d7a2f44802b',
      category: 'Ariza',
      description: 'Kısa',
      photoUrl: '/files/lamba.jpg',
      photoContentType: 'image/jpeg',
      photoSizeBytes: 812345,
      latitude: 36.5871,
      longitude: 36.1742,
      locationSource: 'Gps',
    );

    final result = await useCase.execute(command);

    expect(result, isA<Failure<ReportId, AppError>>());
    expect(
      (result as Failure<ReportId, AppError>).error,
      isA<ValidationError>(),
    );
  });
}
