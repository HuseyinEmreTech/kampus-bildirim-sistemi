import 'report_detail.dart';

/// Detay isteğinin sonucu.
sealed class ReportDetailResult {
  const ReportDetailResult();
}

final class ReportDetailLoaded extends ReportDetailResult {
  const ReportDetailLoaded(this.detail);

  final ReportDetail detail;
}

/// Bildirim yok ya da kullanıcı göremez (404; Rule 01).
final class ReportDetailNotFound extends ReportDetailResult {
  const ReportDetailNotFound();
}

/// Sunucu hatası veya bağlantı sorunu.
final class ReportDetailFailed extends ReportDetailResult {
  const ReportDetailFailed();
}

/// Bildirim detayını getiren kaynak. Gerçek hali sunucu ve
/// `campus_contracts` hazır olunca yazılacak; testlerde sahte kaynak kullanılır.
abstract interface class ReportDetailSource {
  Future<ReportDetailResult> fetch(String reportId);
}
