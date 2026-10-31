import 'package:campus_application/campus_application.dart';
import 'package:campus_domain/campus_domain.dart' show Failure, Success;
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../exception/exception_mapper.dart';
import '../http/json_http.dart';
import '../mapper/report_mapper.dart';
import '../middleware/auth_middleware.dart';
import '../middleware/role_guard_middleware.dart';

/// Bildirim uçları. Kurallar (öğrencinin yalnızca kendi bildirimlerini
/// görmesi, Rule 02 tek üstlenen) use case'lerdedir; burası isteği okur ve
/// sonucu JSON'a çevirir.
class ReportEndpoints {
  ReportEndpoints({
    required ListReportsUseCase listReports,
    required ReportAssignUseCase assignReport,
  }) : _listReports = listReports,
       _assignReport = assignReport;

  final ListReportsUseCase _listReports;
  final ReportAssignUseCase _assignReport;

  static const defaultPage = 1;
  static const defaultPageSize = 20;

  Router get router => Router()
    ..get('/api/reports', _onlyFor('Staff', _list))
    ..get('/api/me/reports', _onlyFor('Student', _list))
    ..put('/api/reports/<id>/assignment', _onlyFor('Staff', _assign));

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

  /// `PUT /api/reports/{id}/assignment`: görevli bildirimi üstlenir.
  /// Bildirim `Yeni` değilse ya da aynı anda başkası üstlendiyse 409.
  Future<Response> _assign(Request request) async {
    final reportId = request.params['id']!;
    final user = currentUser(request);
    final result = await _assignReport.execute(
      AssignReportCommand(
        reportId: reportId,
        assigneeId: user.userId,
        role: user.role,
      ),
    );
    return switch (result) {
      Success() => jsonResponse(200, {
        'reportId': reportId,
        'status': 'Ustlenildi',
        'assigneeId': user.userId,
      }),
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
