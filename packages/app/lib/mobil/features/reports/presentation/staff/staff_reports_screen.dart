import 'dart:async';

import 'package:flutter/material.dart';

import '../../data/report_assigner.dart';
import '../../../../shared/photo/photo_picker.dart';
import '../../data/report_list_item.dart';
import '../../data/report_resolver.dart';
import '../../data/reports_source.dart';
import '../../data/staff_reports_source.dart';
import '../../state/report_pager.dart';
import '../report_labels.dart';
import '../widgets/report_list_body.dart';
import 'resolve_screen.dart';

/// Görevlinin bildirim listesi: "Gelen" ve "Benimkiler" sekmeleri ve kategori
/// filtresi (USR 04); "Gelen"deki bildirimler buradan üstlenilir (USR 05).
class StaffReportsScreen extends StatefulWidget {
  const StaffReportsScreen({
    super.key,
    required this.source,
    required this.assigner,
    required this.resolver,
    required this.photoPicker,
    this.onReportTap,
  });

  final StaffReportsSource source;
  final ReportAssigner assigner;

  /// "Çöz" ekranı için (USR 06).
  final ReportResolver resolver;
  final PhotoPicker photoPicker;

  /// Karta dokununca (ör. detayı açmak için).
  final ValueChanged<ReportListItem>? onReportTap;

  @override
  State<StaffReportsScreen> createState() => _StaffReportsScreenState();
}

class _StaffReportsScreenState extends State<StaffReportsScreen> {
  StaffReportsView _view = StaffReportsView.incoming;

  /// Seçili kategori; `null` ise tüm kategoriler.
  ReportCategory? _category;

  /// Sayfalar her istekte o anki sekme ve kategoriyle istenir.
  late final _pager = ReportPager(
    (page) => widget.source.fetchPage(
      _view,
      category: _category,
      page: page,
      pageSize: reportsPageSize,
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

  /// Bildirimi üstlenir, sonucu söyler ve listeyi yeniler.
  Future<void> _assign(ReportListItem report) async {
    setState(() => _assigningId = report.id);
    final result = await widget.assigner.assign(report.id);
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

  /// Çözme ekranını açar; çözüldüyse listeyi yeniler.
  Future<void> _openResolve(ReportListItem report) async {
    final resolved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => ResolveScreen(
          reportId: report.id,
          resolver: widget.resolver,
          photoPicker: widget.photoPicker,
        ),
      ),
    );
    if (resolved != true) return;
    await _pager.reload();
  }

  /// Yalnızca üstlenilmiş (henüz çözülmemiş) bildirimde "Çöz".
  Widget? _buildResolveButton(ReportListItem report) {
    if (report.status != ReportStatus.ustlenildi) return null;
    return FilledButton.tonal(
      onPressed: () => _openResolve(report),
      child: const Text('Çöz'),
    );
  }

  Widget _buildAssignButton(ReportListItem report) {
    return FilledButton.tonal(
      onPressed: _assigningId == null ? () => _assign(report) : null,
      child: const Text('Üstlen'),
    );
  }

  void _selectCategory(ReportCategory? category) {
    setState(() => _category = category);
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
                  child: Text(categoryLabel(category)),
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
                actionBuilder: switch (_view) {
                  StaffReportsView.incoming => _buildAssignButton,
                  StaffReportsView.mine => _buildResolveButton,
                },
                onTap: widget.onReportTap,
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
