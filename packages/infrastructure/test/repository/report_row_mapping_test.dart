// Veritabanı istemez: domain değerleri ile satırlar arasındaki çeviri.
import 'package:campus_application/campus_application.dart';
import 'package:campus_domain/campus_domain.dart';
import 'package:campus_infrastructure/campus_infrastructure.dart';
import 'package:campus_infrastructure/src/repository/report_row_mapping.dart';
import 'package:test/test.dart';

const _reportId = 'c0000000-0000-4000-8000-0000000000a1';
const _student = 'a0000000-0000-4000-8000-0000000000a1';
const _staff = 'a0000000-0000-4000-8000-0000000000a2';

ReportDetail _detail({
  String category = 'Ariza',
  String status = 'Cozuldu',
  String? assigneeId = _staff,
  ReportPhoto? resolutionPhoto = (
    url: '/files/sonuc.jpg',
    contentType: 'image/jpeg',
    sizeBytes: 2000,
  ),
}) => (
  reportId: _reportId,
  reporterId: _student,
  reporterName: 'Öğrenci',
  assigneeId: assigneeId,
  assigneeName: assigneeId == null ? null : 'Görevli',
  category: category,
  description: 'Lamba yanmıyor',
  photo: (url: '/files/ilk.jpg', contentType: 'image/png', sizeBytes: 1000),
  latitude: 36.5871,
  longitude: 36.1742,
  place: 'B blok',
  locationSource: 'Gps',
  buildingId: null,
  buildingName: null,
  status: status,
  createdAt: DateTime.utc(2026, 10, 19, 9),
  takenAt: assigneeId == null ? null : DateTime.utc(2026, 10, 19, 10),
  resolvedAt: resolutionPhoto == null ? null : DateTime.utc(2026, 10, 19, 11),
  resolutionPhoto: resolutionPhoto,
  resolutionNote: resolutionPhoto == null ? null : 'Değiştirildi',
);

void main() {
  group('yazım', () {
    // Her değer domain'in kendi ayrıştırıcısıyla geri okunabilmeli.
    test('statusText_roundTripsWithParseReportStatus', () {
      for (final status in ReportStatus.values) {
        final parsed = parseReportStatus(statusText(status));
        expect((parsed as Success<ReportStatus, DomainError>).value, status);
      }
      expect(statusText(ReportStatus.ustlenildi), 'Ustlenildi');
    });

    test('categoryText_roundTripsWithParseCategory', () {
      for (final category in Category.values) {
        final parsed = parseCategory(categoryText(category));
        expect((parsed as Success<Category, DomainError>).value, category);
      }
      expect(categoryText(Category.guvenlik), 'Guvenlik');
    });

    test('sourceText_usesDatabaseSpelling', () {
      expect(sourceText(LocationSource.gps), 'Gps');
      expect(sourceText(LocationSource.building), 'Building');
    });
  });

  test('newReportRow_copiesDomainValues', () {
    final report = (Report.create(
      reporterId: _student,
      category: 'temizlik',
      description: 'Koridor kirli',
      photoUrl: '/files/a.jpg',
      photoContentType: 'image/jpeg',
      photoSizeBytes: 500,
      latitude: 36.58,
      longitude: 36.17,
      locationSource: 'building',
      buildingId: 'b0000000-0000-4000-8000-000000000001',
      createdAt: DateTime.utc(2026, 10, 19),
    ) as Success<Report, DomainError>).value;

    final row = newReportRow(report);

    expect(row.reporterId, _student);
    expect(row.category, 'Temizlik');
    expect(row.locationSource, 'Building');
    expect(row.buildingId, 'b0000000-0000-4000-8000-000000000001');
    expect(row.photo.sizeBytes, 500);
  });

  group('filterRow', () {
    test('emptyFilter_allNull', () {
      final row = filterRow(const ReportListFilter());

      expect(row, (
        status: null,
        category: null,
        assigneeId: null,
        reporterId: null,
      ));
    });

    test('fullFilter_usesDatabaseSpelling', () {
      final staff =
          (UserId.create(_staff) as Success<UserId, DomainError>).value;

      final row = filterRow(
        ReportListFilter(
          status: ReportStatus.yeni,
          category: Category.diger,
          assigneeId: staff,
        ),
      );

      expect(row.status, 'Yeni');
      expect(row.category, 'Diger');
      expect(row.assigneeId, _staff);
      expect(row.reporterId, isNull);
    });
  });

  group('restoreReport', () {
    test('resolvedRow_keepsIdStatusAndTimes', () {
      final report = restoreReport(_detail())!;

      expect(report.id.value, _reportId);
      expect(report.status, ReportStatus.cozuldu);
      expect(report.category, Category.ariza);
      expect(report.assigneeId?.value, _staff);
      expect(report.takenAt, DateTime.utc(2026, 10, 19, 10));
      expect(report.resolutionPhoto?.url, '/files/sonuc.jpg');
      expect(report.resolutionNote, 'Değiştirildi');
      expect(report.location.source, LocationSource.gps);
      expect(report.location.place, 'B blok');
    });

    test('newRow_hasNoAssigneeOrResolution', () {
      final report = restoreReport(
        _detail(status: 'Yeni', assigneeId: null, resolutionPhoto: null),
      )!;

      expect(report.status, ReportStatus.yeni);
      expect(report.assigneeId, isNull);
      expect(report.resolutionPhoto, isNull);
    });

    test('unknownCategory_returnsNull', () {
      expect(restoreReport(_detail(category: 'Bilinmeyen')), isNull);
    });

    test('invalidAssigneeId_returnsNull', () {
      expect(restoreReport(_detail(assigneeId: 'uuid-degil')), isNull);
    });

    test('invalidResolutionPhoto_returnsNull', () {
      final gif = (url: '/files/x.gif', contentType: 'image/gif', sizeBytes: 1);

      expect(restoreReport(_detail(resolutionPhoto: gif)), isNull);
    });
  });

  test('summaryOf_copiesRow', () {
    final summary = summaryOf((
      reportId: _reportId,
      category: 'Ariza',
      description: 'Lamba',
      status: 'Yeni',
      place: null,
      buildingName: 'Mühendislik',
      photoUrl: '/files/ilk.jpg',
      assigneeId: null,
      createdAt: DateTime.utc(2026, 10, 19),
    ));

    expect(summary.reportId, _reportId);
    expect(summary.buildingName, 'Mühendislik');
    expect(summary.status, 'Yeni');
  });
}
