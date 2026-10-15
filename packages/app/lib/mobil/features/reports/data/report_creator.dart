import 'new_report.dart';

/// Bildirim gönderme sonucu: oluşturuldu, sunucu reddetti ya da gönderilemedi.
sealed class ReportCreateResult {
  const ReportCreateResult();
}

final class ReportCreated extends ReportCreateResult {
  const ReportCreated();
}

/// Sunucu isteği reddetti (ör. 400, 422); mesaj kullanıcıya gösterilir.
final class ReportRejected extends ReportCreateResult {
  const ReportRejected(this.message);

  final String message;
}

/// Bağlantı hatası gibi nedenlerle istek sonuçlanmadı.
final class ReportCreateFailed extends ReportCreateResult {
  const ReportCreateFailed();
}

/// Yeni bildirimi sunucuya gönderen kaynak.
///
/// Gerçek hali sunucu ve `campus_contracts` hazır olunca yazılacak;
/// testlerde sahte bir kaynak kullanılır.
abstract interface class ReportCreator {
  Future<ReportCreateResult> create(NewReport report);
}
