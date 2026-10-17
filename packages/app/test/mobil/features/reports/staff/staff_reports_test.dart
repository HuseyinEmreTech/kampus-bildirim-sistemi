import 'package:campus_app/mobil/features/reports/data/report_assigner.dart';
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

  /// İstenen sekme ve kategori (`null`: tüm kategoriler).
  final requested = <(StaffReportsView, ReportCategory?)>[];

  @override
  Future<ReportsPageResult> fetchFirstPage(
    StaffReportsView view, {
    ReportCategory? category,
  }) async {
    requested.add((view, category));
    return results[view]!.removeAt(0);
  }
}

/// Verilen sonucu döndüren ve üstlenilen bildirimleri kaydeden sahte kaynak.
class FakeReportAssigner implements ReportAssigner {
  FakeReportAssigner([this.result = const ReportAssigned()]);

  final ReportAssignResult result;
  final assignedIds = <String>[];

  @override
  Future<ReportAssignResult> assign(String reportId) async {
    assignedIds.add(reportId);
    return result;
  }
}

ReportListItem report(String place, {String id = 'r1'}) => ReportListItem(
  id: id,
  category: ReportCategory.ariza,
  status: ReportStatus.yeni,
  place: place,
  createdAt: DateTime(2026, 10, 17),
);

Future<void> pumpScreen(
  WidgetTester tester,
  StaffReportsSource source, {
  ReportAssigner? assigner,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: StaffReportsScreen(
        source: source,
        assigner: assigner ?? FakeReportAssigner(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

/// Gelen sekmesi önce A Blok'u, üstlendikten sonra boş listeyi döndürür.
FakeStaffReportsSource incomingThenEmpty() => FakeStaffReportsSource({
  StaffReportsView.incoming: [
    ReportsPageLoaded([report('A Blok', id: 'r7')]),
    const ReportsPageLoaded([]),
  ],
});

Future<void> selectCategory(WidgetTester tester, String label) async {
  await tester.tap(find.byType(DropdownButton<ReportCategory?>));
  await tester.pumpAndSettle();
  await tester.tap(find.text(label).last);
  await tester.pumpAndSettle();
}

Future<void> tapAssign(WidgetTester tester) async {
  await tester.tap(find.text('Üstlen'));
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

    expect(source.requested, [(StaffReportsView.incoming, null)]);
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

    expect(source.requested.last, (StaffReportsView.mine, null));
    expect(find.textContaining('Kütüphane'), findsOneWidget);
    expect(find.textContaining('A Blok'), findsNothing);
    expect(find.text('Üstlen'), findsNothing);
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

  testWidgets('assign_reloadsList_whenAssigned', (tester) async {
    final assigner = FakeReportAssigner();
    await pumpScreen(tester, incomingThenEmpty(), assigner: assigner);

    await tapAssign(tester);

    expect(assigner.assignedIds, ['r7']);
    expect(find.text('Bildirim üstlenildi'), findsOneWidget);
    expect(find.text('Bekleyen bildirim yok'), findsOneWidget);
  });

  testWidgets('assign_showsTakenMessage_whenAlreadyTaken', (tester) async {
    final assigner = FakeReportAssigner(const ReportAlreadyTaken());
    await pumpScreen(tester, incomingThenEmpty(), assigner: assigner);

    await tapAssign(tester);

    expect(
      find.text('Bu bildirimi başka bir görevli üstlendi'),
      findsOneWidget,
    );
    expect(find.text('Bekleyen bildirim yok'), findsOneWidget);
  });

  testWidgets('assign_showsError_whenFails', (tester) async {
    final assigner = FakeReportAssigner(const ReportAssignFailed());
    await pumpScreen(tester, incomingThenEmpty(), assigner: assigner);

    await tapAssign(tester);

    expect(find.text('Üstlenilemedi, tekrar deneyin'), findsOneWidget);
    expect(find.textContaining('A Blok'), findsOneWidget);
  });

  testWidgets('filtersByCategory_whenCategorySelected', (tester) async {
    final source = FakeStaffReportsSource({
      StaffReportsView.incoming: [
        ReportsPageLoaded([report('A Blok')]),
        ReportsPageLoaded([report('Yemekhane')]),
      ],
    });
    await pumpScreen(tester, source);

    await selectCategory(tester, 'Temizlik');

    expect(source.requested.last, (
      StaffReportsView.incoming,
      ReportCategory.temizlik,
    ));
    expect(find.textContaining('Yemekhane'), findsOneWidget);
  });

  testWidgets('keepsCategory_whenTabChanges', (tester) async {
    final source = FakeStaffReportsSource({
      StaffReportsView.incoming: [
        const ReportsPageLoaded([]),
        const ReportsPageLoaded([]),
      ],
      StaffReportsView.mine: [const ReportsPageLoaded([])],
    });
    await pumpScreen(tester, source);
    await selectCategory(tester, 'Güvenlik');

    await tester.tap(find.text('Benimkiler'));
    await tester.pumpAndSettle();

    expect(source.requested.last, (
      StaffReportsView.mine,
      ReportCategory.guvenlik,
    ));
  });
}
