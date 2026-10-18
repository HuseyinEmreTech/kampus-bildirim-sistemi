import 'package:campus_app/ortak/features/reports/data/reports_source.dart';
import 'package:campus_app/web/features/reports/presentation/reports_list_web.dart';
import 'package:campus_app/web/features/reports/presentation/widgets/report_detail_panel.dart';
import 'package:campus_app/web/features/reports/presentation/widgets/reports_sidebar.dart';
import 'package:campus_app/ortak/features/reports/presentation/report_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'reports_test_support.dart';

void main() {
  testWidgets('navigatesToDetail_onTap', (tester) async {
    setScreenSize(tester, width: 390);
    await tester.pumpWidget(
      MaterialApp(
        home: ReportsListWeb(
          source: FakeReportsSource([
            ReportsPageLoaded([makeReport(place: 'A Blok')]),
          ]),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      tester.widget<ReportsSidebar>(find.byType(ReportsSidebar)).items,
      hasLength(1),
    );
    expect(find.byType(ReportCard), findsOneWidget);
    await tester.tap(find.textContaining('A Blok'));
    await tester.pumpAndSettle();

    expect(find.text('Bildirim detayı'), findsOneWidget);
    expect(find.byType(ReportDetailPanel), findsOneWidget);
  });

  testWidgets('showsEmptyState_whenNoReports', (tester) async {
    setScreenSize(tester, width: 390);
    var createPressed = false;
    await tester.pumpWidget(
      MaterialApp(
        home: ReportsListWeb(
          source: FakeReportsSource([const ReportsPageLoaded([])]),
          onCreateReport: () => createPressed = true,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Henüz bildirim yok'), findsOneWidget);
    await tester.tap(find.text('Bildirim Oluştur'));
    expect(createPressed, isTrue);
  });
}
