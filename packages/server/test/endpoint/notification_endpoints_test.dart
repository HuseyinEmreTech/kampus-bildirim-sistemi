import 'dart:convert';

import 'package:campus_infrastructure/campus_infrastructure.dart';
import 'package:campus_server/src/endpoint/notification_endpoints.dart';
import 'package:campus_server/src/middleware/auth_middleware.dart';
import 'package:campus_server/src/service/token_service.dart';
import 'package:shelf/shelf.dart';
import 'package:test/test.dart';

import '../support/fake_notifications.dart';
import '../support/test_values.dart';

const otherStudentId = 'a0000000-0000-4000-8000-000000000002';
const ownId = 'd0000000-0000-4000-8000-000000000001';
const othersId = 'd0000000-0000-4000-8000-000000000002';

final tokens = TokenService(testJwtConfig);
final studentToken = tokens.createAccessToken(studentId, 'Student');

late FakeNotifications notifications;
late Handler app;

NotificationItem _item(String id, {DateTime? readAt}) => (
  notificationId: id,
  reportId: 'b0000000-0000-4000-8000-000000000001',
  reportCategory: 'Ariza',
  reportDescription: 'B blok lambası yanmıyor',
  type: 'ReportResolved',
  message: 'Bildiriminiz çözüldü: B blok lambası yanmıyor',
  createdAt: DateTime.utc(2026, 10, 2, 11, 40),
  readAt: readAt,
);

void main() {
  setUp(() {
    notifications = FakeNotifications()
      ..items.addAll([
        (userId: studentId, item: _item(ownId)),
        (userId: otherStudentId, item: _item(othersId)),
      ]);
    app = const Pipeline()
        .addMiddleware(authMiddleware(tokens))
        .addHandler(NotificationEndpoints(notifications).router.call);
  });

  test('list_returnsOnlyOwnNotificationsWithUnreadCount', () async {
    final res = await app(_request('GET', 'api/me/notifications'));

    expect(res.statusCode, 200);
    expect(jsonDecode(await res.readAsString()), {
      'unreadCount': 1,
      'items': [
        {
          'notificationId': ownId,
          'reportId': 'b0000000-0000-4000-8000-000000000001',
          'type': 'ReportResolved',
          'message': 'Bildiriminiz çözüldü: B blok lambası yanmıyor',
          'createdAt': '2026-10-02T11:40:00.000Z',
          'readAt': null,
        },
      ],
      'page': 1,
      'pageSize': 20,
    });
  });

  test('list_pageAndPageSize_passedAsLimitAndOffset', () async {
    await app(_request('GET', 'api/me/notifications?page=3&pageSize=10'));

    expect(notifications.lastPage, (limit: 10, offset: 20));
  });

  test('list_pageSizeTooLarge_returns400', () async {
    final res = await app(_request('GET', 'api/me/notifications?pageSize=101'));

    expect(res.statusCode, 400);
    expect((await _errorOf(res))['details'], 'pageSize');
  });

  test('list_pageNotANumber_returns400', () async {
    final res = await app(_request('GET', 'api/me/notifications?page=bir'));

    expect(res.statusCode, 400);
    expect((await _errorOf(res))['details'], 'page');
  });

  test('markRead_own_returns200AndDecreasesUnread', () async {
    final res = await app(_request('PUT', 'api/me/notifications/$ownId/read'));

    expect(res.statusCode, 200);
    expect(jsonDecode(await res.readAsString()), {
      'notificationId': ownId,
      'read': true,
    });
    expect(await notifications.unreadCount(studentId), 0);
  });

  test('markRead_someoneElses_returns404', () async {
    // Rule 01: başkasının bildirimi değişmez, var olduğu da belli edilmez.
    final res = await app(
      _request('PUT', 'api/me/notifications/$othersId/read'),
    );

    expect(res.statusCode, 404);
    expect(await notifications.unreadCount(otherStudentId), 1);
  });

  test('list_byStaff_returns403', () async {
    final staff = tokens.createAccessToken(staffId, 'Staff');
    final res = await app(
      _request('GET', 'api/me/notifications', token: staff),
    );

    expect(res.statusCode, 403);
  });

  test('list_withoutToken_returns401', () async {
    final res = await app(_request('GET', 'api/me/notifications', token: ''));

    expect(res.statusCode, 401);
  });
}

Request _request(String method, String path, {String? token}) {
  final bearer = token ?? studentToken;
  return Request(
    method,
    Uri.parse('http://localhost/$path'),
    headers: {if (bearer.isNotEmpty) 'authorization': 'Bearer $bearer'},
  );
}

Future<Map<String, Object?>> _errorOf(Response res) async {
  final body = jsonDecode(await res.readAsString()) as Map<String, Object?>;
  return body['error']! as Map<String, Object?>;
}
