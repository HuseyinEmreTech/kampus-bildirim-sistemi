import '../database/database.dart';
import '../database/uuid_format.dart';

/// Kampüs binası. Domain'deki `Building` (#15) gelince onunla değişecek.
typedef BuildingRecord = ({
  String buildingId,
  String name,
  double latitude,
  double longitude,
});

/// Binaların PostgreSQL tarafı (`GET /api/buildings`, Rule 06 bina kontrolü).
/// `BuildingRepository` arayüzü (#15) gelince onu uygular.
class BuildingRepositoryImpl {
  BuildingRepositoryImpl(this._db);

  final Database _db;

  static const _columns = 'building_id::text, name, latitude, longitude';
  // Türkçe sıralama: veritabanının varsayılanı bayt sırası olduğu için "Çarşı"
  // "Zz"den sonra gelirdi. `tr-x-icu` postgres:16-alpine imajında var.
  static const _listSql =
      'SELECT $_columns FROM buildings ORDER BY name COLLATE "tr-x-icu"';
  static const _byIdSql =
      'SELECT $_columns FROM buildings WHERE building_id = \$1';

  /// Bütün binalar, ada göre sıralı. Kampüste az bina olduğu için sayfalanmaz.
  Future<List<BuildingRecord>> list() async {
    final rows = await _db.execute(_listSql);
    return rows.map(_toBuilding).toList();
  }

  /// Bildirimde seçilen bina var mı (Rule 06)? UUID değilse ya da yoksa `null`.
  Future<BuildingRecord?> findById(String buildingId) async {
    if (!isUuid(buildingId)) return null;
    final rows = await _db.execute(_byIdSql, [buildingId]);
    if (rows.isEmpty) return null;
    return _toBuilding(rows.single);
  }

  BuildingRecord _toBuilding(List<Object?> row) {
    final [id, name, latitude, longitude] = row;
    return (
      buildingId: id! as String,
      name: name! as String,
      latitude: latitude! as double,
      longitude: longitude! as double,
    );
  }
}
