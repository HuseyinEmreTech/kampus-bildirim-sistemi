import '../../../shared/photo/photo_picker.dart';

/// Çözüldü işaretleme isteğinin sonucu (USR 06).
sealed class ReportResolveResult {
  const ReportResolveResult();
}

final class ReportResolved extends ReportResolveResult {
  const ReportResolved();
}

/// Sunucu reddetti (ör. 400 fotoğraf yok, 403 başkası üstlenmiş; Rule 03-04);
/// mesaj kullanıcıya gösterilir.
final class ReportResolveRejected extends ReportResolveResult {
  const ReportResolveRejected(this.message);

  final String message;
}

/// Sunucu hatası veya bağlantı sorunu.
final class ReportResolveFailed extends ReportResolveResult {
  const ReportResolveFailed();
}

/// Bildirimi sonuç fotoğrafı ve isteğe bağlı notla çözüldü işaretleyen kaynak
/// (`PUT /api/reports/{id}/resolution`, `multipart/form-data`).
///
/// Gerçek hali sunucu ve `campus_contracts` hazır olunca yazılacak;
/// testlerde ve demoda sahte kaynak kullanılır.
abstract interface class ReportResolver {
  Future<ReportResolveResult> resolve({
    required String reportId,
    required PickedPhoto photo,
    String? note,
  });
}
