import 'package:flutter/material.dart';

import '../../data/report_list_item.dart';
import '../student/widgets/report_card.dart';

/// Listenin sonuna bu kadar (piksel) kala bir sonraki sayfa istenir.
const loadMoreThreshold = 200.0;

/// Bildirim listelerinin ortak gövdesi: yükleniyor, hata ve "Tekrar dene",
/// boş durum ya da aşağı çekip yenilenebilen liste; sonunda sonraki sayfa
/// yükleniyor ya da yüklenemedi satırı.
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
    this.controller,
    this.isLoadingMore = false,
    this.loadMoreFailed = false,
    this.onRetryMore,
  });

  final bool isLoading;
  final bool loadFailed;
  final List<ReportListItem> items;
  final String emptyMessage;
  final Future<void> Function() onRefresh;
  final VoidCallback onRetry;

  /// Verilirse her kartın altına bu düğme konur.
  /// `null` dönerse o kartta düğme olmaz.
  final Widget? Function(ReportListItem report)? actionBuilder;

  /// Listenin kaydırma denetleyicisi (sona yaklaşınca sonraki sayfa için).
  final ScrollController? controller;
  final bool isLoadingMore;
  final bool loadMoreFailed;
  final VoidCallback? onRetryMore;

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
    if (items.isEmpty) return _buildEmpty();
    final showFooter = isLoadingMore || loadMoreFailed;
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.builder(
        controller: controller,
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: items.length + (showFooter ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == items.length) return _buildFooter();
          return ReportCard(
            report: items[index],
            action: actionBuilder?.call(items[index]),
          );
        },
      ),
    );
  }

  /// Boş durum da kaydırılabilir olmalı ki aşağı çekip yenilenebilsin.
  Widget _buildEmpty() {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 120),
            child: Center(child: Text(emptyMessage)),
          ),
        ],
      ),
    );
  }

  /// Listenin sonu: sonraki sayfa yükleniyor ya da yüklenemedi.
  Widget _buildFooter() {
    if (!loadMoreFailed) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    return Column(
      children: [
        const Text('Daha fazlası yüklenemedi'),
        TextButton(onPressed: onRetryMore, child: const Text('Tekrar dene')),
      ],
    );
  }
}
