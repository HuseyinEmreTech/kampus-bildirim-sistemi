import 'package:flutter/material.dart';

import '../../../data/report_list_item.dart';

/// Listede tek bir bildirimi gösteren kart.
class ReportCard extends StatelessWidget {
  const ReportCard({super.key, required this.report});

  final ReportListItem report;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _categoryColor(report.category),
          child: const Icon(Icons.report_problem, color: Colors.white),
        ),
        title: Text(_categoryLabel(report.category)),
        subtitle: Text('${report.place}\n${_formatDate(report.createdAt)}'),
        isThreeLine: true,
        trailing: Chip(label: Text(_statusLabel(report.status))),
      ),
    );
  }
}

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

String _statusLabel(ReportStatus status) => switch (status) {
  ReportStatus.yeni => 'Yeni',
  ReportStatus.ustlenildi => 'Üstlenildi',
  ReportStatus.cozuldu => 'Çözüldü',
};

/// Tarihi gün.ay.yıl biçiminde yazar (ek paket kullanmamak için elle).
String _formatDate(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  return '$day.$month.${date.year}';
}
