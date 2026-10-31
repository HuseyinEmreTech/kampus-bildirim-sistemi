import 'package:campus_infrastructure/campus_infrastructure.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../http/json_http.dart';

/// `GET /api/buildings`: bina listesi (konum izni yokken seçim için).
class BuildingEndpoints {
  BuildingEndpoints(this._buildings);

  final BuildingRepositoryImpl _buildings;

  Router get router => Router()
    ..get('/api/buildings', _list)
    ..get('/api/buildings/<id>', _detail);

  Future<Response> _list(Request request) async {
    final buildings = await _buildings.list();
    return jsonResponse(200, {
      'items': [for (final building in buildings) _toJson(building)],
    });
  }

  Future<Response> _detail(Request request) async {
    final building = await _buildings.findById(request.params['id']!);
    if (building == null) {
      return errorResponse(404, 'NOT_FOUND', 'Bina bulunamadı.');
    }
    return jsonResponse(200, _toJson(building));
  }

  static Map<String, Object?> _toJson(BuildingRecord building) => {
    'buildingId': building.buildingId,
    'name': building.name,
    'latitude': building.latitude,
    'longitude': building.longitude,
  };
}
