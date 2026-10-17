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

ReportDetail detail() => ReportDetail(
  id: 'r1',
  category: ReportCategory.ariza,
  status: ReportStatus.ustlenildi,
  description: 'B blok 2. kat koridor lambası yanmıyor',
  place: 'B Blok 2. kat',
  createdAt: DateTime(2026, 10, 15, 9, 15),
  photoUrl: 'https://ornek.test/files/lamba.jpg',
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
    expect(find.text('Üstlenildi'), findsOneWidget);
    expect(find.text('15.10.2026'), findsOneWidget);
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
