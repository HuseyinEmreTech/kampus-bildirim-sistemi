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
/// Şimdilik yalnızca ilk sayfa; sayfa biçimi kararından sonra sayfalama
/// eklenecek. Gerçek hali sunucu ve `campus_contracts` hazır olunca yazılacak.
abstract interface class StaffReportsSource {
  /// [category] verilirse yalnızca o kategori (`category=` parametresi);
  /// `null` ise tüm kategoriler.
  Future<ReportsPageResult> fetchFirstPage(
    StaffReportsView view, {
    ReportCategory? category,
  });
}
