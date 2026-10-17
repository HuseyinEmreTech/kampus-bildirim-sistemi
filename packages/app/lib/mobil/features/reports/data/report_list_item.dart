/// Bildirimin sorun türü (03-domain-design: Category).
enum ReportCategory { ariza, temizlik, guvenlik, diger }

/// Bildirimin durumu (03-domain-design: ReportStatus).
enum ReportStatus { yeni, ustlenildi, cozuldu }

/// Liste ekranında bir bildirim kartı için gereken bilgiler.
///
/// `campus_contracts` içinde bildirim DTO'su gelene kadar uygulamanın kendi
/// görünüm modelidir; DTO gelince `ReportsSource` onu buna çevirir.
class ReportListItem {
  const ReportListItem({
    required this.id,
    required this.category,
    required this.status,
    required this.place,
    required this.createdAt,
  });

  final String id;
  final ReportCategory category;
  final ReportStatus status;
  final String place;
  final DateTime createdAt;
}
