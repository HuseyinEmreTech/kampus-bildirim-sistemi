// Gerçek PostgreSQL ister: DATABASE_URL ortam değişkeni (README §10, .env.example).
@Tags(['db'])
library;

import 'dart:io';

import 'package:campus_infrastructure/campus_infrastructure.dart';
import 'package:test/test.dart';

// Bu testin bağlantılarını pg_stat_activity'de ayırmak için verilen ad.
const _appName = 'sizinti-testi';
const _poolSize = 2;
const _rounds = 30;

// Bağlantı geri verilmezse son adım burada takılır; test süresiyle kırılır.
const _batchTimeout = Duration(seconds: 10);

const _connections = r'''
SELECT count(*)::int,
  count(*) FILTER (WHERE state LIKE 'idle in transaction%')::int
FROM pg_stat_activity WHERE application_name = $1
''';

/// [url]'deki ayarları korur; havuzu [_poolSize] bağlantıya indirir.
String _smallPool(String url) {
  final uri = Uri.parse(url);
  return uri
      .replace(
        queryParameters: {
          ...uri.queryParameters,
          'max_connection_count': '$_poolSize',
          'application_name': _appName,
        },
      )
      .toString();
}

void main() {
  final url = Platform.environment['DATABASE_URL'];

  group('Database bağlantı sızıntısı', () {
    late Database db;
    late Database observer;

    setUpAll(() {
      db = Database.fromUrl(_smallPool(url!));
      observer = Database.fromUrl(url);
    });
    tearDownAll(() async {
      await db.close();
      await observer.close();
    });

    test('pool_afterManyFailures_returnsEveryConnection', () async {
      for (var i = 0; i < _rounds; i++) {
        // İşlem içinde Dart hatası: geri alınmalı, bağlantı havuza dönmeli.
        await expectLater(
          db.transaction((tx) async {
            await tx.execute('SELECT 1');
            throw StateError('işlem yarıda kaldı');
          }),
          throwsStateError,
        );
        // İşlem içinde SQL hatası (sıfıra bölme).
        await expectLater(
          db.transaction((tx) => tx.execute('SELECT 1 / 0')),
          throwsA(isA<Exception>()),
        );
        // İşlem dışında SQL hatası.
        await expectLater(
          db.execute('SELECT 1 / 0'),
          throwsA(isA<Exception>()),
        );
      }

      // Havuzdan fazla eş zamanlı istek: hepsi sırayla bağlantı alabilmeli.
      final results = await Future.wait([
        for (var i = 0; i < _poolSize * 10; i++)
          db.execute(r'SELECT $1::int', [i]),
      ]).timeout(_batchTimeout);

      expect(results, hasLength(_poolSize * 10));
      final row = (await observer.execute(_connections, [_appName])).single;
      expect(row[0], lessThanOrEqualTo(_poolSize), reason: 'havuz sınırı');
      expect(row[1], 0, reason: 'açık kalmış işlem olmamalı');
    });
  }, skip: url == null ? 'DATABASE_URL tanımlı değil' : false);
}
