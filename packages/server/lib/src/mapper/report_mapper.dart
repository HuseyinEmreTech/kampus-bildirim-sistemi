import 'package:campus_application/campus_application.dart';
import 'package:campus_domain/campus_domain.dart' show Category, ReportStatus;

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

/// Bildirim detayı (#159). Sonuç fotoğrafı ve notu yalnızca çözülen
/// bildirimde yer alır.
Map<String, Object?> reportDetailToJson(ReportDetailView detail) {
  final report = detail.report;
  return {
    'reportId': report.id.value,
    'category': _categoryText(report.category),
    'description': report.description,
    'status': _statusText(report.status),
    'place': report.location.place,
    'buildingName': detail.buildingName,
    'photoUrl': report.photo.url,
    'createdAt': report.createdAt.toUtc().toIso8601String(),
    'history': [
      for (final change in detail.history)
        {
          'status': _statusText(change.status),
          'changedAt': change.changedAt.toUtc().toIso8601String(),
          'note': change.note,
        },
    ],
    if (report.status == ReportStatus.cozuldu) ...{
      'resolutionPhotoUrl': report.resolutionPhoto?.url,
      'resolutionNote': report.resolutionNote,
    },
  };
}

// API'deki yazım (05-api-design): liste uçlarıyla aynı.
String _statusText(ReportStatus status) => switch (status) {
  ReportStatus.yeni => 'Yeni',
  ReportStatus.ustlenildi => 'Ustlenildi',
  ReportStatus.cozuldu => 'Cozuldu',
};

String _categoryText(Category category) => switch (category) {
  Category.ariza => 'Ariza',
  Category.temizlik => 'Temizlik',
  Category.guvenlik => 'Guvenlik',
  Category.diger => 'Diger',
};
