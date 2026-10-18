import 'package:flutter/material.dart';

import '../../../../shared/error_text.dart';
import '../../../../shared/location/location_field.dart';
import '../../../../shared/location/location_source.dart';
import '../../../../shared/photo/photo_field.dart';
import '../../../../shared/photo/photo_picker.dart';
import '../../data/new_report.dart';
import '../../data/report_creator.dart';
import '../../data/report_list_item.dart';

/// Oluşturma ekranının kullandığı kaynaklar.
class ReportCreateSources {
  const ReportCreateSources({
    required this.creator,
    required this.photoPicker,
    required this.gps,
    required this.buildings,
  });

  final ReportCreator creator;
  final PhotoPicker photoPicker;
  final LocationProvider gps;
  final BuildingsSource buildings;
}

/// Öğrencinin yeni bildirim oluşturduğu ekran (USR 01): kategori, açıklama,
/// yer tarifi, fotoğraf ve konum. Buradaki kontroller yalnızca kullanıcıya
/// erken uyarı içindir; asıl doğrulama sunucudadır.
class ReportCreateScreen extends StatefulWidget {
  const ReportCreateScreen({super.key, required this.sources});

  final ReportCreateSources sources;

  @override
  State<ReportCreateScreen> createState() => _ReportCreateScreenState();
}

class _ReportCreateScreenState extends State<ReportCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _photoKey = GlobalKey<FormFieldState<PickedPhoto>>();
  final _locationKey = GlobalKey<FormFieldState<LocationChoice>>();
  final _descriptionController = TextEditingController();
  final _placeController = TextEditingController();
  ReportCategory? _category;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _descriptionController.dispose();
    _placeController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final category = _category;
    final photo = _photoKey.currentState?.value;
    final location = _locationKey.currentState?.value;
    if (!_formKey.currentState!.validate()) return;
    if (category == null || photo == null || location == null) return;

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });
    final result = await widget.sources.creator.create(
      NewReport(
        category: category,
        description: _descriptionController.text.trim(),
        photo: photo,
        location: location,
        place: _placeController.text.trim(),
      ),
    );
    if (!mounted) return;

    switch (result) {
      case ReportCreated():
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Bildirim oluşturuldu')));
        Navigator.of(context).pop(true);
      case ReportRejected(:final message):
        _showError(message);
      case ReportCreateFailed():
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
      appBar: AppBar(title: const Text('Yeni bildirim')),
      body: Form(
        key: _formKey,
        // Bütün alanlar her zaman oluşturulsun ki ekran dışında kalanların
        // doğrulaması da çalışsın (ListView görünmeyeni oluşturmaz).
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildCategoryField(),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Açıklama',
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
                maxLength: reportDescriptionMaxLength,
                validator: _validateDescription,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _placeController,
                decoration: const InputDecoration(
                  labelText: 'Yer tarifi',
                  hintText: 'ör. B Blok 2. kat',
                ),
                validator: (value) =>
                    (value ?? '').trim().isEmpty ? 'Yer tarifi yazın' : null,
              ),
              const SizedBox(height: 8),
              PhotoField(
                key: _photoKey,
                picker: widget.sources.photoPicker,
                requiredMessage: 'Fotoğraf ekleyin',
              ),
              const SizedBox(height: 8),
              LocationField(
                key: _locationKey,
                gps: widget.sources.gps,
                buildings: widget.sources.buildings,
              ),
              if (_errorMessage case final message?) ErrorText(message),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _isSubmitting ? null : _submit,
                child: Text(_isSubmitting ? 'Gönderiliyor…' : 'Gönder'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Kategori seçici; seçilmezse form doğrulamasında hata gösterir.
  Widget _buildCategoryField() {
    return FormField<ReportCategory>(
      validator: (_) => _category == null ? 'Kategori seçin' : null,
      builder: (field) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SegmentedButton<ReportCategory>(
            segments: [
              for (final value in ReportCategory.values)
                ButtonSegment(value: value, label: Text(_categoryLabel(value))),
            ],
            // `?` : kategori seçilmemişse (null) küme boş kalır.
            selected: {?_category},
            emptySelectionAllowed: true,
            showSelectedIcon: false,
            onSelectionChanged: (selection) {
              setState(() => _category = selection.firstOrNull);
              if (field.hasError) field.validate();
            },
          ),
          if (field.errorText case final error?) ErrorText(error),
        ],
      ),
    );
  }
}

String? _validateDescription(String? value) {
  final length = value?.trim().length ?? 0;
  if (length < reportDescriptionMinLength) {
    return 'Açıklama en az $reportDescriptionMinLength karakter olmalı';
  }
  return null;
}

String _categoryLabel(ReportCategory category) => switch (category) {
  ReportCategory.ariza => 'Arıza',
  ReportCategory.temizlik => 'Temizlik',
  ReportCategory.guvenlik => 'Güvenlik',
  ReportCategory.diger => 'Diğer',
};
