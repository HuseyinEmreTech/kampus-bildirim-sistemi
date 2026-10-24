/// Üstlenme isteğinin sonucu (USR 05).
sealed class ReportAssignResult {
  const ReportAssignResult();
}

final class ReportAssigned extends ReportAssignResult {
  const ReportAssigned();
}

/// Başka görevli daha önce üstlendi (Rule 02, `409 CONFLICT`).
final class ReportAlreadyTaken extends ReportAssignResult {
  const ReportAlreadyTaken();
}

/// Sunucu hatası veya bağlantı sorunu.
final class ReportAssignFailed extends ReportAssignResult {
  const ReportAssignFailed();
}

/// Bildirimi görevli adına üstlenen kaynak
/// (`PUT /api/reports/{id}/assignment`).
///
/// Gerçek hali sunucu ve `campus_contracts` hazır olunca yazılacak;
/// testlerde sahte bir kaynak kullanılır.
abstract interface class ReportAssigner {
  Future<ReportAssignResult> assign(String reportId);
}
