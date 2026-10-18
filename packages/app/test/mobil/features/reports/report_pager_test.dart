import 'dart:async';

import 'package:campus_app/mobil/features/reports/data/report_list_item.dart';
import 'package:campus_app/mobil/features/reports/data/reports_source.dart';
import 'package:campus_app/mobil/features/reports/state/report_pager.dart';
import 'package:flutter_test/flutter_test.dart';

/// Sayfa isteklerini kaydeden, sonuçları sırayla veren sahte getirme.
class FakePages {
  FakePages(this.results);

  final List<Future<ReportsPageResult>> results;
  final requested = <int>[];

  Future<ReportsPageResult> fetch(int page) {
    requested.add(page);
    return results.removeAt(0);
  }
}

List<ReportListItem> reports(int count, {String prefix = 'Yer'}) => [
  for (var i = 0; i < count; i++)
    ReportListItem(
      id: '$prefix-$i',
      category: ReportCategory.ariza,
      status: ReportStatus.yeni,
      place: '$prefix $i',
      createdAt: DateTime(2026, 10, 18),
    ),
];

Future<ReportsPageResult> loaded(List<ReportListItem> items) =>
    Future.value(ReportsPageLoaded(items));

void main() {
  test('reload_loadsFirstPage_andKnowsMoreExists', () async {
    final pages = FakePages([loaded(reports(reportsPageSize))]);
    final pager = ReportPager(pages.fetch);

    await pager.reload();

    expect(pages.requested, [1]);
    expect(pager.isLoading, isFalse);
    expect(pager.items, hasLength(reportsPageSize));
    expect(pager.hasMore, isTrue);
  });

  test('loadMore_appendsNextPage_andStopsWhenShort', () async {
    final pages = FakePages([
      loaded(reports(reportsPageSize)),
      loaded(reports(5, prefix: 'Son')),
    ]);
    final pager = ReportPager(pages.fetch);
    await pager.reload();

    await pager.loadMore();
    await pager.loadMore();

    expect(pages.requested, [1, 2]);
    expect(pager.items, hasLength(reportsPageSize + 5));
    expect(pager.hasMore, isFalse);
  });

  test('loadMore_marksFailed_andRetryLoadsAgain', () async {
    final pages = FakePages([
      loaded(reports(reportsPageSize)),
      Future.value(const ReportsPageFailed()),
      loaded(reports(1, prefix: 'Son')),
    ]);
    final pager = ReportPager(pages.fetch);
    await pager.reload();

    await pager.loadMore();
    expect(pager.loadMoreFailed, isTrue);
    await pager.retryMore();

    expect(pages.requested, [1, 2, 2]);
    expect(pager.loadMoreFailed, isFalse);
    expect(pager.items.last.place, 'Son 0');
  });

  test('reset_ignoresLateAnswerFromBefore', () async {
    final slow = Completer<ReportsPageResult>();
    final pages = FakePages([slow.future, loaded(reports(1, prefix: 'Yeni'))]);
    final pager = ReportPager(pages.fetch);
    final first = pager.reload();

    await pager.reset();
    slow.complete(ReportsPageLoaded(reports(1, prefix: 'Eski')));
    await first;

    expect(pager.items.single.place, 'Yeni 0');
  });
}
