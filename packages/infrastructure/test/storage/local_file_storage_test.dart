import 'dart:io';
import 'dart:typed_data';

import 'package:campus_infrastructure/campus_infrastructure.dart';
import 'package:image/image.dart' as img;
import 'package:test/test.dart';

const _reportId = 'c0000000-0000-4000-8000-0000000000f1';
const _limit = 4096;

// Dosya imzaları (magic bytes): içerik türü uzantıya değil bunlara göre anlaşılır.
const _jpegHeader = [0xFF, 0xD8, 0xFF, 0xE0, 0x00, 0x10, 0x4A, 0x46];
const _gifHeader = [0x47, 0x49, 0x46, 0x38, 0x39, 0x61, 0x01, 0x00];

final _urlPattern = RegExp(
  r'^/files/c0000000-0000-4000-8000-0000000000f1/[0-9a-f]{32}\.(jpg|png)$',
);

List<int> _file(List<int> header, int totalBytes) => [
  ...header,
  ...List.filled(totalBytes - header.length, 0x2A),
];

img.Image _picture() =>
    img.Image(width: 4, height: 2)..clear(img.ColorRgb8(200, 50, 50));

// Telefonun yazdığı gibi: konum, cihaz modeli ve yön bilgisi.
Uint8List _jpegWithExif({int orientation = 1}) {
  final picture = _picture();
  picture.exif.gpsIfd['GPSLatitude'] = img.IfdValueRational(36, 1);
  picture.exif.imageIfd['Model'] = img.IfdValueAscii('Telefon X');
  picture.exif.imageIfd.orientation = orientation;
  return img.encodeJpg(picture);
}

Uint8List _png() => img.encodePng(_picture());

bool _containsText(List<int> bytes, String text) =>
    String.fromCharCodes(bytes).contains(text);

Stream<List<int>> _oneChunk(List<int> bytes) => Stream.value(bytes);

Stream<List<int>> _byteByByte(List<int> bytes) =>
    Stream.fromIterable(bytes.map((b) => [b]));

Matcher _rejected(PhotoError reason) =>
    isA<PhotoRejected>().having((r) => r.reason, 'reason', reason);

PhotoSaved _expectSaved(SavePhotoResult result) {
  expect(result, isA<PhotoSaved>());
  return result as PhotoSaved;
}

void main() {
  late Directory root;
  late LocalFileStorage storage;

  setUp(() async {
    root = await Directory.systemTemp.createTemp('campus_storage_test_');
    storage = LocalFileStorage(root, maxSizeBytes: _limit);
  });
  tearDown(() => root.delete(recursive: true));

  Future<SavePhotoResult> save(
    Stream<List<int>> bytes, [
    String contentType = 'image/jpeg',
  ]) => storage.save(_reportId, bytes, contentType);

  Future<Uint8List> readSaved(PhotoSaved saved) =>
      File(saved.photo.url.replaceFirst('/files', root.path)).readAsBytes();

  Future<List<String>> filesOnDisk() async => [
    await for (final e in root.list(recursive: true))
      if (e is File) e.path,
  ];

  group('save', () {
    test('save_validJpeg_returnsPhoto', () async {
      final saved = _expectSaved(await save(_oneChunk(_jpegWithExif())));

      expect(saved.photo.url, matches(_urlPattern));
      expect(saved.photo.url, endsWith('.jpg'));
      expect(saved.photo.contentType, 'image/jpeg');
      final onDisk = await readSaved(saved);
      expect(saved.photo.sizeBytes, onDisk.length);
      expect(img.decodeJpg(onDisk)!.width, 4);
    });

    test('save_jpegWithExif_removesLocationAndModel', () async {
      final input = _jpegWithExif();
      expect(_containsText(input, 'Telefon X'), isTrue);

      final saved = _expectSaved(await save(_oneChunk(input)));

      final onDisk = await readSaved(saved);
      expect(_containsText(onDisk, 'Telefon X'), isFalse);
      expect(img.decodeJpgExif(onDisk)?.isEmpty ?? true, isTrue);
    });

    test('save_rotatedJpeg_keepsVisibleOrientation', () async {
      // Yön 6: telefon yan tutulmuş; 4x2 kaydedilen fotoğraf 2x4 görünmeli.
      final saved = _expectSaved(
        await save(_oneChunk(_jpegWithExif(orientation: 6))),
      );

      final picture = img.decodeJpg(await readSaved(saved))!;
      expect((picture.width, picture.height), (2, 4));
    });

    test('save_png_works', () async {
      final saved = _expectSaved(await save(_oneChunk(_png()), 'image/png'));

      expect(saved.photo.url, endsWith('.png'));
      expect(saved.photo.contentType, 'image/png');
    });

    test('save_pngWithTextChunk_removesText', () async {
      final input = img.encodePng(_picture()..addTextData({'Yazar': 'Ayse'}));
      expect(_containsText(input, 'Ayse'), isTrue);

      final saved = _expectSaved(await save(_oneChunk(input), 'image/png'));

      expect(_containsText(await readSaved(saved), 'Ayse'), isFalse);
    });

    test('save_headerSplitAcrossChunks_detectsType', () async {
      final saved = _expectSaved(await save(_byteByByte(_png()), 'image/png'));

      expect(saved.photo.contentType, 'image/png');
    });

    test('save_twice_usesDifferentNames', () async {
      final a = _expectSaved(await save(_oneChunk(_png()), 'image/png'));
      final b = _expectSaved(await save(_oneChunk(_png()), 'image/png'));

      expect(a.photo.url, isNot(b.photo.url));
    });

    test('save_invalidMagicBytes_returnsInvalidFormat', () async {
      final result = await save(_oneChunk(_file(_gifHeader, 20)));

      expect(result, _rejected(PhotoError.invalidFormat));
      expect(await filesOnDisk(), isEmpty);
    });

    test('save_declaredTypeDiffersFromContent_returnsInvalidFormat', () async {
      final result = await save(_oneChunk(_png()));

      expect(result, _rejected(PhotoError.invalidFormat));
    });

    test('save_validSignatureButBrokenImage_returnsInvalidFormat', () async {
      final result = await save(_oneChunk(_file(_jpegHeader, 100)));

      expect(result, _rejected(PhotoError.invalidFormat));
      expect(await filesOnDisk(), isEmpty);
    });

    test('save_truncatedPng_returnsInvalidFormat', () async {
      final png = _png();

      final result = await save(
        _oneChunk(png.sublist(0, png.length ~/ 2)),
        'image/png',
      );

      expect(result, _rejected(PhotoError.invalidFormat));
      expect(await filesOnDisk(), isEmpty);
    });

    test('save_emptyStream_returnsInvalidFormat', () async {
      final result = await save(const Stream.empty());

      expect(result, _rejected(PhotoError.invalidFormat));
    });

    test('save_exactlyAtLimit_succeeds', () async {
      final input = _jpegWithExif();
      storage = LocalFileStorage(root, maxSizeBytes: input.length);

      expect(await save(_oneChunk(input)), isA<PhotoSaved>());
    });

    test('save_overLimit_returnsSizeExceeded', () async {
      final result = await save(_byteByByte(_file(_jpegHeader, _limit + 1)));

      expect(result, _rejected(PhotoError.sizeExceeded));
      expect(await filesOnDisk(), isEmpty);
    });

    test('save_growsWhenReencoded_returnsSizeExceeded', () async {
      // En düşük kalitede küçük bir JPEG, yeniden kodlanınca büyür.
      final noisy = img.Image(width: 32, height: 32);
      for (final p in noisy) {
        p.setRgb((p.x * 37) % 256, (p.y * 91) % 256, (p.x * p.y) % 256);
      }
      final input = img.encodeJpg(noisy, quality: 1);
      storage = LocalFileStorage(root, maxSizeBytes: input.length);

      final result = await save(_oneChunk(input));

      expect(result, _rejected(PhotoError.sizeExceeded));
      expect(await filesOnDisk(), isEmpty);
    });

    test('save_tooManyPixels_returnsSizeExceeded', () async {
      // Fotoğraf 4x2 = 8 piksel; sınır 7 piksel.
      storage = LocalFileStorage(root, maxSizeBytes: _limit, maxPixels: 7);

      final result = await save(_oneChunk(_png()), 'image/png');

      expect(result, _rejected(PhotoError.sizeExceeded));
      expect(await filesOnDisk(), isEmpty);
    });

    test('save_streamFailsMidway_leavesNoFile', () async {
      Stream<List<int>> broken() async* {
        yield _jpegHeader;
        throw const SocketException('bağlantı koptu');
      }

      await expectLater(save(broken()), throwsA(isA<SocketException>()));
      expect(await filesOnDisk(), isEmpty);
    });

    test('save_defaultLimits', () {
      expect(maxPhotoSizeBytes, 5 * 1024 * 1024);
      expect(maxPhotoPixels, 25 * 1000 * 1000);
    });

    test('save_reportIdNotUuid_returnsInvalidReportId', () async {
      final result = await storage.save(
        '../../etc',
        _oneChunk(_png()),
        'image/png',
      );

      expect(result, _rejected(PhotoError.invalidReportId));
      expect(await filesOnDisk(), isEmpty);
    });
  });
}
