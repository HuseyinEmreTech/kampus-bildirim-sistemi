import 'dart:async';

import 'package:flutter/material.dart';

import '../../data/report_creator.dart';
import '../../data/report_list_item.dart';
import '../../data/reports_source.dart';
import 'report_create_screen.dart';
import 'widgets/report_card.dart';

/// Öğrencinin kendi bildirimlerini listeleyen ekran.
///
/// Şimdilik yalnızca ilk sayfa yüklenir; aşağı kaydırınca devamını yükleme
/// ayrı PR'da eklenecek.
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
  bool _isLoading = true;
  bool _loadFailed = false;

  @override
  void initState() {
    super.initState();
    unawaited(_loadFirstPage());
  }

  /// İlk sayfayı baştan yükler; açılışta, yenilemede ve "Tekrar dene"de.
  Future<void> _loadFirstPage() async {
    final result = await widget.source.fetchPage(
      offset: 0,
      limit: reportsPageSize,
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
        case ReportsPageFailed():
          _loadFailed = true;
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
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: _items.length,
      itemBuilder: (context, index) {
        final report = _items[index];
        final onReportTap = widget.onReportTap;
        return ReportCard(
          report: report,
          onTap: onReportTap == null ? null : () => onReportTap(report),
        );
      },
    );
  }
}
