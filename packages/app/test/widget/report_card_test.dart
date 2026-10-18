import 'package:campus_app/ortak/features/reports/data/report_list_item.dart';
import 'package:campus_app/ortak/features/reports/presentation/report_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'reports_test_support.dart';

void main() {
  testWidgets('displaysCategoryColor', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: ReportCard(report: makeReport())),
      ),
    );

    final avatar = tester.widget<CircleAvatar>(find.byType(CircleAvatar));
    expect(avatar.backgroundColor, Colors.orange);
  });

  testWidgets('displaysStatusBadge', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ReportCard(report: makeReport(status: ReportStatus.ustlenildi)),
        ),
      ),
    );

    expect(find.text('Üstlenildi'), findsOneWidget);
  });

  testWidgets('showsThumbnail', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ReportCard(
            report: makeReport(imageUrl: 'https://example.invalid/report.jpg'),
          ),
        ),
      ),
    );

    expect(find.byKey(const Key('report-thumbnail')), findsOneWidget);
  });
}
