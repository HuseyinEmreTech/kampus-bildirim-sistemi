import 'dart:async';

import 'package:campus_app/mobil/shared/location/geolocator_location_provider.dart';
import 'package:campus_app/mobil/shared/location/location_source.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';

const campusPoint = (latitude: 36.58, longitude: 36.17);

/// Geolocator'ın dört çağrısının sahtesi; isteği ve konum alınmasını sayar.
class FakeGeolocator {
  FakeGeolocator({
    this.serviceEnabled = true,
    this.permission = LocationPermission.whileInUse,
    this.afterRequest = LocationPermission.whileInUse,
    this.positionError,
  });

  final bool serviceEnabled;
  final LocationPermission permission;
  final LocationPermission afterRequest;
  final Object? positionError;
  int requests = 0;
  int positionCalls = 0;

  GeolocatorLocationProvider provider() => GeolocatorLocationProvider(
    isServiceEnabled: () async => serviceEnabled,
    checkPermission: () async => permission,
    requestPermission: () async {
      requests++;
      return afterRequest;
    },
    getPosition: () async {
      positionCalls++;
      final error = positionError;
      if (error != null) throw error;
      return campusPoint;
    },
  );
}

/// Eklentinin platform tarafının sahtesi; varsayılan sağlayıcının gerçek
/// `Geolocator` çağrılarını sınamak için.
class FakeGeolocatorPlatform extends GeolocatorPlatform {
  @override
  Future<bool> isLocationServiceEnabled() async => true;

  @override
  Future<LocationPermission> checkPermission() async =>
      LocationPermission.whileInUse;

  @override
  Future<LocationPermission> requestPermission() async =>
      LocationPermission.whileInUse;

  @override
  Future<Position> getCurrentPosition({
    LocationSettings? locationSettings,
  }) async => Position(
    latitude: campusPoint.latitude,
    longitude: campusPoint.longitude,
    timestamp: DateTime(2026, 10, 27),
    accuracy: 5,
    altitude: 0,
    altitudeAccuracy: 0,
    heading: 0,
    headingAccuracy: 0,
    speed: 0,
    speedAccuracy: 0,
  );
}

void main() {
  test('defaultProvider_usesGeolocatorPlugin', () async {
    GeolocatorPlatform.instance = FakeGeolocatorPlatform();

    final result = await GeolocatorLocationProvider().current();

    expect((result as GpsFix).latitude, campusPoint.latitude);
  });

  test('current_returnsFix_whenAlwaysAllowed', () async {
    final fake = FakeGeolocator(permission: LocationPermission.always);

    final result = await fake.provider().current();

    expect(result, isA<GpsFix>());
  });

  test('current_returnsFix_whenAllowed', () async {
    final fake = FakeGeolocator();

    final result = await fake.provider().current();

    final fix = result as GpsFix;
    expect(fix.latitude, campusPoint.latitude);
    expect(fix.longitude, campusPoint.longitude);
    expect(fake.requests, 0);
  });

  test('current_asksPermission_whenNotYetAsked', () async {
    final fake = FakeGeolocator(permission: LocationPermission.denied);

    final result = await fake.provider().current();

    expect(fake.requests, 1);
    expect(result, isA<GpsFix>());
  });

  test('current_returnsDenied_whenUserRefuses', () async {
    final fake = FakeGeolocator(
      permission: LocationPermission.denied,
      afterRequest: LocationPermission.denied,
    );

    final result = await fake.provider().current();

    expect(result, isA<GpsDenied>());
    expect(fake.positionCalls, 0);
  });

  test('current_returnsDenied_withoutAsking_whenDeniedForever', () async {
    final fake = FakeGeolocator(permission: LocationPermission.deniedForever);

    final result = await fake.provider().current();

    expect(result, isA<GpsDenied>());
    expect(fake.requests, 0);
  });

  test('current_returnsUnavailable_whenLocationServiceOff', () async {
    final fake = FakeGeolocator(serviceEnabled: false);

    final result = await fake.provider().current();

    expect(result, isA<GpsUnavailable>());
    expect(fake.positionCalls, 0);
  });

  test('current_returnsUnavailable_whenPositionFails', () async {
    for (final error in [
      TimeoutException('GPS yanıt vermedi'),
      const LocationServiceDisabledException(),
    ]) {
      final fake = FakeGeolocator(positionError: error);

      final result = await fake.provider().current();

      expect(result, isA<GpsUnavailable>(), reason: '$error');
    }
  });
}
