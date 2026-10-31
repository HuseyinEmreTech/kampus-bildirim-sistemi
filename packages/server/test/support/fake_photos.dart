import 'package:campus_infrastructure/campus_infrastructure.dart';

/// Diske yazmayan sahte fotoğraf deposu. Gelen baytları sayar, [nextReject]
/// doluysa o nedenle reddeder; silinen adresleri [deleted]'da tutar.
class FakePhotos implements LocalFileStorage {
  PhotoError? nextReject;
  final saved = <String>[];
  final deleted = <String>[];

  @override
  int get maxSizeBytes => maxPhotoSizeBytes;

  @override
  int get maxPixels => maxPhotoPixels;

  @override
  Future<SavePhotoResult> save(
    String reportId,
    Stream<List<int>> bytes,
    String contentType,
  ) async {
    final size = await bytes.fold<int>(0, (sum, chunk) => sum + chunk.length);
    final reject = nextReject;
    if (reject != null) return PhotoRejected(reject);
    final url = '/files/$reportId/foto-${saved.length + 1}.jpg';
    saved.add(url);
    return PhotoSaved((url: url, contentType: contentType, sizeBytes: size));
  }

  @override
  Future<bool> delete(String url) async {
    deleted.add(url);
    return true;
  }

  @override
  Future<Stream<List<int>>?> openRead(String url) async => null;
}
