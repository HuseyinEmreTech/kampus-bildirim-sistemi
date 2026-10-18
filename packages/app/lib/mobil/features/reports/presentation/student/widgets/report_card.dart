import 'package:flutter/material.dart';

import '../../../../../shared/date_format.dart';
import '../../../data/report_list_item.dart';
import '../../report_labels.dart';

/// Listede tek bir bildirimi gösteren kart.
class ReportCard extends StatelessWidget {
  const ReportCard({super.key, required this.report, this.action, this.onTap});

  final ReportListItem report;

  /// Kartın altında gösterilen isteğe bağlı düğme (ör. görevlinin "Üstlen"i).
  final Widget? action;

  /// Karta dokununca (ör. detayı açmak için).
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final action = this.action;
    return Card(
      child: Column(
        children: [
          _buildTile(),
          // Durum ve düğme altta: büyük yazıda başlığa yer kalsın; sığmazsa
          // düğme alt satıra iner.
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 8, 8),
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Chip(label: Text(statusLabel(report.status))),
                ?action,
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTile() {
    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: categoryColor(report.category),
        child: const Icon(Icons.report_problem, color: Colors.white),
      ),
      title: Text(categoryLabel(report.category)),
      subtitle: Text('${report.place}\n${formatDate(report.createdAt)}'),
      isThreeLine: true,
    );
  }
}
