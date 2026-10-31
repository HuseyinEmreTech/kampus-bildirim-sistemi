import 'dart:async';

import 'package:flutter/material.dart';

import '../../data/report_creator.dart';
import '../../data/report_list_item.dart';
import '../../data/reports_source.dart';
import '../widgets/report_list_body.dart';
import 'report_create_screen.dart';

/// Öğrencinin kendi bildirimlerini listeleyen ekran; "+" ile yeni bildirim
/// açılır.
///
/// Şimdilik yalnızca ilk sayfa yüklenir; aşağı kaydırınca devamını yükleme
/// ayrı PR'da eklenecek.
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bildirimlerim')),
      body: ReportListBody(
        isLoading: _isLoading,
        loadFailed: _loadFailed,
        items: _items,
        emptyMessage: 'Henüz bildiriminiz yok',
        onRefresh: _loadFirstPage,
        onRetry: _retry,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openCreateScreen,
        tooltip: 'Bildirim oluştur',
        child: const Icon(Icons.add),
      ),
    );
  }
}
