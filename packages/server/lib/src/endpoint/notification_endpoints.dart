import 'package:campus_infrastructure/campus_infrastructure.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../http/json_http.dart';
import '../middleware/auth_middleware.dart';
import '../middleware/role_guard_middleware.dart';

/// Öğrencinin "çözüldü" bildirimleri. Rule 01: yalnızca kendi bildirimleri.
class NotificationEndpoints {
  NotificationEndpoints(this._notifications);

  final NotificationRepositoryImpl _notifications;

  static const defaultPageSize = 20;
  static const maxPageSize = 100;

  Router get router => Router()
    ..get('/api/me/notifications', _onlyStudent(_list))
    ..put('/api/me/notifications/<id>/read', _onlyStudent(_markRead));

  static Handler _onlyStudent(Handler handler) => const Pipeline()
      .addMiddleware(requireRole('Student'))
      .addHandler(handler);

  Future<Response> _list(Request request) async {
    final params = request.url.queryParameters;
    final page = int.tryParse(params['page'] ?? '1');
    final pageSize = int.tryParse(params['pageSize'] ?? '$defaultPageSize');
    if (page == null || page < 1) {
      return errorResponse(
        400,
        'VALIDATION_ERROR',
        'page 1 veya daha büyük bir sayı olmalı.',
        details: 'page',
      );
    }
    if (pageSize == null || pageSize < 1 || pageSize > maxPageSize) {
      return errorResponse(
        400,
        'VALIDATION_ERROR',
        'pageSize 1-100 arasında olmalı.',
        details: 'pageSize',
      );
    }

    final userId = currentUser(request).userId;
    final items = await _notifications.list(
      userId,
      limit: pageSize,
      offset: (page - 1) * pageSize,
    );
    final unread = await _notifications.unreadCount(userId);
    return jsonResponse(200, {
      'unreadCount': unread,
      'items': [
        for (final item in items)
          {
            'notificationId': item.notificationId,
            'reportId': item.reportId,
            'type': item.type,
            'message': item.message,
            'createdAt': item.createdAt.toUtc().toIso8601String(),
            'readAt': item.readAt?.toUtc().toIso8601String(),
          },
      ],
      'page': page,
      'pageSize': pageSize,
    });
  }

  Future<Response> _markRead(Request request) async {
    final notificationId = request.params['id']!;
    final userId = currentUser(request).userId;
    final outcome = await _notifications.markRead(notificationId, userId);
    return switch (outcome) {
      MarkReadOutcome.marked => jsonResponse(200, {
        'notificationId': notificationId,
        'read': true,
      }),
      MarkReadOutcome.notFound => errorResponse(
        404,
        'NOT_FOUND',
        'Bildirim bulunamadı.',
      ),
    };
  }
}
