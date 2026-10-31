import 'dart:convert';
import 'dart:typed_data';

import 'package:campus_app/mobil/shared/photo/photo_field.dart';
import 'package:campus_app/mobil/shared/photo/photo_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// 1x1 piksel PNG (sahte fotoğraf).
final tinyPng = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==',
);

PickedPhoto photo({Uint8List? bytes, String contentType = 'image/png'}) =>
    PickedPhoto(bytes: bytes ?? tinyPng, contentType: contentType);

/// Verilen sonucu döndüren ve istenen kaynakları kaydeden sahte seçici.
class FakePhotoPicker implements PhotoPicker {
  FakePhotoPicker(this.result);

  final PhotoPickResult result;
  final sources = <PhotoSource>[];

  @override
  Future<PhotoPickResult> pick(PhotoSource source) async {
    sources.add(source);
    return result;
  }
}

final formKey = GlobalKey<FormState>();

Future<void> pumpField(WidgetTester tester, PhotoPicker picker) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Form(
          key: formKey,
          child: PhotoField(
            picker: picker,
            requiredMessage: 'Sonuç fotoğrafı ekleyin',
          ),
        ),
      ),
    ),
  );
}

Future<void> tapAndSettle(WidgetTester tester, String text) async {
  await tester.tap(find.text(text));
  await tester.pumpAndSettle();
}

void main() {
  test('photoProblem_acceptsSmallJpegAndPng', () {
    expect(photoProblem(photo(contentType: 'image/jpeg')), isNull);
    expect(photoProblem(photo()), isNull);
  });

  test('photoProblem_rejectsOtherTypes', () {
    expect(
      photoProblem(photo(contentType: 'image/gif')),
      'Yalnızca JPEG veya PNG fotoğraf seçilebilir',
    );
  });

  test('photoProblem_rejectsTooLarge', () {
    expect(
      photoProblem(photo(bytes: Uint8List(maxPhotoBytes + 1))),
      'Fotoğraf en fazla 5 MB olabilir',
    );
  });

  testWidgets('showsRequiredError_whenNoPhoto', (tester) async {
    await pumpField(tester, FakePhotoPicker(const PhotoPickCancelled()));

    formKey.currentState!.validate();
    await tester.pump();

    expect(find.text('Sonuç fotoğrafı ekleyin'), findsOneWidget);
  });

  testWidgets('picksFromCamera_andShowsPreview', (tester) async {
    final picker = FakePhotoPicker(PhotoPicked(photo()));
    await pumpField(tester, picker);

    await tapAndSettle(tester, 'Fotoğraf çek');

    expect(picker.sources, [PhotoSource.camera]);
    expect(find.byType(Image), findsOneWidget);
    expect(formKey.currentState!.validate(), isTrue);
  });

  testWidgets('showsError_whenPhotoTooLarge', (tester) async {
    final big = photo(bytes: Uint8List(maxPhotoBytes + 1));
    await pumpField(tester, FakePhotoPicker(PhotoPicked(big)));

    await tapAndSettle(tester, 'Galeriden seç');

    expect(find.text('Fotoğraf en fazla 5 MB olabilir'), findsOneWidget);
    expect(find.byType(Image), findsNothing);
  });

  testWidgets('showsMessage_whenPermissionDenied', (tester) async {
    await pumpField(tester, FakePhotoPicker(const PhotoPickDenied()));

    await tapAndSettle(tester, 'Fotoğraf çek');

    expect(find.text('Kamera ya da galeri izni verilmedi'), findsOneWidget);
  });

  testWidgets('remove_clearsPhoto', (tester) async {
    await pumpField(tester, FakePhotoPicker(PhotoPicked(photo())));
    await tapAndSettle(tester, 'Fotoğraf çek');

    await tapAndSettle(tester, 'Kaldır');

    expect(find.byType(Image), findsNothing);
    expect(formKey.currentState!.validate(), isFalse);
  });
}
