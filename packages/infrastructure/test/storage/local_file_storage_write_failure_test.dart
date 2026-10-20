import 'dart:async';
import 'dart:io';

import 'package:campus_infrastructure/campus_infrastructure.dart';
import 'package:image/image.dart' as img;
import 'package:test/test.dart';

const _reportId = 'c0000000-0000-4000-8000-0000000000f1';

// Gerçek dosya, test zone'unun dışında (IOOverrides olmadan) kurulur.
File _realFile(String path) => Zone.root.run(() => File(path));

// Disk dolmuş gibi: verinin yarısını yazar, sonra hata verir.
class _HalfWriteFile implements File {
  _HalfWriteFile(String path) : _real = _realFile(path);

  final File _real;

  @override
  String get path => _real.path;

  @override
  Future<File> writeAsBytes(
    List<int> bytes, {
    FileMode mode = FileMode.write,
    bool flush = false,
  }) async {
    await _real.writeAsBytes(bytes.sublist(0, bytes.length ~/ 2));
    throw FileSystemException('disk dolu', path);
  }

  @override
  Future<bool> exists() => _real.exists();

  @override
  Future<FileSystemEntity> delete({bool recursive = false}) =>
      _real.delete(recursive: recursive);

  @override
  Future<File> rename(String newPath) => _real.rename(newPath);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late Directory root;

  setUp(() async {
    root = await Directory.systemTemp.createTemp('campus_storage_fail_test_');
  });
  tearDown(() => root.delete(recursive: true));

  test('save_finalWriteFails_leavesNoFile', () async {
    final storage = LocalFileStorage(root);
    final jpeg = img.encodeJpg(img.Image(width: 4, height: 2));

    // Yüklenen akışın geçici dosyası (.part) normal yazılır; temizlenmiş
    // fotoğrafın yazılması yarıda kalır.
    final saving = IOOverrides.runZoned(
      () => storage.save(_reportId, Stream.value(jpeg), 'image/jpeg'),
      createFile: (path) =>
          path.endsWith('.part') ? _realFile(path) : _HalfWriteFile(path),
    );

    await expectLater(saving, throwsA(isA<FileSystemException>()));
    final left = [
      await for (final e in root.list(recursive: true))
        if (e is File) e.path,
    ];
    expect(left, isEmpty);
  });
}
