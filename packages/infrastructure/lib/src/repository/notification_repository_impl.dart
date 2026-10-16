import '../database/database.dart';
import '../database/uuid_format.dart';

/// `markRead` sonucu. Application'daki `AppError` (#15) gelince ona çevrilecek.
enum MarkReadOutcome { marked, notFound }

/// Öğrenci bildirimlerinin PostgreSQL tarafı. `NotificationRepository` arayüzü (#15)
/// gelince onu uygular.
class NotificationRepositoryImpl {
  NotificationRepositoryImpl(this._db);

  final Database _db;

  // Yalnızca sahibinin bildirimi değişir (Rule 01). İkinci istekte ilk okunma
  // zamanı korunur; böylece istek tekrarlansa da sonuç aynı kalır.
  static const _markReadSql = r'''
UPDATE notifications SET read_at = COALESCE(read_at, NOW())
WHERE notification_id = $1 AND user_id = $2
''';

  static const _unreadCountSql = r'''
SELECT count(*) FROM notifications WHERE user_id = $1 AND read_at IS NULL
''';

  /// [notificationId] bildirimini [userId] için okundu işaretler. Bildirim yoksa ya da
  /// başkasınınsa `notFound`: başkasının bildiriminin var olduğu da belli edilmez.
  Future<MarkReadOutcome> markRead(String notificationId, String userId) async {
    if (!isUuid(notificationId)) return MarkReadOutcome.notFound;
    final result = await _db.execute(_markReadSql, [notificationId, userId]);
    if (result.affectedRows == 0) return MarkReadOutcome.notFound;
    return MarkReadOutcome.marked;
  }

  /// [userId] öğrencisinin okunmamış bildirim sayısı (liste ekranındaki rozet).
  Future<int> unreadCount(String userId) async {
    final rows = await _db.execute(_unreadCountSql, [userId]);
    return rows.single.single! as int;
  }
}
