import 'dart:async';

import 'package:campus_infrastructure/src/storage/concurrency_limit.dart';
import 'package:test/test.dart';

void main() {
  test('run_underLimit_startsAtOnce', () async {
    final limit = ConcurrencyLimit(2);
    final first = Completer<void>();
    final second = Completer<void>();
    var started = 0;

    final a = limit.run(() {
      started++;
      return first.future;
    });
    final b = limit.run(() {
      started++;
      return second.future;
    });
    await pumpEventQueue();

    expect(started, 2);
    expect(limit.running, 2);
    first.complete();
    second.complete();
    await Future.wait([a, b]);
    expect(limit.running, 0);
  });

  test('run_overLimit_waitsForFreeSlot', () async {
    final limit = ConcurrencyLimit(1);
    final first = Completer<void>();
    var secondStarted = false;

    final a = limit.run(() => first.future);
    final b = limit.run(() async => secondStarted = true);
    await pumpEventQueue();
    expect(secondStarted, isFalse);
    expect(limit.running, 1);

    first.complete();
    await Future.wait([a, b]);
    expect(secondStarted, isTrue);
    expect(limit.running, 0);
  });

  test('run_manyTasks_neverExceedsLimit', () async {
    final limit = ConcurrencyLimit(2);
    var active = 0;
    var peak = 0;

    await Future.wait([
      for (var i = 0; i < 10; i++)
        limit.run(() async {
          active++;
          peak = active > peak ? active : peak;
          await Future<void>.delayed(const Duration(milliseconds: 5));
          active--;
        }),
    ]);

    expect(peak, 2);
    expect(limit.running, 0);
  });

  test('run_taskFails_releasesSlotForNext', () async {
    final limit = ConcurrencyLimit(1);

    final failing = limit.run<void>(() async => throw StateError('bozuk'));
    final next = limit.run(() async => 'tamam');

    await expectLater(failing, throwsStateError);
    expect(await next, 'tamam');
    expect(limit.running, 0);
  });

  test('run_returnsTaskValue', () async {
    final limit = ConcurrencyLimit(1);

    expect(await limit.run(() async => 42), 42);
  });
}
