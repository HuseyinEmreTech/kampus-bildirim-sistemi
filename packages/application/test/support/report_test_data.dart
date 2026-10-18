import 'package:campus_application/campus_application.dart';
import 'package:campus_domain/campus_domain.dart';
import 'package:test/test.dart';

import 'fake_report_repository.dart';

const studentId = '5c98741b-64c8-49de-9e68-3d7a2f44802b';
const staffId = '6a98741b-64c8-49de-9e68-3d7a2f44802b';
const otherStaffId = '7a98741b-64c8-49de-9e68-3d7a2f44802b';
final createdAt = DateTime.utc(2026, 10, 12, 10, 0, 0);

Report newReport({String? reporterId, String? category}) {
  final result = Report.create(
    reporterId: reporterId ?? studentId,
    category: category ?? 'Ariza',
    description: 'B blok lambası yanmıyor',
    photoUrl: '/files/lamba.jpg',
    photoContentType: 'image/jpeg',
    photoSizeBytes: 812345,
    latitude: 36.5871,
    longitude: 36.1742,
    locationSource: 'Gps',
    createdAt: createdAt,
  );
  return (result as Success<Report, DomainError>).value;
}

Future<Report> assignedReport(
  FakeReportRepository repository, {
  String assigneeId = staffId,
}) async {
  final report = newReport();
  repository.seed(report);
  final result = await ReportAssignUseCase(repository).execute(
    AssignReportCommand(
      reportId: report.id.value,
      assigneeId: assigneeId,
      role: 'Staff',
    ),
  );
  expect(result, isA<Success<Unit, AppError>>());
  return report;
}
