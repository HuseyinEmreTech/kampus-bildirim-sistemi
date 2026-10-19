import 'package:campus_app/mobil/features/reports/data/report_list_item.dart';
import 'package:campus_app/mobil/features/reports/data/reports_source.dart';
import 'package:campus_app/mobil/features/reports/data/staff_reports_source.dart';
import 'package:campus_app/mobil/features/reports/presentation/staff/staff_reports_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Her sekme için sırayla verilen sonuçları döndüren ve istekleri kaydeden sahte kaynak.
class FakeStaffReportsSource implements StaffReportsSource {
  FakeStaffReportsSource(this.results);

  final Map<StaffReportsView, List<ReportsPageResult>> results;
  final requested = <StaffReportsView>[];

  @override
  Future<ReportsPageResult> fetchFirstPage(StaffReportsView view) async {
    requested.add(view);
    return results[view]!.removeAt(0);
  }
}

ReportListItem report(String place) => ReportListItem(
  category: ReportCategory.ariza,
  status: ReportStatus.yeni,
  place: place,
  createdAt: DateTime(2026, 10, 17),
);

Future<void> pumpScreen(WidgetTester tester, StaffReportsSource source) async {
  await tester.pumpWidget(
    MaterialApp(home: StaffReportsScreen(source: source)),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('showsIncomingReports_byDefault', (tester) async {
    final source = FakeStaffReportsSource({
      StaffReportsView.incoming: [
        ReportsPageLoaded([report('A Blok')]),
      ],
    });

    await pumpScreen(tester, source);

    expect(source.requested, [StaffReportsView.incoming]);
    expect(find.textContaining('A Blok'), findsOneWidget);
  });

  testWidgets('showsMyReports_whenMineSelected', (tester) async {
    final source = FakeStaffReportsSource({
      StaffReportsView.incoming: [
        ReportsPageLoaded([report('A Blok')]),
      ],
      StaffReportsView.mine: [
        ReportsPageLoaded([report('Kütüphane')]),
      ],
    });
    await pumpScreen(tester, source);

    await tester.tap(find.text('Benimkiler'));
    await tester.pumpAndSettle();

    expect(source.requested.last, StaffReportsView.mine);
    expect(find.textContaining('Kütüphane'), findsOneWidget);
    expect(find.textContaining('A Blok'), findsNothing);
  });

  testWidgets('showsEmptyState_whenNoReports', (tester) async {
    final source = FakeStaffReportsSource({
      StaffReportsView.incoming: [const ReportsPageLoaded([])],
    });

    await pumpScreen(tester, source);

    expect(find.text('Bekleyen bildirim yok'), findsOneWidget);
  });

  testWidgets('showsRetry_whenLoadFails', (tester) async {
    final source = FakeStaffReportsSource({
      StaffReportsView.incoming: [
        const ReportsPageFailed(),
        ReportsPageLoaded([report('A Blok')]),
      ],
    });
    await pumpScreen(tester, source);

    expect(find.text('Bildirimler yüklenemedi'), findsOneWidget);

    await tester.tap(find.text('Tekrar dene'));
    await tester.pumpAndSettle();

    expect(find.textContaining('A Blok'), findsOneWidget);
  });
}
