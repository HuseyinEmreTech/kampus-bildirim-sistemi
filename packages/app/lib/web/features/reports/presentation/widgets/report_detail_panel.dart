import 'package:flutter/material.dart';

import '../../../../../ortak/features/reports/data/report_list_item.dart';
import '../../../../../ortak/features/reports/presentation/report_card.dart';
import '../../../../../ortak/features/reports/presentation/status_badge.dart';

class ReportDetailPanel extends StatelessWidget {
  const ReportDetailPanel({
    super.key,
    this.report,
    this.isStaff = false,
    this.onAssign,
    this.onResolve,
  });

  final ReportListItem? report;
  final bool isStaff;
  final Future<void> Function(ReportListItem report)? onAssign;
  final Future<void> Function(ReportListItem report)? onResolve;

  @override
  Widget build(BuildContext context) {
    final selected = report;
    if (selected == null) {
      return const Center(child: Text('Bir bildirim seçin'));
    }

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _photo(selected),
        const SizedBox(height: 20),
        Text(
          reportCategoryLabel(selected.category),
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        StatusBadge(status: selected.status),
        const SizedBox(height: 20),
        Text('Açıklama', style: Theme.of(context).textTheme.titleMedium),
        Text(
          selected.description?.trim().isNotEmpty == true
              ? selected.description!
              : 'Açıklama eklenmemiş.',
        ),
        const SizedBox(height: 20),
        Text('Konum', style: Theme.of(context).textTheme.titleMedium),
        Card(
          child: ListTile(
            leading: const Icon(Icons.location_on_outlined),
            title: Text(selected.place),
            subtitle: const Text('Harita verisi mevcut değil'),
          ),
        ),
        const SizedBox(height: 20),
        Text('Durum geçmişi', style: Theme.of(context).textTheme.titleMedium),
        ListTile(
          leading: Icon(
            Icons.circle,
            color: reportCategoryColor(selected.category),
            size: 14,
          ),
          title: Text(reportStatusLabel(selected.status)),
          subtitle: Text(_formatDate(selected.createdAt)),
        ),
        if (isStaff) ...[
          const SizedBox(height: 16),
          if (selected.status == ReportStatus.yeni)
            FilledButton(
              onPressed: onAssign == null
                  ? null
                  : () => _confirmAction(
                      context,
                      title: 'Bildirimi üstlen?',
                      action: () => onAssign!(selected),
                    ),
              child: const Text('Üstlen'),
            ),
          if (selected.status != ReportStatus.cozuldu)
            OutlinedButton(
              onPressed: onResolve == null
                  ? null
                  : () => _confirmAction(
                      context,
                      title: 'Bildirimi çözüldü olarak işaretle?',
                      action: () => onResolve!(selected),
                    ),
              child: const Text('Çöz'),
            ),
        ],
      ],
    );
  }

  Widget _photo(ReportListItem selected) {
    final imageUrl = selected.imageUrl;
    if (imageUrl == null || imageUrl.isEmpty) {
      return Container(
        height: 240,
        color: Colors.black12,
        alignment: Alignment.center,
        child: const Icon(Icons.image_not_supported_outlined, size: 48),
      );
    }

    return Image.network(
      imageUrl,
      height: 320,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Container(
        height: 240,
        color: Colors.black12,
        alignment: Alignment.center,
        child: const Icon(Icons.broken_image_outlined, size: 48),
      ),
    );
  }

  Future<void> _confirmAction(
    BuildContext context, {
    required String title,
    required Future<void> Function() action,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('İptal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Onayla'),
          ),
        ],
      ),
    );
    if (confirmed == true) await action();
  }
}

String _formatDate(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  return '$day.$month.${date.year}';
}
