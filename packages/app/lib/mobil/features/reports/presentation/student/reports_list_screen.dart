import 'dart:async';

import 'package:flutter/material.dart';

import '../../data/report_list_item.dart';
import '../../data/reports_source.dart';
import 'widgets/report_card.dart';

/// Öğrencinin kendi bildirimlerini listeleyen ekran.
///
/// Şimdilik yalnızca ilk sayfa yüklenir; aşağı kaydırınca devamını yükleme
/// ayrı PR'da eklenecek.
class ReportsListScreen extends StatefulWidget {
  const ReportsListScreen({super.key, required this.source});

  final ReportsSource source;

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

  void _retry() {
    setState(() => _isLoading = true);
    unawaited(_loadFirstPage());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bildirimlerim')),
      body: _buildBody(),
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
      itemBuilder: (context, index) => ReportCard(report: _items[index]),
    );
  }
}
