import 'package:flutter/material.dart';

import '../data/report_list_item.dart';
import 'status_badge.dart';

class ReportCard extends StatelessWidget {
  const ReportCard({
    super.key,
    required this.report,
    this.onTap,
    this.isSelected = false,
    this.action,
  });

  final ReportListItem report;
  final VoidCallback? onTap;
  final bool isSelected;

  /// Kartın altında sağda gösterilen isteğe bağlı düğme (ör. görevlinin
  /// "Üstlen"i); verilmezse kart eskisi gibidir.
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final color = _categoryColor(report.category);
    final action = this.action;
    return Card(
      clipBehavior: Clip.antiAlias,
      color: isSelected
          ? Theme.of(context).colorScheme.secondaryContainer
          : null,
      child: InkWell(
        onTap: onTap,
        mouseCursor: onTap == null
            ? SystemMouseCursors.basic
            : SystemMouseCursors.click,
        hoverColor: Theme.of(context).colorScheme.primary
            .withValues(alpha: 0.08),
        child: Column(
          children: [
            ListTile(
              leading: _thumbnail(color),
              title: Text(_categoryLabel(report.category)),
              subtitle: Text(
                '${report.place}\n${_formatDate(report.createdAt)}',
              ),
              isThreeLine: true,
              trailing: StatusBadge(status: report.status),
            ),
            if (action != null)
              Padding(
                padding: const EdgeInsets.only(right: 8, bottom: 8),
                child: Align(alignment: Alignment.centerRight, child: action),
              ),
          ],
        ),
      ),
    );
  }

  Widget _thumbnail(Color color) {
    final imageUrl = report.imageUrl;
    if (imageUrl == null || imageUrl.isEmpty) {
      return CircleAvatar(
        backgroundColor: color,
        child: const Icon(Icons.report_problem, color: Colors.white),
      );
    }

    return ClipRRect(
      key: const Key('report-thumbnail'),
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        imageUrl,
        width: 48,
        height: 48,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => CircleAvatar(
          backgroundColor: color,
          child: const Icon(Icons.broken_image, color: Colors.white),
        ),
      ),
    );
  }
}

String reportCategoryLabel(ReportCategory category) => _categoryLabel(category);

Color reportCategoryColor(ReportCategory category) => _categoryColor(category);

String reportStatusLabel(ReportStatus status) => switch (status) {
  ReportStatus.yeni => 'Yeni',
  ReportStatus.ustlenildi => 'Üstlenildi',
  ReportStatus.cozuldu => 'Çözüldü',
};

String _categoryLabel(ReportCategory category) => switch (category) {
  ReportCategory.ariza => 'Arıza',
  ReportCategory.temizlik => 'Temizlik',
  ReportCategory.guvenlik => 'Güvenlik',
  ReportCategory.diger => 'Diğer',
};

Color _categoryColor(ReportCategory category) => switch (category) {
  ReportCategory.ariza => Colors.orange,
  ReportCategory.temizlik => Colors.teal,
  ReportCategory.guvenlik => Colors.red,
  ReportCategory.diger => Colors.blueGrey,
};

String _formatDate(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  return '$day.$month.${date.year}';
}
