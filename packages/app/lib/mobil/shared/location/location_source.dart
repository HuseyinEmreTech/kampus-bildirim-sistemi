/// Kampüs binası (`GET /api/buildings`).
class Building {
  const Building({required this.id, required this.name});

  final String id;
  final String name;
}

/// Bildirimin konumu: GPS noktası ya da seçilen bina (05-api-design:
/// `locationSource=Gps` ya da `Building`). Kampüs sınırı sunucuda (Rule 06).
sealed class LocationChoice {
  const LocationChoice();
}

final class GpsChoice extends LocationChoice {
  const GpsChoice({required this.latitude, required this.longitude});

  final double latitude;
  final double longitude;
}

final class BuildingChoice extends LocationChoice {
  const BuildingChoice(this.building);

  final Building building;
}

sealed class BuildingsResult {
  const BuildingsResult();
}

final class BuildingsLoaded extends BuildingsResult {
  const BuildingsLoaded(this.buildings);

  final List<Building> buildings;
}

final class BuildingsFailed extends BuildingsResult {
  const BuildingsFailed();
}

/// Bina listesini getiren kaynak; gerçek hali sunucu hazır olunca yazılacak.
abstract interface class BuildingsSource {
  Future<BuildingsResult> fetch();
}

/// Telefonun konumunu alma sonucu.
sealed class GpsResult {
  const GpsResult();
}

final class GpsFix extends GpsResult {
  const GpsFix({required this.latitude, required this.longitude});

  final double latitude;
  final double longitude;
}

final class GpsDenied extends GpsResult {
  const GpsDenied();
}

/// Konum kapalı ya da alınamadı.
final class GpsUnavailable extends GpsResult {
  const GpsUnavailable();
}

/// Telefonun GPS konumunu veren kaynak; gerçek hali
/// `GeolocatorLocationProvider`, testlerde sahtesi kullanılır.
abstract interface class LocationProvider {
  Future<GpsResult> current();
}
