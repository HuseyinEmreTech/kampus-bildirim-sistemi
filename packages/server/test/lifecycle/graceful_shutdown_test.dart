import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:campus_server/src/lifecycle/graceful_shutdown.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:test/test.dart';

void main() {
  test('shutDown_closesServerThenDatabase', () async {
    final server = await io.serve(
      (Request request) => Response.ok('OK'),
      InternetAddress.loopbackIPv4,
      0,
    );
    final port = server.port;
    var databaseClosed = false;
    final lines = <String>[];

    await shutDown(
      server: server,
      closeDatabase: () async => databaseClosed = true,
      write: lines.add,
    );

    expect(databaseClosed, isTrue);
    expect(lines.last, contains('Sunucu kapandı'));
    await expectLater(
      Socket.connect(InternetAddress.loopbackIPv4, port),
      throwsA(isA<SocketException>()),
    );
  });

  test('shutDown_waitsForRequestInProgress', () async {
    final release = Completer<void>();
    final started = Completer<void>();
    final server = await io.serve(
      (Request request) async {
        started.complete();
        await release.future;
        return Response.ok('bitti');
      },
      InternetAddress.loopbackIPv4,
      0,
    );
    final client = HttpClient();
    final response = client
        .get(InternetAddress.loopbackIPv4.address, server.port, '/')
        .then((request) => request.close());
    await started.future;
    var databaseClosed = false;
    var finished = false;

    final closing = shutDown(
      server: server,
      closeDatabase: () async => databaseClosed = true,
      write: (_) {},
    ).then((_) => finished = true);
    await Future<void>.delayed(const Duration(milliseconds: 300));

    // İstek sürerken kapanma bitmemeli, veritabanı açık kalmalı.
    expect(finished, isFalse);
    expect(databaseClosed, isFalse);

    release.complete();
    final res = await response;
    expect(res.statusCode, 200);
    expect(await res.transform(utf8.decoder).join(), 'bitti');
    await closing;
    expect(databaseClosed, isTrue);
    client.close();
  });

  test('shutDown_forcesOpenConnectionsAfterGrace', () async {
    final server = await io.serve(
      (Request request) async {
        await Completer<void>().future; // hiç bitmeyen istek
        return Response.ok('OK');
      },
      InternetAddress.loopbackIPv4,
      0,
    );
    final socket = await Socket.connect(
      InternetAddress.loopbackIPv4,
      server.port,
    );
    final socketClosed = Completer<void>();
    void markClosed() {
      if (!socketClosed.isCompleted) socketClosed.complete();
    }

    socket.listen(
      (_) {},
      onDone: markClosed,
      onError: (Object _) => markClosed(),
    );
    socket.write('GET / HTTP/1.1\r\nHost: localhost\r\n\r\n');
    await socket.flush();
    await Future<void>.delayed(const Duration(milliseconds: 50));
    var databaseClosed = false;

    final stopwatch = Stopwatch()..start();
    await shutDown(
      server: server,
      closeDatabase: () async => databaseClosed = true,
      grace: const Duration(milliseconds: 300),
      write: (_) {},
    );

    // Süre dolana kadar beklendi, sonra bağlantı zorla kapatıldı.
    expect(stopwatch.elapsed, greaterThanOrEqualTo(_almostGrace));
    await socketClosed.future.timeout(const Duration(seconds: 2));
    expect(databaseClosed, isTrue);
  });

  test('shutdownSignals_sigtermOnlyOutsideWindows', () {
    expect(shutdownSignals(), hasLength(Platform.isWindows ? 1 : 2));
  });
}

// Zamanlayıcı birkaç ms erken uyanabilir; 300 ms'lik süreye küçük pay.
const _almostGrace = Duration(milliseconds: 250);
