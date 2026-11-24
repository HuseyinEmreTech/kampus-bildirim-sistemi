import 'dart:async';

import 'package:flutter/material.dart';

import 'photo_picker.dart';

/// Önizlemenin yüksekliği.
const _previewHeight = 160.0;

/// Form içinde fotoğraf alanı: "Fotoğraf çek" / "Galeriden seç", önizleme ve
/// "Kaldır". Fotoğraf seçilmezse form doğrulamasında [requiredMessage] çıkar;
/// kurallara uymayan fotoğraf (Rule 07) alınmaz, nedeni gösterilir.
///
/// [recoverLost] açıksa Android'in kapattığı uygulamadan kalan fotoğraf
/// alan açılınca geri konur. Yalnızca bildirim oluşturmada açılır: fotoğrafın
/// hangi bildirim için çekildiği bilinmediğinden, çözme ekranında başka bir
/// bildirimin sonuç fotoğrafı olarak (Rule 04) yanlışlıkla gönderilebilirdi.
class PhotoField extends FormField<PickedPhoto> {
  PhotoField({
    super.key,
    required PhotoPicker picker,
    required String requiredMessage,
    bool recoverLost = false,
  }) : super(
         validator: (photo) => photo == null ? requiredMessage : null,
         builder: (field) => _PhotoFieldView(
           field: field,
           picker: picker,
           recoverLost: recoverLost,
         ),
       );
}

class _PhotoFieldView extends StatefulWidget {
  const _PhotoFieldView({
    required this.field,
    required this.picker,
    required this.recoverLost,
  });

  final FormFieldState<PickedPhoto> field;
  final PhotoPicker picker;
  final bool recoverLost;

  @override
  State<_PhotoFieldView> createState() => _PhotoFieldViewState();
}

class _PhotoFieldViewState extends State<_PhotoFieldView> {
  /// Son alma denemesinin sorunu (çok büyük, izin yok...).
  String? _pickProblem;

  /// Geri konan fotoğraf için kullanıcıya bilgi.
  var _recovered = false;

  @override
  void initState() {
    super.initState();
    if (!widget.recoverLost) return;
    if (widget.picker case final LostPhotoRecovery recovery) {
      unawaited(_recoverLost(recovery));
    }
  }

  /// Android uygulamayı kamera açıkken kapattıysa çekilen fotoğrafı geri
  /// koyar; kurallara uymuyorsa nedenini gösterir.
  Future<void> _recoverLost(LostPhotoRecovery recovery) async {
    final photo = await recovery.recoverLostPhoto();
    if (!mounted || photo == null || widget.field.value != null) return;
    final problem = photoProblem(photo);
    setState(() {
      _pickProblem = problem;
      _recovered = problem == null;
    });
    if (problem == null) widget.field.didChange(photo);
  }

  Future<void> _pick(PhotoSource source) async {
    final result = await widget.picker.pick(source);
    if (!mounted) return;
    final problem = switch (result) {
      PhotoPicked(:final photo) => photoProblem(photo),
      PhotoPickCancelled() => null,
      PhotoPickDenied() => 'Kamera ya da galeri izni verilmedi',
      PhotoPickFailed() => 'Fotoğraf alınamadı, tekrar deneyin',
    };
    setState(() {
      _pickProblem = problem;
      _recovered = false;
    });
    if (result case PhotoPicked(:final photo) when problem == null) {
      widget.field.didChange(photo);
    }
  }

  void _remove() {
    setState(() {
      _pickProblem = null;
      _recovered = false;
    });
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
            errorBuilder: (_, _, _) => const Icon(Icons.broken_image),
          ),
          if (_recovered) const Text('Önceki çekimden kalan fotoğraf eklendi'),
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
        if (error != null)
          Text(
            error,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
      ],
    );
  }
}
