import 'package:campus_application/campus_application.dart';

/// Uygulama katmanının liste sonucunu API yanıtına çevirir.
/// Contracts paketindeki DTO'lar gelince bu dönüşüm oraya taşınabilir.
Map<String, Object?> reportPageToJson(Paginated<ReportSummary> page) => {
  'items': [for (final report in page.items) reportSummaryToJson(report)],
  'page': page.page,
  'pageSize': page.pageSize,
  'total': page.total,
};

Map<String, Object?> reportSummaryToJson(ReportSummary report) => {
  'reportId': report.reportId,
  'category': report.category,
  'description': report.description,
  'status': report.status,
  'place': report.place,
  'buildingName': report.buildingName,
  'photoUrl': report.photoUrl,
  'assigneeId': report.assigneeId,
  'createdAt': report.createdAt.toUtc().toIso8601String(),
};
