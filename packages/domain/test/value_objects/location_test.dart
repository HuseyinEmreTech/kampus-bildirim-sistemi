import 'package:campus_domain/campus_domain.dart';
import 'package:test/test.dart';

void main() {
  test('create_gps_returnsSuccess', () {
    final result = Location.create(
      latitude: 36.5871,
      longitude: 36.1742,
      source: 'Gps',
      place: 'B Blok',
    );
    expect(result, isA<Success<Location, DomainError>>());
  });

  test('create_buildingWithoutId_returnsInvalidLocation', () {
    final result = Location.create(
      latitude: 36.5871,
      longitude: 36.1742,
      source: 'Building',
    );
    expect(result, isA<Failure<Location, DomainError>>());
  });

  test('create_invalidLatitude_returnsInvalidLocation', () {
    final result = Location.create(
      latitude: 91,
      longitude: 36.1742,
      source: 'Gps',
    );
    expect(result, isA<Failure<Location, DomainError>>());
  });

  // #209: yer tarifi en fazla 100 karakter (03-domain-design, V1 VARCHAR(100)).
  test('place_over100_isRejected', () {
    final result = _gpsWithPlace('a' * 101);
    expect(result, isA<Failure<Location, DomainError>>());
    expect((result as Failure).error, isA<InvalidPlace>());
  });

  test('place_exactly100_isAccepted', () {
    final result = _gpsWithPlace('a' * 100);
    expect(result, isA<Success<Location, DomainError>>());
  });

  test('place_null_isAccepted', () {
    final result = _gpsWithPlace(null);
    expect(result, isA<Success<Location, DomainError>>());
  });

  // NaN ile her karşılaştırma false döner; aralık denetimi tek başına yakalamaz.
  test('location_nan_isRejected', () {
    final result = Location.create(
      latitude: double.nan,
      longitude: double.nan,
      source: 'Gps',
    );
    expect(result, isA<Failure<Location, DomainError>>());
  });

  test('location_infinity_isRejected', () {
    final result = Location.create(
      latitude: 36.5871,
      longitude: double.infinity,
      source: 'Gps',
    );
    expect(result, isA<Failure<Location, DomainError>>());
  });

  test('create_unknownSource_returnsInvalidLocation', () {
    final result = Location.create(
      latitude: 36.5871,
      longitude: 36.1742,
      source: 'Unknown',
    );
    expect(result, isA<Failure<Location, DomainError>>());
  });
}

Result<Location, DomainError> _gpsWithPlace(String? place) => Location.create(
  latitude: 36.5871,
  longitude: 36.1742,
  source: 'Gps',
  place: place,
);
