import 'package:campus_app/mobil/features/reports/data/new_report.dart';
import 'package:campus_app/mobil/features/reports/data/report_creator.dart';
import 'package:campus_app/mobil/features/reports/data/report_list_item.dart';
import 'package:campus_app/mobil/features/reports/data/reports_source.dart';
import 'package:campus_app/mobil/features/reports/presentation/student/report_create_screen.dart';
import 'package:campus_app/mobil/features/reports/presentation/student/reports_list_screen.dart';
import 'package:campus_app/mobil/features/reports/presentation/student/widgets/report_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Sırayla verilen sonuçları döndüren sahte kaynak.
class FakeReportsSource implements ReportsSource {
  FakeReportsSource(this.results);

  final List<ReportsPageResult> results;

  /// İstenen sayfa numaraları, sırayla.
  final requestedPages = <int>[];

  @override
  Future<ReportsPageResult> fetchPage({
    required int page,
    required int pageSize,
  }) async {
    requestedPages.add(page);
    return results.removeAt(0);
  }
}

/// Her gönderimi kabul eden sahte kaynak.
class AcceptingReportCreator implements ReportCreator {
  @override
  Future<ReportCreateResult> create(NewReport report) async =>
      const ReportCreated();
}

/// [count] tane bildirim; yerleri "Yer [from]", "Yer [from]+1", ...
List<ReportListItem> reports(int count, {int from = 0}) => [
  for (var i = from; i < from + count; i++) report(place: 'Yer $i'),
];

Future<void> scrollToEnd(WidgetTester tester) async {
  await tester.drag(find.byType(ListView), const Offset(0, -5000));
  await tester.pumpAndSettle();
}

ReportListItem report({String place = 'A Blok'}) => ReportListItem(
  id: 'r1',
  category: ReportCategory.ariza,
  status: ReportStatus.yeni,
  place: place,
  createdAt: DateTime(2026, 10, 15),
);

Future<void> pumpScreen(
  WidgetTester tester,
  ReportsSource source, {
  ValueChanged<ReportListItem>? onReportTap,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: ReportsListScreen(
        source: source,
        creator: AcceptingReportCreator(),
        onReportTap: onReportTap,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('showsEmptyState_whenNoReports', (tester) async {
    final source = FakeReportsSource([const ReportsPageLoaded([])]);

    await pumpScreen(tester, source);

    expect(find.text('Henüz bildiriminiz yok'), findsOneWidget);
  });

  testWidgets('showsReports_whenDataExists', (tester) async {
    final source = FakeReportsSource([
      ReportsPageLoaded([report()]),
    ]);

    await pumpScreen(tester, source);

    expect(find.byType(ReportCard), findsOneWidget);
    expect(find.text('Arıza'), findsOneWidget);
    expect(find.text('Yeni'), findsOneWidget);
    expect(find.textContaining('A Blok'), findsOneWidget);
    expect(find.textContaining('15.10.2026'), findsOneWidget);
  });

  testWidgets('refresh_updatesList', (tester) async {
    final source = FakeReportsSource([
      ReportsPageLoaded([report(place: 'A Blok')]),
      ReportsPageLoaded([report(place: 'Kütüphane')]),
    ]);
    await pumpScreen(tester, source);

    await tester.fling(find.byType(ListView), const Offset(0, 400), 1000);
    await tester.pumpAndSettle();

    expect(find.textContaining('Kütüphane'), findsOneWidget);
    expect(find.textContaining('A Blok'), findsNothing);
  });

  testWidgets('showsRetry_whenLoadFails', (tester) async {
    final source = FakeReportsSource([
      const ReportsPageFailed(),
      ReportsPageLoaded([report()]),
    ]);
    await pumpScreen(tester, source);

    expect(find.text('Bildirimler yüklenemedi'), findsOneWidget);

    await tester.tap(find.text('Tekrar dene'));
    await tester.pumpAndSettle();

    expect(find.byType(ReportCard), findsOneWidget);
  });

  testWidgets('opensCreateScreen_onAddTap', (tester) async {
    await pumpScreen(tester, FakeReportsSource([const ReportsPageLoaded([])]));

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    expect(find.byType(ReportCreateScreen), findsOneWidget);
  });

  testWidgets('reloadsList_afterReportCreated', (tester) async {
    final source = FakeReportsSource([
      const ReportsPageLoaded([]),
      ReportsPageLoaded([report(place: 'Kütüphane')]),
    ]);
    await pumpScreen(tester, source);
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Temizlik'));
    await tester.enterText(find.byType(TextFormField), 'Kütüphanede ışık yok');
    await tester.tap(find.text('Gönder'));
    await tester.pumpAndSettle();

    expect(find.byType(ReportCreateScreen), findsNothing);
    expect(find.textContaining('Kütüphane'), findsOneWidget);
  });

  testWidgets('callsOnReportTap_whenCardTapped', (tester) async {
    ReportListItem? tapped;
    await pumpScreen(
      tester,
      FakeReportsSource([
        ReportsPageLoaded([report()]),
      ]),
      onReportTap: (item) => tapped = item,
    );

    await tester.tap(find.byType(ReportCard));

    expect(tapped?.id, 'r1');
  });

  testWidgets('loadsMore_onScroll', (tester) async {
    final source = FakeReportsSource([
      ReportsPageLoaded(reports(reportsPageSize)),
      ReportsPageLoaded(reports(5, from: reportsPageSize)),
    ]);
    await pumpScreen(tester, source);

    await scrollToEnd(tester);
    await tester.scrollUntilVisible(find.textContaining('Yer 24'), 300);

    expect(source.requestedPages, [1, 2]);
    expect(find.textContaining('Yer 24'), findsOneWidget);
  });

  testWidgets('stopsLoading_whenLastPageIsShort', (tester) async {
    final source = FakeReportsSource([ReportsPageLoaded(reports(5))]);
    await pumpScreen(tester, source);

    await scrollToEnd(tester);

    expect(source.requestedPages, [1]);
  });

  testWidgets('showsLoadMoreRetry_whenNextPageFails', (tester) async {
    final source = FakeReportsSource([
      ReportsPageLoaded(reports(reportsPageSize)),
      const ReportsPageFailed(),
      ReportsPageLoaded(reports(1, from: reportsPageSize)),
    ]);
    await pumpScreen(tester, source);
    await scrollToEnd(tester);
    await scrollToEnd(tester);

    expect(find.text('Daha fazlası yüklenemedi'), findsOneWidget);

    await tester.tap(find.text('Tekrar dene'));
    await tester.pumpAndSettle();
    await scrollToEnd(tester);

    expect(source.requestedPages, [1, 2, 2]);
    expect(find.textContaining('Yer 20'), findsOneWidget);
  });
}
