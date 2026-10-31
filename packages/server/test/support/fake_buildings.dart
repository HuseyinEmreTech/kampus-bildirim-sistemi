import 'package:campus_domain/campus_domain.dart';
import 'package:campus_infrastructure/campus_infrastructure.dart';

/// Bellek içi sahte bina deposu.
class FakeBuildings implements BuildingRepositoryImpl {
  final buildings = <BuildingRecord>[];

  @override
  Future<List<BuildingRecord>> list() async => buildings;

  @override
  Future<BuildingRecord?> findById(String buildingId) async =>
      buildings.where((b) => b.buildingId == buildingId).firstOrNull;
}

/// Hep aynı anı söyleyen saat; testte zaman belirsizliği olmasın.
class FixedClock implements Clock {
  FixedClock(this.time);

  final DateTime time;

  @override
  DateTime now() => time;
}
