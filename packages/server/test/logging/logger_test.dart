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
}
