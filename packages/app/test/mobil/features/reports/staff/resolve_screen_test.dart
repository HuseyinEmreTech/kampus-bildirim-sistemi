import 'dart:convert';

import 'package:campus_app/mobil/features/reports/data/report_resolver.dart';
import 'package:campus_app/mobil/features/reports/presentation/staff/resolve_screen.dart';
import 'package:campus_app/mobil/shared/photo/photo_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

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

/// Verilen sonucu döndüren ve gelen istekleri kaydeden sahte kaynak.
class FakeResolver implements ReportResolver {
  FakeResolver(this.result);

  final ReportResolveResult result;
  final received = <(String, PickedPhoto, String?)>[];

  @override
  Future<ReportResolveResult> resolve({
    required String reportId,
    required PickedPhoto photo,
    String? note,
  }) async {
    received.add((reportId, photo, note));
    return result;
  }
}

/// Ekranı bir önceki sayfadan açar; böylece kapanınca geri dönüş görülebilir.
Future<void> openScreen(WidgetTester tester, ReportResolver resolver) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<bool>(
                builder: (_) => ResolveScreen(
                  reportId: 'r7',
                  resolver: resolver,
                  photoPicker: FakePicker(),
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

Future<void> submit(WidgetTester tester) async {
  await tester.tap(find.text('Çözüldü olarak işaretle'));
  await tester.pumpAndSettle();
}

Future<void> addPhoto(WidgetTester tester) async {
  await tester.tap(find.text('Fotoğraf çek'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('showsPhotoRequired_whenNoPhoto', (tester) async {
    final resolver = FakeResolver(const ReportResolved());
    await openScreen(tester, resolver);

    await submit(tester);

    expect(find.text('Sonuç fotoğrafı ekleyin'), findsOneWidget);
    expect(resolver.received, isEmpty);
  });

  testWidgets('submitsPhotoAndNote_andCloses', (tester) async {
    final resolver = FakeResolver(const ReportResolved());
    await openScreen(tester, resolver);

    await addPhoto(tester);
    await tester.enterText(find.byType(TextFormField), 'Lamba değiştirildi.');
    await submit(tester);

    final (id, photo, note) = resolver.received.single;
    expect(id, 'r7');
    expect(photo, same(tinyPng));
    expect(note, 'Lamba değiştirildi.');
    expect(find.byType(ResolveScreen), findsNothing);
    expect(find.text('Bildirim çözüldü'), findsOneWidget);
  });

  testWidgets('sendsNoNote_whenNoteEmpty', (tester) async {
    final resolver = FakeResolver(const ReportResolved());
    await openScreen(tester, resolver);

    await addPhoto(tester);
    await submit(tester);

    expect(resolver.received.single.$3, isNull);
  });

  testWidgets('showsServerMessage_whenRejected', (tester) async {
    final resolver = FakeResolver(
      const ReportResolveRejected('Bu bildirimi siz üstlenmediniz.'),
    );
    await openScreen(tester, resolver);

    await addPhoto(tester);
    await submit(tester);

    expect(find.text('Bu bildirimi siz üstlenmediniz.'), findsOneWidget);
    expect(find.byType(ResolveScreen), findsOneWidget);
  });

  testWidgets('showsError_whenFails', (tester) async {
    await openScreen(tester, FakeResolver(const ReportResolveFailed()));

    await addPhoto(tester);
    await submit(tester);

    expect(find.text('Gönderilemedi, tekrar deneyin'), findsOneWidget);
  });
}
