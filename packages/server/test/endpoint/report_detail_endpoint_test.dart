import 'dart:convert';

import 'package:campus_application/campus_application.dart';
import 'package:campus_domain/campus_domain.dart';
import 'package:campus_server/src/middleware/auth_middleware.dart';
import 'package:campus_server/src/service/token_service.dart';
import 'package:shelf/shelf.dart';
import 'package:test/test.dart';

import '../support/fake_report_repository.dart';
import '../support/test_values.dart';

// GET /api/reports/{id} (#159).
const otherStudentId = 'a0000000-0000-4000-8000-000000000002';
const missingReportId = 'c0000000-0000-4000-8000-000000000999';

final tokens = TokenService(testJwtConfig);
final staffToken = tokens.createAccessToken(staffId, 'Staff');
final studentToken = tokens.createAccessToken(studentId, 'Student');

late FakeReportRepository reports;
late Handler app;

void main() {
  setUp(() {
    reports = FakeReportRepository();
    app = const Pipeline()
        .addMiddleware(authMiddleware(tokens))
        .addHandler(reportEndpointsWith(reports).router.call);
  });

  test('student_seesOwnReport', () async {
    final report = newReport(studentId);
    reports
      ..stored = report
      ..storedBuildingName = 'Mühendislik'
      ..storedHistory = [
        ReportStatusChange(
          status: ReportStatus.yeni,
          changedAt: DateTime.utc(2026, 10, 2, 9, 15),
        ),
      ];

    final res = await app(_get(report.id.value, studentToken));

    expect(res.statusCode, 200);
    expect(await _bodyOf(res), {
      'reportId': report.id.value,
      'category': 'Ariza',
      'description': 'B blok lambası yanmıyor',
      'status': 'Yeni',
      'place': null,
      'buildingName': 'Mühendislik',
      'photoUrl': '/files/lamba.jpg',
      'createdAt': '2026-10-02T09:15:00.000Z',
      'history': [
        {
          'status': 'Yeni',
          'changedAt': '2026-10-02T09:15:00.000Z',
          'note': null,
        },
      ],
    });
  });

  test('student_gets404_forOthersReport', () async {
    final report = newReport(otherStudentId);
    reports.stored = report;

    final res = await app(_get(report.id.value, studentToken));

    expect(res.statusCode, 404);
    expect((await _bodyOf(res))['error'], containsPair('code', 'NOT_FOUND'));
  });

  test('staff_seesAnyReport', () async {
    final report = newReport(otherStudentId);
    reports.stored = report;

    final res = await app(_get(report.id.value, staffToken));

    expect(res.statusCode, 200);
    expect(await _bodyOf(res), containsPair('reportId', report.id.value));
  });

  test('malformedId_returns404', () async {
    final res = await app(_get('bir-uuid-degil', staffToken));

    expect(res.statusCode, 404);
  });

  test('missing_returns404', () async {
    reports.stored = newReport(studentId);

    final res = await app(_get(missingReportId, staffToken));

    expect(res.statusCode, 404);
  });

  test('resolved_includesResolutionFields', () async {
    reports.stored = _resolvedReport();

    final res = await app(_get(reports.stored!.id.value, staffToken));

    final body = await _bodyOf(res);
    expect(body['status'], 'Cozuldu');
    expect(body['resolutionPhotoUrl'], '/files/sonuc.jpg');
    expect(body['resolutionNote'], 'Ampul değişti');
  });

  test('notResolved_hasNoResolutionFields', () async {
    reports.stored = assignedReport(studentId, staffId);

    final res = await app(_get(reports.stored!.id.value, staffToken));

    final body = await _bodyOf(res);
    expect(body['status'], 'Ustlenildi');
    expect(body.containsKey('resolutionPhotoUrl'), isFalse);
  });

  test('anonymous_returns401', () async {
    final res = await app(_get(missingReportId, null));

    expect(res.statusCode, 401);
  });
}

Report _resolvedReport() {
  final photo = Photo.create(
    url: '/files/sonuc.jpg',
    contentType: 'image/jpeg',
    sizeBytes: 2000,
  );
  final resolved = assignedReport(studentId, staffId).resolve(
    assigneeId: (UserId.create(staffId) as Success<UserId, DomainError>).value,
    role: Role.staff,
    resolutionPhoto: (photo as Success<Photo, DomainError>).value,
    resolvedAt: DateTime.utc(2026, 10, 2, 11),
    note: 'Ampul değişti',
  );
  return (resolved as Success<Report, DomainError>).value;
}

Request _get(String id, String? token) => Request(
  'GET',
  Uri.parse('http://localhost/api/reports/$id'),
  headers: {if (token != null) 'authorization': 'Bearer $token'},
);

Future<Map<String, Object?>> _bodyOf(Response res) async =>
    jsonDecode(await res.readAsString()) as Map<String, Object?>;
