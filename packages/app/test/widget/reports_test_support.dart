import 'package:campus_app/ortak/features/reports/data/report_list_item.dart';
import 'package:campus_app/ortak/features/reports/data/reports_source.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeReportsSource implements ReportsSource {
  FakeReportsSource(this.results);

  final List<ReportsPageResult> results;
  int fetchCount = 0;

  @override
  Future<ReportsPageResult> fetchPage({
    required int offset,
    required int limit,
  }) async {
    fetchCount++;
    return results.removeAt(0);
  }
}

ReportListItem makeReport({
  ReportCategory category = ReportCategory.ariza,
  ReportStatus status = ReportStatus.yeni,
  String place = 'A Blok',
  DateTime? createdAt,
  String? imageUrl,
}) => ReportListItem(
  category: category,
  status: status,
  place: place,
  createdAt: createdAt ?? DateTime(2026, 10, 15),
  imageUrl: imageUrl,
);

void setScreenSize(WidgetTester tester, {required double width}) {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = Size(width, 900);
}
