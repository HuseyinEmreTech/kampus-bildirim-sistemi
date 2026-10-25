import 'package:campus_application/campus_application.dart';
import 'package:campus_domain/campus_domain.dart';

import '../database/database.dart';
import 'report_repository_impl.dart';
import 'report_row_mapping.dart';

/// Application'daki [ReportRepository] arayüzünün PostgreSQL karşılığı (#15, #17).
/// SQL [ReportRepositoryImpl]'dadır, değer çevirisi `report_row_mapping.dart`'ta;
/// bu sınıf sonuçları [AppError] olarak döner. Veritabanına ulaşılamazsa istisna
/// dışarı sızmaz, [UnknownError] döner.
final class PostgresReportRepository implements ReportRepository {
  PostgresReportRepository(Database db) : _reports = ReportRepositoryImpl(db);

  final ReportRepositoryImpl _reports;

  static const _databaseFailure = UnknownError('veritabanı işlemi başarısız');
  static const _unreadableRow = UnknownError('kayıtlı bildirim okunamadı');

  /// Kimlik domain'den gelir ([Report.id]). Oluşma zamanı ise veritabanının
  /// saatinden yazılır: üstlenme ve çözülme zamanları da oradan gelir, iki farklı
  /// saat zaman sırasını bozmaz.
  @override
  Future<Result<ReportId, AppError>> create(Report report) => _guard(() async {
    await _reports.create(newReportRow(report), reportId: report.id.value);
    return Success(report.id);
  });

  /// Rule 02: koşul veritabanındaki UPDATE'tedir; aynı anda gelen ikinci görevli
  /// [ConflictError] alır.
  @override
  Future<Result<Unit, AppError>> assign(ReportId reportId, UserId assigneeId) =>
      _guard(() async {
        final outcome = await _reports.assign(reportId.value, assigneeId.value);
        return switch (outcome) {
          AssignOutcome.assigned => const Success(Unit.value),
          AssignOutcome.alreadyAssigned => const Failure(
            ConflictError('Bildirim zaten üstlenilmiş'),
          ),
          AssignOutcome.invalidTransition => const Failure(
            InvalidTransitionError(),
          ),
          AssignOutcome.notFound => const Failure(NotFoundError()),
        };
      });

  /// Rule 03 ve Rule 04: yalnızca üstlenen görevli çözer; durum, geçmiş ve
  /// öğrenciye bildirim aynı işlemde yazılır.
  @override
  Future<Result<Unit, AppError>> resolve(
    ReportId reportId,
    UserId assigneeId,
    Photo resolutionPhoto, {
    String? note,
  }) => _guard(() async {
    final outcome = await _reports.resolve(
      reportId.value,
      assigneeId.value,
      photoRow(resolutionPhoto),
      note: note,
    );
    return switch (outcome) {
      ResolveOutcome.resolved => const Success(Unit.value),
      ResolveOutcome.notAssignee => const Failure(ForbiddenError()),
      ResolveOutcome.invalidTransition => const Failure(
        InvalidTransitionError(),
      ),
      ResolveOutcome.notFound => const Failure(NotFoundError()),
    };
  });

  /// Sayfa ve toplam aynı süzgeçle iki sorguda alınır. [limit] ve [offset]'i
  /// use case denetler; geçersizse depo boş sayfa döner.
  @override
  Future<Result<Paginated<ReportSummary>, AppError>> list({
    required ReportListFilter filter,
    required int limit,
    required int offset,
  }) => _guard(() async {
    final rowFilter = filterRow(filter);
    final rows = await _reports.list(rowFilter, limit: limit, offset: offset);
    final total = await _reports.count(rowFilter);
    return Success(
      Paginated(
        items: [for (final row in rows) summaryOf(row)],
        total: total,
        page: limit > 0 ? offset ~/ limit + 1 : 1,
        pageSize: limit,
      ),
    );
  });

  /// Bildirim yoksa `null`. Yetki burada denetlenmez (Rule 01 use case'te).
  @override
  Future<Result<Report?, AppError>> findById(ReportId reportId) =>
      _guard(() async {
        final row = await _reports.findById(reportId.value);
        if (row == null) return const Success(null);
        final report = restoreReport(row);
        if (report == null) return const Failure(_unreadableRow);
        return Success(report);
      });

  // Veritabanı hatası (bağlantı, zaman aşımı) istisna olarak gelir; servis akışı
  // istisnayla yönetilmez, [UnknownError]'a çevrilir. Programlama hataları
  // (`Error`) yakalanmaz.
  Future<Result<T, AppError>> _guard<T>(
    Future<Result<T, AppError>> Function() run,
  ) async {
    try {
      return await run();
    } on Exception {
      return const Failure(_databaseFailure);
    }
  }
}
