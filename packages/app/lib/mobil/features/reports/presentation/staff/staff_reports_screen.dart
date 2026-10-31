import 'dart:async';

import 'package:flutter/material.dart';

import '../../data/report_assigner.dart';
import '../../data/report_list_item.dart';
import '../../data/staff_reports_source.dart';
import '../../state/report_pager.dart';
import '../student/widgets/report_card.dart';
import '../widgets/report_list_body.dart';

/// Görevlinin bildirim listesi: "Gelen" ve "Benimkiler" sekmeleri ve kategori
/// filtresi (USR 04); "Gelen"deki bildirimler buradan üstlenilir (USR 05).
/// Aşağı kaydırdıkça sonraki sayfa yüklenir.
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
  StaffReportsView _view = StaffReportsView.incoming;

  /// Seçili kategori; `null` ise tüm kategoriler.
  ReportCategory? _category;

  /// Sekme ya da kategori değişince `reset` ile baştan yüklenir; eski
  /// seçimin geç gelen cevabı yok sayılır.
  late final _pager = ReportPager(
    ({required offset, required limit}) => widget.source.fetchPage(
      _view,
      category: _category,
      offset: offset,
      limit: limit,
    ),
  );
  final _scroll = ScrollController();

  /// Üstlenme isteği süren bildirim; o kartın düğmesi kilitlenir.
  String? _assigningId;

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
    await _pager.reload();
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
    unawaited(_pager.reset());
  }

  void _selectView(StaffReportsView view) {
    setState(() => _view = view);
    unawaited(_pager.reset());
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
              onSelectionChanged: (selection) => _selectView(selection.first),
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
            child: ListenableBuilder(
              listenable: _pager,
              builder: (context, _) => ReportListBody(
                isLoading: _pager.isLoading,
                loadFailed: _pager.loadFailed,
                items: _pager.items,
                emptyMessage: switch (_view) {
                  StaffReportsView.incoming => 'Bekleyen bildirim yok',
                  StaffReportsView.mine => 'Üstlendiğiniz bildirim yok',
                },
                onRefresh: _pager.reload,
                onRetry: () => unawaited(_pager.reset()),
                actionBuilder: _view == StaffReportsView.incoming
                    ? _buildAssignButton
                    : null,
                controller: _scroll,
                isLoadingMore: _pager.isLoadingMore,
                loadMoreFailed: _pager.loadMoreFailed,
                onRetryMore: () => unawaited(_pager.retryMore()),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
