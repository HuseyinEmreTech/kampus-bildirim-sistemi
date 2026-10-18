final class ListReportsQuery {
  const ListReportsQuery({
    required this.currentUserId,
    required this.role,
    this.status,
    this.category,
    this.assigneeId,
    this.reporterId,
    this.page = 1,
    this.pageSize = 20,
  });

  final String currentUserId;
  final String role;
  final String? status;
  final String? category;
  final String? assigneeId;
  final String? reporterId;
  final int page;
  final int pageSize;
}
