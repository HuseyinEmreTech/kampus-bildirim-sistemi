import 'dart:typed_data';

/// Fotoğraf en fazla bu kadar bayt olabilir (Rule 07: 5 MB).
const maxPhotoBytes = 5 * 1024 * 1024;

/// İzin verilen fotoğraf türleri (Rule 07).
const allowedPhotoTypes = {'image/jpeg', 'image/png'};

/// Kameradan ya da galeriden alınan fotoğraf.
class PickedPhoto {
  const PickedPhoto({required this.bytes, required this.contentType});

  final Uint8List bytes;
  final String contentType;
}

/// Fotoğrafın nereden alınacağı.
enum PhotoSource { camera, gallery }

/// Fotoğraf alma sonucu.
sealed class PhotoPickResult {
  const PhotoPickResult();
}

final class PhotoPicked extends PhotoPickResult {
  const PhotoPicked(this.photo);

  final PickedPhoto photo;
}

/// Kullanıcı vazgeçti.
final class PhotoPickCancelled extends PhotoPickResult {
  const PhotoPickCancelled();
}

/// Kamera ya da galeri izni verilmedi.
final class PhotoPickDenied extends PhotoPickResult {
  const PhotoPickDenied();
}

final class PhotoPickFailed extends PhotoPickResult {
  const PhotoPickFailed();
}

/// Kameradan ya da galeriden fotoğraf alan kaynak.
///
/// Gerçek hali `ImagePickerPhotoPicker`; testlerde sahte bir seçici
/// kullanılır.
abstract interface class PhotoPicker {
  Future<PhotoPickResult> pick(PhotoSource source);
}

/// Fotoğraf kurallara uymuyorsa kullanıcıya gösterilecek neden; uyuyorsa
/// `null`. Yalnızca erken uyarıdır; asıl kontrol sunucudadır.
String? photoProblem(PickedPhoto photo) {
  if (!allowedPhotoTypes.contains(photo.contentType)) {
    return 'Yalnızca JPEG veya PNG fotoğraf seçilebilir';
  }
  if (photo.bytes.length > maxPhotoBytes) {
    return 'Fotoğraf en fazla 5 MB olabilir';
  }
  return null;
}
