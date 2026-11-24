import 'dart:convert';
import 'dart:typed_data';

import 'package:campus_app/mobil/features/reports/data/http_report_creator.dart';
import 'package:campus_app/mobil/features/reports/data/new_report.dart';
import 'package:campus_app/mobil/features/reports/data/report_creator.dart';
import 'package:campus_app/mobil/features/reports/data/report_list_item.dart';
import 'package:campus_app/mobil/shared/api/api_client.dart';
import 'package:campus_app/mobil/shared/location/location_source.dart';
import 'package:campus_app/mobil/shared/photo/photo_picker.dart';
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

http.Response error(int status, String code, String message) => json({
  'error': {'code': code, 'message': message},
}, status);

/// JPEG imzasıyla başlayan sahte fotoğraf baytları.
final photo = PickedPhoto(
  bytes: Uint8List.fromList([0xFF, 0xD8, 0xFF, 0xE0, 1, 2, 3, 4]),
  contentType: 'image/jpeg',
);

NewReport report(LocationChoice location, {String? place = 'Kantin'}) =>
    NewReport(
      category: ReportCategory.temizlik,
      description: 'Kantin masaları kirli',
      photo: photo,
      location: location,
      place: place,
    );

/// Çok parçalı gövdede [name] alanının değeri.
String? fieldOf(http.Request request, String name) {
  final text = latin1.decode(request.bodyBytes);
  final match = RegExp('name="$name"\r\n\r\n([^\r]*)\r\n').firstMatch(text);
  return match?.group(1);
}

void main() {
  test('create_sendsMultipartFields', () async {
    final (:api, :requests) = apiWith(
      () => json({'reportId': 'r1', 'status': 'Yeni'}, 201),
    );

    final result = await HttpReportCreator(api)
        .create(report(const GpsChoice(latitude: 36.5871, longitude: 36.1742)));

    final request = requests.single;
    expect(result, isA<ReportCreated>());
    expect(request.method, 'POST');
    expect(request.url.path, '/api/reports');
    expect(request.headers['Content-Type'], startsWith('multipart/form-data'));
    expect(fieldOf(request, 'category'), 'Temizlik');
    expect(fieldOf(request, 'locationSource'), 'Gps');
    expect(fieldOf(request, 'latitude'), '36.5871');
    expect(fieldOf(request, 'place'), 'Kantin');
    final text = latin1.decode(request.bodyBytes);
    expect(text, contains('name="photo"; filename="foto.jpg"'));
    expect(text, contains('Content-Type: image/jpeg'));
    expect(request.headers['Authorization'], 'Bearer belirtec');
  });

  test('create_sendsBuilding_andMapsErrors', () async {
    final building = apiWith(() => json({'reportId': 'r1'}, 201));
    await HttpReportCreator(
      building.api,
    ).create(report(const BuildingChoice(Building(id: 'b1', name: 'A Blok'))));
    final down = apiWith(() => error(500, 'INTERNAL', 'Hata'));

    final downResult = await HttpReportCreator(down.api)
        .create(report(const GpsChoice(latitude: 0, longitude: 0)));

    expect(fieldOf(building.requests.single, 'locationSource'), 'Building');
    expect(fieldOf(building.requests.single, 'buildingId'), 'b1');
    expect(downResult, isA<ReportCreateFailed>());
  });

  test('create_mapsOutsideCampus422ToRejected', () async {
    final rejected = apiWith(
      () => error(422, 'OUTSIDE_CAMPUS', 'Konum kampüs dışında.'),
    );

    final result = await HttpReportCreator(rejected.api)
        .create(report(const GpsChoice(latitude: 0, longitude: 0)));

    expect((result as ReportRejected).message, 'Konum kampüs dışında.');
  });

  test('create_omitsPlace_whenEmpty', () async {
    // Arrange: yer tarifi isteğe bağlı (#198).
    final (:api, :requests) = apiWith(
      () => json({'reportId': 'r1', 'status': 'Yeni'}, 201),
    );

    // Act
    await HttpReportCreator(
      api,
    ).create(report(const GpsChoice(latitude: 1, longitude: 2), place: null));

    // Assert: boş alan gönderilmez.
    expect(fieldOf(requests.single, 'place'), isNull);
  });
}
