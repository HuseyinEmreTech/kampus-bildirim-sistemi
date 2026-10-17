import 'package:campus_domain/campus_domain.dart';

import '../core/app_error.dart';
import '../core/error_mapper.dart';
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
    final roleResult = parseRole(query.role);
    final currentUserIdResult = UserId.create(query.currentUserId);

    final Role role;
    switch (roleResult) {
      case Success(value: final value):
        role = value;
      case Failure(error: final error):
        return Failure(mapDomainError(error));
    }

    final UserId currentUserId;
    switch (currentUserIdResult) {
      case Success(value: final value):
        currentUserId = value;
      case Failure(error: final error):
        return Failure(mapDomainError(error));
    }

    if (query.page < 1) {
      return const Failure(
        ValidationError('page', 'page 1 veya daha büyük olmalı'),
      );
    }
    if (query.pageSize < minPageSize || query.pageSize > maxPageSize) {
      return const Failure(
        ValidationError('pageSize', 'pageSize 1-100 arasında olmalı'),
      );
    }

    final ReportStatus? status;
    if (query.status == null) {
      status = null;
    } else {
      final result = parseReportStatus(query.status!);
      switch (result) {
        case Success(value: final value):
          status = value;
        case Failure(error: final error):
          return Failure(mapDomainError(error));
      }
    }

    final Category? category;
    if (query.category == null) {
      category = null;
    } else {
      final result = parseCategory(query.category!);
      switch (result) {
        case Success(value: final value):
          category = value;
        case Failure(error: final error):
          return Failure(mapDomainError(error));
      }
    }

    final UserId? assigneeId;
    if (query.assigneeId == null) {
      assigneeId = null;
    } else {
      final result = UserId.create(query.assigneeId!);
      switch (result) {
        case Success(value: final value):
          assigneeId = value;
        case Failure(error: final error):
          return Failure(mapDomainError(error));
      }
    }

    final UserId? reporterId;
    if (query.reporterId == null) {
      reporterId = null;
    } else {
      final result = UserId.create(query.reporterId!);
      switch (result) {
        case Success(value: final value):
          reporterId = value;
        case Failure(error: final error):
          return Failure(mapDomainError(error));
      }
    }

    final UserId? effectiveReporterId;
    final UserId? effectiveAssigneeId;
    if (role == Role.student) {
      effectiveReporterId = currentUserId;
      effectiveAssigneeId = null;
    } else {
      effectiveReporterId = reporterId;
      effectiveAssigneeId = assigneeId;
    }

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
}
