import 'package:campus_domain/campus_domain.dart';

final class ReportListFilter {
  const ReportListFilter({
    this.status,
    this.category,
    this.assigneeId,
    this.reporterId,
  });

  final ReportStatus? status;
  final Category? category;
  final UserId? assigneeId;
  final UserId? reporterId;
}
