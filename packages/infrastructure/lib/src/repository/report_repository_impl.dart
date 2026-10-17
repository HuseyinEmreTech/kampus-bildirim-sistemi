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

/// Bildirim detayı: bildirenin, görevlinin ve binanın adlarıyla birlikte.
typedef ReportDetail = ({
  String reportId,
  String reporterId,
  String reporterName,
  String? assigneeId,
  String? assigneeName,
  String category,
  String description,
  ReportPhoto photo,
  double latitude,
  double longitude,
  String? place,
  String locationSource,
  String? buildingId,
  String? buildingName,
  String status,
  DateTime createdAt,
  DateTime? takenAt,
  DateTime? resolvedAt,
  ReportPhoto? resolutionPhoto,
  String? resolutionNote,
});

/// Durum geçmişinin bir satırı. İlk satırda [fromStatus] boştur (bildirim açıldı).
typedef StatusChange = ({
  String? fromStatus,
  String toStatus,
  String changedById,
  String changedByName,
  DateTime changedAt,
  String? note,
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

  // Bildireni ve binayı her zaman, görevliyi varsa getirir (LEFT JOIN).
  static const _detailSql = r'''
SELECT r.report_id::text, r.reporter_id::text, reporter.full_name,
  r.assignee_id::text, assignee.full_name, r.category, r.description,
  r.photo_url, r.photo_content_type, r.photo_size_bytes, r.latitude,
  r.longitude, r.place, r.location_source, r.building_id::text, b.name,
  r.status, r.created_at, r.taken_at, r.resolved_at, r.resolution_photo_url,
  r.resolution_photo_content_type, r.resolution_photo_size_bytes,
  r.resolution_note
FROM reports r
JOIN users reporter ON reporter.user_id = r.reporter_id
LEFT JOIN users assignee ON assignee.user_id = r.assignee_id
LEFT JOIN buildings b ON b.building_id = r.building_id
WHERE r.report_id = $1
''';

  // Eskiden yeniye; her işlem kendi NOW() değerini yazdığı için sıra doğru çıkar.
  static const _historySql = r'''
SELECT h.from_status, h.to_status, h.changed_by::text, u.full_name,
  h.changed_at, h.note
FROM status_history h
JOIN users u ON u.user_id = h.changed_by
WHERE h.report_id = $1
ORDER BY h.changed_at
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

  /// [reportId] UUID değilse ya da bildirim yoksa `null`. Yetki burada denetlenmez:
  /// öğrenci yalnızca kendi bildirimini görür (Rule 01), service [ReportDetail.reporterId]
  /// alanına bakar.
  Future<ReportDetail?> findById(String reportId) async {
    if (!isUuid(reportId)) return null;
    final rows = await _db.execute(_detailSql, [reportId]);
    if (rows.isEmpty) return null;
    return _toDetail(rows.single);
  }

  /// Bildirimin durum geçmişi, eskiden yeniye. [reportId] UUID değilse ya da
  /// bildirim yoksa boş liste. Service önce [findById] ile yetkiyi denetler.
  Future<List<StatusChange>> findHistory(String reportId) async {
    if (!isUuid(reportId)) return const [];
    final rows = await _db.execute(_historySql, [reportId]);
    return [
      for (final [from, to, changedById, changedByName, changedAt, note]
          in rows)
        (
          fromStatus: from as String?,
          toStatus: to! as String,
          changedById: changedById! as String,
          changedByName: changedByName! as String,
          changedAt: changedAt! as DateTime,
          note: note as String?,
        ),
    ];
  }

  ReportDetail _toDetail(List<Object?> row) {
    final [
      reportId,
      reporterId,
      reporterName,
      assigneeId,
      assigneeName,
      category,
      description,
      photoUrl,
      photoType,
      photoSize,
      latitude,
      longitude,
      place,
      locationSource,
      buildingId,
      buildingName,
      status,
      createdAt,
      takenAt,
      resolvedAt,
      resolutionUrl,
      resolutionType,
      resolutionSize,
      resolutionNote,
    ] = row;
    return (
      reportId: reportId! as String,
      reporterId: reporterId! as String,
      reporterName: reporterName! as String,
      assigneeId: assigneeId as String?,
      assigneeName: assigneeName as String?,
      category: category! as String,
      description: description! as String,
      photo: (
        url: photoUrl! as String,
        contentType: photoType! as String,
        sizeBytes: photoSize! as int,
      ),
      latitude: latitude! as double,
      longitude: longitude! as double,
      place: place as String?,
      locationSource: locationSource! as String,
      buildingId: buildingId as String?,
      buildingName: buildingName as String?,
      status: status! as String,
      createdAt: createdAt! as DateTime,
      takenAt: takenAt as DateTime?,
      resolvedAt: resolvedAt as DateTime?,
      // Veritabanı kuralı: sonuç fotoğrafının alanları ya hep dolu ya hep boş.
      resolutionPhoto: resolutionUrl == null
          ? null
          : (
              url: resolutionUrl as String,
              contentType: resolutionType! as String,
              sizeBytes: resolutionSize! as int,
            ),
      resolutionNote: resolutionNote as String?,
    );
  }

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
