import 'package:campus_app/mobil/features/reports/data/report_assigner.dart';
import 'package:campus_app/mobil/features/reports/data/report_list_item.dart';
import 'package:campus_app/mobil/features/reports/data/report_resolver.dart';
import 'package:campus_app/mobil/features/reports/data/reports_source.dart';
import 'package:campus_app/mobil/features/reports/data/staff_reports_source.dart';
import 'package:campus_app/mobil/features/reports/presentation/staff/resolve_screen.dart';
import 'package:campus_app/mobil/features/reports/presentation/staff/staff_reports_screen.dart';
import 'package:campus_app/mobil/shared/photo/photo_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Her sekme için sırayla verilen sonuçları döndüren ve istekleri kaydeden sahte kaynak.
class FakeStaffReportsSource implements StaffReportsSource {
  FakeStaffReportsSource(this.results);

  final Map<StaffReportsView, List<ReportsPageResult>> results;

  /// İstenen sekme ve kategori (`null`: tüm kategoriler).
  final requested = <(StaffReportsView, ReportCategory?)>[];

  /// İstenen sayfa numaraları, sırayla.
  final requestedPages = <int>[];

  @override
  Future<ReportsPageResult> fetchPage(
    StaffReportsView view, {
    ReportCategory? category,
    required int page,
    required int pageSize,
  }) async {
    requested.add((view, category));
    requestedPages.add(page);
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

/// Bu testlerde çözme ekranı yalnızca açılıyor; gönderim kendi testinde.
class UnusedResolver implements ReportResolver {
  @override
  Future<ReportResolveResult> resolve({
    required String reportId,
    required PickedPhoto photo,
    String? note,
  }) async => const ReportResolveFailed();
}

class UnusedPicker implements PhotoPicker {
  @override
  Future<PhotoPickResult> pick(PhotoSource source) async =>
      const PhotoPickCancelled();
}

ReportListItem report(
  String place, {
  String id = 'r1',
  ReportStatus status = ReportStatus.yeni,
}) => ReportListItem(
  id: id,
  category: ReportCategory.ariza,
  status: status,
  place: place,
  createdAt: DateTime(2026, 10, 17),
);

Future<void> pumpScreen(
  WidgetTester tester,
  StaffReportsSource source, {
  ReportAssigner? assigner,
  ValueChanged<ReportListItem>? onReportTap,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: StaffReportsScreen(
        source: source,
        assigner: assigner ?? FakeReportAssigner(),
        resolver: UnusedResolver(),
        photoPicker: UnusedPicker(),
        onReportTap: onReportTap,
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

  testWidgets('callsOnReportTap_whenCardTapped', (tester) async {
    ReportListItem? tapped;
    await pumpScreen(
      tester,
      incomingThenEmpty(),
      onReportTap: (item) => tapped = item,
    );

    await tester.tap(find.textContaining('A Blok'));

    expect(tapped?.id, 'r7');
  });

  testWidgets('loadsMore_onScroll', (tester) async {
    final source = FakeStaffReportsSource({
      StaffReportsView.incoming: [
        ReportsPageLoaded([
          for (var i = 0; i < reportsPageSize; i++) report('Yer $i', id: 'r$i'),
        ]),
        ReportsPageLoaded([report('Son yer', id: 'son')]),
      ],
    });
    await pumpScreen(tester, source);

    await tester.drag(find.byType(ListView), const Offset(0, -10000));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.textContaining('Son yer'), 300);

    expect(source.requestedPages, [1, 2]);
    expect(find.textContaining('Son yer'), findsOneWidget);
  });

  testWidgets('resolveButton_opensResolveScreen_forAssignedInMine', (
    tester,
  ) async {
    final source = FakeStaffReportsSource({
      StaffReportsView.incoming: [const ReportsPageLoaded([])],
      StaffReportsView.mine: [
        ReportsPageLoaded([
          report('A Blok', id: 'r7', status: ReportStatus.ustlenildi),
          report('Kütüphane', id: 'r8', status: ReportStatus.cozuldu),
        ]),
      ],
    });
    await pumpScreen(tester, source);
    await tester.tap(find.text('Benimkiler'));
    await tester.pumpAndSettle();

    expect(find.text('Çöz'), findsOneWidget);

    await tester.tap(find.text('Çöz'));
    await tester.pumpAndSettle();

    expect(find.byType(ResolveScreen), findsOneWidget);
  });
}
