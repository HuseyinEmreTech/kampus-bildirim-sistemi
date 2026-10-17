final class ReportSummary {
  const ReportSummary({
    required this.reportId,
    required this.category,
    required this.description,
    required this.status,
    this.place,
    this.buildingName,
    required this.photoUrl,
    this.assigneeId,
    required this.createdAt,
  });

  final String reportId;
  final String category;
  final String description;
  final String status;
  final String? place;
  final String? buildingName;
  final String photoUrl;
  final String? assigneeId;
  final DateTime createdAt;
}
