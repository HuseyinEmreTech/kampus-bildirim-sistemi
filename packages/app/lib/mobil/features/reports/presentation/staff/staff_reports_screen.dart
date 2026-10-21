import 'dart:async';

import 'package:flutter/material.dart';

import '../../data/report_assigner.dart';
import '../../data/report_list_item.dart';
import '../../data/reports_source.dart';
import '../../data/staff_reports_source.dart';
import '../student/widgets/report_card.dart';
import '../widgets/report_list_body.dart';

/// Görevlinin bildirim listesi: "Gelen" ve "Benimkiler" sekmeleri ve kategori
/// filtresi (USR 04); "Gelen"deki bildirimler buradan üstlenilir (USR 05).
class StaffReportsScreen extends StatefulWidget {
  const StaffReportsScreen({
    super.key,
    required this.source,
    required this.assigner,
  });

  final StaffReportsSource source;
  final ReportAssigner assigner;

  @override
  State<StaffReportsScreen> createState() => _StaffReportsScreenState();
}

class _StaffReportsScreenState extends State<StaffReportsScreen> {
  final _items = <ReportListItem>[];
  StaffReportsView _view = StaffReportsView.incoming;

  /// Seçili kategori; `null` ise tüm kategoriler.
  ReportCategory? _category;
  bool _isLoading = true;
  bool _loadFailed = false;

  /// Üstlenme isteği süren bildirim; o kartın düğmesi kilitlenir.
  String? _assigningId;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  /// Seçili sekme ve kategorinin ilk sayfasını yükler.
  Future<void> _load() async {
    final view = _view;
    final category = _category;
    final result = await widget.source.fetchFirstPage(view, category: category);
    // Cevap gelene kadar ekran kapanmış ya da seçim değişmiş olabilir.
    if (!mounted || view != _view || category != _category) return;
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

  /// [reportId] kimlikli bildirimi üstlenir, sonucu söyler ve listeyi
  /// yeniler.
  Future<void> _assign(String reportId) async {
    setState(() => _assigningId = reportId);
    final result = await widget.assigner.assign(reportId);
    if (!mounted) return;

    setState(() => _assigningId = null);
    final message = switch (result) {
      ReportAssigned() => 'Bildirim üstlenildi',
      ReportAlreadyTaken() => 'Bu bildirimi başka bir görevli üstlendi',
      ReportAssignFailed() => 'Üstlenilemedi, tekrar deneyin',
    };
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
    if (result is ReportAssignFailed) return;
    await _load();
  }

  /// Kimliği olmayan bildirim üstlenilemez; düğme gösterilmez.
  Widget? _buildAssignButton(ReportListItem report) {
    final reportId = report.id;
    if (reportId == null) return null;
    return FilledButton.tonal(
      onPressed: _assigningId == null ? () => _assign(reportId) : null,
      child: const Text('Üstlen'),
    );
  }

  void _selectCategory(ReportCategory? category) {
    _category = category;
    _showLoadingAndReload();
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
          DropdownButton<ReportCategory?>(
            value: _category,
            onChanged: _selectCategory,
            items: [
              const DropdownMenuItem(child: Text('Tüm kategoriler')),
              for (final category in ReportCategory.values)
                DropdownMenuItem(
                  value: category,
                  child: Text(reportCategoryLabel(category)),
                ),
            ],
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
              actionBuilder: _view == StaffReportsView.incoming
                  ? _buildAssignButton
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}
