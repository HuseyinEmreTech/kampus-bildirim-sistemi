import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../shared/date_format.dart';
import '../../data/report_detail.dart';
import '../../data/report_detail_source.dart';
import '../report_labels.dart';

/// Fotoğrafların ekrandaki yüksekliği.
const _photoHeight = 200.0;

/// Bildirim detayı: bilgiler, fotoğraf ve durum geçmişi (USR 02); çözüldüyse
/// görevlinin sonuç fotoğrafı ve notu (USR 03).
class ReportDetailScreen extends StatefulWidget {
  const ReportDetailScreen({
    super.key,
    required this.reportId,
    required this.source,
    this.actionBuilder,
  });

  final String reportId;
  final ReportDetailSource source;

  /// Verilirse yüklenen detayın altında gösterilen işlem (ör. görevlinin
  /// Üstlen / Çöz düğmesi); `reload` detayı yeniden yükler.
  final Widget Function(ReportDetail detail, Future<void> Function() reload)?
  actionBuilder;

  @override
  State<ReportDetailScreen> createState() => _ReportDetailScreenState();
}

class _ReportDetailScreenState extends State<ReportDetailScreen> {
  /// `null` iken yükleniyor.
  ReportDetailResult? _result;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
    setState(() => _result = null);
    final result = await widget.source.fetch(widget.reportId);
    if (!mounted) return;
    setState(() => _result = result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bildirim detayı')),
      body: switch (_result) {
        null => const Center(child: CircularProgressIndicator()),
        ReportDetailLoaded(:final detail) => _DetailView(detail: detail),
        ReportDetailNotFound() => const Center(
          child: Text('Bildirim bulunamadı'),
        ),
        ReportDetailFailed() => Center(
          child: TextButton.icon(
            onPressed: _load,
            icon: const Icon(Icons.refresh),
            label: const Text('Tekrar dene'),
          ),
        ),
      },
      bottomNavigationBar: _buildAction(),
    );
  }

  Widget? _buildAction() {
    final actionBuilder = widget.actionBuilder;
    if (actionBuilder == null) return null;
    if (_result case ReportDetailLoaded(:final detail)) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: actionBuilder(detail, _load),
        ),
      );
    }
    return null;
  }
}

class _DetailView extends StatelessWidget {
  const _DetailView({required this.detail});

  final ReportDetail detail;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final resolution = detail.resolution;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _Photo(url: detail.photoUrl, label: 'Bildirim fotoğrafı'),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          children: [
            Chip(label: Text(categoryLabel(detail.category))),
            Chip(label: Text(statusLabel(detail.status))),
          ],
        ),
        Text(detail.place, style: textTheme.titleMedium),
        Text(formatDate(detail.createdAt)),
        const SizedBox(height: 8),
        Text(detail.description),
        if (resolution != null) ...[
          const SizedBox(height: 16),
          Text('Sonuç', style: textTheme.titleMedium),
          _Photo(url: resolution.photoUrl, label: 'Sonuç fotoğrafı'),
          if (resolution.note case final note?) Text(note),
        ],
        const SizedBox(height: 16),
        Text('Durum geçmişi', style: textTheme.titleMedium),
        for (final change in detail.history)
          ListTile(
            dense: true,
            leading: const Icon(Icons.circle, size: 12),
            title: Text(statusLabel(change.to)),
            // Not varsa tarihin yanına: "16.10.2026 · Yerine gidiliyor".
            subtitle: Text(
              [formatDate(change.changedAt), ?change.note].join(' · '),
            ),
          ),
      ],
    );
  }
}

/// Fotoğraf; yüklenemezse yerinde kırık resim simgesi. Ekran okuyucu iki
/// durumda da [label]'ı okur.
class _Photo extends StatelessWidget {
  const _Photo({required this.url, required this.label});

  final String url;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      image: true,
      label: label,
      child: Image.network(
        url,
        height: _photoHeight,
        fit: BoxFit.cover,
        excludeFromSemantics: true,
        errorBuilder: (_, _, _) => const SizedBox(
          height: _photoHeight,
          child: Center(child: Icon(Icons.broken_image)),
        ),
      ),
    );
  }
}
