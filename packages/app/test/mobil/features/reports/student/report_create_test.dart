import 'dart:convert';

import 'package:campus_app/mobil/features/reports/data/new_report.dart';
import 'package:campus_app/mobil/features/reports/data/report_creator.dart';
import 'package:campus_app/mobil/features/reports/data/report_list_item.dart';
import 'package:campus_app/mobil/features/reports/presentation/student/report_create_screen.dart';
import 'package:campus_app/mobil/shared/location/location_source.dart';
import 'package:campus_app/mobil/shared/photo/photo_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Verilen sonucu döndüren ve gelen bildirimleri saklayan sahte kaynak.
class FakeReportCreator implements ReportCreator {
  FakeReportCreator(this.result);

  final ReportCreateResult result;
  final received = <NewReport>[];

  @override
  Future<ReportCreateResult> create(NewReport report) async {
    received.add(report);
    return result;
  }
}

final tinyPng = PickedPhoto(
  bytes: base64Decode(
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==',
  ),
  contentType: 'image/png',
);

class FakePicker implements PhotoPicker {
  @override
  Future<PhotoPickResult> pick(PhotoSource source) async =>
      PhotoPicked(tinyPng);
}

class FakeGps implements LocationProvider {
  @override
  Future<GpsResult> current() async =>
      const GpsFix(latitude: 36.5871, longitude: 36.1742);
}

class FakeBuildings implements BuildingsSource {
  @override
  Future<BuildingsResult> fetch() async => const BuildingsLoaded([]);
}

/// Ekranı bir önceki sayfadan açar; böylece kapanınca geri dönüş görülebilir.
Future<void> openScreen(WidgetTester tester, ReportCreator creator) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<bool>(
                builder: (_) => ReportCreateScreen(
                  sources: ReportCreateSources(
                    creator: creator,
                    photoPicker: FakePicker(),
                    gps: FakeGps(),
                    buildings: FakeBuildings(),
                  ),
                ),
              ),
            ),
            child: const Text('Aç'),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('Aç'));
  await tester.pumpAndSettle();
}

const validDescription = 'Koridor lambası yanmıyor';

/// Ekranın altında kalabilecek bir öğeye kaydırıp dokunur.
Future<void> tapVisible(WidgetTester tester, String text) async {
  await tester.ensureVisible(find.text(text));
  await tester.tap(find.text(text));
  await tester.pumpAndSettle();
}

Finder field(String label) => find.widgetWithText(TextFormField, label);

Future<void> fillForm(
  WidgetTester tester,
  String description, {
  bool withPhoto = true,
  bool withLocation = true,
}) async {
  await tester.tap(find.text('Temizlik'));
  await tester.enterText(field('Açıklama'), description);
  await tester.enterText(field('Yer tarifi'), 'B Blok 2. kat');
  if (withPhoto) await tapVisible(tester, 'Fotoğraf çek');
  if (withLocation) await tapVisible(tester, 'Konumumu al');
}

Future<void> submit(WidgetTester tester) => tapVisible(tester, 'Gönder');

void main() {
  testWidgets('showsValidationError_whenCategoryMissing', (tester) async {
    final creator = FakeReportCreator(const ReportCreated());
    await openScreen(tester, creator);

    await tester.enterText(field('Açıklama'), validDescription);
    await submit(tester);

    expect(find.text('Kategori seçin'), findsOneWidget);
    expect(creator.received, isEmpty);
  });

  testWidgets('showsValidationError_whenDescriptionTooShort', (tester) async {
    final creator = FakeReportCreator(const ReportCreated());
    await openScreen(tester, creator);

    await fillForm(tester, 'abc');
    await submit(tester);

    expect(find.text('Açıklama en az 5 karakter olmalı'), findsOneWidget);
    expect(creator.received, isEmpty);
  });

  testWidgets('submitsSuccessfully_withValidData', (tester) async {
    final creator = FakeReportCreator(const ReportCreated());
    await openScreen(tester, creator);

    await fillForm(tester, validDescription);
    await submit(tester);

    expect(creator.received.single.category, ReportCategory.temizlik);
    expect(creator.received.single.description, validDescription);
    expect(creator.received.single.photo, same(tinyPng));
    expect(creator.received.single.place, 'B Blok 2. kat');
    expect(creator.received.single.location, isA<GpsChoice>());
    expect(find.byType(ReportCreateScreen), findsNothing);
    expect(find.text('Bildirim oluşturuldu'), findsOneWidget);
  });

  testWidgets('showsServerError_whenRejected', (tester) async {
    final creator = FakeReportCreator(
      const ReportRejected('Konum kampüs dışında.'),
    );
    await openScreen(tester, creator);

    await fillForm(tester, validDescription);
    await submit(tester);

    expect(find.text('Konum kampüs dışında.'), findsOneWidget);
    expect(find.byType(ReportCreateScreen), findsOneWidget);
  });

  testWidgets('showsValidationError_whenPhotoMissing', (tester) async {
    final creator = FakeReportCreator(const ReportCreated());
    await openScreen(tester, creator);

    await fillForm(tester, validDescription, withPhoto: false);
    await submit(tester);

    expect(find.text('Fotoğraf ekleyin'), findsOneWidget);
    expect(creator.received, isEmpty);
  });

  testWidgets('showsValidationError_whenLocationMissing', (tester) async {
    final creator = FakeReportCreator(const ReportCreated());
    await openScreen(tester, creator);

    await fillForm(tester, validDescription, withLocation: false);
    await submit(tester);

    expect(
      find.text('Konum seçin: konumunuzu alın ya da bina seçin'),
      findsOneWidget,
    );
    expect(creator.received, isEmpty);
  });
}
