import 'dart:convert';

import 'package:campus_server/src/logging/logger.dart';
import 'package:test/test.dart';

void main() {
  test('serverLog writes timestamped message without throwing', () {
    expect(
      () => serverLog('test message'),
      returnsNormally,
      reason: 'Ortak logger çalışmalı',
    );
  });

  test('serverLog_writesJsonLine', () {
    final lines = <String>[];
    serverLog('merhaba', write: lines.add);
    final log = jsonDecode(lines.single) as Map<String, Object?>;
    expect(log['level'], 'info');
    expect(log['message'], 'merhaba');
    expect(DateTime.tryParse(log['time']! as String), isNotNull);
  });

  test('writeLog_addsFieldsAndUtcTime', () {
    final lines = <String>[];
    writeLog(
      'error',
      {'status': 500},
      write: lines.add,
      now: () => DateTime.utc(2026, 10, 17),
    );
    expect(jsonDecode(lines.single), {
      'time': '2026-10-17T00:00:00.000Z',
      'level': 'error',
      'status': 500,
    });
  });
}
