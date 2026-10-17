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
    this.actionBuilder,
    this.onTap,
  });

  final bool isLoading;
  final bool loadFailed;
  final List<ReportListItem> items;
  final String emptyMessage;
  final Future<void> Function() onRefresh;
  final VoidCallback onRetry;

  /// Verilirse her kartın altına bu düğme konur.
  final Widget Function(ReportListItem report)? actionBuilder;

  /// Verilirse karta dokununca çağrılır.
  final ValueChanged<ReportListItem>? onTap;

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
            : ReportCard(
                report: items[index],
                action: actionBuilder?.call(items[index]),
                onTap: _tapOf(items[index]),
              ),
      ),
    );
  }

  VoidCallback? _tapOf(ReportListItem report) {
    final onTap = this.onTap;
    return onTap == null ? null : () => onTap(report);
  }
}
