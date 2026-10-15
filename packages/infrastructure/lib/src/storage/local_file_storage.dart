import 'dart:io';
import 'dart:isolate';
import 'dart:math';
import 'dart:typed_data';

import 'package:image/image.dart' as img;

/// Rule 07: fotoğraf en fazla 5 MB.
const maxPhotoSizeBytes = 5 * 1024 * 1024;

/// Açılacak en büyük fotoğraf: 25 megapiksel. Küçük bir dosya çok büyük en/boy
/// bildirebilir; açılınca belleği doldurmasın diye önce yalnızca başlığa bakılır.
const maxPhotoPixels = 25 * 1000 * 1000;

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
/// Rule 07: fotoğraf yeniden kodlanarak kaydedilir; EXIF (konum, cihaz) ve
/// içine gizlenmiş başka veri diske yazılmaz, yalnızca pikseller kalır.
class LocalFileStorage {
  LocalFileStorage(
    this._root, {
    this.maxSizeBytes = maxPhotoSizeBytes,
    this.maxPixels = maxPhotoPixels,
  });

  final Directory _root;
  final int maxSizeBytes;
  final int maxPixels;

  static const _urlPrefix = '/files';
  static const _headerLength = 8;
  static const _nameBytes = 16;
  static const _jpegSignature = [0xFF, 0xD8, 0xFF];
  static const _pngSignature = [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A];
  static const _extensions = {'image/jpeg': 'jpg', 'image/png': 'png'};
  static const _jpegQuality = 85;

  static final _uuid = RegExp(
    r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
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

      final original = await partFile.readAsBytes();
      final limit = maxPixels;
      // Çözme ve sıkıştırma işlemciyi saniyeler boyunca meşgul eder; sunucu
      // diğer isteklere cevap verebilsin diye ayrı bir isolate'te yapılır.
      final cleaned = await Isolate.run(
        () => _reencode(original, contentType, limit),
      );
      if (cleaned case PhotoRejected()) return cleaned;
      final bytesOut = (cleaned as _Cleaned).bytes;
      // Yeniden kodlanan dosya girdiden büyük çıkabilir; sınır diskteki dosya için de geçerli.
      if (bytesOut.length > maxSizeBytes) {
        return const PhotoRejected(PhotoError.sizeExceeded);
      }
      await File(_pathFor(url)).writeAsBytes(bytesOut, flush: true);
      return PhotoSaved((
        url: url,
        contentType: contentType,
        sizeBytes: bytesOut.length,
      ));
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

  // Önce yalnızca başlıktaki en/boy okunur; sınırı aşan fotoğraf açılmaz.
  // JPEG çözücü EXIF'teki yön bilgisini piksellere kendisi işler; sonra bütün
  // üst veri atılır ve yalnızca pikseller yeniden kodlanır.
  static Object _reencode(Uint8List data, String contentType, int maxPixels) {
    final decoder = contentType == 'image/png'
        ? img.PngDecoder()
        : img.JpegDecoder();
    try {
      final info = decoder.startDecode(data);
      if (info == null) return const PhotoRejected(PhotoError.invalidFormat);
      if (info.width * info.height > maxPixels) {
        return const PhotoRejected(PhotoError.sizeExceeded);
      }
      // Yalnızca ilk kare: hareketli PNG'nin diğer kareleri belleği şişirmesin.
      final decoded = decoder.decodeFrame(0);
      if (decoded == null) return const PhotoRejected(PhotoError.invalidFormat);

      final clean = decoded
        ..exif = img.ExifData()
        ..textData = null
        ..iccProfile = null;
      return _Cleaned(
        contentType == 'image/png'
            ? img.encodePng(clean)
            : img.encodeJpg(clean, quality: _jpegQuality),
      );
    } on img.ImageException {
      // Paket bozuk dosyadaki her hatayı ImageException olarak bildirir.
      return const PhotoRejected(PhotoError.invalidFormat);
    }
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

  String _pathFor(String url) =>
      '${_root.path}${url.substring(_urlPrefix.length)}';
}

final class _Cleaned {
  const _Cleaned(this.bytes);

  final Uint8List bytes;
}
