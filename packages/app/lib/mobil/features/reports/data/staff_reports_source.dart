import 'report_list_item.dart';
import 'reports_source.dart';

/// Görevli listesinin sekmeleri (USR 04).
enum StaffReportsView {
  /// Henüz kimsenin üstlenmediği bildirimler (`GET /api/reports?status=Yeni`).
  incoming,

  /// İsteği yapan görevlinin üstlendikleri (`GET /api/reports?assignee=me`).
  mine,
}

/// Görevlinin bildirim listesini sayfa sayfa getiren kaynak
/// (`GET /api/reports?status=&category=&assignee=&page=&pageSize=`;
/// [page] 1'den başlar, 05-api-design). Gerçek hali sunucu ve
/// `campus_contracts` hazır olunca yazılacak.
abstract interface class StaffReportsSource {
  /// [category] verilirse yalnızca o kategori; `null` ise tüm kategoriler.
  Future<ReportsPageResult> fetchPage(
    StaffReportsView view, {
    ReportCategory? category,
    required int page,
    required int pageSize,
  });
}
