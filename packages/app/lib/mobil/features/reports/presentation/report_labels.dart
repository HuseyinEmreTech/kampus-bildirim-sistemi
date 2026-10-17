import 'package:flutter/material.dart';

import '../data/report_list_item.dart';

/// Kategori ve durumun ekranda görünen adı ve rengi; kart ve detay ortak kullanır.
String categoryLabel(ReportCategory category) => switch (category) {
  ReportCategory.ariza => 'Arıza',
  ReportCategory.temizlik => 'Temizlik',
  ReportCategory.guvenlik => 'Güvenlik',
  ReportCategory.diger => 'Diğer',
};

Color categoryColor(ReportCategory category) => switch (category) {
  ReportCategory.ariza => Colors.orange,
  ReportCategory.temizlik => Colors.teal,
  ReportCategory.guvenlik => Colors.red,
  ReportCategory.diger => Colors.blueGrey,
};

String statusLabel(ReportStatus status) => switch (status) {
  ReportStatus.yeni => 'Yeni',
  ReportStatus.ustlenildi => 'Üstlenildi',
  ReportStatus.cozuldu => 'Çözüldü',
};
