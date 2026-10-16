import 'package:campus_app/mobil/features/reports/data/report_list_item.dart';
import 'package:campus_app/mobil/features/reports/data/reports_source.dart';
import 'package:campus_app/mobil/features/reports/presentation/student/reports_list_screen.dart';
import 'package:campus_app/mobil/features/reports/presentation/student/widgets/report_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Sırayla verilen sonuçları döndüren sahte kaynak.
class FakeReportsSource implements ReportsSource {
  FakeReportsSource(this.results);

  final List<ReportsPageResult> results;

  @override
  Future<ReportsPageResult> fetchPage({
    required int offset,
    required int limit,
  }) async {
    return results.removeAt(0);
  }
}

ReportListItem report({String place = 'A Blok'}) => ReportListItem(
  category: ReportCategory.ariza,
  status: ReportStatus.yeni,
  place: place,
  createdAt: DateTime(2026, 10, 15),
);

Future<void> pumpScreen(WidgetTester tester, ReportsSource source) async {
  await tester.pumpWidget(MaterialApp(home: ReportsListScreen(source: source)));
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
}
