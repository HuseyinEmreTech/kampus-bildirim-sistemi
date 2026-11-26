import 'dart:async';

import 'package:campus_app/mobil/features/reports/data/report_list_item.dart';
import 'package:campus_app/mobil/features/reports/data/reports_source.dart';
import 'package:campus_app/mobil/features/reports/state/report_pager.dart';
import 'package:flutter_test/flutter_test.dart';

/// İstenen başlangıç sıralarını kaydeden, sonuçları sırayla veren sahte
/// getirme.
class FakePages {
  FakePages(this.results);

  final List<Future<ReportsPageResult>> results;
  final requestedOffsets = <int>[];

  Future<ReportsPageResult> fetch({required int offset, required int limit}) {
    requestedOffsets.add(offset);
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

    expect(pages.requestedOffsets, [0]);
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

    expect(pages.requestedOffsets, [0, reportsPageSize]);
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

    expect(pages.requestedOffsets, [0, reportsPageSize, reportsPageSize]);
    expect(pager.loadMoreFailed, isFalse);
    expect(pager.items.last.place, 'Son 0');
  });

  test('reload_keepsItems_andMarksFailed_whenFirstPageFails', () async {
    final pages = FakePages([
      loaded(reports(1)),
      Future.value(const ReportsPageFailed()),
    ]);
    final pager = ReportPager(pages.fetch);
    await pager.reload();

    await pager.reload();

    expect(pager.loadFailed, isTrue);
    expect(pager.items, hasLength(1));
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

  test('dispose_ignoresAnswerArrivingLater', () async {
    final slow = Completer<ReportsPageResult>();
    final pager = ReportPager(FakePages([slow.future]).fetch);
    var notified = false;
    pager.addListener(() => notified = true);
    final pending = pager.reload();

    pager.dispose();
    slow.complete(ReportsPageLoaded(reports(1)));
    await pending;

    expect(notified, isFalse);
  });

  test('reset_unlocksLoadMore_whenOldPageStillLoading', () async {
    // Arrange: ilk sayfa dolu, ikinci sayfa isteği askıda kalıyor.
    final slow = Completer<ReportsPageResult>();
    final pages = FakePages([
      loaded(reports(20)),
      slow.future,
      loaded(reports(20, prefix: 'Yeni')),
      loaded(reports(5, prefix: 'Sonraki')),
    ]);
    final pager = ReportPager(pages.fetch);
    await pager.reload();
    final pending = pager.loadMore();

    // Act: sonraki sayfa beklenirken sekme değişir.
    await pager.reset();
    slow.complete(ReportsPageLoaded(reports(20, prefix: 'Eski')));
    await pending;
    await pager.loadMore();

    // Assert: yeni sekmede sayfalama kilitli kalmadı.
    expect(pager.isLoadingMore, isFalse);
    expect(pager.items.last.place, 'Sonraki 4');
  });

  test('reload_ignoresLoadMoreThatStartedBefore', () async {
    // Arrange
    final slow = Completer<ReportsPageResult>();
    final pages = FakePages([
      loaded(reports(20)),
      slow.future,
      loaded(reports(20, prefix: 'Taze')),
    ]);
    final pager = ReportPager(pages.fetch);
    await pager.reload();
    final pending = pager.loadMore();

    // Act: sonraki sayfa beklenirken liste yenilenir (ör. üstlenmeden sonra).
    await pager.reload();
    slow.complete(ReportsPageLoaded(reports(20, prefix: 'Eski')));
    await pending;

    // Assert: eski offset'le gelen sayfa yeni listeye eklenmez.
    expect(pager.items, hasLength(20));
    expect(pager.items.first.place, 'Taze 0');
    expect(pager.isLoadingMore, isFalse);
  });
}
