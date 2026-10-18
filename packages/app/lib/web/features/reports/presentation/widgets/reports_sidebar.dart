import 'package:flutter/material.dart';

import '../../../../../ortak/features/reports/data/report_list_item.dart';
import '../../../../../ortak/features/reports/presentation/report_card.dart';
import 'filter_bar.dart';

class ReportsSidebar extends StatelessWidget {
  const ReportsSidebar({
    super.key,
    required this.items,
    required this.isStaff,
    required this.onRefresh,
    required this.onSelect,
    required this.onCreateReport,
    this.selectedReport,
    this.statusFilter,
    this.categoryFilter,
    this.dateRange,
    required this.onStatusChanged,
    required this.onCategoryChanged,
    required this.onDateRangeChanged,
  });

  final List<ReportListItem> items;
  final bool isStaff;
  final Future<void> Function() onRefresh;
  final ValueChanged<ReportListItem> onSelect;
  final VoidCallback? onCreateReport;
  final ReportListItem? selectedReport;
  final ReportStatus? statusFilter;
  final ReportCategory? categoryFilter;
  final DateTimeRange? dateRange;
  final ValueChanged<ReportStatus?> onStatusChanged;
  final ValueChanged<ReportCategory?> onCategoryChanged;
  final ValueChanged<DateTimeRange?> onDateRangeChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (isStaff)
          FilterBar(
            status: statusFilter,
            category: categoryFilter,
            dateRange: dateRange,
            onStatusChanged: onStatusChanged,
            onCategoryChanged: onCategoryChanged,
            onDateRangeChanged: onDateRangeChanged,
          ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: onRefresh,
            child: items.isEmpty ? _emptyState() : _reportList(),
          ),
        ),
      ],
    );
  }

  Widget _emptyState() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 100),
        const Center(child: Text('Henüz bildirim yok')),
        const SizedBox(height: 16),
        Center(
          child: isStaff
              ? OutlinedButton.icon(
                  onPressed: onRefresh,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Yenile'),
                )
              : FilledButton.icon(
                  onPressed: onCreateReport,
                  icon: const Icon(Icons.add),
                  label: const Text('Bildirim Oluştur'),
                ),
        ),
      ],
    );
  }

  Widget _reportList() {
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final report = items[index];
        return ReportCard(
          report: report,
          isSelected: identical(report, selectedReport),
          onTap: () => onSelect(report),
        );
      },
    );
  }
}
