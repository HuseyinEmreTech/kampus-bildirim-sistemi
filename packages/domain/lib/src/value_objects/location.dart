import '../core/domain_error.dart';
import '../core/result.dart';
import 'enums.dart';

final class Location {
  const Location._({
    required this.latitude,
    required this.longitude,
    required this.source,
    this.place,
    this.buildingId,
  });

  final double latitude;
  final double longitude;
  final String? place;
  final LocationSource source;
  final String? buildingId;

  static Result<Location, DomainError> create({
    required double latitude,
    required double longitude,
    required String source,
    String? place,
    String? buildingId,
  }) {
    if (latitude < -90 || latitude > 90) {
      return const Failure(
        InvalidLocation('latitude -90..90 aralığında olmalı'),
      );
    }
    if (longitude < -180 || longitude > 180) {
      return const Failure(
        InvalidLocation('longitude -180..180 aralığında olmalı'),
      );
    }

    final sourceValue = switch (source.toLowerCase()) {
      'gps' => LocationSource.gps,
      'building' => LocationSource.building,
      _ => null,
    };
    if (sourceValue == null) {
      return const Failure(
        InvalidLocation('source yalnızca Gps veya Building olabilir'),
      );
    }

    if (sourceValue == LocationSource.building) {
      final trimmedBuildingId = buildingId?.trim();
      if (trimmedBuildingId == null || trimmedBuildingId.isEmpty) {
        return const Failure(
          InvalidLocation('Building kaynağında buildingId zorunlu'),
        );
      }
    }

    final trimmedPlace = place?.trim();

    return Success(
      Location._(
        latitude: latitude,
        longitude: longitude,
        source: sourceValue,
        place: trimmedPlace,
        buildingId: buildingId?.trim(),
      ),
    );
  }
}
