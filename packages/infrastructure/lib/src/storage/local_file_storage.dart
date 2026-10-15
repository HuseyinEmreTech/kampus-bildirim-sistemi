import 'dart:io';
import 'dart:math';

/// Rule 07: fotoğraf en fazla 5 MB.
const maxPhotoSizeBytes = 5 * 1024 * 1024;

/// Fotoğrafın neden kabul edilmediği. `AppError` (#15) gelince ona çevrilecek.
enum PhotoError { invalidFormat, sizeExceeded, invalidReportId }

/// Kaydedilen fotoğraf. Domain'deki `Photo` (#15) gelince onunla değişecek.
typedef StoredPhoto = ({String url, String contentType, int sizeBytes});

sealed class SavePhotoResult {
  const SavePhotoResult();
}

final class PhotoSaved extends SavePhotoResult {
  const PhotoSaved(this.photo);

  final StoredPhoto photo;
}

final class PhotoRejected extends SavePhotoResult {
  const PhotoRejected(this.reason);

  final PhotoError reason;
}

/// Fotoğrafları sunucu diskinde `<kök>/<reportId>/<rastgele-ad>.<uzantı>` olarak saklar.
/// `FileStorage` arayüzü (#15, application) gelince onu uygular.
///
/// Henüz yapılmayan: EXIF temizleme (Rule 07), `image` paketi onayını bekliyor.
class LocalFileStorage {
  LocalFileStorage(this._root, {this.maxSizeBytes = maxPhotoSizeBytes});

  final Directory _root;
  final int maxSizeBytes;

  static const _urlPrefix = '/files';
  static const _headerLength = 8;
  static const _nameBytes = 16;
  static const _jpegSignature = [0xFF, 0xD8, 0xFF];
  static const _pngSignature = [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A];
  static const _extensions = {'image/jpeg': 'jpg', 'image/png': 'png'};

  static final _uuid = RegExp(
    r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
  );

  // Yalnızca bu sınıfın ürettiği biçim kabul edilir; `..` gibi yollar eşleşemez.
  static final _storedUrl = RegExp(
    r'^/files/[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}'
    r'/[0-9a-f]{32}\.(?:jpg|png)$',
  );

  static final _random = Random.secure();

  /// [bytes] akışını okuyup kaydeder. Tür, istemcinin söylediği [contentType]'a değil
  /// dosyanın ilk baytlarına (imza) bakılarak belirlenir; ikisi uyuşmazsa reddedilir.
  /// Sınır aşılırsa okuma durur ve yarım dosya silinir.
  Future<SavePhotoResult> save(
    String reportId,
    Stream<List<int>> bytes,
    String contentType,
  ) async {
    if (!_uuid.hasMatch(reportId)) {
      return const PhotoRejected(PhotoError.invalidReportId);
    }

    final header = <int>[];
    IOSink? sink;
    File? partFile;
    String? url;
    var size = 0;

    try {
      await for (final chunk in bytes) {
        size += chunk.length;
        if (size > maxSizeBytes) {
          return const PhotoRejected(PhotoError.sizeExceeded);
        }
        if (sink != null) {
          sink.add(chunk);
          continue;
        }

        header.addAll(chunk);
        if (header.length < _headerLength) continue;

        if (_detectType(header) != contentType) {
          return const PhotoRejected(PhotoError.invalidFormat);
        }
        url = _newUrl(reportId, contentType);
        partFile = File('${_pathFor(url)}.part');
        await partFile.parent.create(recursive: true);
        sink = partFile.openWrite()..add(header);
      }

      // Akış imza uzunluğundan kısa bittiyse hiç dosya açılmamıştır.
      if (sink == null || url == null || partFile == null) {
        return const PhotoRejected(PhotoError.invalidFormat);
      }
      await sink.close();
      sink = null;
      await partFile.rename(_pathFor(url));
      partFile = null;
      return PhotoSaved((url: url, contentType: contentType, sizeBytes: size));
    } finally {
      // Yarıda kalan dosya, kapatma da hata verse silinir.
      try {
        await sink?.close();
      } finally {
        if (partFile != null && await partFile.exists()) {
          await partFile.delete();
        }
      }
    }
  }

  /// Kaydedilmiş fotoğrafı okumak için açar; adres geçersizse ya da dosya yoksa `null`.
  Future<Stream<List<int>>?> openRead(String url) async {
    final file = _fileFor(url);
    if (file == null || !await file.exists()) return null;
    return file.openRead();
  }

  /// Kaydedilmiş fotoğrafı siler; silindiyse `true`.
  Future<bool> delete(String url) async {
    final file = _fileFor(url);
    if (file == null || !await file.exists()) return false;
    await file.delete();
    return true;
  }

  String? _detectType(List<int> header) {
    if (_startsWith(header, _pngSignature)) return 'image/png';
    if (_startsWith(header, _jpegSignature)) return 'image/jpeg';
    return null;
  }

  bool _startsWith(List<int> bytes, List<int> signature) {
    if (bytes.length < signature.length) return false;
    for (var i = 0; i < signature.length; i++) {
      if (bytes[i] != signature[i]) return false;
    }
    return true;
  }

  // Dosya adını sunucu üretir (Rule 07): tahmin edilemez 128 bit rastgele değer.
  String _newUrl(String reportId, String contentType) {
    final name = List.generate(
      _nameBytes,
      (_) => _random.nextInt(256).toRadixString(16).padLeft(2, '0'),
    ).join();
    return '$_urlPrefix/$reportId/$name.${_extensions[contentType]}';
  }

  File? _fileFor(String url) {
    if (!_storedUrl.hasMatch(url)) return null;
    return File(_pathFor(url));
  }

  String _pathFor(String url) =>
      '${_root.path}${url.substring(_urlPrefix.length)}';
}
