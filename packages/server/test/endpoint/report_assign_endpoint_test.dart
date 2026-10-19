import 'dart:convert';

import 'package:campus_application/campus_application.dart';
import 'package:campus_domain/campus_domain.dart';
import 'package:campus_server/src/middleware/auth_middleware.dart';
import 'package:campus_server/src/service/token_service.dart';
import 'package:shelf/shelf.dart';
import 'package:test/test.dart';

import '../support/fake_report_repository.dart';
import '../support/test_values.dart';

final tokens = TokenService(testJwtConfig);
final staffToken = tokens.createAccessToken(staffId, 'Staff');
final studentToken = tokens.createAccessToken(studentId, 'Student');

late FakeReportRepository reports;
late Handler app;
late String reportId;

void main() {
  setUp(() {
    reports = FakeReportRepository()..stored = newReport(studentId);
    reportId = reports.stored!.id.value;
    app = const Pipeline()
        .addMiddleware(authMiddleware(tokens))
        .addHandler(reportEndpointsWith(reports).router.call);
  });

  test('assign_newReport_returns200AndStaffIsAssignee', () async {
    final res = await app(_put(reportId, staffToken));

    expect(res.statusCode, 200);
    expect(jsonDecode(await res.readAsString()), {
      'reportId': reportId,
      'status': 'Ustlenildi',
      'assigneeId': staffId,
    });
    expect(reports.lastAssign, (reportId: reportId, assigneeId: staffId));
  });

  test('assign_alreadyAssigned_returns409', () async {
    final assigned = reports.stored!.assign(
      assigneeId:
          (UserId.create(staffId) as Success<UserId, DomainError>).value,
      role: Role.staff,
      takenAt: DateTime.utc(2026, 10, 2, 10),
    );
    reports.stored = (assigned as Success<Report, DomainError>).value;

    final res = await app(_put(reportId, staffToken));

    expect(res.statusCode, 409);
    expect((await _errorOf(res))['code'], 'CONFLICT');
    expect(reports.lastAssign, isNull);
  });

  test('assign_sameTimeAsAnotherStaff_returns409', () async {
    // Rule 02: iki görevli aynı anda basarsa veritabanı ikincisini reddeder.
    reports.nextAssign = const Failure(ConflictError('zaten üstlenilmiş'));

    final res = await app(_put(reportId, staffToken));

    expect(res.statusCode, 409);
    expect((await _errorOf(res))['code'], 'CONFLICT');
  });

  test('assign_unknownReport_returns404', () async {
    reports.stored = null;

    final res = await app(_put(reportId, staffToken));

    expect(res.statusCode, 404);
  });

  test('assign_idNotUuid_returns400', () async {
    final res = await app(_put('abc', staffToken));

    expect(res.statusCode, 400);
    expect((await _errorOf(res))['details'], 'id');
  });

  test('assign_byStudent_returns403', () async {
    final res = await app(_put(reportId, studentToken));

    expect(res.statusCode, 403);
    expect(reports.lastAssign, isNull);
  });

  test('assign_withoutToken_returns401', () async {
    final res = await app(_put(reportId, null));

    expect(res.statusCode, 401);
  });
}

Request _put(String id, String? token) => Request(
  'PUT',
  Uri.parse('http://localhost/api/reports/$id/assignment'),
  headers: {if (token != null) 'authorization': 'Bearer $token'},
);

Future<Map<String, Object?>> _errorOf(Response res) async {
  final body = jsonDecode(await res.readAsString()) as Map<String, Object?>;
  return body['error']! as Map<String, Object?>;
}
