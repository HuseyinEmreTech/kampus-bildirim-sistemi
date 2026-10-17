/// Öğrenciye gelen "çözüldü" bildirimi (03-domain-design: Notification).
///
/// JSON okuma (`fromJson`) gerçek sunucu kaynağıyla birlikte yazılacak.
class NotificationItem {
  const NotificationItem({
    required this.id,
    required this.reportId,
    required this.message,
    required this.createdAt,
    required this.isRead,
  });

  final String id;
  final String reportId;
  final String message;
  final DateTime createdAt;
  final bool isRead;

  /// Okundu işaretlenmiş kopyası.
  NotificationItem markedRead() => NotificationItem(
    id: id,
    reportId: reportId,
    message: message,
    createdAt: createdAt,
    isRead: true,
  );
}
