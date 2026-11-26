import 'dart:convert';

import 'package:campus_app/mobil/features/reports/data/http_reports_source.dart';
import 'package:campus_app/mobil/features/reports/data/report_list_item.dart';
import 'package:campus_app/mobil/features/reports/data/reports_source.dart';
import 'package:campus_app/mobil/shared/api/api_client.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

/// Gelen istekleri kaydeden ve verilen yanıtı döndüren sahte sunucu.
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

/// Sunucunun liste yanıtı (`reportPageToJson`), sahte veri.
Map<String, Object?> page(List<Map<String, Object?>> items) => {
  'items': items,
  'page': 1,
  'pageSize': 20,
  'total': items.length,
};

Map<String, Object?> summary({
  String place = 'B Blok 2. kat',
  String? buildingName,
  String? photoUrl = '/files/r1/foto.jpg',
}) => {
  'reportId': 'r1',
  'category': 'Ariza',
  'description': 'Koridor lambası yanmıyor',
  'status': 'Ustlenildi',
  'place': place,
  'buildingName': buildingName,
  'photoUrl': photoUrl,
  'assigneeId': 'g1',
  'createdAt': '2026-10-15T09:15:00.000Z',
};

void main() {
  test('list_parsesPage', () async {
    final (:api, :requests) = apiWith(() => json(page([summary()]), 200));

    final result = await HttpReportsSource(api)
        .fetchPage(offset: 20, limit: 20);

    final item = (result as ReportsPageLoaded).items.single;
    expect(requests.single.url.path, '/api/me/reports');
    expect(requests.single.url.queryParameters, {
      'page': '2',
      'pageSize': '20',
    });
    expect(item.id, 'r1');
    expect(item.category, ReportCategory.ariza);
    expect(item.status, ReportStatus.ustlenildi);
    expect(item.place, 'B Blok 2. kat');
    expect(item.description, 'Koridor lambası yanmıyor');
    expect(item.imageUrl, 'http://sunucu.test/files/r1/foto.jpg');
    expect(item.createdAt, DateTime.utc(2026, 10, 15, 9, 15));
  });

  test('fetchPage_usesBuildingName_whenPlaceEmpty', () async {
    final (:api, requests: _) = apiWith(
      () => json(
        page([summary(place: '', buildingName: 'Kütüphane', photoUrl: null)]),
        200,
      ),
    );

    final result = await HttpReportsSource(api).fetchPage(offset: 0, limit: 20);

    final item = (result as ReportsPageLoaded).items.single;
    expect(item.place, 'Kütüphane');
    expect(item.imageUrl, isNull);
  });

  test('fetchPage_fails_onErrorOrUnexpectedBody', () async {
    for (final response in [
      json({
        'error': {'code': 'FORBIDDEN', 'message': 'Yetki yok'},
      }, 403),
      json({'items': 'bozuk'}, 200),
      json(
        page([
          {...summary(), 'category': 'Bilinmeyen'},
        ]),
        200,
      ),
    ]) {
      final (:api, requests: _) = apiWith(() => response);

      final result = await HttpReportsSource(api)
          .fetchPage(offset: 0, limit: 20);

      expect(result, isA<ReportsPageFailed>(), reason: response.body);
    }
  });
}
