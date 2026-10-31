import 'package:campus_infrastructure/campus_infrastructure.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../http/json_http.dart';

/// `GET /api/buildings`: bina listesi (konum izni yokken seçim için).
class BuildingEndpoints {
  BuildingEndpoints(this._buildings);

  final BuildingRepositoryImpl _buildings;

  Router get router => Router()..get('/api/buildings', _list);

  Future<Response> _list(Request request) async {
    final buildings = await _buildings.list();
    return jsonResponse(200, {
      'items': [
        for (final building in buildings)
          {
            'buildingId': building.buildingId,
            'name': building.name,
            'latitude': building.latitude,
            'longitude': building.longitude,
          },
      ],
    });
  }
}
