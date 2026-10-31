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
  static const _notYetConnected = UnknownError('bu işlem henüz bağlı değil');

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

  /// Çözme, liste ve detay bir sonraki PR'da bağlanacak (#17). O zamana kadar
  /// hata döner; sunucu bu üç ucu henüz bu sınıfa bağlamamalı.
  @override
  Future<Result<Unit, AppError>> resolve(
    ReportId reportId,
    UserId assigneeId,
    Photo resolutionPhoto, {
    String? note,
  }) async => const Failure(_notYetConnected);

  @override
  Future<Result<Paginated<ReportSummary>, AppError>> list({
    required ReportListFilter filter,
    required int limit,
    required int offset,
  }) async => const Failure(_notYetConnected);

  @override
  Future<Result<Report?, AppError>> findById(ReportId reportId) async =>
      const Failure(_notYetConnected);

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
