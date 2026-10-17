// Gerçek PostgreSQL ister: DATABASE_URL ortam değişkeni (README §10, .env.example).
@Tags(['db'])
library;

import 'dart:io';

import 'package:campus_infrastructure/campus_infrastructure.dart';
import 'package:test/test.dart';

// Sunucuda hâlâ çalışan sorguyu bulmak için bu testin bağlantılarına verilen ad.
const _appName = 'zaman-asimi-testi';

const _runningSleeps = r'''
SELECT count(*)::int FROM pg_stat_activity
WHERE application_name = $1 AND state = 'active' AND query LIKE '%pg_sleep%'
''';

/// [url]'deki ayarları korur; zaman aşımını 1 saniyeye, havuzu tek bağlantıya indirir.
String _withShortTimeout(String url) {
  final uri = Uri.parse(url);
  return uri
      .replace(
        queryParameters: {
          ...uri.queryParameters,
          'query_timeout': '1',
          'max_connection_count': '1',
          'application_name': _appName,
        },
      )
      .toString();
}

void main() {
  final url = Platform.environment['DATABASE_URL'];

  group('Database query_timeout', () {
    late Database db;
    late Database observer;

    setUpAll(() {
      db = Database.fromUrl(_withShortTimeout(url!));
      observer = Database.fromUrl(url);
    });
    tearDownAll(() async {
      await db.close();
      await observer.close();
    });

    test('execute_slowerThanTimeout_failsAndCancelsOnServer', () async {
      final stopwatch = Stopwatch()..start();

      await expectLater(
        db.execute('SELECT pg_sleep(5)'),
        throwsA(isA<Exception>()),
      );

      expect(stopwatch.elapsed, lessThan(const Duration(seconds: 4)));
      final running = await observer.execute(_runningSleeps, [_appName]);
      expect(running.single.single, 0, reason: 'sorgu sunucuda durmalı');
    });

    // Havuzda tek bağlantı var: zaman aşımından sonra da kullanılabilmeli.
    test('execute_afterTimeout_connectionStillUsable', () async {
      await expectLater(
        db.execute('SELECT pg_sleep(5)'),
        throwsA(isA<Exception>()),
      );

      final result = await db.execute('SELECT 1');

      expect(result.single.single, 1);
    });
  }, skip: url == null ? 'DATABASE_URL tanımlı değil' : false);
}
