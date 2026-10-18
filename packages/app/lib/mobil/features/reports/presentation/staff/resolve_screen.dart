import 'package:flutter/material.dart';

import '../../../../shared/photo/photo_field.dart';
import '../../../../shared/photo/photo_picker.dart';
import '../../data/report_resolver.dart';

/// Notun en çok karakter sayısı. API'de yazılı bir sınır yok (doğrulanmadı);
/// bildirim açıklamasıyla aynı tutuldu.
const resolutionNoteMaxLength = 500;

/// Görevlinin üstlendiği bildirimi çözüldü işaretlediği ekran (USR 06):
/// sonuç fotoğrafı zorunlu (Rule 04), not isteğe bağlı.
class ResolveScreen extends StatefulWidget {
  const ResolveScreen({
    super.key,
    required this.reportId,
    required this.resolver,
    required this.photoPicker,
  });

  final String reportId;
  final ReportResolver resolver;
  final PhotoPicker photoPicker;

  @override
  State<ResolveScreen> createState() => _ResolveScreenState();
}

class _ResolveScreenState extends State<ResolveScreen> {
  final _formKey = GlobalKey<FormState>();
  final _photoKey = GlobalKey<FormFieldState<PickedPhoto>>();
  final _noteController = TextEditingController();
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final photo = _photoKey.currentState?.value;
    if (!_formKey.currentState!.validate() || photo == null) return;

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });
    final note = _noteController.text.trim();
    final result = await widget.resolver.resolve(
      reportId: widget.reportId,
      photo: photo,
      note: note.isEmpty ? null : note,
    );
    if (!mounted) return;

    switch (result) {
      case ReportResolved():
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Bildirim çözüldü')));
        Navigator.of(context).pop(true);
      case ReportResolveRejected(:final message):
        _showError(message);
      case ReportResolveFailed():
        _showError('Gönderilemedi, tekrar deneyin');
    }
  }

  void _showError(String message) {
    setState(() {
      _isSubmitting = false;
      _errorMessage = message;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Çözüldü işaretle')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text('Sonuç fotoğrafı'),
            const SizedBox(height: 8),
            PhotoField(
              key: _photoKey,
              picker: widget.photoPicker,
              requiredMessage: 'Sonuç fotoğrafı ekleyin',
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _noteController,
              decoration: const InputDecoration(
                labelText: 'Not (isteğe bağlı)',
              ),
              maxLines: 3,
              maxLength: resolutionNoteMaxLength,
            ),
            if (_errorMessage case final message?)
              Text(
                message,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _isSubmitting ? null : _submit,
              child: Text(
                _isSubmitting ? 'Gönderiliyor…' : 'Çözüldü olarak işaretle',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
