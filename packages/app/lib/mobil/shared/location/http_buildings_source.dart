import '../api/api_client.dart';
import 'location_source.dart';

/// Bina listesi: `GET /api/buildings` (`{ items: [{ buildingId, name }] }`).
class HttpBuildingsSource implements BuildingsSource {
  HttpBuildingsSource(this._api);

  final ApiClient _api;

  @override
  Future<BuildingsResult> fetch() async {
    final response = await _api.get('/api/buildings');
    if (response case ApiSuccess(body: {'items': final List<Object?> items})) {
      final buildings = <Building>[];
      for (final item in items) {
        if (item case {
          'buildingId': final String id,
          'name': final String name,
        }) {
          buildings.add(Building(id: id, name: name));
        } else {
          return const BuildingsFailed();
        }
      }
      return BuildingsLoaded(buildings);
    }
    return const BuildingsFailed();
  }
}
