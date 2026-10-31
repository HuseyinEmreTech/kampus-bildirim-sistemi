import 'package:flutter/foundation.dart';

import '../data/report_list_item.dart';
import '../data/reports_source.dart';

/// Bir sayfa isteği; `ReportsSource.fetchPage` doğrudan verilebilir.
typedef FetchReportsPage = Future<ReportsPageResult> Function({
  required int offset,
  required int limit,
});

/// Sayfalı bildirim listesinin durumu; ekranlar `ListenableBuilder` ile dinler.
///
/// Gelen sayfa tam dolu değilse son sayfa sayılır. [reset] çağrılınca önceki
/// isteklerin geç gelen cevabı yok sayılır (ör. sekme ya da filtre değişince).
class ReportPager extends ChangeNotifier {
  ReportPager(this._fetchPage, {this.pageSize = reportsPageSize});

  final FetchReportsPage _fetchPage;
  final int pageSize;

  final _items = <ReportListItem>[];
  bool _isLoading = true;
  bool _loadFailed = false;
  bool _hasMore = true;
  bool _isLoadingMore = false;
  bool _loadMoreFailed = false;

  /// Her [reset]'te artar; eski isteğin cevabı bununla ayırt edilir.
  int _generation = 0;
  bool _disposed = false;

  List<ReportListItem> get items => List.unmodifiable(_items);
  bool get isLoading => _isLoading;
  bool get loadFailed => _loadFailed;
  bool get hasMore => _hasMore;
  bool get isLoadingMore => _isLoadingMore;
  bool get loadMoreFailed => _loadMoreFailed;

  /// Listeyi boşaltıp yükleniyor gösterir ve ilk sayfayı ister.
  Future<void> reset() {
    _generation++;
    _items.clear();
    _isLoading = true;
    _notify();
    return reload();
  }

  /// İlk sayfayı yeniden ister; bu sırada eldeki liste görünür kalır.
  Future<void> reload() async {
    final generation = _generation;
    final result = await _fetchPage(offset: 0, limit: pageSize);
    if (generation != _generation) return;
    _isLoading = false;
    switch (result) {
      case ReportsPageLoaded(:final items):
        _loadFailed = false;
        _loadMoreFailed = false;
        _items
          ..clear()
          ..addAll(items);
        _hasMore = items.length == pageSize;
      case ReportsPageFailed():
        _loadFailed = true;
    }
    _notify();
  }

  /// Sonraki sayfayı listenin sonuna ekler; son sayfadaysa, istek sürüyorsa
  /// ya da önceki deneme başarısızsa bir şey yapmaz.
  Future<void> loadMore() async {
    if (!_hasMore || _isLoadingMore || _loadMoreFailed) return;
    final generation = _generation;
    _isLoadingMore = true;
    _notify();
    final result = await _fetchPage(offset: _items.length, limit: pageSize);
    if (generation != _generation) return;
    _isLoadingMore = false;
    switch (result) {
      case ReportsPageLoaded(:final items):
        _items.addAll(items);
        _hasMore = items.length == pageSize;
      case ReportsPageFailed():
        _loadMoreFailed = true;
    }
    _notify();
  }

  /// Başarısız sonraki sayfa isteğini yeniden dener.
  Future<void> retryMore() {
    _loadMoreFailed = false;
    return loadMore();
  }

  /// Ekran kapandıktan sonra gelen cevap dinleyicilere iletilmez.
  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
