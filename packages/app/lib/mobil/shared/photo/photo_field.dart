import 'package:flutter/material.dart';

import '../error_text.dart';
import 'photo_picker.dart';

/// Önizlemenin yüksekliği.
const _previewHeight = 160.0;

/// Form içinde fotoğraf alanı: "Fotoğraf çek" / "Galeriden seç", önizleme ve
/// "Kaldır". Fotoğraf seçilmezse form doğrulamasında [requiredMessage] çıkar;
/// kurallara uymayan fotoğraf (Rule 07) alınmaz, nedeni gösterilir.
class PhotoField extends FormField<PickedPhoto> {
  PhotoField({
    super.key,
    required PhotoPicker picker,
    required String requiredMessage,
  }) : super(
         validator: (photo) => photo == null ? requiredMessage : null,
         builder: (field) => _PhotoFieldView(field: field, picker: picker),
       );
}

class _PhotoFieldView extends StatefulWidget {
  const _PhotoFieldView({required this.field, required this.picker});

  final FormFieldState<PickedPhoto> field;
  final PhotoPicker picker;

  @override
  State<_PhotoFieldView> createState() => _PhotoFieldViewState();
}

class _PhotoFieldViewState extends State<_PhotoFieldView> {
  /// Son alma denemesinin sorunu (çok büyük, izin yok...).
  String? _pickProblem;

  Future<void> _pick(PhotoSource source) async {
    final result = await widget.picker.pick(source);
    if (!mounted) return;
    final problem = switch (result) {
      PhotoPicked(:final photo) => photoProblem(photo),
      PhotoPickCancelled() => null,
      PhotoPickDenied() => 'Kamera ya da galeri izni verilmedi',
      PhotoPickFailed() => 'Fotoğraf alınamadı, tekrar deneyin',
    };
    setState(() => _pickProblem = problem);
    if (result case PhotoPicked(:final photo) when problem == null) {
      widget.field.didChange(photo);
    }
  }

  void _remove() {
    setState(() => _pickProblem = null);
    widget.field.didChange(null);
  }

  @override
  Widget build(BuildContext context) {
    final photo = widget.field.value;
    final error = _pickProblem ?? widget.field.errorText;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (photo != null) ...[
          Image.memory(
            photo.bytes,
            height: _previewHeight,
            fit: BoxFit.cover,
            semanticLabel: 'Seçilen fotoğraf',
            errorBuilder: (_, _, _) => const Icon(Icons.broken_image),
          ),
          TextButton(onPressed: _remove, child: const Text('Kaldır')),
        ] else
          Wrap(
            spacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: () => _pick(PhotoSource.camera),
                icon: const Icon(Icons.photo_camera),
                label: const Text('Fotoğraf çek'),
              ),
              OutlinedButton.icon(
                onPressed: () => _pick(PhotoSource.gallery),
                icon: const Icon(Icons.photo_library),
                label: const Text('Galeriden seç'),
              ),
            ],
          ),
        if (error != null) ErrorText(error),
      ],
    );
  }
}
