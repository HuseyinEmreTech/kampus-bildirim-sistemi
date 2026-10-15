import 'package:campus_app/mobil/features/reports/data/new_report.dart';
import 'package:campus_app/mobil/features/reports/data/report_creator.dart';
import 'package:campus_app/mobil/features/reports/data/report_list_item.dart';
import 'package:campus_app/mobil/features/reports/presentation/student/report_create_screen.dart';
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

/// Ekranı bir önceki sayfadan açar; böylece kapanınca geri dönüş görülebilir.
Future<void> openScreen(WidgetTester tester, ReportCreator creator) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<bool>(
                builder: (_) => ReportCreateScreen(creator: creator),
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

Future<void> fillForm(WidgetTester tester, String description) async {
  await tester.tap(find.text('Temizlik'));
  await tester.enterText(find.byType(TextFormField), description);
}

Future<void> submit(WidgetTester tester) async {
  await tester.tap(find.text('Gönder'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('showsValidationError_whenCategoryMissing', (tester) async {
    final creator = FakeReportCreator(const ReportCreated());
    await openScreen(tester, creator);

    await tester.enterText(find.byType(TextFormField), validDescription);
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
}
