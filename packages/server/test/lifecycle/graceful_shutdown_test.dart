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

    final closing = shutDown(
      server: server,
      closeDatabase: () async => databaseClosed = true,
      write: (_) {},
    );
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
    socket.write('GET / HTTP/1.1\r\nHost: localhost\r\n\r\n');
    await socket.flush();
    await Future<void>.delayed(const Duration(milliseconds: 50));
    var databaseClosed = false;

    final stopwatch = Stopwatch()..start();
    await shutDown(
      server: server,
      closeDatabase: () async => databaseClosed = true,
      grace: const Duration(milliseconds: 200),
      write: (_) {},
    );

    expect(databaseClosed, isTrue);
    expect(stopwatch.elapsed, lessThan(const Duration(seconds: 2)));
    socket.destroy();
  });

  test('shutdownSignals_alwaysIncludesSigint', () {
    expect(shutdownSignals(), isNotEmpty);
  });
}
