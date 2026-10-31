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
