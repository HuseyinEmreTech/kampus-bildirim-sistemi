import '../core/domain_error.dart';
import '../core/result.dart';
import '../value_objects/enums.dart';
import '../value_objects/location.dart';
import '../value_objects/photo.dart';
import '../value_objects/report_id.dart';
import '../value_objects/user_id.dart';

final class Report {
  Report._({
    required this.id,
    required this.reporterId,
    required this.category,
    required this.description,
    required this.photo,
    required this.location,
    required this.status,
    required this.createdAt,
    this.assigneeId,
    this.takenAt,
    this.resolvedAt,
    this.resolutionPhoto,
    this.resolutionNote,
  });

  final ReportId id;
  final UserId reporterId;
  final UserId? assigneeId;
  final Category category;
  final String description;
  final Photo photo;
  final Location location;
  final ReportStatus status;
  final DateTime createdAt;
  final DateTime? takenAt;
  final DateTime? resolvedAt;
  final Photo? resolutionPhoto;
  final String? resolutionNote;

  static Result<Report, DomainError> create({
    required String reporterId,
    required String category,
    required String description,
    required String photoUrl,
    required String photoContentType,
    required int photoSizeBytes,
    required double latitude,
    required double longitude,
    required String locationSource,
    String? place,
    String? buildingId,
    required DateTime createdAt,
  }) {
    final reporterResult = UserId.create(reporterId);
    final photoResult = Photo.create(
      url: photoUrl,
      contentType: photoContentType,
      sizeBytes: photoSizeBytes,
    );
    final locationResult = Location.create(
      latitude: latitude,
      longitude: longitude,
      source: locationSource,
      place: place,
      buildingId: buildingId,
    );
    final categoryResult = parseCategory(category);

    final trimmedDescription = description.trim();
    if (trimmedDescription.length < 5 || trimmedDescription.length > 500) {
      return const Failure(
        InvalidDescription('açıklama 5-500 karakter arasında olmalı'),
      );
    }

    return reporterResult.map(
      (reporter) => photoResult.map(
        (photo) => locationResult.map(
          (location) => categoryResult.map((categoryValue) {
            final id = ReportId.generate();
            return Success<Report, DomainError>(
              Report._(
                id: id,
                reporterId: reporter,
                category: categoryValue,
                description: trimmedDescription,
                photo: photo,
                location: location,
                status: ReportStatus.yeni,
                createdAt: createdAt,
              ),
            );
          }, (error) => Failure<Report, DomainError>(error)),
          (error) => Failure<Report, DomainError>(error),
        ),
        (error) => Failure<Report, DomainError>(error),
      ),
      (error) => Failure<Report, DomainError>(error),
    );
  }

  /// Yalnızca depo kullanır: veritabanındaki kayıtlı (doğrulanmış) veriden
  /// nesneyi geri kurar. `create` gibi iş kuralı denetlemez; kurallar yazma
  /// anında ve veritabanı kısıtlarında uygulanır. Kimlik, durum ve zamanlar
  /// olduğu gibi korunur.
  static Report restore({
    required ReportId id,
    required UserId reporterId,
    required Category category,
    required String description,
    required Photo photo,
    required Location location,
    required ReportStatus status,
    required DateTime createdAt,
    UserId? assigneeId,
    DateTime? takenAt,
    DateTime? resolvedAt,
    Photo? resolutionPhoto,
    String? resolutionNote,
  }) => Report._(
    id: id,
    reporterId: reporterId,
    assigneeId: assigneeId,
    category: category,
    description: description,
    photo: photo,
    location: location,
    status: status,
    createdAt: createdAt,
    takenAt: takenAt,
    resolvedAt: resolvedAt,
    resolutionPhoto: resolutionPhoto,
    resolutionNote: resolutionNote,
  );

  Result<Report, DomainError> assign({
    required UserId assigneeId,
    required Role role,
    required DateTime takenAt,
  }) {
    if (role != Role.staff) {
      return const Failure(InvalidRole());
    }
    if (status != ReportStatus.yeni) {
      return const Failure(InvalidTransition());
    }
    return Success(
      _copy(
        status: ReportStatus.ustlenildi,
        assigneeId: assigneeId,
        takenAt: takenAt,
      ),
    );
  }

  Result<Report, DomainError> resolve({
    required UserId assigneeId,
    required Role role,
    required Photo resolutionPhoto,
    required DateTime resolvedAt,
    String? note,
  }) {
    if (role != Role.staff) {
      return const Failure(InvalidRole());
    }
    if (status != ReportStatus.ustlenildi) {
      return const Failure(InvalidTransition());
    }
    if (this.assigneeId?.value != assigneeId.value) {
      return const Failure(InvalidTransition());
    }

    final trimmedNote = note?.trim();
    if (trimmedNote != null && trimmedNote.length > 500) {
      return const Failure(
        InvalidDescription('çözüm notu en fazla 500 karakter olmalı'),
      );
    }

    return Success(
      _copy(
        status: ReportStatus.cozuldu,
        resolutionPhoto: resolutionPhoto,
        resolutionNote: trimmedNote,
        resolvedAt: resolvedAt,
      ),
    );
  }

  Report _copy({
    ReportId? id,
    UserId? reporterId,
    UserId? assigneeId,
    Category? category,
    String? description,
    Photo? photo,
    Location? location,
    ReportStatus? status,
    DateTime? createdAt,
    DateTime? takenAt,
    DateTime? resolvedAt,
    Photo? resolutionPhoto,
    String? resolutionNote,
  }) => Report._(
    id: id ?? this.id,
    reporterId: reporterId ?? this.reporterId,
    assigneeId: assigneeId ?? this.assigneeId,
    category: category ?? this.category,
    description: description ?? this.description,
    photo: photo ?? this.photo,
    location: location ?? this.location,
    status: status ?? this.status,
    createdAt: createdAt ?? this.createdAt,
    takenAt: takenAt ?? this.takenAt,
    resolvedAt: resolvedAt ?? this.resolvedAt,
    resolutionPhoto: resolutionPhoto ?? this.resolutionPhoto,
    resolutionNote: resolutionNote ?? this.resolutionNote,
  );
}
