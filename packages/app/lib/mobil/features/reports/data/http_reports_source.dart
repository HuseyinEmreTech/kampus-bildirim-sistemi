import '../../../shared/api/api_client.dart';
import 'report_json.dart';
import 'reports_source.dart';

/// Ekrandaki `offset`/`limit`'i sunucunun `page` (1'den) ve `pageSize`
/// parametrelerine çevirir (05-api-design).
Map<String, String> _pageQuery(int offset, int limit) => {
  'page': '${offset ~/ limit + 1}',
  'pageSize': '$limit',
};

Future<ReportsPageResult> _fetch(
  ApiClient api,
  String path,
  Map<String, String> query,
) async {
  final response = await api.get(path, query: query);
  if (response case ApiSuccess(:final body)) {
    final items = reportItemsFromJson(
      body,
      photoUrlOf: (photo) => api.url(photo).toString(),
    );
    if (items != null) return ReportsPageLoaded(items);
  }
  return const ReportsPageFailed();
}

/// Öğrencinin kendi bildirimleri: `GET /api/me/reports`.
class HttpReportsSource implements ReportsSource {
  HttpReportsSource(this._api);

  final ApiClient _api;

  @override
  Future<ReportsPageResult> fetchPage({
    required int offset,
    required int limit,
  }) => _fetch(_api, '/api/me/reports', _pageQuery(offset, limit));
}
