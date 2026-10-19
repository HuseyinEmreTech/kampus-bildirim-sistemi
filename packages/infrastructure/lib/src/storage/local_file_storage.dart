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
  static const _png = 'image/png';
  static const _jpeg = 'image/jpeg';
  static const _extensions = {_jpeg: 'jpg', _png: 'png'};
  static const _jpegQuality = 85;

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
      // `await` burada gerekli: geçici dosya, temizleme bitmeden silinmesin.
      return await _cleanAndStore(partFile, url, contentType);
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
    if (file == null) return false;
    // Önce "var mı" diye bakmak yerine doğrudan silinir: aynı anda iki silme
    // gelirse ikincisi hata fırlatmak yerine `false` alır.
    try {
      await file.delete();
      return true;
    } on PathNotFoundException {
      return false;
    }
  }

  /// Geçici dosyadaki fotoğrafı EXIF'ten temizleyip asıl adıyla yazar.
  Future<SavePhotoResult> _cleanAndStore(
    File partFile,
    String url,
    String contentType,
  ) async {
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
    // Önce geçici adla yazılır: yazma yarıda kalırsa (disk dolu) asıl adla
    // yarım bir fotoğraf kalmaz.
    final cleanFile = File('${_pathFor(url)}.temiz');
    try {
      await cleanFile.writeAsBytes(bytesOut, flush: true);
      await cleanFile.rename(_pathFor(url));
    } finally {
      if (await cleanFile.exists()) await cleanFile.delete();
    }
    return PhotoSaved((
      url: url,
      contentType: contentType,
      sizeBytes: bytesOut.length,
    ));
  }

  // Önce yalnızca başlıktaki en/boy okunur; sınırı aşan fotoğraf açılmaz.
  // JPEG çözücü EXIF'teki yön bilgisini piksellere kendisi işler; sonra bütün
  // üst veri atılır ve yalnızca pikseller yeniden kodlanır.
  static Object _reencode(Uint8List data, String contentType, int maxPixels) {
    // JPEG'de başlıktan okunan en/boy gerçek kareden farklı olabilir; sınır
    // çözücüye de verilir ki kareyi açmadan önce kendisi de kontrol etsin.
    final decoder = contentType == _png
        ? img.PngDecoder()
        : img.JpegDecoder(maxPixels: maxPixels);
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
        contentType == _png
            ? img.encodePng(clean)
            : img.encodeJpg(clean, quality: _jpegQuality),
      );
    } on img.ImageException {
      // Paket bozuk dosyadaki her hatayı ImageException olarak bildirir.
      return const PhotoRejected(PhotoError.invalidFormat);
    }
  }

  String? _detectType(List<int> header) {
    if (_startsWith(header, _pngSignature)) return _png;
    if (_startsWith(header, _jpegSignature)) return _jpeg;
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

final class _Cleaned {
  const _Cleaned(this.bytes);

  final Uint8List bytes;
}
