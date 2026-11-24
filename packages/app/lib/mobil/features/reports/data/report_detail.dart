import 'report_list_item.dart';

/// Bir durum değişimi (03-domain-design: StatusHistory).
class StatusChange {
  const StatusChange({required this.to, required this.changedAt, this.note});

  final ReportStatus to;
  final DateTime changedAt;
  final String? note;
}

/// Görevlinin çözüm kaydı: sonuç fotoğrafı zorunlu, not isteğe bağlı (Rule 04).
class Resolution {
  const Resolution({required this.photoUrl, this.note});

  final String photoUrl;
  final String? note;
}

/// Bildirim detayı ve durum geçmişi (`GET /api/reports/{id}`).
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
    required this.history,
    this.resolution,
  });

  final String id;
  final ReportCategory category;
  final ReportStatus status;
  final String description;
  final String place;
  final DateTime createdAt;
  final String photoUrl;

  /// Eskiden yeniye durum değişimleri.
  final List<StatusChange> history;

  /// Yalnızca çözülen bildirimde dolu.
  final Resolution? resolution;
}
