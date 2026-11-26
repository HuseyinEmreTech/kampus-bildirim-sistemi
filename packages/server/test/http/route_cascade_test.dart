import 'dart:convert';

import 'package:campus_application/campus_application.dart';
import 'package:campus_server/src/endpoint/building_endpoints.dart';
import 'package:campus_server/src/endpoint/notification_endpoints.dart';
import 'package:campus_server/src/endpoint/report_creation_endpoint.dart';
import 'package:campus_server/src/endpoint/report_resolution_endpoint.dart';
import 'package:campus_server/src/endpoint/user_endpoints.dart';
import 'package:campus_server/src/http/route_cascade.dart';
import 'package:campus_server/src/middleware/auth_middleware.dart';
import 'package:campus_server/src/service/token_service.dart';
import 'package:shelf/shelf.dart';
import 'package:test/test.dart';

import '../support/fake_buildings.dart';
import '../support/fake_notifications.dart';
import '../support/fake_photos.dart';
import '../support/fake_report_repository.dart';
import '../support/fake_repositories.dart';
import '../support/test_values.dart';

// Uçlar bin/server.dart'taki sırayla zincirlenir; bir ucun kendi 404'ü
// sıradaki router'a geçip düz metne dönüşmemeli (#230).
const otherStudentId = 'a0000000-0000-4000-8000-000000000002';
const missingId = 'c0000000-0000-4000-8000-000000000999';
const othersNotificationId = 'd0000000-0000-4000-8000-000000000002';

final tokens = TokenService(testJwtConfig);
final staffToken = tokens.createAccessToken(staffId, 'Staff');
final studentToken = tokens.createAccessToken(studentId, 'Student');

late FakeReportRepository reports;
late FakeNotifications notifications;
late Handler app;

void main() {
  setUp(() {
    reports = FakeReportRepository();
    notifications = FakeNotifications()
      ..items.add((
        userId: otherStudentId,
        item: (
          notificationId: othersNotificationId,
          reportId: 'b0000000-0000-4000-8000-000000000001',
          reportCategory: 'Ariza',
          reportDescription: 'B blok lambası yanmıyor',
          type: 'ReportResolved',
          message: 'Bildiriminiz çözüldü',
          createdAt: DateTime.utc(2026, 11, 26),
          readAt: null,
        ),
      ));
    app = const Pipeline()
        .addMiddleware(authMiddleware(tokens))
        .addHandler(
          routeAll([
            UserEndpoints(FakeUsers()).router.call,
            BuildingEndpoints(FakeBuildings()).router.call,
            NotificationEndpoints(notifications).router.call,
            reportEndpointsWith(reports).router.call,
            ReportCreationEndpoint(
              createReport: ReportCreateUseCase(
                reports,
                FixedClock(DateTime.utc(2026, 11, 26)),
              ),
              photos: FakePhotos(),
              buildings: FakeBuildings(),
            ).router.call,
            ReportResolutionEndpoint(
              resolveReport: ReportResolveUseCase(reports),
              photos: FakePhotos(),
            ).router.call,
          ]),
        );
  });

  test('unknownBuilding_returnsJson404', () async {
    final res = await app(_request('GET', 'api/buildings/$missingId'));

    await _expectJson404(res);
  });

  test('assignMissingReport_returnsJson404', () async {
    final res = await app(
      _request('PUT', 'api/reports/$missingId/assignment', token: staffToken),
    );

    await _expectJson404(res);
  });

  test('markReadOthersNotification_returnsJson404', () async {
    final res = await app(
      _request('PUT', 'api/me/notifications/$othersNotificationId/read'),
    );

    await _expectJson404(res);
  });

  test('unknownRoute_returnsJson404', () async {
    final res = await app(_request('GET', 'api/olmayan-adres'));

    await _expectJson404(res);
  });
}

Request _request(String method, String path, {String? token}) => Request(
  method,
  Uri.parse('http://localhost/$path'),
  headers: {'authorization': 'Bearer ${token ?? studentToken}'},
);

Future<void> _expectJson404(Response res) async {
  expect(res.statusCode, 404);
  final body = jsonDecode(await res.readAsString()) as Map<String, Object?>;
  expect(body['error'], containsPair('code', 'NOT_FOUND'));
}
