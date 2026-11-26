import 'dart:io';

import '../logging/logger.dart';

/// Süren isteklerin bitmesi için beklenen en uzun süre. `docker stop` 10 sn
/// sonra süreci öldürür (SIGKILL); kapanma bundan önce bitmeli (#212).
const shutdownGrace = Duration(seconds: 5);

/// Kapanırken açık bağlantı kalıp kalmadığına bu aralıkla bakılır.
const shutdownPollInterval = Duration(milliseconds: 100);

/// Sunucuyu kapatan sinyaller. SIGINT (Ctrl+C) her yerde; SIGTERM
/// (`docker stop`) Windows'ta dinlenemez.
List<Stream<ProcessSignal>> shutdownSignals() => [
  ProcessSignal.sigint.watch(),
  if (!Platform.isWindows) ProcessSignal.sigterm.watch(),
];

/// Önce yeni istek almayı bırakır ve süren istekleri [grace] kadar bekler;
/// süre dolarsa açık bağlantıları zorla kapatır. Sonra veritabanı havuzunu
/// kapatır.
Future<void> shutDown({
  required HttpServer server,
  required Future<void> Function() closeDatabase,
  Duration grace = shutdownGrace,
  LogWriter? write,
}) async {
  _log('Kapanma sinyali alındı; yeni istek alınmıyor.', write);
  // close() yalnızca dinlemeyi bırakır; süren istekleri beklemez.
  await server.close();
  final waited = Stopwatch()..start();
  while (server.connectionsInfo().active > 0 && waited.elapsed < grace) {
    await Future<void>.delayed(shutdownPollInterval);
  }
  await server.close(force: true);
  await closeDatabase();
  _log('Sunucu kapandı.', write);
}

void _log(String message, LogWriter? write) =>
    write == null ? serverLog(message) : serverLog(message, write: write);
