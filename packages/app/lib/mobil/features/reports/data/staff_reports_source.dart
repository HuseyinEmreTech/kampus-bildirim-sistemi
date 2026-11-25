import 'report_list_item.dart';
import 'reports_source.dart';

/// Görevli listesinin sekmeleri (USR 04).
enum StaffReportsView {
  /// Henüz kimsenin üstlenmediği bildirimler (`GET /api/reports?status=Yeni`).
  incoming,

  /// İsteği yapan görevlinin üstlendikleri (`GET /api/reports?assignee=me`).
  mine,
}

/// Görevlinin bildirim listesini getiren kaynak.
///
/// Sayfalar öğrenci listesindeki gibi `offset`/`limit` ile istenir. Gerçek
/// hali sunucu ve `campus_contracts` hazır olunca yazılacak.
abstract interface class StaffReportsSource {
  /// [category] verilirse yalnızca o kategori (`category=` parametresi);
  /// `null` ise tüm kategoriler.
  Future<ReportsPageResult> fetchPage(
    StaffReportsView view, {
    ReportCategory? category,
    required int offset,
    required int limit,
  });
}
