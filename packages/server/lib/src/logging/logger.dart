import 'dart:convert';
import 'dart:io';

/// Günlük satırını yazan fonksiyon. Testlerde yerine liste verilir.
typedef LogWriter = void Function(String line);

void _stdoutWriter(String line) => stdout.writeln(line);

/// Bir günlük kaydını tek satır JSON olarak yazar (yapılandırılmış günlük).
/// Her satırda en az `time` (UTC, ISO 8601) ve `level` bulunur.
void writeLog(
  String level,
  Map<String, Object?> fields, {
  LogWriter write = _stdoutWriter,
  DateTime Function() now = DateTime.now,
}) {
  write(
    jsonEncode({
      'time': now().toUtc().toIso8601String(),
      'level': level,
      ...fields,
    }),
  );
}

/// Sunucu tarafı için ortak günlük kaydı: `{"time":..,"level":"info","message":..}`.
void serverLog(String message, {LogWriter write = _stdoutWriter}) =>
    writeLog('info', {'message': message}, write: write);
