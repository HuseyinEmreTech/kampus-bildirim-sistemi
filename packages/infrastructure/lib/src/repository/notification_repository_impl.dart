import '../database/database.dart';
import '../database/paging.dart';
import '../database/uuid_format.dart';

/// `markRead` sonucu. Application'daki `AppError` (#15) gelince ona çevrilecek.
enum MarkReadOutcome { marked, notFound }

/// Öğrencinin bildirim kutusundaki bir satır. [readAt] boşsa okunmamış.
/// [reportCategory] ve [reportDescription] satırın hangi bildirime ait olduğunu
/// gösterir; her satır için ayrıca bildirim sorgulamak gerekmez (N+1 yok).
typedef NotificationItem = ({
  String notificationId,
  String reportId,
  String reportCategory,
  String reportDescription,
  String type,
  String message,
  DateTime createdAt,
  DateTime? readAt,
});

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

  // Yeniden eskiye; aynı anda oluşanlar kimliğe göre sıralanır, sayfalar kaymaz.
  static const _listSql = r'''
SELECT n.notification_id::text, n.report_id::text, r.category, r.description,
  n.type, n.message, n.created_at, n.read_at
FROM notifications n
JOIN reports r ON r.report_id = n.report_id
WHERE n.user_id = $1
ORDER BY n.created_at DESC, n.notification_id DESC
LIMIT $2 OFFSET $3
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

  /// [userId] öğrencisinin bildirimleri (Rule 01), yeniden eskiye. [offset] kadarını
  /// atlar, en çok [limit] tane döner. Sayfa geçersizse boş liste döner,
  /// veritabanına gidilmez.
  Future<List<NotificationItem>> list(
    String userId, {
    required int limit,
    required int offset,
  }) async {
    if (!isValidPage(limit, offset)) return const [];
    final rows = await _db.execute(_listSql, [userId, limit, offset]);
    return [
      for (final [
            id,
            reportId,
            reportCategory,
            reportDescription,
            type,
            message,
            createdAt,
            readAt,
          ]
          in rows)
        (
          notificationId: id! as String,
          reportId: reportId! as String,
          reportCategory: reportCategory! as String,
          reportDescription: reportDescription! as String,
          type: type! as String,
          message: message! as String,
          createdAt: createdAt! as DateTime,
          readAt: readAt as DateTime?,
        ),
    ];
  }

  /// [userId] öğrencisinin okunmamış bildirim sayısı (liste ekranındaki rozet).
  Future<int> unreadCount(String userId) async {
    final rows = await _db.execute(_unreadCountSql, [userId]);
    return rows.single.single! as int;
  }
}
