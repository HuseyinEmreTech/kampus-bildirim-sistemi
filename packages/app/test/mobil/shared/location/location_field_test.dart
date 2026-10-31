import 'package:campus_app/mobil/shared/location/location_field.dart';
import 'package:campus_app/mobil/shared/location/location_source.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeGps implements LocationProvider {
  FakeGps(this.result);

  final GpsResult result;

  @override
  Future<GpsResult> current() async => result;
}

/// Sırayla verilen sonuçları döndüren sahte bina listesi.
class FakeBuildings implements BuildingsSource {
  FakeBuildings(this.results);

  final List<BuildingsResult> results;

  @override
  Future<BuildingsResult> fetch() async => results.removeAt(0);
}

const buildings = BuildingsLoaded([
  Building(id: 'b1', name: 'A Blok'),
  Building(id: 'b2', name: 'Kütüphane'),
]);

final formKey = GlobalKey<FormState>();
final fieldKey = GlobalKey<FormFieldState<LocationChoice>>();

Future<void> pumpField(
  WidgetTester tester, {
  required GpsResult gps,
  List<BuildingsResult> buildingResults = const [buildings],
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Form(
          key: formKey,
          child: LocationField(
            key: fieldKey,
            gps: FakeGps(gps),
            buildings: FakeBuildings(List.of(buildingResults)),
          ),
        ),
      ),
    ),
  );
}

Future<void> tapAndSettle(WidgetTester tester, Finder finder) async {
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Future<void> chooseBuilding(WidgetTester tester, String name) async {
  await tapAndSettle(tester, find.byType(DropdownButton<Building>));
  await tapAndSettle(tester, find.text(name).last);
}

void main() {
  testWidgets('showsRequired_whenNothingChosen', (tester) async {
    await pumpField(tester, gps: const GpsDenied());

    formKey.currentState!.validate();
    await tester.pump();

    expect(
      find.text('Konum seçin: konumunuzu alın ya da bina seçin'),
      findsOneWidget,
    );
  });

  testWidgets('usesGps_whenFixAvailable', (tester) async {
    await pumpField(
      tester,
      gps: const GpsFix(latitude: 36.5871, longitude: 36.1742),
    );

    await tapAndSettle(tester, find.text('Konumumu al'));

    expect(find.text('Konum alındı'), findsOneWidget);
    expect(fieldKey.currentState!.value, isA<GpsChoice>());
    expect(formKey.currentState!.validate(), isTrue);
  });

  testWidgets('offersBuildings_whenPermissionDenied', (tester) async {
    await pumpField(tester, gps: const GpsDenied());

    await tapAndSettle(tester, find.text('Konumumu al'));
    expect(find.text('Konum izni verilmedi; bina seçin'), findsOneWidget);
    await chooseBuilding(tester, 'Kütüphane');

    final choice = fieldKey.currentState!.value;
    expect((choice as BuildingChoice).building.id, 'b2');
  });

  testWidgets('choosesBuilding_withoutTryingGps', (tester) async {
    await pumpField(tester, gps: const GpsUnavailable());

    await tapAndSettle(tester, find.text('Bina listesinden seç'));
    await chooseBuilding(tester, 'A Blok');

    expect(formKey.currentState!.validate(), isTrue);
  });

  testWidgets('retriesBuildings_whenListFails', (tester) async {
    await pumpField(
      tester,
      gps: const GpsUnavailable(),
      buildingResults: [const BuildingsFailed(), buildings],
    );

    await tapAndSettle(tester, find.text('Konumumu al'));
    expect(find.text('Bina listesi yüklenemedi'), findsOneWidget);
    await tapAndSettle(tester, find.text('Tekrar dene'));

    expect(find.byType(DropdownButton<Building>), findsOneWidget);
  });
}
