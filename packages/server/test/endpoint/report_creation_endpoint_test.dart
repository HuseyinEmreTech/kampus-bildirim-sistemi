import 'dart:convert';

import 'package:campus_application/campus_application.dart';
import 'package:campus_domain/campus_domain.dart';
import 'package:campus_server/src/endpoint/report_creation_endpoint.dart';
import 'package:campus_server/src/middleware/auth_middleware.dart';
import 'package:campus_server/src/service/token_service.dart';
import 'package:shelf/shelf.dart';
import 'package:test/test.dart';

import '../support/fake_buildings.dart';
import '../support/fake_photos.dart';
import '../support/fake_report_repository.dart';
import '../support/multipart_body.dart';
import '../support/test_values.dart';

const buildingId = 'c0000000-0000-4000-8000-000000000001';
const jpeg = [0xFF, 0xD8, 0xFF, 0xE0, 1, 2, 3, 4];

final tokens = TokenService(testJwtConfig);
final studentToken = tokens.createAccessToken(studentId, 'Student');

late FakeReportRepository reports;
late FakePhotos photos;
late Handler app;

void main() {
  setUp(() {
    reports = FakeReportRepository();
    photos = FakePhotos();
    final buildings = FakeBuildings()
      ..buildings.add((
        buildingId: buildingId,
        name: 'B Blok',
        latitude: 36.5875,
        longitude: 36.1750,
      ));
    app = const Pipeline()
        .addMiddleware(authMiddleware(tokens))
        .addHandler(
          ReportCreationEndpoint(
            createReport: ReportCreateUseCase(
              reports,
              FixedClock(DateTime.utc(2026, 10, 24, 22)),
            ),
            photos: photos,
            buildings: buildings,
          ).router.call,
        );
  });

  test('create_gpsWithPhoto_returns201AndSavesReport', () async {
    final res = await app(_create(_gpsFields()));

    expect(res.statusCode, 201);
    final body = jsonDecode(await res.readAsString()) as Map<String, Object?>;
    final created = reports.lastCreated!;
    expect(body, {'reportId': created.id.value, 'status': 'Yeni'});
    expect(created.reporterId.value, studentId);
    expect(created.category, Category.ariza);
    expect(created.photo.url, photos.saved.single);
    expect(created.location.latitude, 36.5871);
    expect(created.location.place, 'B blok 2. kat');
    expect(photos.deleted, isEmpty);
  });

  test('create_buildingSource_usesBuildingCoordinates', () async {
    final res = await app(
      _create([
        textPart('category', 'Temizlik'),
        textPart('description', 'Koridor çok kirli'),
        textPart('locationSource', 'Building'),
        textPart('buildingId', buildingId),
        filePart('photo', 'image/jpeg', jpeg),
      ]),
    );

    expect(res.statusCode, 201);
    expect(reports.lastCreated!.location.latitude, 36.5875);
    expect(reports.lastCreated!.location.buildingId, buildingId);
  });

  test('create_unknownBuilding_returns422AndDeletesPhoto', () async {
    final res = await app(
      _create([
        textPart('category', 'Temizlik'),
        textPart('description', 'Koridor çok kirli'),
        textPart('locationSource', 'Building'),
        textPart('buildingId', 'c0000000-0000-4000-8000-000000000099'),
        filePart('photo', 'image/jpeg', jpeg),
      ]),
    );

    expect(res.statusCode, 422);
    expect((await _errorOf(res))['code'], 'BUILDING_NOT_FOUND');
    expect(photos.deleted, photos.saved);
    expect(reports.lastCreated, isNull);
  });

  test('create_withoutPhoto_returns400', () async {
    final fields = _gpsFields()..removeLast();
    final res = await app(_create(fields));

    expect(res.statusCode, 400);
    expect((await _errorOf(res))['details'], 'photo');
  });

  test('create_withoutDescription_returns400AndDeletesPhoto', () async {
    final fields = _gpsFields()..removeAt(1);
    final res = await app(_create(fields));

    expect(res.statusCode, 400);
    expect((await _errorOf(res))['details'], 'description');
    expect(photos.deleted, photos.saved);
  });

  test('create_shortDescription_returns400FromDomain', () async {
    final fields = _gpsFields()..[1] = textPart('description', 'kısa');
    final res = await app(_create(fields));

    expect(res.statusCode, 400);
    expect((await _errorOf(res))['code'], 'VALIDATION_ERROR');
    expect(photos.deleted, photos.saved);
    expect(reports.lastCreated, isNull);
  });

  test('create_latitudeNotANumber_returns400', () async {
    final fields = _gpsFields()..[3] = textPart('latitude', 'kuzey');
    final res = await app(_create(fields));

    expect(res.statusCode, 400);
    expect((await _errorOf(res))['details'], 'latitude');
  });

  test('create_byStaff_returns403', () async {
    final staff = tokens.createAccessToken(staffId, 'Staff');
    final res = await app(_create(_gpsFields(), token: staff));

    expect(res.statusCode, 403);
    expect(photos.saved, isEmpty);
  });
}

/// Geçerli bir Gps bildirimi; fotoğraf son sırada.
List<TestPart> _gpsFields() => [
  textPart('category', 'Ariza'),
  textPart('description', 'B blok 2. kat koridor lambası yanmıyor'),
  textPart('locationSource', 'Gps'),
  textPart('latitude', '36.5871'),
  textPart('longitude', '36.1742'),
  textPart('place', 'B blok 2. kat'),
  filePart('photo', 'image/jpeg', jpeg),
];

Request _create(List<TestPart> parts, {String? token}) => multipartRequest(
  'POST',
  '/api/reports',
  parts,
  token: token ?? studentToken,
);

Future<Map<String, Object?>> _errorOf(Response res) async {
  final body = jsonDecode(await res.readAsString()) as Map<String, Object?>;
  return body['error']! as Map<String, Object?>;
}
