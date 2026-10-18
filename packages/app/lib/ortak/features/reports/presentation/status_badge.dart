import 'package:flutter/material.dart';

import '../data/report_list_item.dart';

class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.status});

  final ReportStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      ReportStatus.yeni => ('Yeni', Colors.blue),
      ReportStatus.ustlenildi => ('Üstlenildi', Colors.orange),
      ReportStatus.cozuldu => ('Çözüldü', Colors.green),
    };

    return Chip(
      label: Text(label),
      backgroundColor: color.withValues(alpha: 0.12),
      side: BorderSide(color: color.withValues(alpha: 0.35)),
      visualDensity: VisualDensity.compact,
    );
  }
}
