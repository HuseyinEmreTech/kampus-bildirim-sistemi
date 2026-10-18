import 'report_list_item.dart';

/// Bir sayfada istenen bildirim sayısı.
const reportsPageSize = 20;

/// Bir sayfa isteğinin sonucu: ya sayfa geldi ya da yüklenemedi.
sealed class ReportsPageResult {
  const ReportsPageResult();
}

final class ReportsPageLoaded extends ReportsPageResult {
  const ReportsPageLoaded(this.items);

  final List<ReportListItem> items;
}

final class ReportsPageFailed extends ReportsPageResult {
  const ReportsPageFailed();
}

/// Öğrencinin bildirimlerini sayfa sayfa getiren kaynak
/// (`GET /api/me/reports?page=&pageSize=`; [page] 1'den başlar, 05-api-design).
///
/// Gerçek hali sunucu ve `campus_contracts` hazır olunca yazılacak;
/// testlerde sahte bir kaynak kullanılır.
abstract interface class ReportsSource {
  Future<ReportsPageResult> fetchPage({
    required int page,
    required int pageSize,
  });
}
