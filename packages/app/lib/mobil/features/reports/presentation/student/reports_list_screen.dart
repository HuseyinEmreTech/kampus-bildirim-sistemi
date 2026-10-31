import 'dart:async';

import 'package:flutter/material.dart';

import '../../data/report_creator.dart';
import '../../data/reports_source.dart';
import '../../state/report_pager.dart';
import '../widgets/report_list_body.dart';
import 'report_create_screen.dart';

/// Öğrencinin kendi bildirimlerini listeleyen ekran; aşağı kaydırdıkça
/// sonraki sayfa yüklenir, "+" ile yeni bildirim açılır.
class ReportsListScreen extends StatefulWidget {
  const ReportsListScreen({
    super.key,
    required this.source,
    required this.creator,
  });

  final ReportsSource source;

  /// "Bildirim oluştur" ekranına verilen kaynak.
  final ReportCreator creator;

  @override
  State<ReportsListScreen> createState() => _ReportsListScreenState();
}

class _ReportsListScreenState extends State<ReportsListScreen> {
  late final _pager = ReportPager(widget.source.fetchPage);
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
    unawaited(_pager.reload());
  }

  @override
  void dispose() {
    _scroll.dispose();
    _pager.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scroll.position.extentAfter > loadMoreThreshold) return;
    unawaited(_pager.loadMore());
  }

  /// Oluşturma ekranını açar; bildirim oluşturulduysa listeyi baştan yükler.
  Future<void> _openCreateScreen() async {
    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => ReportCreateScreen(creator: widget.creator),
      ),
    );
    if (created != true) return;
    await _pager.reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bildirimlerim')),
      body: ListenableBuilder(
        listenable: _pager,
        builder: (context, _) => ReportListBody(
          isLoading: _pager.isLoading,
          loadFailed: _pager.loadFailed,
          items: _pager.items,
          emptyMessage: 'Henüz bildiriminiz yok',
          onRefresh: _pager.reload,
          onRetry: () => unawaited(_pager.reset()),
          controller: _scroll,
          isLoadingMore: _pager.isLoadingMore,
          loadMoreFailed: _pager.loadMoreFailed,
          onRetryMore: () => unawaited(_pager.retryMore()),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openCreateScreen,
        tooltip: 'Bildirim oluştur',
        child: const Icon(Icons.add),
      ),
    );
  }
}
