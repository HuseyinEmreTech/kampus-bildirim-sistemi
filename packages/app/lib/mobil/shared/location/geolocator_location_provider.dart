import 'package:geolocator/geolocator.dart';

import 'location_source.dart';

/// GPS bu sürede konum vermezse "alınamadı" sayılır; kullanıcı bina
/// listesine geçebilir.
const _gpsTimeout = Duration(seconds: 15);

/// Enlem ve boylam.
typedef GpsPosition = ({double latitude, double longitude});

/// Telefonun gerçek GPS konumu (`geolocator`).
///
/// Konum kapalıysa ya da alınamazsa [GpsUnavailable]; izin verilmezse
/// [GpsDenied] döner (ekran bina listesini önerir). Eklentinin hataları
/// burada sonuca çevrilir; ekran istisna görmez. Testte dört çağrının
/// sahtesi verilir.
class GeolocatorLocationProvider implements LocationProvider {
  GeolocatorLocationProvider({
    Future<bool> Function()? isServiceEnabled,
    Future<LocationPermission> Function()? checkPermission,
    Future<LocationPermission> Function()? requestPermission,
    Future<GpsPosition> Function()? getPosition,
  }) : _isServiceEnabled =
           isServiceEnabled ?? Geolocator.isLocationServiceEnabled,
       _checkPermission = checkPermission ?? Geolocator.checkPermission,
       _requestPermission = requestPermission ?? Geolocator.requestPermission,
       _getPosition = getPosition ?? _currentPosition;

  final Future<bool> Function() _isServiceEnabled;
  final Future<LocationPermission> Function() _checkPermission;
  final Future<LocationPermission> Function() _requestPermission;
  final Future<GpsPosition> Function() _getPosition;

  @override
  Future<GpsResult> current() async {
    try {
      if (!await _isServiceEnabled()) return const GpsUnavailable();
      switch (await _permission()) {
        case LocationPermission.denied || LocationPermission.deniedForever:
          return const GpsDenied();
        case LocationPermission.whileInUse ||
            LocationPermission.always ||
            LocationPermission.unableToDetermine:
          final position = await _getPosition();
          return GpsFix(
            latitude: position.latitude,
            longitude: position.longitude,
          );
      }
    } on Exception {
      // Zaman aşımı, konumun bu sırada kapanması, eksik izin tanımı.
      return const GpsUnavailable();
    }
  }

  /// İzin henüz sorulmadıysa (ya da bir kez reddedildiyse) bir kez sorar;
  /// "bir daha sorma" denmişse sormaz.
  Future<LocationPermission> _permission() async {
    final permission = await _checkPermission();
    if (permission != LocationPermission.denied) return permission;
    return _requestPermission();
  }
}

Future<GpsPosition> _currentPosition() async {
  final position = await Geolocator.getCurrentPosition(
    locationSettings: const LocationSettings(
      accuracy: LocationAccuracy.high,
      timeLimit: _gpsTimeout,
    ),
  );
  return (latitude: position.latitude, longitude: position.longitude);
}
