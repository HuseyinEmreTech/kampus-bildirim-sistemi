import 'dart:convert';

import 'package:campus_server/src/endpoint/building_endpoints.dart';
import 'package:campus_server/src/middleware/auth_middleware.dart';
import 'package:campus_server/src/service/token_service.dart';
import 'package:shelf/shelf.dart';
import 'package:test/test.dart';

import '../support/fake_buildings.dart';
import '../support/test_values.dart';

final tokens = TokenService(testJwtConfig);

late FakeBuildings buildings;
late Handler app;

void main() {
  setUp(() {
    buildings = FakeBuildings();
    // Sunucudaki gibi: adres, auth middleware'in arkasında.
    app = const Pipeline()
        .addMiddleware(authMiddleware(tokens))
        .addHandler(BuildingEndpoints(buildings).router.call);
  });

  test('list_returnsAllBuildingsAsItems', () async {
    buildings.buildings.addAll([
      (
        buildingId: 'c0000000-0000-4000-8000-000000000001',
        name: 'A Blok',
        latitude: 36.5871,
        longitude: 36.1742,
      ),
      (
        buildingId: 'c0000000-0000-4000-8000-000000000002',
        name: 'Kütüphane',
        latitude: 36.5880,
        longitude: 36.1755,
      ),
    ]);

    final res = await app(_get(tokens.createAccessToken(studentId, 'Student')));

    expect(res.statusCode, 200);
    expect(jsonDecode(await res.readAsString()), {
      'items': [
        {
          'buildingId': 'c0000000-0000-4000-8000-000000000001',
          'name': 'A Blok',
          'latitude': 36.5871,
          'longitude': 36.1742,
        },
        {
          'buildingId': 'c0000000-0000-4000-8000-000000000002',
          'name': 'Kütüphane',
          'latitude': 36.5880,
          'longitude': 36.1755,
        },
      ],
    });
  });

  test('list_noBuildings_returnsEmptyItems', () async {
    final res = await app(_get(tokens.createAccessToken(staffId, 'Staff')));

    expect(res.statusCode, 200);
    expect(jsonDecode(await res.readAsString()), {'items': <Object?>[]});
  });

  test('list_withoutToken_returns401', () async {
    final res = await app(_get(null));

    expect(res.statusCode, 401);
  });

  test('detail_existingBuilding_returnsIt', () async {
    buildings.buildings.add((
      buildingId: 'c0000000-0000-4000-8000-000000000001',
      name: 'A Blok',
      latitude: 36.5871,
      longitude: 36.1742,
    ));

    final res = await app(
      _get(
        tokens.createAccessToken(studentId, 'Student'),
        path: 'api/buildings/c0000000-0000-4000-8000-000000000001',
      ),
    );

    expect(res.statusCode, 200);
    expect(jsonDecode(await res.readAsString()), {
      'buildingId': 'c0000000-0000-4000-8000-000000000001',
      'name': 'A Blok',
      'latitude': 36.5871,
      'longitude': 36.1742,
    });
  });

  test('detail_unknownBuilding_returns404', () async {
    final res = await app(
      _get(
        tokens.createAccessToken(studentId, 'Student'),
        path: 'api/buildings/c0000000-0000-4000-8000-000000000099',
      ),
    );

    expect(res.statusCode, 404);
    final body = jsonDecode(await res.readAsString()) as Map<String, Object?>;
    expect((body['error']! as Map<String, Object?>)['code'], 'NOT_FOUND');
  });

  test('detail_withoutToken_returns401', () async {
    final res = await app(
      _get(null, path: 'api/buildings/c0000000-0000-4000-8000-000000000001'),
    );

    expect(res.statusCode, 401);
  });
}

Request _get(String? token, {String path = 'api/buildings'}) => Request(
  'GET',
  Uri.parse('http://localhost/$path'),
  headers: {if (token != null) 'authorization': 'Bearer $token'},
);
