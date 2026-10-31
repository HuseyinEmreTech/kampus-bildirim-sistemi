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

const reportId = 'b0000000-0000-4000-8000-000000000001';

late FakeReportRepository reports;
late Handler app;

void main() {
  setUp(() {
    reports = FakeReportRepository();
    // Sunucudaki gibi: adresler auth middleware'in arkasında.
    app = const Pipeline()
        .addMiddleware(authMiddleware(tokens))
        .addHandler(reportEndpointsWith(reports).router.call);
  });

  test('staffList_noParams_returnsPageWithDefaults', () async {
    reports.nextList = Success(
      Paginated(
        items: [
          ReportSummary(
            reportId: reportId,
            category: 'Ariza',
            description: 'Koridor lambası yanmıyor',
            status: 'Yeni',
            place: 'B blok 2. kat',
            photoUrl: '/photos/1.jpg',
            createdAt: DateTime.utc(2026, 10, 2, 9, 15),
          ),
        ],
        total: 1,
        page: 1,
        pageSize: 20,
      ),
    );

    final res = await app(_get('api/reports', staffToken));

    expect(res.statusCode, 200);
    expect(jsonDecode(await res.readAsString()), {
      'items': [
        {
          'reportId': reportId,
          'category': 'Ariza',
          'description': 'Koridor lambası yanmıyor',
          'status': 'Yeni',
          'place': 'B blok 2. kat',
          'buildingName': null,
          'photoUrl': '/photos/1.jpg',
          'assigneeId': null,
          'createdAt': '2026-10-02T09:15:00.000Z',
        },
      ],
      'page': 1,
      'pageSize': 20,
      'total': 1,
    });
    // Parametre yoksa varsayılan sayfa ve filtresiz liste.
    expect(reports.lastLimit, 20);
    expect(reports.lastOffset, 0);
    expect(reports.lastFilter!.reporterId, isNull);
    expect(reports.lastFilter!.assigneeId, isNull);
  });

  test('staffList_filtersAndPaging_passedToRepository', () async {
    await app(
      _get(
        'api/reports?status=Yeni&category=Ariza&page=3&pageSize=10',
        staffToken,
      ),
    );

    expect(reports.lastFilter!.status, ReportStatus.yeni);
    expect(reports.lastFilter!.category, Category.ariza);
    expect(reports.lastLimit, 10);
    expect(reports.lastOffset, 20);
  });

  test('staffList_assigneeMe_filtersByCurrentUser', () async {
    await app(_get('api/reports?assignee=me', staffToken));

    expect(reports.lastFilter!.assigneeId!.value, staffId);
  });

  test('studentMeReports_onlyOwnReports', () async {
    final res = await app(_get('api/me/reports', studentToken));

    expect(res.statusCode, 200);
    expect(reports.lastFilter!.reporterId!.value, studentId);
  });

  test('studentOnStaffList_returns403', () async {
    final res = await app(_get('api/reports', studentToken));

    expect(res.statusCode, 403);
    expect(reports.lastFilter, isNull);
  });

  test('staffOnMeReports_returns403', () async {
    final res = await app(_get('api/me/reports', staffToken));

    expect(res.statusCode, 403);
  });

  test('withoutToken_returns401', () async {
    final res = await app(_get('api/reports', null));

    expect(res.statusCode, 401);
  });

  test('pageNotANumber_returns400', () async {
    final res = await app(_get('api/reports?page=abc', staffToken));

    expect(res.statusCode, 400);
    expect(await _errorOf(res), {
      'code': 'VALIDATION_ERROR',
      'message': 'page bir tam sayı olmalı.',
      'details': 'page',
    });
  });

  test('pageSizeTooLarge_returns400', () async {
    final res = await app(_get('api/reports?pageSize=101', staffToken));

    expect(res.statusCode, 400);
    expect((await _errorOf(res))['details'], 'pageSize');
    expect(reports.lastFilter, isNull);
  });

  test('assigneeOtherThanMe_returns400', () async {
    final res = await app(_get('api/reports?assignee=baskasi', staffToken));

    expect(res.statusCode, 400);
    expect((await _errorOf(res))['details'], 'assignee');
  });

  test('repositoryError_returns500WithoutInternalDetails', () async {
    reports.nextList = const Failure(UnknownError('bağlantı koptu: 10.0.0.5'));

    final res = await app(_get('api/reports', staffToken));

    expect(res.statusCode, 500);
    expect(await res.readAsString(), isNot(contains('10.0.0.5')));
  });
}

Request _get(String path, String? token) => Request(
  'GET',
  Uri.parse('http://localhost/$path'),
  headers: {if (token != null) 'authorization': 'Bearer $token'},
);

Future<Map<String, Object?>> _errorOf(Response res) async {
  final body = jsonDecode(await res.readAsString()) as Map<String, Object?>;
  return body['error']! as Map<String, Object?>;
}
