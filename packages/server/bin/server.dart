import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_cors_headers/shelf_cors_headers.dart';

void main() async {
  final router = Router();

  // Hafta 3 Görevin: Sunucu ayakta mı kontrolü (GET /health)
  router.get('/health', (Request request) {
    return Response.ok(
      '{"status": "ok", "message": "Campus Server calisiyor"}',
      headers: {'content-type': 'application/json'},
    );
  });

  final handler = const Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(corsHeaders())
      .addHandler(router.call);

  final server = await io.serve(handler, InternetAddress.anyIPv4, 8080);
 // print('🚀 Sunucu çalışıyor: http://${server.address.host}:${server.port}');
}