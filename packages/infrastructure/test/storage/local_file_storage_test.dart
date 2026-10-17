import 'dart:convert';
import 'dart:io';

import 'package:campus_infrastructure/campus_infrastructure.dart';
import 'package:test/test.dart';

const _reportId = 'c0000000-0000-4000-8000-0000000000f1';

// Dosya imzaları (magic bytes): içerik türü uzantıya değil bunlara göre anlaşılır.
const _jpegHeader = [0xFF, 0xD8, 0xFF, 0xE0, 0x00, 0x10, 0x4A, 0x46];
const _pngHeader = [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A];
const _gifHeader = [0x47, 0x49, 0x46, 0x38, 0x39, 0x61, 0x01, 0x00];

final _urlPattern = RegExp(
  r'^/files/c0000000-0000-4000-8000-0000000000f1/[0-9a-f]{32}\.(jpg|png)$',
);

List<int> _file(List<int> header, int totalBytes) => [
  ...header,
  ...List.filled(totalBytes - header.length, 0x2A),
];

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
    storage = LocalFileStorage(root, maxSizeBytes: 64);
  });
  tearDown(() => root.delete(recursive: true));

  Future<SavePhotoResult> save(
    Stream<List<int>> bytes, [
    String contentType = 'image/jpeg',
  ]) => storage.save(_reportId, bytes, contentType);

  Future<List<String>> filesOnDisk() async => [
    await for (final e in root.list(recursive: true))
      if (e is File) e.path,
  ];

  group('save', () {
    test('save_validJpeg_returnsPhoto', () async {
      final bytes = _file(_jpegHeader, 40);

      final saved = _expectSaved(await save(_oneChunk(bytes)));

      expect(saved.photo.url, matches(_urlPattern));
      expect(saved.photo.url, endsWith('.jpg'));
      expect(saved.photo.contentType, 'image/jpeg');
      expect(saved.photo.sizeBytes, 40);
      final path = saved.photo.url.replaceFirst('/files', root.path);
      expect(await File(path).readAsBytes(), bytes);
    });

    test('save_png_works', () async {
      final saved = _expectSaved(
        await save(_oneChunk(_file(_pngHeader, 30)), 'image/png'),
      );

      expect(saved.photo.url, endsWith('.png'));
      expect(saved.photo.contentType, 'image/png');
    });

    test('save_headerSplitAcrossChunks_detectsType', () async {
      final saved = _expectSaved(
        await save(_byteByByte(_file(_pngHeader, 20)), 'image/png'),
      );

      expect(saved.photo.sizeBytes, 20);
    });

    test('save_twice_usesDifferentNames', () async {
      final a = _expectSaved(await save(_oneChunk(_file(_jpegHeader, 10))));
      final b = _expectSaved(await save(_oneChunk(_file(_jpegHeader, 10))));

      expect(a.photo.url, isNot(b.photo.url));
    });

    test('save_invalidMagicBytes_returnsInvalidFormat', () async {
      final result = await save(_oneChunk(_file(_gifHeader, 20)));

      expect(result, _rejected(PhotoError.invalidFormat));
      expect(await filesOnDisk(), isEmpty);
    });

    test('save_declaredTypeDiffersFromContent_returnsInvalidFormat', () async {
      final result = await save(_oneChunk(_file(_pngHeader, 20)));

      expect(result, _rejected(PhotoError.invalidFormat));
    });

    test('save_emptyStream_returnsInvalidFormat', () async {
      final result = await save(const Stream.empty());

      expect(result, _rejected(PhotoError.invalidFormat));
    });

    test('save_exactlyAtLimit_succeeds', () async {
      final result = await save(_oneChunk(_file(_jpegHeader, 64)));

      expect(_expectSaved(result).photo.sizeBytes, 64);
    });

    test('save_overLimit_returnsSizeExceeded', () async {
      final result = await save(_byteByByte(_file(_jpegHeader, 65)));

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

    test('save_defaultLimit_is5MB', () {
      expect(maxPhotoSizeBytes, 5 * 1024 * 1024);
    });

    test('save_reportIdNotUuid_returnsInvalidReportId', () async {
      final result = await storage.save(
        '../../etc',
        _oneChunk(_file(_jpegHeader, 10)),
        'image/jpeg',
      );

      expect(result, _rejected(PhotoError.invalidReportId));
      expect(await filesOnDisk(), isEmpty);
    });
  });
  group('openRead and delete', () {
    // Gerçek, çözülebilen 1x1 PNG (67 bayt). Sahte başlıklı dosyayı EXIF
    // temizliği (#53) reddeder; bu dosya iki PR'ın sırasından bağımsız geçer.
    final png = base64Decode(
      'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAAAAAA6fptVAAAACklEQVR42mNoAAAAggCB2kUIOwAAAABJRU5ErkJggg==',
    );
    Future<PhotoSaved> savePng() async =>
        _expectSaved(await save(_oneChunk(png), 'image/png'));

    setUp(() => storage = LocalFileStorage(root));

    test('openRead_savedFile_returnsBytesOnDisk', () async {
      final saved = await savePng();
      final [onDisk] = await filesOnDisk();

      final stream = await storage.openRead(saved.photo.url);

      expect(
        await stream!.expand((c) => c).toList(),
        File(onDisk).readAsBytesSync(),
      );
    });

    test('openRead_malformedUrl_returnsNull', () async {
      expect(await storage.openRead('/files/$_reportId/../../x.jpg'), isNull);
      expect(await storage.openRead('/etc/passwd'), isNull);
    });

    test('delete_existingFile_removesFile', () async {
      final saved = await savePng();

      expect(await storage.delete(saved.photo.url), isTrue);
      expect(await storage.openRead(saved.photo.url), isNull);
      expect(await filesOnDisk(), isEmpty);
    });

    test('delete_sameFileTwiceAtOnce_onlyOneDeletes', () async {
      final saved = await savePng();

      final results = await Future.wait([
        storage.delete(saved.photo.url),
        storage.delete(saved.photo.url),
      ]);

      expect(results, unorderedEquals([true, false]));
    });

    test('delete_unknownFile_returnsFalse', () async {
      expect(
        await storage.delete('/files/$_reportId/${'0' * 32}.jpg'),
        isFalse,
      );
    });

    test('delete_pathTraversalUrl_returnsFalseAndKeepsFile', () async {
      final outside = File('${root.path}/../campus_outside_test.jpg');
      await outside.writeAsBytes(_file(_jpegHeader, 10));
      addTearDown(outside.delete);

      expect(
        await storage.delete('/files/../campus_outside_test.jpg'),
        isFalse,
      );
      expect(await outside.exists(), isTrue);
    });
  });
}
