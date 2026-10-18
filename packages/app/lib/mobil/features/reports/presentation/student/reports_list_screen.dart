import 'dart:async';

import 'package:flutter/material.dart';

import '../../data/report_creator.dart';
import '../../data/report_list_item.dart';
import '../../data/reports_source.dart';
import 'report_create_screen.dart';
import 'widgets/report_card.dart';

/// Listenin sonuna bu kadar (piksel) kala bir sonraki sayfa istenir.
const _loadMoreThreshold = 200.0;

/// Öğrencinin kendi bildirimlerini listeleyen ekran; aşağı kaydırdıkça
/// sonraki sayfa yüklenir. Gelen sayfa tam dolu değilse son sayfadır.
class ReportsListScreen extends StatefulWidget {
  const ReportsListScreen({
    super.key,
    required this.source,
    required this.creator,
    this.onReportTap,
  });

  final ReportsSource source;

  /// "Bildirim oluştur" ekranına verilen kaynak.
  final ReportCreator creator;

  /// Karta dokununca (ör. detayı açmak için).
  final ValueChanged<ReportListItem>? onReportTap;

  @override
  State<ReportsListScreen> createState() => _ReportsListScreenState();
}

class _ReportsListScreenState extends State<ReportsListScreen> {
  final _items = <ReportListItem>[];
  final _scroll = ScrollController();
  bool _isLoading = true;
  bool _loadFailed = false;
  int _loadedPages = 0;
  bool _hasMore = true;
  bool _isLoadingMore = false;
  bool _loadMoreFailed = false;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
    unawaited(_loadFirstPage());
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  /// İlk sayfayı baştan yükler; açılışta, yenilemede ve "Tekrar dene"de.
  Future<void> _loadFirstPage() async {
    final result = await widget.source.fetchPage(
      page: 1,
      pageSize: reportsPageSize,
    );
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      switch (result) {
        case ReportsPageLoaded(:final items):
          _loadFailed = false;
          _items
            ..clear()
            ..addAll(items);
          _loadedPages = 1;
          _hasMore = items.length == reportsPageSize;
          _loadMoreFailed = false;
        case ReportsPageFailed():
          _loadFailed = true;
      }
    });
  }

  void _onScroll() {
    if (_scroll.position.extentAfter > _loadMoreThreshold) return;
    if (!_hasMore || _isLoadingMore || _loadMoreFailed) return;
    unawaited(_loadNextPage());
  }

  /// Bir sonraki sayfayı listenin sonuna ekler.
  Future<void> _loadNextPage() async {
    setState(() {
      _isLoadingMore = true;
      _loadMoreFailed = false;
    });
    final result = await widget.source.fetchPage(
      page: _loadedPages + 1,
      pageSize: reportsPageSize,
    );
    if (!mounted) return;
    setState(() {
      _isLoadingMore = false;
      switch (result) {
        case ReportsPageLoaded(:final items):
          _items.addAll(items);
          _loadedPages++;
          _hasMore = items.length == reportsPageSize;
        case ReportsPageFailed():
          _loadMoreFailed = true;
      }
    });
  }

  /// Oluşturma ekranını açar; bildirim oluşturulduysa listeyi baştan yükler.
  Future<void> _openCreateScreen() async {
    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => ReportCreateScreen(creator: widget.creator),
      ),
    );
    if (created != true) return;
    await _loadFirstPage();
  }

  void _retry() {
    setState(() => _isLoading = true);
    unawaited(_loadFirstPage());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bildirimlerim')),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: _openCreateScreen,
        tooltip: 'Bildirim oluştur',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_loadFailed && _items.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Bildirimler yüklenemedi'),
            const SizedBox(height: 8),
            FilledButton(onPressed: _retry, child: const Text('Tekrar dene')),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _loadFirstPage,
      child: _items.isEmpty ? _buildEmpty() : _buildList(),
    );
  }

  /// Boş durum da kaydırılabilir olmalı ki aşağı çekip yenilenebilsin.
  Widget _buildEmpty() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: const [
        SizedBox(height: 120),
        Center(child: Text('Henüz bildiriminiz yok')),
      ],
    );
  }

  Widget _buildList() {
    final showFooter = _isLoadingMore || _loadMoreFailed;
    return ListView.builder(
      controller: _scroll,
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: _items.length + (showFooter ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _items.length) return _buildFooter();
        final report = _items[index];
        final onReportTap = widget.onReportTap;
        return ReportCard(
          report: report,
          onTap: onReportTap == null ? null : () => onReportTap(report),
        );
      },
    );
  }

  /// Listenin sonu: sonraki sayfa yükleniyor ya da yüklenemedi.
  Widget _buildFooter() {
    if (!_loadMoreFailed) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    return Column(
      children: [
        const Text('Daha fazlası yüklenemedi'),
        TextButton(
          onPressed: () => unawaited(_loadNextPage()),
          child: const Text('Tekrar dene'),
        ),
      ],
    );
  }
}
