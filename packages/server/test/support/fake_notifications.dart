import 'package:campus_infrastructure/campus_infrastructure.dart';

/// Bellek içi sahte bildirim deposu. Gerçek SQL gibi yalnızca sahibinin
/// bildirimlerini verir ve değiştirir (Rule 01).
class FakeNotifications implements NotificationRepositoryImpl {
  final items = <({String userId, NotificationItem item})>[];
  ({int limit, int offset})? lastPage;

  @override
  Future<List<NotificationItem>> list(
    String userId, {
    required int limit,
    required int offset,
  }) async {
    lastPage = (limit: limit, offset: offset);
    return items
        .where((n) => n.userId == userId)
        .map((n) => n.item)
        .skip(offset)
        .take(limit)
        .toList();
  }

  @override
  Future<int> unreadCount(String userId) async =>
      items.where((n) => n.userId == userId && n.item.readAt == null).length;

  @override
  Future<MarkReadOutcome> markRead(String notificationId, String userId) async {
    final index = items.indexWhere(
      (n) => n.userId == userId && n.item.notificationId == notificationId,
    );
    if (index < 0) return MarkReadOutcome.notFound;
    final old = items[index].item;
    items[index] = (
      userId: userId,
      item: (
        notificationId: old.notificationId,
        reportId: old.reportId,
        reportCategory: old.reportCategory,
        reportDescription: old.reportDescription,
        type: old.type,
        message: old.message,
        createdAt: old.createdAt,
        readAt: old.readAt ?? DateTime.utc(2026, 10, 24, 23),
      ),
    );
    return MarkReadOutcome.marked;
  }
}
