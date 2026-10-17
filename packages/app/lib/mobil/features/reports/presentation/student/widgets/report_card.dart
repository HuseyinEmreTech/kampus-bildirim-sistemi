import 'package:flutter/material.dart';

import '../../../../../shared/date_format.dart';
import '../../../data/report_list_item.dart';
import '../../report_labels.dart';

/// Listede tek bir bildirimi gösteren kart.
class ReportCard extends StatelessWidget {
  const ReportCard({super.key, required this.report});

  final ReportListItem report;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: categoryColor(report.category),
          child: const Icon(Icons.report_problem, color: Colors.white),
        ),
        title: Text(categoryLabel(report.category)),
        subtitle: Text('${report.place}\n${formatDate(report.createdAt)}'),
        isThreeLine: true,
        trailing: Chip(label: Text(statusLabel(report.status))),
      ),
    );
  }
}
