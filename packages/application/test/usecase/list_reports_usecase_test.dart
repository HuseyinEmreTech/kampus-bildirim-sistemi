import 'package:campus_application/campus_application.dart';
import 'package:campus_domain/campus_domain.dart';
import 'package:test/test.dart';

import '../support/fake_report_repository.dart';

void main() {
  late FakeReportRepository repository;
  late ListReportsUseCase useCase;
  final studentId = '5c98741b-64c8-49de-9e68-3d7a2f44802b';
  final otherStudentId = '5c98741b-64c8-49de-9e68-3d7a2f44802c';

  Report createReport(String reporterId, String category) {
    final result = Report.create(
      reporterId: reporterId,
      category: category,
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
    useCase = ListReportsUseCase(repository);
  });

  test('execute_studentSeesOnlyOwnReports', () async {
    repository.seed(createReport(studentId, 'Ariza'));
    repository.seed(createReport(otherStudentId, 'Temizlik'));

    final result = await useCase.execute(
      ListReportsQuery(currentUserId: studentId, role: 'Student'),
    );

    expect(result, isA<Success<Paginated<ReportSummary>, AppError>>());
    final page = (result as Success<Paginated<ReportSummary>, AppError>).value;
    expect(page.items, hasLength(1));
    expect(page.items.first.category, 'ariza');
  });

  test('execute_staffSeesAllReports', () async {
    repository.seed(createReport(studentId, 'Ariza'));
    repository.seed(createReport(otherStudentId, 'Temizlik'));

    final result = await useCase.execute(
      ListReportsQuery(
        currentUserId: '6a98741b-64c8-49de-9e68-3d7a2f44802b',
        role: 'Staff',
      ),
    );

    expect(result, isA<Success<Paginated<ReportSummary>, AppError>>());
    final page = (result as Success<Paginated<ReportSummary>, AppError>).value;
    expect(page.items, hasLength(2));
  });
}
