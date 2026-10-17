import 'dart:async';

import 'package:flutter/material.dart';

import '../../data/report_list_item.dart';
import '../../data/reports_source.dart';
import '../../data/staff_reports_source.dart';
import '../widgets/report_list_body.dart';

/// Görevlinin bildirim listesi: "Gelen" ve "Benimkiler" sekmeleri (USR 04).
class StaffReportsScreen extends StatefulWidget {
  const StaffReportsScreen({super.key, required this.source});

  final StaffReportsSource source;

  @override
  State<StaffReportsScreen> createState() => _StaffReportsScreenState();
}

class _StaffReportsScreenState extends State<StaffReportsScreen> {
  final _items = <ReportListItem>[];
  StaffReportsView _view = StaffReportsView.incoming;
  bool _isLoading = true;
  bool _loadFailed = false;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  /// Seçili sekmenin ilk sayfasını yükler.
  Future<void> _load() async {
    final view = _view;
    final result = await widget.source.fetchFirstPage(view);
    // Cevap gelene kadar ekran kapanmış ya da sekme değişmiş olabilir.
    if (!mounted || view != _view) return;
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

  void _showLoadingAndReload({StaffReportsView? view}) {
    setState(() {
      _view = view ?? _view;
      _isLoading = true;
      _items.clear();
    });
    unawaited(_load());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bildirimler')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: SegmentedButton<StaffReportsView>(
              segments: const [
                ButtonSegment(
                  value: StaffReportsView.incoming,
                  label: Text('Gelen'),
                ),
                ButtonSegment(
                  value: StaffReportsView.mine,
                  label: Text('Benimkiler'),
                ),
              ],
              selected: {_view},
              showSelectedIcon: false,
              onSelectionChanged: (selection) =>
                  _showLoadingAndReload(view: selection.first),
            ),
          ),
          Expanded(
            child: ReportListBody(
              isLoading: _isLoading,
              loadFailed: _loadFailed,
              items: _items,
              emptyMessage: switch (_view) {
                StaffReportsView.incoming => 'Bekleyen bildirim yok',
                StaffReportsView.mine => 'Üstlendiğiniz bildirim yok',
              },
              onRefresh: _load,
              onRetry: _showLoadingAndReload,
            ),
          ),
        ],
      ),
    );
  }
}
