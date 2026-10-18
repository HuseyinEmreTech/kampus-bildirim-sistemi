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

  test('create_unknownSource_returnsInvalidLocation', () {
    final result = Location.create(
      latitude: 36.5871,
      longitude: 36.1742,
      source: 'Unknown',
    );
    expect(result, isA<Failure<Location, DomainError>>());
  });
}
