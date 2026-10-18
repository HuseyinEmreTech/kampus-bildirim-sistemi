import 'package:campus_domain/campus_domain.dart';
import 'package:test/test.dart';

void main() {
  final reporterId = '5c98741b-64c8-49de-9e68-3d7a2f44802b';
  final staffId = (UserId.create(
    '6a98741b-64c8-49de-9e68-3d7a2f44802b',
  ) as Success<UserId, DomainError>).value;
  final otherStaffId = (UserId.create(
    '7a98741b-64c8-49de-9e68-3d7a2f44802b',
  ) as Success<UserId, DomainError>).value;
  final now = DateTime.utc(2026, 10, 12, 10, 0, 0);

  Report createReport() {
    final result = Report.create(
      reporterId: reporterId,
      category: 'Ariza',
      description: 'B blok lambası yanmıyor',
      photoUrl: '/files/lamba.jpg',
      photoContentType: 'image/jpeg',
      photoSizeBytes: 812345,
      latitude: 36.5871,
      longitude: 36.1742,
      locationSource: 'Gps',
      createdAt: now,
    );
    return (result as Success<Report, DomainError>).value;
  }

  group('create', () {
    test('validData_returnsYeniReport', () {
      final report = createReport();
      expect(report.status, ReportStatus.yeni);
      expect(report.assigneeId, isNull);
    });

    test('shortDescription_returnsInvalidDescription', () {
      final result = Report.create(
        reporterId: reporterId,
        category: 'Ariza',
        description: 'Kısa',
        photoUrl: '/files/lamba.jpg',
        photoContentType: 'image/jpeg',
        photoSizeBytes: 812345,
        latitude: 36.5871,
        longitude: 36.1742,
        locationSource: 'Gps',
        createdAt: now,
      );
      expect(result, isA<Failure<Report, DomainError>>());
    });

    test('invalidReporterId_returnsInvalidId', () {
      final result = Report.create(
        reporterId: 'not-valid',
        category: 'Ariza',
        description: 'B blok lambası yanmıyor',
        photoUrl: '/files/lamba.jpg',
        photoContentType: 'image/jpeg',
        photoSizeBytes: 812345,
        latitude: 36.5871,
        longitude: 36.1742,
        locationSource: 'Gps',
        createdAt: now,
      );
      expect(result, isA<Failure<Report, DomainError>>());
    });

    test('invalidPhoto_returnsInvalidPhoto', () {
      final result = Report.create(
        reporterId: reporterId,
        category: 'Ariza',
        description: 'B blok lambası yanmıyor',
        photoUrl: '',
        photoContentType: 'image/jpeg',
        photoSizeBytes: 812345,
        latitude: 36.5871,
        longitude: 36.1742,
        locationSource: 'Gps',
        createdAt: now,
      );
      expect(result, isA<Failure<Report, DomainError>>());
    });

    test('invalidLocation_returnsInvalidLocation', () {
      final result = Report.create(
        reporterId: reporterId,
        category: 'Ariza',
        description: 'B blok lambası yanmıyor',
        photoUrl: '/files/lamba.jpg',
        photoContentType: 'image/jpeg',
        photoSizeBytes: 812345,
        latitude: 91,
        longitude: 36.1742,
        locationSource: 'Gps',
        createdAt: now,
      );
      expect(result, isA<Failure<Report, DomainError>>());
    });

    test('invalidCategory_returnsInvalidDescription', () {
      final result = Report.create(
        reporterId: reporterId,
        category: 'Yok',
        description: 'B blok lambası yanmıyor',
        photoUrl: '/files/lamba.jpg',
        photoContentType: 'image/jpeg',
        photoSizeBytes: 812345,
        latitude: 36.5871,
        longitude: 36.1742,
        locationSource: 'Gps',
        createdAt: now,
      );
      expect(result, isA<Failure<Report, DomainError>>());
    });
  });

  group('assign', () {
    test('staffOnYeni_returnsUstlenildi', () {
      final result = createReport().assign(
        assigneeId: staffId,
        role: Role.staff,
        takenAt: now,
      );
      expect(result, isA<Success<Report, DomainError>>());
      final updated = (result as Success<Report, DomainError>).value;
      expect(updated.status, ReportStatus.ustlenildi);
      expect(updated.assigneeId?.value, staffId.value);
    });

    test('studentOnYeni_returnsInvalidRole', () {
      final result = createReport().assign(
        assigneeId: staffId,
        role: Role.student,
        takenAt: now,
      );
      expect(result, isA<Failure<Report, DomainError>>());
    });

    test('assignOnUstlenildi_returnsInvalidTransition', () {
      final assigned = (createReport().assign(
        assigneeId: staffId,
        role: Role.staff,
        takenAt: now,
      ) as Success<Report, DomainError>).value;

      final result = assigned.assign(
        assigneeId: otherStaffId,
        role: Role.staff,
        takenAt: now,
      );
      expect(result, isA<Failure<Report, DomainError>>());
    });
  });

  group('resolve', () {
    Report assignedReport() {
      return (createReport().assign(
        assigneeId: staffId,
        role: Role.staff,
        takenAt: now,
      ) as Success<Report, DomainError>).value;
    }

    Photo resolutionPhoto() {
      return (Photo.create(
        url: '/files/sonuc.jpg',
        contentType: 'image/jpeg',
        sizeBytes: 500000,
      ) as Success<Photo, DomainError>).value;
    }

    test('assigneeOnUstlenildi_returnsCozuldu', () {
      final result = assignedReport().resolve(
        assigneeId: staffId,
        role: Role.staff,
        resolutionPhoto: resolutionPhoto(),
        resolvedAt: now,
      );
      expect(result, isA<Success<Report, DomainError>>());
      final updated = (result as Success<Report, DomainError>).value;
      expect(updated.status, ReportStatus.cozuldu);
    });

    test('otherStaffOnUstlenildi_returnsInvalidTransition', () {
      final result = assignedReport().resolve(
        assigneeId: otherStaffId,
        role: Role.staff,
        resolutionPhoto: resolutionPhoto(),
        resolvedAt: now,
      );
      expect(result, isA<Failure<Report, DomainError>>());
    });

    test('resolveOnYeni_returnsInvalidTransition', () {
      final result = createReport().resolve(
        assigneeId: staffId,
        role: Role.staff,
        resolutionPhoto: resolutionPhoto(),
        resolvedAt: now,
      );
      expect(result, isA<Failure<Report, DomainError>>());
    });

    test('studentRole_returnsInvalidRole', () {
      final result = assignedReport().resolve(
        assigneeId: staffId,
        role: Role.student,
        resolutionPhoto: resolutionPhoto(),
        resolvedAt: now,
      );
      expect(result, isA<Failure<Report, DomainError>>());
    });

    test('longNote_returnsInvalidDescription', () {
      final result = assignedReport().resolve(
        assigneeId: staffId,
        role: Role.staff,
        resolutionPhoto: resolutionPhoto(),
        resolvedAt: now,
        note: 'a' * 501,
      );
      expect(result, isA<Failure<Report, DomainError>>());
    });
  });

  group('restore', () {
    final reportId = (ReportId.create(
      'd4816d0a-cd8e-4442-98c0-65d3ba11be70',
    ) as Success<ReportId, DomainError>).value;
    final reporter =
        (UserId.create(reporterId) as Success<UserId, DomainError>).value;
    final photo = (Photo.create(
      url: '/files/lamba.jpg',
      contentType: 'image/jpeg',
      sizeBytes: 812345,
    ) as Success<Photo, DomainError>).value;
    final location = (Location.create(
      latitude: 36.5871,
      longitude: 36.1742,
      source: 'Gps',
    ) as Success<Location, DomainError>).value;

    test('storedAssignedReport_restoresEveryField', () {
      final report = Report.restore(
        id: reportId,
        reporterId: reporter,
        assigneeId: staffId,
        category: Category.ariza,
        description: 'B blok lambası yanmıyor',
        photo: photo,
        location: location,
        status: ReportStatus.ustlenildi,
        createdAt: now,
        takenAt: now,
      );

      expect(report.id.value, reportId.value);
      expect(report.status, ReportStatus.ustlenildi);
      expect(report.assigneeId?.value, staffId.value);
      expect(report.takenAt, now);
      expect(report.resolvedAt, isNull);
    });

    test('storedResolvedReport_restoresResolution', () {
      final report = Report.restore(
        id: reportId,
        reporterId: reporter,
        assigneeId: staffId,
        category: Category.ariza,
        description: 'B blok lambası yanmıyor',
        photo: photo,
        location: location,
        status: ReportStatus.cozuldu,
        createdAt: now,
        takenAt: now,
        resolvedAt: now,
        resolutionPhoto: photo,
        resolutionNote: 'Lamba değişti',
      );

      expect(report.status, ReportStatus.cozuldu);
      expect(report.resolutionPhoto?.url, photo.url);
      expect(report.resolutionNote, 'Lamba değişti');
    });

    test('restoredAssignedReport_canResolve', () {
      final report = Report.restore(
        id: reportId,
        reporterId: reporter,
        assigneeId: staffId,
        category: Category.ariza,
        description: 'B blok lambası yanmıyor',
        photo: photo,
        location: location,
        status: ReportStatus.ustlenildi,
        createdAt: now,
        takenAt: now,
      );

      final result = report.resolve(
        assigneeId: staffId,
        role: Role.staff,
        resolutionPhoto: photo,
        resolvedAt: now,
      );

      expect(result, isA<Success<Report, DomainError>>());
    });
  });
}
