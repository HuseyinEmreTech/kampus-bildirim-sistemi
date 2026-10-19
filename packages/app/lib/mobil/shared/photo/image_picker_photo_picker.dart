import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import 'photo_picker.dart';

/// Fotoğraf en fazla bu genişlikte istenir; telefon fotoğrafı 5 MB sınırını
/// (Rule 07) aşmasın.
const _maxPhotoWidth = 1920.0;

/// JPEG sıkıştırma kalitesi (0-100).
const _photoQuality = 85;

/// Eklentinin "izin verilmedi" hata kodları (kamera ve galeri).
const _deniedCodes = {'camera_access_denied', 'photo_access_denied'};

/// `ImagePicker().pickImage` biçiminde fotoğraf alma fonksiyonu; testte
/// sahtesi verilir.
typedef PickImage = Future<XFile?> Function({
  required ImageSource source,
  double? maxWidth,
  int? imageQuality,
});

/// Kameradan ya da galeriden gerçek fotoğraf alan kaynak (`image_picker`).
///
/// Eklentinin hatası (izin yok, kamera yok) burada yakalanıp sonuç tipine
/// çevrilir; ekran istisna görmez.
class ImagePickerPhotoPicker implements PhotoPicker {
  ImagePickerPhotoPicker({PickImage? pickImage})
    : _pickImage = pickImage ?? ImagePicker().pickImage;

  final PickImage _pickImage;

  @override
  Future<PhotoPickResult> pick(PhotoSource source) async {
    try {
      final file = await _pickImage(
        source: switch (source) {
          PhotoSource.camera => ImageSource.camera,
          PhotoSource.gallery => ImageSource.gallery,
        },
        maxWidth: _maxPhotoWidth,
        imageQuality: _photoQuality,
      );
      if (file == null) return const PhotoPickCancelled();
      final bytes = await file.readAsBytes();
      return PhotoPicked(
        PickedPhoto(bytes: bytes, contentType: _contentTypeOf(file)),
      );
    } on PlatformException catch (error) {
      if (_deniedCodes.contains(error.code)) return const PhotoPickDenied();
      return const PhotoPickFailed();
    }
  }
}

/// Platform türü verdiyse o; vermediyse dosya uzantısından. Bilinmeyen tür
/// `photoProblem` tarafından reddedilir.
String _contentTypeOf(XFile file) {
  final mimeType = file.mimeType;
  if (mimeType != null) return mimeType;
  // Telefonda ad yoldan gelir; boşsa yolun kendisine bakılır.
  final name = (file.name.isEmpty ? file.path : file.name).toLowerCase();
  if (name.endsWith('.jpg') || name.endsWith('.jpeg')) return 'image/jpeg';
  if (name.endsWith('.png')) return 'image/png';
  return 'application/octet-stream';
}
