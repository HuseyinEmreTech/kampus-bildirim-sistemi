import 'package:flutter/material.dart';

import '../../../../../ortak/features/reports/data/report_list_item.dart';
import '../../../../../ortak/features/reports/presentation/report_card.dart';

class FilterBar extends StatelessWidget {
  const FilterBar({
    super.key,
    required this.status,
    required this.category,
    required this.dateRange,
    required this.onStatusChanged,
    required this.onCategoryChanged,
    required this.onDateRangeChanged,
  });

  final ReportStatus? status;
  final ReportCategory? category;
  final DateTimeRange? dateRange;
  final ValueChanged<ReportStatus?> onStatusChanged;
  final ValueChanged<ReportCategory?> onCategoryChanged;
  final ValueChanged<DateTimeRange?> onDateRangeChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          DropdownButtonFormField<ReportStatus?>(
            key: const Key('report-status-filter'),
            initialValue: status,
            decoration: const InputDecoration(labelText: 'Durum'),
            items: [
              const DropdownMenuItem<ReportStatus?>(
                value: null,
                child: Text('Tüm durumlar'),
              ),
              ...ReportStatus.values.map(
                (value) => DropdownMenuItem<ReportStatus?>(
                  value: value,
                  child: Text(reportStatusLabel(value)),
                ),
              ),
            ],
            onChanged: onStatusChanged,
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<ReportCategory?>(
            key: const Key('report-category-filter'),
            initialValue: category,
            decoration: const InputDecoration(labelText: 'Kategori'),
            items: [
              const DropdownMenuItem<ReportCategory?>(
                value: null,
                child: Text('Tüm kategoriler'),
              ),
              ...ReportCategory.values.map(
                (value) => DropdownMenuItem<ReportCategory?>(
                  value: value,
                  child: Text(reportCategoryLabel(value)),
                ),
              ),
            ],
            onChanged: onCategoryChanged,
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () async {
              final now = DateTime.now();
              final selected = await showDateRangePicker(
                context: context,
                firstDate: DateTime(now.year - 10),
                lastDate: DateTime(now.year + 1),
                initialDateRange: dateRange,
              );
              if (selected != null) onDateRangeChanged(selected);
            },
            icon: const Icon(Icons.date_range),
            label: Text(
              dateRange == null
                  ? 'Tarih aralığı'
                  : '${_formatDate(dateRange!.start)} - '
                        '${_formatDate(dateRange!.end)}',
            ),
          ),
          if (dateRange != null)
            TextButton(
              onPressed: () => onDateRangeChanged(null),
              child: const Text('Tarihi temizle'),
            ),
        ],
      ),
    );
  }
}

String _formatDate(DateTime date) =>
    '${date.day.toString().padLeft(2, '0')}.'
    '${date.month.toString().padLeft(2, '0')}.${date.year}';
