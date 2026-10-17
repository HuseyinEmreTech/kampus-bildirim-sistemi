import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../shared/date_format.dart';
import '../../data/report_detail.dart';
import '../../data/report_detail_source.dart';
import 'widgets/report_card.dart';

/// Fotoğrafların ekrandaki yüksekliği.
const _photoHeight = 200.0;

/// Bildirim detayı: kategori, durum, yer, tarih, açıklama ve fotoğraf (USR 02).
class ReportDetailScreen extends StatefulWidget {
  const ReportDetailScreen({
    super.key,
    required this.reportId,
    required this.source,
  });

  final String reportId;
  final ReportDetailSource source;

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
    );
  }
}

class _DetailView extends StatelessWidget {
  const _DetailView({required this.detail});

  final ReportDetail detail;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _Photo(url: detail.photoUrl),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          children: [
            Chip(label: Text(reportCategoryLabel(detail.category))),
            Chip(label: Text(reportStatusLabel(detail.status))),
          ],
        ),
        Text(detail.place, style: textTheme.titleMedium),
        Text(formatDate(detail.createdAt)),
        const SizedBox(height: 8),
        Text(detail.description),
      ],
    );
  }
}

/// Fotoğraf; yüklenemezse yerinde kırık resim simgesi.
class _Photo extends StatelessWidget {
  const _Photo({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    return Image.network(
      url,
      height: _photoHeight,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => const SizedBox(
        height: _photoHeight,
        child: Center(child: Icon(Icons.broken_image)),
      ),
    );
  }
}
