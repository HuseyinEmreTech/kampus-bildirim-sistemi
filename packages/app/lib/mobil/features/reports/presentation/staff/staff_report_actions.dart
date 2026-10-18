import 'package:flutter/material.dart';

import '../../../../shared/photo/photo_picker.dart';
import '../../data/report_assigner.dart';
import '../../data/report_detail.dart';
import '../../data/report_list_item.dart';
import '../../data/report_resolver.dart';
import 'resolve_screen.dart';

/// Görevlinin detay ekranındaki işlemi: yeni bildirimde "Üstlen" (USR 05),
/// üstlenilmişte "Çöz" (USR 06), çözülmüşte hiçbiri. İşlemden sonra
/// [onChanged] ile detay yeniden yüklenir.
class StaffReportActions extends StatefulWidget {
  const StaffReportActions({
    super.key,
    required this.detail,
    required this.assigner,
    required this.resolver,
    required this.photoPicker,
    required this.onChanged,
  });

  final ReportDetail detail;
  final ReportAssigner assigner;
  final ReportResolver resolver;
  final PhotoPicker photoPicker;
  final Future<void> Function() onChanged;

  @override
  State<StaffReportActions> createState() => _StaffReportActionsState();
}

class _StaffReportActionsState extends State<StaffReportActions> {
  bool _busy = false;

  Future<void> _assign() async {
    setState(() => _busy = true);
    final result = await widget.assigner.assign(widget.detail.id);
    if (!mounted) return;
    setState(() => _busy = false);
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(assignResultMessage(result))));
    if (result is ReportAssignFailed) return;
    await widget.onChanged();
  }

  Future<void> _resolve() async {
    final resolved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => ResolveScreen(
          reportId: widget.detail.id,
          resolver: widget.resolver,
          photoPicker: widget.photoPicker,
        ),
      ),
    );
    if (resolved != true) return;
    await widget.onChanged();
  }

  @override
  Widget build(BuildContext context) {
    return switch (widget.detail.status) {
      ReportStatus.yeni => FilledButton(
        onPressed: _busy ? null : _assign,
        child: const Text('Üstlen'),
      ),
      ReportStatus.ustlenildi => FilledButton(
        onPressed: _resolve,
        child: const Text('Çöz'),
      ),
      ReportStatus.cozuldu => const SizedBox.shrink(),
    };
  }
}
