import 'package:flutter/material.dart';

import '../../data/report_list_item.dart';
import '../student/widgets/report_card.dart';

/// Bildirim listelerinin ortak gövdesi: yükleniyor, hata ve "Tekrar dene",
/// boş durum ya da aşağı çekip yenilenebilen liste.
class ReportListBody extends StatelessWidget {
  const ReportListBody({
    super.key,
    required this.isLoading,
    required this.loadFailed,
    required this.items,
    required this.emptyMessage,
    required this.onRefresh,
    required this.onRetry,
  });

  final bool isLoading;
  final bool loadFailed;
  final List<ReportListItem> items;
  final String emptyMessage;
  final Future<void> Function() onRefresh;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (loadFailed && items.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Bildirimler yüklenemedi'),
            const SizedBox(height: 8),
            FilledButton(onPressed: onRetry, child: const Text('Tekrar dene')),
          ],
        ),
      );
    }
    // Boş durum da kaydırılabilir olmalı ki aşağı çekip yenilenebilsin.
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: items.isEmpty ? 1 : items.length,
        itemBuilder: (context, index) => items.isEmpty
            ? Padding(
                padding: const EdgeInsets.only(top: 120),
                child: Center(child: Text(emptyMessage)),
              )
            : ReportCard(report: items[index]),
      ),
    );
  }
}
