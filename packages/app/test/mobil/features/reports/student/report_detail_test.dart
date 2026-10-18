import 'package:campus_app/mobil/features/reports/data/report_detail.dart';
import 'package:campus_app/mobil/features/reports/data/report_detail_source.dart';
import 'package:campus_app/mobil/features/reports/data/report_list_item.dart';
import 'package:campus_app/mobil/features/reports/presentation/student/report_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Sırayla verilen sonuçları döndüren ve istenen kimlikleri kaydeden sahte kaynak.
class FakeReportDetailSource implements ReportDetailSource {
  FakeReportDetailSource(this.results);

  final List<ReportDetailResult> results;
  final requestedIds = <String>[];

  @override
  Future<ReportDetailResult> fetch(String reportId) async {
    requestedIds.add(reportId);
    return results.removeAt(0);
  }
}

final created = DateTime(2026, 10, 15, 9, 15);

ReportDetail detail({bool resolved = false}) => ReportDetail(
  id: 'r1',
  category: ReportCategory.ariza,
  status: resolved ? ReportStatus.cozuldu : ReportStatus.ustlenildi,
  description: 'B blok 2. kat koridor lambası yanmıyor',
  place: 'B Blok 2. kat',
  createdAt: created,
  photoUrl: 'https://ornek.test/files/lamba.jpg',
  history: [
    StatusChange(to: ReportStatus.yeni, changedAt: created),
    StatusChange(
      to: ReportStatus.ustlenildi,
      changedAt: DateTime(2026, 10, 16),
      note: 'Yerine gidiliyor',
    ),
  ],
  resolution: resolved
      ? const Resolution(
          photoUrl: 'https://ornek.test/files/sonuc.jpg',
          note: 'Lamba değiştirildi.',
        )
      : null,
);

Future<void> pumpScreen(WidgetTester tester, ReportDetailSource source) async {
  await tester.pumpWidget(
    MaterialApp(
      home: ReportDetailScreen(reportId: 'r1', source: source),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('showsDetail_whenLoaded', (tester) async {
    final source = FakeReportDetailSource([ReportDetailLoaded(detail())]);

    await pumpScreen(tester, source);

    expect(source.requestedIds, ['r1']);
    expect(find.text('B blok 2. kat koridor lambası yanmıyor'), findsOneWidget);
    expect(find.text('B Blok 2. kat'), findsOneWidget);
    expect(find.text('Arıza'), findsOneWidget);
    expect(find.widgetWithText(Chip, 'Üstlenildi'), findsOneWidget);
    expect(find.text('15.10.2026'), findsWidgets); // üstte ve geçmişte
    expect(find.text('Sonuç'), findsNothing);
  });

  testWidgets('showsHistory_inOrder', (tester) async {
    await pumpScreen(
      tester,
      FakeReportDetailSource([ReportDetailLoaded(detail())]),
    );
    await tester.scrollUntilVisible(
      find.textContaining('Yerine gidiliyor'),
      200,
    );

    expect(find.text('Durum geçmişi'), findsOneWidget);
    expect(find.text('Yeni'), findsOneWidget);
    expect(find.text('16.10.2026 · Yerine gidiliyor'), findsOneWidget);
  });

  testWidgets('showsResolution_whenResolved', (tester) async {
    await pumpScreen(
      tester,
      FakeReportDetailSource([ReportDetailLoaded(detail(resolved: true))]),
    );
    await tester.scrollUntilVisible(find.text('Lamba değiştirildi.'), 200);

    expect(find.text('Sonuç'), findsOneWidget);
    expect(find.text('Lamba değiştirildi.'), findsOneWidget);
  });

  testWidgets('tapPhoto_opensZoomableViewer', (tester) async {
    await pumpScreen(
      tester,
      FakeReportDetailSource([ReportDetailLoaded(detail())]),
    );

    await tester.tap(find.bySemanticsLabel('Bildirim fotoğrafı'));
    await tester.pumpAndSettle();

    expect(find.byType(InteractiveViewer), findsOneWidget);
    expect(find.byType(Hero), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.byType(InteractiveViewer), findsNothing);
    expect(find.text('B Blok 2. kat'), findsOneWidget);
  });

  testWidgets('tapResolutionPhoto_opensViewerWithItsTitle', (tester) async {
    await pumpScreen(
      tester,
      FakeReportDetailSource([ReportDetailLoaded(detail(resolved: true))]),
    );
    final photo = find.bySemanticsLabel('Sonuç fotoğrafı');
    await tester.scrollUntilVisible(photo, 200);

    await tester.tap(photo);
    await tester.pumpAndSettle();

    expect(find.byType(InteractiveViewer), findsOneWidget);
    expect(find.widgetWithText(AppBar, 'Sonuç fotoğrafı'), findsOneWidget);
  });

  testWidgets('showsNotFound_whenMissing', (tester) async {
    await pumpScreen(
      tester,
      FakeReportDetailSource([const ReportDetailNotFound()]),
    );

    expect(find.text('Bildirim bulunamadı'), findsOneWidget);
  });

  testWidgets('showsRetry_whenLoadFails', (tester) async {
    final source = FakeReportDetailSource([
      const ReportDetailFailed(),
      ReportDetailLoaded(detail()),
    ]);
    await pumpScreen(tester, source);

    await tester.tap(find.text('Tekrar dene'));
    await tester.pumpAndSettle();

    expect(find.text('B Blok 2. kat'), findsOneWidget);
  });
}
