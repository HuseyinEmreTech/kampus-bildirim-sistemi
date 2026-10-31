/// Kampüs sınırını tutan ortam değişkenleri (.env.example). Dikdörtgenin
/// güneybatı ve kuzeydoğu köşeleri, ondalık noktalı derece (ör. `36.5850`).
const campusSouthWestLatitudeKey = 'CAMPUS_SW_LAT';
const campusSouthWestLongitudeKey = 'CAMPUS_SW_LNG';
const campusNorthEastLatitudeKey = 'CAMPUS_NE_LAT';
const campusNorthEastLongitudeKey = 'CAMPUS_NE_LNG';

/// Enlem -90..90, boylam -180..180 derece (03-domain-design, Location).
const maxAbsLatitude = 90.0;
const maxAbsLongitude = 180.0;

/// Kampüs dikdörtgeni. Bir konumun içinde olup olmadığına domain bakar (Rule 06);
/// burası yalnızca yapılandırmadan okur. Domain'deki karşılığı (#15) gelince
/// onunla değişecek.
typedef CampusBounds = ({
  double southWestLatitude,
  double southWestLongitude,
  double northEastLatitude,
  double northEastLongitude,
});

/// Değer neden kabul edilmedi.
enum CampusBoundsError { missing, notANumber, outOfRange, notOrdered }

sealed class CampusBoundsResult {
  const CampusBoundsResult();
}

final class CampusBoundsLoaded extends CampusBoundsResult {
  const CampusBoundsLoaded(this.bounds);

  final CampusBounds bounds;
}

/// [key] hangi değişkenin düzeltilmesi gerektiğini söyler; sunucu açılırken
/// bunu günlüğe yazıp durur.
final class CampusBoundsInvalid extends CampusBoundsResult {
  const CampusBoundsInvalid(this.key, this.reason);

  final String key;
  final CampusBoundsError reason;
}

/// Kampüs sınırını ortam değişkenlerinden okur. Sunucu `Platform.environment`
/// verir; testler elle hazırlanmış bir map verir.
CampusBoundsResult loadCampusBounds(Map<String, String> environment) {
  final values = <String, double>{};
  for (final (key, limit) in [
    (campusSouthWestLatitudeKey, maxAbsLatitude),
    (campusSouthWestLongitudeKey, maxAbsLongitude),
    (campusNorthEastLatitudeKey, maxAbsLatitude),
    (campusNorthEastLongitudeKey, maxAbsLongitude),
  ]) {
    final text = environment[key]?.trim() ?? '';
    if (text.isEmpty) {
      return CampusBoundsInvalid(key, CampusBoundsError.missing);
    }
    final value = double.tryParse(text);
    if (value == null || !value.isFinite) {
      return CampusBoundsInvalid(key, CampusBoundsError.notANumber);
    }
    if (value.abs() > limit) {
      return CampusBoundsInvalid(key, CampusBoundsError.outOfRange);
    }
    values[key] = value;
  }

  // Köşeler yer değiştirirse dikdörtgen boş kalır ve her konum reddedilir.
  final bounds = (
    southWestLatitude: values[campusSouthWestLatitudeKey]!,
    southWestLongitude: values[campusSouthWestLongitudeKey]!,
    northEastLatitude: values[campusNorthEastLatitudeKey]!,
    northEastLongitude: values[campusNorthEastLongitudeKey]!,
  );
  if (bounds.northEastLatitude <= bounds.southWestLatitude) {
    return const CampusBoundsInvalid(
      campusNorthEastLatitudeKey,
      CampusBoundsError.notOrdered,
    );
  }
  if (bounds.northEastLongitude <= bounds.southWestLongitude) {
    return const CampusBoundsInvalid(
      campusNorthEastLongitudeKey,
      CampusBoundsError.notOrdered,
    );
  }
  return CampusBoundsLoaded(bounds);
}
