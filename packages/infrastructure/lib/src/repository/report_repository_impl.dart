import 'package:postgres/postgres.dart' show TxSession;

import '../database/database.dart';

/// `assign` sonucu. Application'daki `AppError` (#15) gelince ona çevrilecek.
enum AssignOutcome { assigned, alreadyAssigned, invalidTransition, notFound }

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

  static const _insertHistorySql = r'''
INSERT INTO status_history (report_id, from_status, to_status, changed_by)
VALUES ($1, $2, $3, $4)
''';

  static const _statusSql = r'SELECT status FROM reports WHERE report_id = $1';

  /// [assigneeId] görevlisini bildirime atar; yalnızca `Yeni` ve görevlisiz bildirimde olur.
  /// Durum değişimi ve durum geçmişi aynı işlemde yazılır: biri olmazsa ikisi de olmaz.
  Future<AssignOutcome> assign(String reportId, String assigneeId) async {
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

  Future<void> _insertHistory(
    TxSession tx,
    String reportId,
    String from,
    String to,
    String changedBy,
  ) => tx.execute(
    _insertHistorySql,
    parameters: [reportId, from, to, changedBy],
  );
}
