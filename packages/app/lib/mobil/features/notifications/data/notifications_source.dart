import 'notification_item.dart';

/// Bildirim listesi isteğinin sonucu.
sealed class NotificationsResult {
  const NotificationsResult();
}

final class NotificationsLoaded extends NotificationsResult {
  const NotificationsLoaded({required this.items, required this.unreadCount});

  final List<NotificationItem> items;
  final int unreadCount;
}

final class NotificationsFailed extends NotificationsResult {
  const NotificationsFailed();
}

/// Öğrencinin bildirimlerini getiren ve okundu işaretleyen kaynak
/// (`GET /api/me/notifications`, `PUT /api/me/notifications/{id}/read`).
///
/// Şimdilik yalnızca ilk sayfa. Gerçek hali sunucu ve `campus_contracts`
/// hazır olunca yazılacak; testlerde sahte bir kaynak kullanılır.
abstract interface class NotificationsSource {
  Future<NotificationsResult> fetchFirstPage();

  /// İşaretlendiyse `true`, sunucu veya bağlantı hatasında `false` döner.
  Future<bool> markRead(String notificationId);
}
