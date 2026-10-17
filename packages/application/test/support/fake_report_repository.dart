import 'package:campus_application/campus_application.dart';
import 'package:campus_domain/campus_domain.dart';

AppError _mapDomainError(DomainError error) => switch (error) {
  InvalidRole() => const ForbiddenError(),
  InvalidTransition() => const InvalidTransitionError(),
  MissingResolutionPhoto() => const MissingResolutionPhotoError(),
  InvalidPhoto(:final reason) => ValidationError('photo', reason),
  InvalidLocation(:final reason) => ValidationError('location', reason),
  InvalidDescription(:final reason) => ValidationError('description', reason),
  InvalidId(:final reason) => ValidationError('id', reason),
};

final class FakeHistoryEntry {
  FakeHistoryEntry({
    required this.fromStatus,
    required this.toStatus,
    required this.changedById,
    required this.changedAt,
    this.note,
  });

  final String? fromStatus;
  final String toStatus;
  final String changedById;
  final DateTime changedAt;
  final String? note;
}

final class FakeNotification {
  FakeNotification({
    required this.userId,
    required this.reportId,
    required this.type,
    required this.message,
    required this.createdAt,
  });

  final String userId;
  final String reportId;
  final String type;
  final String message;
  final DateTime createdAt;
}

/// Bellek içi sahte depo. Testlerde gerçek PostgreSQL’e bağlanmadan
/// UseCase davranışlarını ve durum geçişlerini doğrulamak için kullanılır.
final class FakeReportRepository implements ReportRepository {
  final Map<String, Report> _reports = {};
  final Map<String, List<FakeHistoryEntry>> _history = {};
  final List<FakeNotification> _notifications = [];

  void seed(Report report) {
    _reports[report.id.value] = report;
  }

  List<FakeHistoryEntry> historyFor(String reportId) =>
      List.unmodifiable(_history[reportId] ?? const []);

  List<FakeNotification> get notifications => List.unmodifiable(_notifications);

  @override
  Future<Result<ReportId, AppError>> create(Report report) async {
    _reports[report.id.value] = report;
    _addHistory(
      report.id.value,
      null,
      ReportStatus.yeni.name,
      report.reporterId.value,
      DateTime.now(),
    );
    return Success(report.id);
  }

  @override
  Future<Result<Unit, AppError>> assign(
    ReportId reportId,
    UserId assigneeId,
  ) async {
    final report = _reports[reportId.value];
    if (report == null) {
      return const Failure(NotFoundError());
    }

    final now = DateTime.now();
    final result = report.assign(
      assigneeId: assigneeId,
      role: Role.staff,
      takenAt: now,
    );

    return result.map((updated) {
      _reports[reportId.value] = updated;
      _addHistory(
        reportId.value,
        ReportStatus.yeni.name,
        ReportStatus.ustlenildi.name,
        assigneeId.value,
        now,
      );
      return const Success<Unit, AppError>(Unit.value);
    }, (error) => Failure<Unit, AppError>(_mapDomainError(error)));
  }

  @override
  Future<Result<Unit, AppError>> resolve(
    ReportId reportId,
    UserId assigneeId,
    Photo resolutionPhoto, {
    String? note,
  }) async {
    final report = _reports[reportId.value];
    if (report == null) {
      return const Failure(NotFoundError());
    }

    final now = DateTime.now();
    final result = report.resolve(
      assigneeId: assigneeId,
      role: Role.staff,
      resolutionPhoto: resolutionPhoto,
      resolvedAt: now,
      note: note,
    );

    return result.map((updated) {
      _reports[reportId.value] = updated;
      _addHistory(
        reportId.value,
        ReportStatus.ustlenildi.name,
        ReportStatus.cozuldu.name,
        assigneeId.value,
        now,
        note: note,
      );
      _notifications.add(
        FakeNotification(
          userId: updated.reporterId.value,
          reportId: reportId.value,
          type: NotificationType.reportResolved.name,
          message: 'Bildiriminiz çözüldü.',
          createdAt: now,
        ),
      );
      return const Success<Unit, AppError>(Unit.value);
    }, (error) => Failure<Unit, AppError>(_mapDomainError(error)));
  }

  @override
  Future<Result<Paginated<ReportSummary>, AppError>> list({
    required ReportListFilter filter,
    required int limit,
    required int offset,
  }) async {
    final all = _reports.values.where((report) {
      if (filter.status != null && report.status != filter.status) return false;
      if (filter.category != null && report.category != filter.category) {
        return false;
      }
      if (filter.assigneeId != null &&
          report.assigneeId?.value != filter.assigneeId!.value) {
        return false;
      }
      if (filter.reporterId != null &&
          report.reporterId.value != filter.reporterId!.value) {
        return false;
      }
      return true;
    }).toList();

    all.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    final total = all.length;
    final items = all.skip(offset).take(limit).map(_toSummary).toList();

    final page = offset ~/ limit + 1;
    return Success(
      Paginated(items: items, total: total, page: page, pageSize: limit),
    );
  }

  @override
  Future<Result<Report?, AppError>> findById(ReportId reportId) async {
    return Success(_reports[reportId.value]);
  }

  ReportSummary _toSummary(Report report) => ReportSummary(
    reportId: report.id.value,
    category: report.category.name,
    description: report.description,
    status: report.status.name,
    place: report.location.place,
    buildingName: null,
    photoUrl: report.photo.url,
    assigneeId: report.assigneeId?.value,
    createdAt: report.createdAt,
  );

  void _addHistory(
    String reportId,
    String? fromStatus,
    String toStatus,
    String changedById,
    DateTime changedAt, {
    String? note,
  }) {
    _history.putIfAbsent(reportId, () => []);
    _history[reportId]!.add(
      FakeHistoryEntry(
        fromStatus: fromStatus,
        toStatus: toStatus,
        changedById: changedById,
        changedAt: changedAt,
        note: note,
      ),
    );
  }
}
