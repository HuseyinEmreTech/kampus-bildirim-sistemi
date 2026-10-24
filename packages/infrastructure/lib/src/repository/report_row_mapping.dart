import 'package:campus_application/campus_application.dart';
import 'package:campus_domain/campus_domain.dart';

import 'report_repository_impl.dart';

// Domain değerleri ile veritabanı satırları arasındaki çeviri. Saf fonksiyonlar:
// veritabanı istemez, CI'da da çalışan birim testleri vardır.

/// Veritabanındaki ve API'deki yazım (V1 CHECK'leri, 05-api-design).
String statusText(ReportStatus status) => switch (status) {
  ReportStatus.yeni => 'Yeni',
  ReportStatus.ustlenildi => 'Ustlenildi',
  ReportStatus.cozuldu => 'Cozuldu',
};

String categoryText(Category category) => switch (category) {
  Category.ariza => 'Ariza',
  Category.temizlik => 'Temizlik',
  Category.guvenlik => 'Guvenlik',
  Category.diger => 'Diger',
};

String sourceText(LocationSource source) => switch (source) {
  LocationSource.gps => 'Gps',
  LocationSource.building => 'Building',
};

ReportPhoto photoRow(Photo photo) => (
  url: photo.url,
  contentType: photo.contentType,
  sizeBytes: photo.sizeBytes,
);

/// Yeni bildirimin satırı; kimlik [Report.id] ayrıca verilir.
NewReport newReportRow(Report report) => (
  reporterId: report.reporterId.value,
  category: categoryText(report.category),
  description: report.description,
  photo: photoRow(report.photo),
  latitude: report.location.latitude,
  longitude: report.location.longitude,
  place: report.location.place,
  locationSource: sourceText(report.location.source),
  buildingId: report.location.buildingId,
);

/// Liste süzgeci; boş alan "hepsi" demek.
ReportFilter filterRow(ReportListFilter filter) => (
  status: _optional(filter.status, statusText),
  category: _optional(filter.category, categoryText),
  assigneeId: filter.assigneeId?.value,
  reporterId: filter.reporterId?.value,
);

ReportSummary summaryOf(ReportListRow row) => ReportSummary(
  reportId: row.reportId,
  category: row.category,
  description: row.description,
  status: row.status,
  place: row.place,
  buildingName: row.buildingName,
  photoUrl: row.photoUrl,
  assigneeId: row.assigneeId,
  createdAt: row.createdAt,
);

/// Kayıtlı satırdan [Report] kurar; kimlik, durum ve zamanlar korunur. Değerler
/// yazılırken denetlendiği için kayıtlı satır geçerlidir; yine de bir alan
/// domain'e uymazsa (ör. elle değiştirilmiş satır) `null` döner.
Report? restoreReport(ReportDetail row) {
  final id = _valueOrNull(ReportId.create(row.reportId));
  final reporterId = _valueOrNull(UserId.create(row.reporterId));
  final category = _valueOrNull(parseCategory(row.category));
  final status = _valueOrNull(parseReportStatus(row.status));
  final photo = _photoFrom(row.photo);
  final location = _valueOrNull(
    Location.create(
      latitude: row.latitude,
      longitude: row.longitude,
      source: row.locationSource,
      place: row.place,
      buildingId: row.buildingId,
    ),
  );
  final assigneeText = row.assigneeId;
  final assigneeId = assigneeText == null
      ? null
      : _valueOrNull(UserId.create(assigneeText));
  final resolutionRow = row.resolutionPhoto;
  final resolutionPhoto = resolutionRow == null
      ? null
      : _photoFrom(resolutionRow);
  if (id == null ||
      reporterId == null ||
      category == null ||
      status == null ||
      photo == null ||
      location == null ||
      (assigneeText != null && assigneeId == null) ||
      (resolutionRow != null && resolutionPhoto == null)) {
    return null;
  }
  return Report.restore(
    id: id,
    reporterId: reporterId,
    category: category,
    description: row.description,
    photo: photo,
    location: location,
    status: status,
    createdAt: row.createdAt,
    assigneeId: assigneeId,
    takenAt: row.takenAt,
    resolvedAt: row.resolvedAt,
    resolutionPhoto: resolutionPhoto,
    resolutionNote: row.resolutionNote,
  );
}

Photo? _photoFrom(ReportPhoto row) => _valueOrNull(
  Photo.create(
    url: row.url,
    contentType: row.contentType,
    sizeBytes: row.sizeBytes,
  ),
);

T? _valueOrNull<T>(Result<T, DomainError> result) => switch (result) {
  Success(:final value) => value,
  Failure() => null,
};

String? _optional<T extends Object>(T? value, String Function(T) text) =>
    value == null ? null : text(value);
