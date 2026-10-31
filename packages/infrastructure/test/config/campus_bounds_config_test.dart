// Veritabanı gerektirmez; CI'da (-x db) da çalışır.
import 'package:campus_infrastructure/campus_infrastructure.dart';
import 'package:test/test.dart';

// .env.example'daki örnek dikdörtgen: seed ve demo verisindeki binaları kapsar.
const _valid = {
  campusSouthWestLatitudeKey: '36.5840',
  campusSouthWestLongitudeKey: '36.1715',
  campusNorthEastLatitudeKey: '36.5900',
  campusNorthEastLongitudeKey: '36.1770',
};

Map<String, String> _with(String key, String? value) {
  final env = {..._valid};
  if (value == null) {
    env.remove(key);
  } else {
    env[key] = value;
  }
  return env;
}

Matcher _invalid(String key, CampusBoundsError reason) =>
    isA<CampusBoundsInvalid>()
        .having((r) => r.key, 'key', key)
        .having((r) => r.reason, 'reason', reason);

void main() {
  test('load_validValues_returnsBounds', () {
    final result = loadCampusBounds(_valid);

    expect(result, isA<CampusBoundsLoaded>());
    final bounds = (result as CampusBoundsLoaded).bounds;
    expect(bounds.southWestLatitude, 36.5840);
    expect(bounds.southWestLongitude, 36.1715);
    expect(bounds.northEastLatitude, 36.5900);
    expect(bounds.northEastLongitude, 36.1770);
  });

  test('load_valueWithSpaces_isTrimmed', () {
    final result = loadCampusBounds(
      _with(campusNorthEastLatitudeKey, ' 36.5900 '),
    );

    expect(result, isA<CampusBoundsLoaded>());
  });

  test('load_missingValue_returnsMissing', () {
    expect(
      loadCampusBounds(_with(campusSouthWestLatitudeKey, null)),
      _invalid(campusSouthWestLatitudeKey, CampusBoundsError.missing),
    );
    expect(
      loadCampusBounds(_with(campusSouthWestLatitudeKey, '  ')),
      _invalid(campusSouthWestLatitudeKey, CampusBoundsError.missing),
    );
  });

  // Virgüllü yazım (Türkçe ondalık) sessizce yanlış okunmasın.
  test('load_notANumber_returnsNotANumber', () {
    expect(
      loadCampusBounds(_with(campusNorthEastLongitudeKey, '36,1770')),
      _invalid(campusNorthEastLongitudeKey, CampusBoundsError.notANumber),
    );
    expect(
      loadCampusBounds(_with(campusNorthEastLongitudeKey, 'NaN')),
      _invalid(campusNorthEastLongitudeKey, CampusBoundsError.notANumber),
    );
  });

  test('load_latitudeOutsideEarth_returnsOutOfRange', () {
    expect(
      loadCampusBounds(_with(campusNorthEastLatitudeKey, '90.1')),
      _invalid(campusNorthEastLatitudeKey, CampusBoundsError.outOfRange),
    );
  });

  test('load_longitudeOutsideEarth_returnsOutOfRange', () {
    expect(
      loadCampusBounds(_with(campusSouthWestLongitudeKey, '-180.5')),
      _invalid(campusSouthWestLongitudeKey, CampusBoundsError.outOfRange),
    );
  });

  // Köşeler yer değiştirirse dikdörtgen boş kalır, her bildirim reddedilirdi.
  test('load_cornersSwapped_returnsNotOrdered', () {
    expect(
      loadCampusBounds(_with(campusNorthEastLatitudeKey, '36.5840')),
      _invalid(campusNorthEastLatitudeKey, CampusBoundsError.notOrdered),
    );
    expect(
      loadCampusBounds(_with(campusNorthEastLongitudeKey, '36.1700')),
      _invalid(campusNorthEastLongitudeKey, CampusBoundsError.notOrdered),
    );
  });
}
