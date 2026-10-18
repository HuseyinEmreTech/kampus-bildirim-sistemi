import 'package:campus_app/ortak/features/reports/data/report_list_item.dart';
import 'package:campus_app/ortak/features/reports/data/reports_source.dart';
import 'package:campus_app/web/features/reports/presentation/reports_list_web.dart';
import 'package:campus_app/web/features/reports/presentation/widgets/report_detail_panel.dart';
import 'package:campus_app/web/features/reports/presentation/widgets/reports_sidebar.dart';
import 'package:campus_app/ortak/features/reports/presentation/report_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'reports_test_support.dart';

void main() {
  testWidgets('showsSidebarAndDetail_onDesktop', (tester) async {
    setScreenSize(tester, width: 1200);
    await tester.pumpWidget(
      MaterialApp(
        home: ReportsListWeb(
          source: FakeReportsSource([
            ReportsPageLoaded([makeReport()]),
          ]),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(ReportsSidebar), findsOneWidget);
    expect(find.byType(ReportDetailPanel), findsOneWidget);
    expect(find.byType(ReportCard), findsOneWidget);
    expect(
      tester.widget<ReportsSidebar>(find.byType(ReportsSidebar)).items,
      hasLength(1),
    );
  });

  testWidgets('selectsReport_showsDetailInPanel', (tester) async {
    setScreenSize(tester, width: 1200);
    await tester.pumpWidget(
      MaterialApp(
        home: ReportsListWeb(
          source: FakeReportsSource([
            ReportsPageLoaded([
              makeReport(place: 'Kütüphane'),
              makeReport(place: 'A Blok'),
            ]),
          ]),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.textContaining('Kütüphane'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Kütüphane'), findsWidgets);
    expect(find.text('Konum'), findsOneWidget);
  });

  testWidgets('filtersWork_onStaffView', (tester) async {
    setScreenSize(tester, width: 1200);
    await tester.pumpWidget(
      MaterialApp(
        home: ReportsListWeb(
          isStaff: true,
          source: FakeReportsSource([
            ReportsPageLoaded([
              makeReport(place: 'Yeni rapor'),
              makeReport(
                status: ReportStatus.cozuldu,
                place: 'Çözülmüş rapor',
                category: ReportCategory.temizlik,
              ),
              makeReport(
                status: ReportStatus.cozuldu,
                place: 'Diğer çözülmüş rapor',
                category: ReportCategory.guvenlik,
              ),
            ]),
          ]),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('report-status-filter')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Çözüldü').last);
    await tester.pumpAndSettle();

    expect(find.textContaining('Diğer çözülmüş rapor'), findsOneWidget);
    await tester.tap(find.byKey(const Key('report-category-filter')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Temizlik').last);
    await tester.pumpAndSettle();

    expect(find.textContaining('Çözülmüş rapor'), findsOneWidget);
    expect(find.textContaining('Diğer çözülmüş rapor'), findsNothing);
  });

  testWidgets('opensDetailInBottomSheet_onTablet', (tester) async {
    setScreenSize(tester, width: 720);
    await tester.pumpWidget(
      MaterialApp(
        home: ReportsListWeb(
          source: FakeReportsSource([
            ReportsPageLoaded([makeReport(place: 'Kütüphane')]),
          ]),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.textContaining('Kütüphane'));
    await tester.pumpAndSettle();

    expect(find.text('Konum'), findsOneWidget);
  });
}
