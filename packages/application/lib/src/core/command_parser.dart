import 'package:campus_domain/campus_domain.dart';

import 'app_error.dart';
import 'error_mapper.dart';

typedef BaseCommand = ({Role role, ReportId reportId, UserId assigneeId});

final class CommandParser {
  CommandParser._();

  static Result<BaseCommand, AppError> parseBase({
    required String role,
    required String reportId,
    required String assigneeId,
  }) {
    final Role parsedRole;
    switch (parseRole(role)) {
      case Success(value: final value):
        parsedRole = value;
      case Failure(error: final error):
        return Failure(mapDomainError(error));
    }

    final ReportId parsedReportId;
    switch (ReportId.create(reportId)) {
      case Success(value: final value):
        parsedReportId = value;
      case Failure(error: final error):
        return Failure(mapDomainError(error));
    }

    final UserId parsedAssigneeId;
    switch (UserId.create(assigneeId)) {
      case Success(value: final value):
        parsedAssigneeId = value;
      case Failure(error: final error):
        return Failure(mapDomainError(error));
    }

    return Success((
      role: parsedRole,
      reportId: parsedReportId,
      assigneeId: parsedAssigneeId,
    ));
  }
}
