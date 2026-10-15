import 'package:postgres/postgres.dart' show TxSession;

import '../database/database.dart';
import '../database/uuid_format.dart';

/// `assign` sonucu. Application'daki `AppError` (#15) gelince ona çevrilecek.
enum AssignOutcome { assigned, alreadyAssigned, invalidTransition, notFound }

/// `resolve` sonucu. Application'daki `AppError` (#15) gelince ona çevrilecek.
enum ResolveOutcome { resolved, notAssignee, invalidTransition, notFound }

/// Bildirim ve sonuç fotoğrafı. Domain'deki `Photo` (#15) gelince onunla değişecek.
typedef ReportPhoto = ({String url, String contentType, int sizeBytes});

/// Öğrencinin açtığı yeni bildirim. Domain'deki `Report` (#15) gelince onunla değişecek.
/// Kuralları (Rule 01, Rule 06) service kontrol eder; burada yalnızca kayıt var.
typedef NewReport = ({
  String reporterId,
  String category,
  String description,
  ReportPhoto photo,
  double latitude,
  double longitude,
  String? place,
  String locationSource,
  String? buildingId,
});

/// Bildirimlerin PostgreSQL tarafı. `ReportRepository` arayüzü (#15) gelince onu uygular.
class ReportRepositoryImpl {
  ReportRepositoryImpl(this._db);

  final Database _db;

  // Rule 02: koşul UPDATE'in içinde. Aynı anda gelen iki istekten PostgreSQL satırı
  // yalnızca birine değiştirtir; ikincisi koşulu sağlamadığı için 0 satır değiştirir.
  static const _assignSql = r'''
UPDATE reports
SET assignee_id = $2, taken_at = NOW(), status = 'Ustlenildi'
WHERE report_id = $1 AND assignee_id IS NULL AND status = 'Yeni'
''';

  // Rule 03: yalnızca üstlenen görevli, yalnızca `Ustlenildi` iken çözebilir.
  static const _resolveSql = r'''
UPDATE reports
SET status = 'Cozuldu', resolved_at = NOW(), resolution_photo_url = $3,
  resolution_photo_content_type = $4, resolution_photo_size_bytes = $5,
  resolution_note = $6
WHERE report_id = $1 AND assignee_id = $2 AND status = 'Ustlenildi'
RETURNING reporter_id::text
''';

  static const _createSql = r'''
INSERT INTO reports (reporter_id, category, description, photo_url,
  photo_content_type, photo_size_bytes, latitude, longitude, place,
  location_source, building_id)
VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11)
RETURNING report_id::text
''';

  static const _insertHistorySql = r'''
INSERT INTO status_history (report_id, from_status, to_status, changed_by, note)
VALUES ($1, $2, $3, $4, $5)
''';

  static const _insertResolvedNotificationSql = r'''
INSERT INTO notifications (user_id, report_id, type, message)
VALUES ($1, $2, 'ReportResolved', $3)
''';

  static const _resolvedMessage = 'Bildiriminiz çözüldü.';

  static const _statusSql = r'SELECT status FROM reports WHERE report_id = $1';

  static const _statusAndAssigneeSql =
      r'SELECT status, assignee_id::text FROM reports WHERE report_id = $1';

  /// Bildirimi `Yeni` olarak kaydeder ve kimliğini döner. İlk durum geçmişi satırı
  /// (boş → `Yeni`) aynı işlemde yazılır. Bina kimliğinin var olduğunu service
  /// önceden `BuildingRepositoryImpl.findById` ile denetler.
  Future<String> create(NewReport report) => _db.transaction((tx) async {
    final rows = await tx.execute(
      _createSql,
      parameters: [
        report.reporterId,
        report.category,
        report.description,
        report.photo.url,
        report.photo.contentType,
        report.photo.sizeBytes,
        report.latitude,
        report.longitude,
        report.place,
        report.locationSource,
        report.buildingId,
      ],
    );
    final reportId = rows.single.single! as String;
    await _insertHistory(tx, reportId, null, 'Yeni', report.reporterId);
    return reportId;
  });

  /// [assigneeId] görevlisini bildirime atar; yalnızca `Yeni` ve görevlisiz bildirimde olur.
  /// Durum değişimi ve durum geçmişi aynı işlemde yazılır: biri olmazsa ikisi de olmaz.
  Future<AssignOutcome> assign(String reportId, String assigneeId) async {
    if (!isUuid(reportId)) return AssignOutcome.notFound;
    final assigned = await _db.transaction((tx) async {
      final result = await tx.execute(
        _assignSql,
        parameters: [reportId, assigneeId],
      );
      if (result.affectedRows != 1) return false;
      await _insertHistory(tx, reportId, 'Yeni', 'Ustlenildi', assigneeId);
      return true;
    });
    if (assigned) return AssignOutcome.assigned;
    return _whyNotAssigned(reportId);
  }

  // Satır değişmediyse nedenini bulur. Veritabanı kuralına göre `Yeni` olmayan
  // bildirimin görevlisi vardır: `Ustlenildi` başkası almış, `Cozuldu` geçiş geçersiz.
  Future<AssignOutcome> _whyNotAssigned(String reportId) async {
    final rows = await _db.execute(_statusSql, [reportId]);
    if (rows.isEmpty) return AssignOutcome.notFound;
    final status = rows.single.single;
    if (status == 'Cozuldu') return AssignOutcome.invalidTransition;
    return AssignOutcome.alreadyAssigned;
  }

  /// Bildirimi [photo] ile çözüldü işaretler; yalnızca üstlenen [assigneeId] yapabilir.
  ///
  /// Rule 04: durum, durum geçmişi ve öğrenciye "çözüldü" bildirimi aynı işlemde yazılır.
  Future<ResolveOutcome> resolve(
    String reportId,
    String assigneeId,
    ReportPhoto photo, {
    String? note,
  }) async {
    if (!isUuid(reportId)) return ResolveOutcome.notFound;
    final resolved = await _db.transaction((tx) async {
      final rows = await tx.execute(
        _resolveSql,
        parameters: [
          reportId,
          assigneeId,
          photo.url,
          photo.contentType,
          photo.sizeBytes,
          note,
        ],
      );
      if (rows.isEmpty) return false;

      final reporterId = rows.single.single! as String;
      await _insertHistory(
        tx,
        reportId,
        'Ustlenildi',
        'Cozuldu',
        assigneeId,
        note: note,
      );
      await tx.execute(
        _insertResolvedNotificationSql,
        parameters: [reporterId, reportId, _resolvedMessage],
      );
      return true;
    });
    if (resolved) return ResolveOutcome.resolved;
    return _whyNotResolved(reportId, assigneeId);
  }

  Future<ResolveOutcome> _whyNotResolved(
    String reportId,
    String assigneeId,
  ) async {
    final rows = await _db.execute(_statusAndAssigneeSql, [reportId]);
    if (rows.isEmpty) return ResolveOutcome.notFound;
    final [status, currentAssignee] = rows.single;
    if (status == 'Ustlenildi' && currentAssignee != assigneeId) {
      return ResolveOutcome.notAssignee;
    }
    return ResolveOutcome.invalidTransition;
  }

  Future<void> _insertHistory(
    TxSession tx,
    String reportId,
    String? from,
    String to,
    String changedBy, {
    String? note,
  }) => tx.execute(
    _insertHistorySql,
    parameters: [reportId, from, to, changedBy, note],
  );
}
