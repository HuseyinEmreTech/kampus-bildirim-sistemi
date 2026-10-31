import 'package:campus_application/campus_application.dart';
import 'package:campus_domain/campus_domain.dart' show Failure, Success;
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../exception/exception_mapper.dart';
import '../http/json_http.dart';
import '../mapper/report_mapper.dart';
import '../middleware/auth_middleware.dart';
import '../middleware/role_guard_middleware.dart';

/// `GET /api/reports` (görevli) ve `GET /api/me/reports` (öğrenci).
/// Öğrencinin yalnızca kendi bildirimlerini görmesi [ListReportsUseCase]'te
/// sağlanır; burası sorgu parametrelerini okur ve sonucu JSON'a çevirir.
class ReportEndpoints {
  ReportEndpoints(this._listReports);

  final ListReportsUseCase _listReports;

  static const defaultPage = 1;
  static const defaultPageSize = 20;

  Router get router => Router()
    ..get('/api/reports', _onlyFor('Staff', _list))
    ..get('/api/me/reports', _onlyFor('Student', _list));

  static Handler _onlyFor(String role, Handler handler) =>
      const Pipeline().addMiddleware(requireRole(role)).addHandler(handler);

  Future<Response> _list(Request request) async {
    final params = request.url.queryParameters;
    final page = _intParam(params['page'], defaultPage);
    if (page == null) return _notANumber('page');
    final pageSize = _intParam(params['pageSize'], defaultPageSize);
    if (pageSize == null) return _notANumber('pageSize');

    final assignee = params['assignee'];
    if (assignee != null && assignee != 'me') {
      return errorResponse(
        400,
        'VALIDATION_ERROR',
        "assignee yalnızca 'me' olabilir.",
        details: 'assignee',
      );
    }

    final user = currentUser(request);
    final result = await _listReports.execute(
      ListReportsQuery(
        currentUserId: user.userId,
        role: user.role,
        status: params['status'],
        category: params['category'],
        assigneeId: assignee == null ? null : user.userId,
        page: page,
        pageSize: pageSize,
      ),
    );
    return switch (result) {
      Success(:final value) => jsonResponse(200, reportPageToJson(value)),
      Failure(:final error) => appErrorResponse(error),
    };
  }

  /// Parametre yoksa [fallback]; sayı değilse `null`.
  static int? _intParam(String? raw, int fallback) =>
      raw == null ? fallback : int.tryParse(raw);

  static Response _notANumber(String field) => errorResponse(
    400,
    'VALIDATION_ERROR',
    '$field bir tam sayı olmalı.',
    details: field,
  );
}
