import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../ortak/features/reports/data/report_list_item.dart';
import '../../../../ortak/features/reports/data/reports_source.dart';
import '../../../../ortak/responsive/responsive_layout.dart';
import 'widgets/report_detail_panel.dart';
import 'widgets/reports_sidebar.dart';

class ReportsListWeb extends StatefulWidget {
  const ReportsListWeb({
    super.key,
    required this.source,
    this.isStaff = false,
    this.onCreateReport,
    this.onAssignReport,
    this.onResolveReport,
  });

  final ReportsSource source;
  final bool isStaff;
  final VoidCallback? onCreateReport;
  final Future<void> Function(ReportListItem report)? onAssignReport;
  final Future<void> Function(ReportListItem report)? onResolveReport;

  @override
  State<ReportsListWeb> createState() => _ReportsListWebState();
}

class _ReportsListWebState extends State<ReportsListWeb> {
  List<ReportListItem> _items = [];
  ReportListItem? _selectedReport;
  ReportStatus? _statusFilter;
  ReportCategory? _categoryFilter;
  DateTimeRange? _dateRange;
  bool _isLoading = true;
  bool _loadFailed = false;

  @override
  void initState() {
    super.initState();
    unawaited(_loadReports());
  }

  Future<void> _loadReports() async {
    final result = await widget.source.fetchPage(
      offset: 0,
      limit: reportsPageSize,
    );
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      switch (result) {
        case ReportsPageLoaded(:final items):
          _items = items;
          _loadFailed = false;
          if (_selectedReport != null && !items.contains(_selectedReport)) {
            _selectedReport = null;
          }
        case ReportsPageFailed():
          _loadFailed = true;
      }
    });
  }

  List<ReportListItem> get _filteredItems => _items
      .where((report) {
        if (_statusFilter != null && report.status != _statusFilter) {
          return false;
        }
        if (_categoryFilter != null && report.category != _categoryFilter) {
          return false;
        }
        final range = _dateRange;
        if (range != null &&
            (report.createdAt.isBefore(range.start) ||
                report.createdAt.isAfter(
                  DateTime(
                    range.end.year,
                    range.end.month,
                    range.end.day,
                    23,
                    59,
                    59,
                    999,
                  ),
                ))) {
          return false;
        }
        return true;
      })
      .toList(growable: false);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bildirimler')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _loadFailed && _items.isEmpty
          ? _loadError()
          : ResponsiveLayout(
              mobile: _mobileLayout(),
              tablet: _tabletLayout(),
              desktop: _desktopLayout(),
            ),
    );
  }

  Widget _loadError() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Bildirimler yüklenemedi'),
          const SizedBox(height: 8),
          FilledButton(
            onPressed: () {
              setState(() => _isLoading = true);
              unawaited(_loadReports());
            },
            child: const Text('Tekrar dene'),
          ),
        ],
      ),
    );
  }

  Widget _mobileLayout() {
    return _sidebar(
      onSelect: (report) => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (context) => Scaffold(
            appBar: AppBar(title: const Text('Bildirim detayı')),
            body: _detail(report),
          ),
        ),
      ),
    );
  }

  Widget _tabletLayout() {
    return _sidebar(
      onSelect: (report) async {
        await showModalBottomSheet<void>(
          context: context,
          isScrollControlled: true,
          builder: (context) => SafeArea(
            child: SizedBox(
              height: MediaQuery.sizeOf(context).height * 0.9,
              child: _detail(report),
            ),
          ),
        );
      },
    );
  }

  Widget _desktopLayout() {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: _sidebar(
            onSelect: (report) => setState(() => _selectedReport = report),
          ),
        ),
        const VerticalDivider(width: 1),
        Expanded(flex: 3, child: _detail(_selectedReport)),
      ],
    );
  }

  Widget _sidebar({required ValueChanged<ReportListItem> onSelect}) {
    return ReportsSidebar(
      items: _filteredItems,
      isStaff: widget.isStaff,
      onRefresh: _loadReports,
      onSelect: onSelect,
      onCreateReport: widget.onCreateReport,
      selectedReport: _selectedReport,
      statusFilter: _statusFilter,
      categoryFilter: _categoryFilter,
      dateRange: _dateRange,
      onStatusChanged: (value) => setState(() => _statusFilter = value),
      onCategoryChanged: (value) => setState(() => _categoryFilter = value),
      onDateRangeChanged: (value) => setState(() => _dateRange = value),
    );
  }

  Widget _detail(ReportListItem? report) => ReportDetailPanel(
    report: report,
    isStaff: widget.isStaff,
    onAssign: widget.onAssignReport,
    onResolve: widget.onResolveReport,
  );
}
