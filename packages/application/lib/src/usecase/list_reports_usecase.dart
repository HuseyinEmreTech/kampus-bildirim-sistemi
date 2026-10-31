import 'package:campus_domain/campus_domain.dart';

import '../core/app_error.dart';
import '../dto/list_reports_query.dart';
import '../dto/paginated.dart';
import '../dto/report_summary.dart';
import '../repository/report_list_filter.dart';
import '../repository/report_repository.dart';

final class ListReportsUseCase {
  ListReportsUseCase(this._repository);

  final ReportRepository _repository;

  static const int minPageSize = 1;
  static const int maxPageSize = 100;

  Future<Result<Paginated<ReportSummary>, AppError>> execute(
    ListReportsQuery query,
  ) async {
    final role = _parseRole(query.role);
    if (role == null) {
      return _validation('role', 'rol geçersiz');
    }

    final currentUserId = _parseUserId(query.currentUserId);
    if (currentUserId == null) {
      return _validation('currentUserId', 'userId geçersiz');
    }

    if (query.page < 1) {
      return _validation('page', 'page 1 veya daha büyük olmalı');
    }
    if (query.pageSize < minPageSize || query.pageSize > maxPageSize) {
      return _validation('pageSize', 'pageSize 1-100 arasında olmalı');
    }

    final statusRaw = _parseOptionalStatus(query.status);
    if (statusRaw == _invalid) {
      return _validation('status', 'status geçersiz');
    }
    final status = statusRaw as ReportStatus?;

    final categoryRaw = _parseOptionalCategory(query.category);
    if (categoryRaw == _invalid) {
      return _validation('category', 'kategori geçersiz');
    }
    final category = categoryRaw as Category?;

    final assigneeIdRaw = _parseOptionalUserId(query.assigneeId);
    if (assigneeIdRaw == _invalid) {
      return _validation('assigneeId', 'assigneeId geçersiz');
    }
    final assigneeId = assigneeIdRaw as UserId?;

    final reporterIdRaw = _parseOptionalUserId(query.reporterId);
    if (reporterIdRaw == _invalid) {
      return _validation('reporterId', 'reporterId geçersiz');
    }
    final reporterId = reporterIdRaw as UserId?;

    final effectiveReporterId = role == Role.student
        ? currentUserId
        : reporterId;
    final effectiveAssigneeId = role == Role.student ? null : assigneeId;

    final filter = ReportListFilter(
      status: status,
      category: category,
      assigneeId: effectiveAssigneeId,
      reporterId: effectiveReporterId,
    );

    final offset = (query.page - 1) * query.pageSize;

    return _repository.list(
      filter: filter,
      limit: query.pageSize,
      offset: offset,
    );
  }

  static const Object _invalid = Object();

  Role? _parseRole(String value) {
    return switch (parseRole(value)) {
      Success(value: final role) => role,
      Failure() => null,
    };
  }

  UserId? _parseUserId(String value) {
    return switch (UserId.create(value)) {
      Success(value: final id) => id,
      Failure() => null,
    };
  }

  Object? _parseOptionalStatus(String? value) {
    if (value == null) {
      return null;
    }
    return switch (parseReportStatus(value)) {
      Success(value: final status) => status,
      Failure() => _invalid,
    };
  }

  Object? _parseOptionalCategory(String? value) {
    if (value == null) {
      return null;
    }
    return switch (parseCategory(value)) {
      Success(value: final category) => category,
      Failure() => _invalid,
    };
  }

  Object? _parseOptionalUserId(String? value) {
    if (value == null) {
      return null;
    }
    return switch (UserId.create(value)) {
      Success(value: final id) => id,
      Failure() => _invalid,
    };
  }

  static Result<Paginated<ReportSummary>, AppError> _validation(
    String field,
    String message,
  ) => Failure(ValidationError(field, message));
}
