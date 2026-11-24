import 'package:campus_domain/campus_domain.dart';

/// Bildirim detayı (#159): bildirim, bina adı ve durum geçmişi tek okumada.
final class ReportDetailView {
  const ReportDetailView({
    required this.report,
    this.buildingName,
    required this.history,
  });

  final Report report;

  /// Konum bina listesinden seçilmediyse `null`.
  final String? buildingName;

  /// Durum değişiklikleri, eskiden yeniye. İlk satır bildirimin açılışıdır.
  final List<ReportStatusChange> history;
}

/// Durum geçmişinin bir satırı: bildirimin hangi duruma ne zaman geçtiği.
final class ReportStatusChange {
  const ReportStatusChange({
    required this.status,
    required this.changedAt,
    this.note,
  });

  final ReportStatus status;
  final DateTime changedAt;

  /// Görevlinin çözerken yazdığı not; diğer satırlarda `null`.
  final String? note;
}
