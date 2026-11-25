import 'dart:convert';

import 'package:campus_app/mobil/shared/api/api_client.dart';
import 'package:campus_app/mobil/shared/location/http_buildings_source.dart';
import 'package:campus_app/mobil/shared/location/location_source.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

({ApiClient api, List<http.Request> requests}) apiWith(
  http.Response Function() respond,
) {
  final requests = <http.Request>[];
  final client = MockClient((request) async {
    requests.add(request);
    return respond();
  });
  final api = ApiClient(
    baseUrl: Uri.parse('http://sunucu.test'),
    token: () => 'belirtec',
    client: client,
  );
  return (api: api, requests: requests);
}

http.Response json(Object body, int status) => http.Response(
  jsonEncode(body),
  status,
  headers: {'content-type': 'application/json; charset=utf-8'},
);

void main() {
  test('buildings_fetch_readsList_orFails', () async {
    // Arrange
    final ok = apiWith(
      () => json({
        'items': [
          {
            'buildingId': 'b1',
            'name': 'A Blok',
            'latitude': 36.58,
            'longitude': 36.17,
          },
        ],
      }, 200),
    );
    final bad = apiWith(() => json({'items': 'bozuk'}, 200));

    // Act
    final loaded = await HttpBuildingsSource(ok.api).fetch();
    final failed = await HttpBuildingsSource(bad.api).fetch();

    // Assert
    expect(ok.requests.single.url.path, '/api/buildings');
    expect((loaded as BuildingsLoaded).buildings.single.name, 'A Blok');
    expect(failed, isA<BuildingsFailed>());
  });
}
