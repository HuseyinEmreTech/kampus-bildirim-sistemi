import 'report_list_item.dart';

/// Bildirim detayı (`GET /api/reports/{id}`). Durum geçmişi ve görevlinin
/// sonuç fotoğrafı/notu 2. parçada eklenecek.
///
/// Fotoğraf adresleri tam adrestir; sunucunun verdiği yolu tam adrese
/// çevirmek gerçek kaynağın işidir.
class ReportDetail {
  const ReportDetail({
    required this.id,
    required this.category,
    required this.status,
    required this.description,
    required this.place,
    required this.createdAt,
    required this.photoUrl,
  });

  final String id;
  final ReportCategory category;
  final ReportStatus status;
  final String description;
  final String place;
  final DateTime createdAt;
  final String photoUrl;
}
