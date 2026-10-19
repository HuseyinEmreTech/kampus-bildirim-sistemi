import 'package:campus_app/mobil/shared/photo/image_picker_photo_picker.dart';
import 'package:campus_app/mobil/shared/photo/photo_picker.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';

final bytes = Uint8List.fromList([1, 2, 3]);

/// Verilen dosyayı döndüren (ya da hatayı fırlatan) ve istenenleri kaydeden
/// sahte `pickImage`.
class FakePickImage {
  FakePickImage({this.file, this.error});

  final XFile? file;
  final PlatformException? error;
  ImageSource? askedSource;
  double? askedMaxWidth;
  int? askedQuality;

  Future<XFile?> call({
    required ImageSource source,
    double? maxWidth,
    int? imageQuality,
  }) async {
    askedSource = source;
    askedMaxWidth = maxWidth;
    askedQuality = imageQuality;
    final error = this.error;
    if (error != null) throw error;
    return file;
  }
}

void main() {
  test('pick_returnsJpeg_whenCameraPhotoTaken', () async {
    final fake = FakePickImage(file: XFile.fromData(bytes, path: 'IMG_1.jpg'));

    final result = await ImagePickerPhotoPicker(pickImage: fake.call)
        .pick(PhotoSource.camera);

    expect(fake.askedSource, ImageSource.camera);
    final photo = (result as PhotoPicked).photo;
    expect(photo.bytes, bytes);
    expect(photo.contentType, 'image/jpeg');
  });

  test('pick_usesGallery_andKnowsPng', () async {
    final fake = FakePickImage(file: XFile.fromData(bytes, path: 'ekran.PNG'));

    final result = await ImagePickerPhotoPicker(pickImage: fake.call)
        .pick(PhotoSource.gallery);

    expect(fake.askedSource, ImageSource.gallery);
    expect((result as PhotoPicked).photo.contentType, 'image/png');
  });

  test('pick_prefersMimeType_whenPlatformGivesIt', () async {
    final file = XFile.fromData(bytes, path: 'adsiz', mimeType: 'image/png');
    final fake = FakePickImage(file: file);

    final result = await ImagePickerPhotoPicker(pickImage: fake.call)
        .pick(PhotoSource.gallery);

    expect((result as PhotoPicked).photo.contentType, 'image/png');
  });

  test('pick_asksForSmallerPhoto', () async {
    final fake = FakePickImage(file: XFile.fromData(bytes, path: 'a.jpg'));

    await ImagePickerPhotoPicker(pickImage: fake.call).pick(PhotoSource.camera);

    expect(fake.askedMaxWidth, isNotNull);
    expect(fake.askedQuality, isNotNull);
  });

  test('pick_returnsCancelled_whenNothingChosen', () async {
    final result = await ImagePickerPhotoPicker(pickImage: FakePickImage().call)
        .pick(PhotoSource.camera);

    expect(result, isA<PhotoPickCancelled>());
  });

  test('pick_returnsDenied_whenPermissionRefused', () async {
    for (final code in ['camera_access_denied', 'photo_access_denied']) {
      final fake = FakePickImage(error: PlatformException(code: code));

      final result = await ImagePickerPhotoPicker(pickImage: fake.call)
          .pick(PhotoSource.camera);

      expect(result, isA<PhotoPickDenied>(), reason: code);
    }
  });

  test('pick_returnsFailed_onOtherPlatformError', () async {
    final fake = FakePickImage(error: PlatformException(code: 'no_camera'));

    final result = await ImagePickerPhotoPicker(pickImage: fake.call)
        .pick(PhotoSource.camera);

    expect(result, isA<PhotoPickFailed>());
  });
}
