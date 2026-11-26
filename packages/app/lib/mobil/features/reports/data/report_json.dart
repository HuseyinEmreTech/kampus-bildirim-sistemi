import 'report_list_item.dart';

/// Kategorinin API'deki yazılışı (05-api-design: `Ariza, Temizlik, Guvenlik,
/// Diger`).
String categoryToJson(ReportCategory category) => switch (category) {
  ReportCategory.ariza => 'Ariza',
  ReportCategory.temizlik => 'Temizlik',
  ReportCategory.guvenlik => 'Guvenlik',
  ReportCategory.diger => 'Diger',
};

/// Durumun API'deki yazılışı (`Yeni, Ustlenildi, Cozuldu`).
String statusToJson(ReportStatus status) => switch (status) {
  ReportStatus.yeni => 'Yeni',
  ReportStatus.ustlenildi => 'Ustlenildi',
  ReportStatus.cozuldu => 'Cozuldu',
};

ReportCategory? _categoryFrom(String value) => ReportCategory.values
    .where((category) => categoryToJson(category) == value)
    .firstOrNull;

ReportStatus? _statusFrom(String value) => ReportStatus.values
    .where((status) => statusToJson(status) == value)
    .firstOrNull;

/// Liste yanıtındaki bir bildirimi okur (sunucu `reportSummaryToJson`):
/// `reportId, category, description, status, place, buildingName, photoUrl,
/// createdAt`. Biçim beklenenden farklıysa `null`. [photoUrlOf] göreli
/// fotoğraf yolunu tam adrese çevirir.
ReportListItem? reportListItemFromJson(
  Map<String, Object?> json, {
  required String Function(String path) photoUrlOf,
}) {
  if (json case {
    'reportId': final String id,
    'category': final String categoryValue,
    'status': final String statusValue,
    'createdAt': final String createdAtValue,
  }) {
    final category = _categoryFrom(categoryValue);
    final status = _statusFrom(statusValue);
    final createdAt = DateTime.tryParse(createdAtValue);
    if (category == null || status == null || createdAt == null) return null;
    final photoUrl = json['photoUrl'];
    return ReportListItem(
      id: id,
      category: category,
      status: status,
      place: _placeOf(json),
      createdAt: createdAt,
      description: json['description'] as String?,
      imageUrl: photoUrl is String ? photoUrlOf(photoUrl) : null,
    );
  }
  return null;
}

/// Yer tarifi yoksa bina adı; ikisi de yoksa boş.
String _placeOf(Map<String, Object?> json) {
  final place = json['place'];
  if (place is String && place.isNotEmpty) return place;
  final building = json['buildingName'];
  return building is String ? building : '';
}

/// Sayfalı yanıtın (`{ items: [...] }`) bildirimlerini okur; biçim farklıysa
/// ya da bir öğe okunamazsa `null`.
List<ReportListItem>? reportItemsFromJson(
  Object? body, {
  required String Function(String path) photoUrlOf,
}) {
  if (body case {'items': final List<Object?> items}) {
    final reports = <ReportListItem>[];
    for (final item in items) {
      if (item is! Map<String, Object?>) return null;
      final report = reportListItemFromJson(item, photoUrlOf: photoUrlOf);
      if (report == null) return null;
      reports.add(report);
    }
    return reports;
  }
  return null;
}
