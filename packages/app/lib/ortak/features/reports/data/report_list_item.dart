/// Bildirimin sorun türü (03-domain-design: Category).
enum ReportCategory { ariza, temizlik, guvenlik, diger }

/// Bildirimin durumu (03-domain-design: ReportStatus).
enum ReportStatus { yeni, ustlenildi, cozuldu }

/// Liste ve ayrıntı görünümünün kullandığı bildirim görünüm modeli.
class ReportListItem {
  const ReportListItem({
    required this.category,
    required this.status,
    required this.place,
    required this.createdAt,
    this.description,
    this.imageUrl,
  });

  final ReportCategory category;
  final ReportStatus status;
  final String place;
  final DateTime createdAt;
  final String? description;
  final String? imageUrl;
}
