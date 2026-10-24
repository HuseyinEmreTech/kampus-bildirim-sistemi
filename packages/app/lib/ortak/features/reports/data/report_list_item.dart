/// Bildirimin sorun türü (03-domain-design: Category).
enum ReportCategory { ariza, temizlik, guvenlik, diger }

/// Bildirimin durumu (03-domain-design: ReportStatus).
enum ReportStatus { yeni, ustlenildi, cozuldu }

/// Liste ve ayrıntı görünümünün kullandığı bildirim görünüm modeli.
class ReportListItem {
  const ReportListItem({
    this.id,
    required this.category,
    required this.status,
    required this.place,
    required this.createdAt,
    this.description,
    this.imageUrl,
  });

  /// Sunucudaki kimlik; bildirim üzerinde işlem (ör. görevlinin "Üstlen"i)
  /// için gerekir. Yalnızca gösterilen listelerde boş kalabilir.
  final String? id;
  final ReportCategory category;
  final ReportStatus status;
  final String place;
  final DateTime createdAt;
  final String? description;
  final String? imageUrl;
}
